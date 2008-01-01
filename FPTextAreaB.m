//
//  FPTextAreaB.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 12/12/06.
//  Copyright 2006 Andrew de los Reyes. All rights reserved.
//

#import "FPTextAreaB.h"
#import "NSMutableDictionaryAdditions.h"
#import "FPArchiveExtras.h"
#import "FPLogging.h"

@implementation FPTextAreaB

+ (NSString *)archivalClassName;
{
    return @"TextArea";
}

- (id)initWithGraphic:(FPGraphic *)graphic
{
    self = [super initWithGraphic:graphic];
    assert([graphic class] == [FPTextAreaB class]);
    if (self) {
        FPTextAreaB *gr = (FPTextAreaB *)graphic;
        self->_textStorage = [[NSTextStorage allocWithZone:[self zone]] init];
        [_textStorage replaceCharactersInRange:NSMakeRange(0, [_textStorage length])
                          withAttributedString:gr->_textStorage];
        self->_editor = nil;
        self->_isPlacing = gr->_isPlacing;
        self->_isEditing = gr->_isEditing;
        self->_isAutoSizedX = gr->_isAutoSizedX;
        self->_isAutoSizedY = gr->_isAutoSizedY;
        self->_editorScaleFactor = gr->_editorScaleFactor;
    }
    return self;
}

static NSString *editorFrameKey = @"editorFrame";
static NSString *editorTextStorageKey = @"editorTextStorage";
static NSString *autoSizedXArchiveKey = @"autoSizedX";
static NSString *autoSizedYArchiveKey = @"autoSizedY";

// caller owns returned object
- (void)instantiateVariableWidthEditor
{
    NSTextView *ret =
    [[NSTextView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 40.0, 40.0)];
    [[ret textContainer] setLineFragmentPadding:1.0];
    [ret setDrawsBackground:NO];
    [ret setPostsFrameChangedNotifications:YES];
    [ret setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter]
         addObserver:self
            selector:@selector(myFrameChanged:)
                name:NSViewFrameDidChangeNotification
              object:ret];
    
    [[ret textContainer] setWidthTracksTextView:NO];
    [[ret textContainer] setContainerSize:NSMakeSize(1.0e6, 1.0e6)];
    [ret setHorizontallyResizable:YES];
    [ret setMinSize:NSMakeSize(1.0, 1.0)];
    [ret setMaxSize:NSMakeSize(1.0e6, 1.0e6)];
    
    [[ret textContainer] setHeightTracksTextView:NO];
    [ret setVerticallyResizable:YES];
    
    assert(ret);
    _editor = [ret retain];
}

- (id)initWithArchivalDictionary:(NSDictionary *)dict
                  inDocumentView:(FPDocumentView *)docView
{
    self = [super initWithArchivalDictionary:dict
                              inDocumentView:docView];
    if (self) {
        NSData *rtf_data = [[dict objectForKey:editorTextStorageKey]
                            dataUsingEncoding:NSUTF8StringEncoding];
        _textStorage = [[NSTextStorage alloc] initWithRTF:rtf_data
                                       documentAttributes:nil];
        if (nil == _textStorage)  // decoding error
            _textStorage = [[NSTextStorage alloc] init];
        _isPlacing = NO;
        _isEditing = NO;
        _isAutoSizedX = [[dict objectForKey:autoSizedXArchiveKey] boolValue];
        _isAutoSizedY = [[dict objectForKey:autoSizedYArchiveKey] boolValue];
        _editorScaleFactor = 1.0;
        _gFlags.drawsStroke = NO;
    }
    return self;
}

- (NSDictionary *)archivalDictionary
{
    NSMutableDictionary *ret =
        [NSMutableDictionary
         dictionaryWithDictionary:[super archivalDictionary]];
    [ret setObject:arrayFromRect([_editor frame])
         forNonexistentKey:editorFrameKey];
    NSData *d =
        [_textStorage RTFFromRange:NSMakeRange(0, [_textStorage length])
                documentAttributes:nil];
    NSString *rtfstr =
        [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];

    [ret setObject:rtfstr forNonexistentKey:editorTextStorageKey];
    [ret setObject:[NSNumber numberWithBool:_isAutoSizedX]
         forNonexistentKey:autoSizedXArchiveKey];
    [ret setObject:[NSNumber numberWithBool:_isAutoSizedY]
         forNonexistentKey:autoSizedYArchiveKey];
    return ret;
}

- (id)initInDocumentView:(FPDocumentView *)docView
{
    self = [super initInDocumentView:docView];
    if (self) {
        _editor = nil;
        _textStorage = [[NSTextStorage alloc] init];
        _isPlacing = NO;
        _isEditing = NO;
        _isAutoSizedX = YES;
        _isAutoSizedY = YES;
        _editorScaleFactor = 1.0;
        _gFlags.drawsStroke = NO;
        _knobMask = MiddleLeftKnob | MiddleRightKnob;
    }
    return self;
}

- (BOOL)isEditable
{
    return YES;
}

- (BOOL)placeWithEvent:(NSEvent *)theEvent
{
    _isPlacing = YES;
    _page = [_docView pageForPointFromEvent:theEvent];
    NSPoint point = [_docView pagePointForPointFromEvent:theEvent page:_page];
    
    _bounds.origin = point;
    point = [_docView pagePointForPointFromEvent:theEvent page:_page];
    _bounds.size = NSMakeSize(10.0,10.0);
    _naturalBounds.origin = point;
    _naturalBounds.size = NSMakeSize(1.0, 1.0);
    
    // if the next event is mouse up, then the user didn't drag at all
    theEvent = [[_docView window] nextEventMatchingMask:
                (NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
    _isAutoSizedX = _isAutoSizedY = YES;
    if ([theEvent type] != NSLeftMouseUp) {
        [self resizeWithEvent:theEvent byKnob:LowerRightKnob];
    }
    _isPlacing = NO;
    return YES;
}

static NSLayoutManager *sharedDrawingLayoutManager();

- (void)setBounds:(NSRect)bounds
{
    if ((!_isPlacing) && (!_isEditing)) {
        //NSRect pixelBounds = [_docView convertRect:bounds fromPage:_page];
        NSLayoutManager *lm = sharedDrawingLayoutManager();
        NSTextContainer *tc = [[lm textContainers] objectAtIndex:0];
        NSRange glyphRange;
        [tc setContainerSize:NSMakeSize(NSWidth(bounds), 1.0e6)];
        [_textStorage addLayoutManager:lm];
        // Force layout of the text and find out how much of it fits in
        // the container.
        glyphRange = [lm glyphRangeForTextContainer:tc];
        NSRect glyphRect = [lm usedRectForTextContainer:tc];
        [_textStorage removeLayoutManager:lm];
        float heightChange = NSHeight(glyphRect) - NSHeight(bounds);
        bounds.origin.y -= heightChange;
        bounds.size.height = NSHeight(glyphRect);
        NSLog(@"glyph: %@\n", NSStringFromRect(glyphRect));
    }
    [super setBounds:bounds];
}

- (void)resizeWithEvent:(NSEvent *)theEvent byKnob:(int)knob
{
    [super resizeWithEvent:theEvent byKnob:knob];
    if (NSWidth([self bounds]) >= 10.0)  // only go fixed size if it's wide enough
        _isAutoSizedX = NO;
}

static NSLayoutManager *sharedDrawingLayoutManager() {
    // This method returns an NSLayoutManager that can be used to draw the contents of a SKTTextArea.
    static NSLayoutManager *sharedLM = nil;
    if (!sharedLM) {
        NSTextContainer *tc = [[NSTextContainer allocWithZone:NULL] initWithContainerSize:NSMakeSize(1.0e6, 1.0e6)];
        
        sharedLM = [[NSLayoutManager allocWithZone:NULL] init];
        
        [tc setWidthTracksTextView:NO];
        [tc setHeightTracksTextView:NO];
        [tc setLineFragmentPadding:1.0];
        [sharedLM addTextContainer:tc];
        [tc release];
    }
    return sharedLM;
}

- (void)draw:(BOOL)selected
{
    if (_gFlags.drawsStroke) {
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:[self bounds]];
        [path setLineWidth:[self strokeWidth]];
        [[NSColor blackColor] set];
        [path stroke];
    } else if (selected || _isPlacing) {
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:[self bounds]];
        [path setLineWidth:[self strokeWidth]];
        [[NSColor lightGrayColor] set];
        [path stroke];
    }
    if (!_isEditing) {
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform scaleXBy:1.0 yBy:-1.0];
        [transform translateXBy:0.0
                            yBy:(-1.0*(NSMinY(_bounds) + NSMaxY(_bounds)))];
        [transform concat];
    
        //NSTextStorage *contents = [_editor textStorage];
        if ([_textStorage length] > 0) {
            NSLayoutManager *lm = sharedDrawingLayoutManager();
            NSTextContainer *tc = [[lm textContainers] objectAtIndex:0];
            NSRange glyphRange;
            [tc setContainerSize:_bounds.size];
            [_textStorage addLayoutManager:lm];
            // Force layout of the text and find out how much of it fits in
            // the container.
            glyphRange = [lm glyphRangeForTextContainer:tc];

            if (glyphRange.length > 0) {
                [lm drawBackgroundForGlyphRange:glyphRange
                                        atPoint:_bounds.origin];
                [lm drawGlyphsForGlyphRange:glyphRange
                                    atPoint:_bounds.origin];
            }
            [_textStorage removeLayoutManager:lm];
        }
        [transform invert];
        [transform concat];
    }
}

- (void)documentDidZoom
{
    NSLog(@"document did zoom\n");
    if (nil == _editor) return;
    [_editor scaleUnitSquareToSize:NSMakeSize([_docView scaleFactor] /
                                              _editorScaleFactor,
                                              [_docView scaleFactor] /
                                              _editorScaleFactor)];
    _editorScaleFactor = [_docView scaleFactor];
    [_editor setFrame:[_docView convertRect:_bounds fromPage:_page]];
}

- (void)myFrameChanged:(NSTextView *)foo
{
//    NSLog(@"frame changed\n");
//    NSLog(@"editor frame:  %@\n", NSStringFromRect([_editor frame]));
//    NSLog(@"editor bounds: %@\n", NSStringFromRect([_editor bounds]));
    NSLog(@"myFrameChanged:\n");
    [_docView setNeedsDisplayInRect:[_docView convertRect:[self safeBounds]
                                                 fromPage:_page]];
    NSLog(@"new bounds: %@\n", NSStringFromRect([self bounds]));
//    NSRect frame = [_editor frame];
//    NSLog(@"my frame: %@\n", NSStringFromRect(frame));
//    NSLog(@"used rect fc: %@\n", NSStringFromRect([[_editor layoutManager] usedRectForTextContainer:[_editor textContainer]]));
//    [self setBounds:[_docView convertRect:frame toPage:_page]];
//    [_docView setNeedsDisplayInRect:[_docView convertRect:[self safeBounds] fromPage:_page]];
}

- (void)startEditing
{
    //NSTextStorage *contents = [[NSTextStorage allocWithZone:[self zone]] init];
    DLog(@"mouse down\n");
    _isEditing = YES;
    BOOL isFirstEdit = NO;
    if (_editor == nil) {
        isFirstEdit = YES;
        DLog(@"allocating\n");
        [self instantiateVariableWidthEditor];
	}
    [self documentDidZoom];
    [_textStorage addLayoutManager:[_editor layoutManager]];
	
    if (_isAutoSizedX) {
        NSRect frame = _bounds;
        [[_editor layoutManager]
        glyphRangeForTextContainer:[_editor textContainer]];
        frame.size = [[_editor layoutManager]
                  usedRectForTextContainer:[_editor textContainer]].size;

        [[_editor textContainer] setContainerSize:NSMakeSize(1.0e6,
                                                             1.0e6)];
        [[_editor textContainer] setWidthTracksTextView:NO];
        [_editor setHorizontallyResizable:YES];
    } else {
        [[_editor textContainer] setContainerSize:NSMakeSize(NSWidth(_bounds),
                                                             1.0e6)];
        [[_editor textContainer] setWidthTracksTextView:NO];
        [_editor setHorizontallyResizable:NO];
    }
    [_editor setFrame:[_docView convertRect:_bounds fromPage:_page]];
    [_docView addSubview:_editor];

    if (isFirstEdit) {
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:[_docView currentFont] forKey:NSFontAttributeName];
        [_editor setTypingAttributes:attributes];
        DLog(@"editingn w/ attributes: %@\n", attributes);
    }
    
    [_editor setDelegate:self];
    [[_docView window] makeFirstResponder:_editor];
}

// When text changes, we may need to update the frame of the in-use NSTextView
// and our bounds.
- (void)textDidChange:(NSNotification *)notification {
    DLog(@"textDidChange:\n");

    // first invalidate the current (ie, old) bounds
    [_docView setNeedsDisplayInRect:[_docView convertRect:[self safeBounds]
                                                 fromPage:_page]];

    // get the frame of the editor and use it to compute the new bounds
    NSRect frame = [_editor frame];
    [[_editor layoutManager]
     glyphRangeForTextContainer:[_editor textContainer]];
    frame.size = [[_editor layoutManager]
                  usedRectForTextContainer:[_editor textContainer]].size;
    frame.size.height *= _editorScaleFactor;
    frame.size.width *= _editorScaleFactor;
    if (NO == _isAutoSizedX)
        frame.size.width = NSWidth([self bounds]);

    // set the frame to the text view and ourself
    [_editor setFrame:frame];
    [self setBounds:[_docView convertRect:frame toPage:_page]];

    // trigger redrawing in the new bounds
    [_docView setNeedsDisplayInRect:[_docView convertRect:[self safeBounds]
                                                 fromPage:_page]];
    DLog(@"new bounds: %@\n", NSStringFromRect([self bounds]));
}

- (void)stopEditing
{
	NSLog(@"stop editing\n");
    assert(_editor);
    [_textStorage removeLayoutManager:[_editor layoutManager]];
    [_editor setSelectedRange:NSMakeRange(0, 0)];
    [_editor setDelegate:nil];
	//[[_editor layoutManager] setDelegate:nil];
    [_editor removeFromSuperview];
    _isEditing = NO;
}

@end
