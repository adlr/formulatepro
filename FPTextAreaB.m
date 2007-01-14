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

static NSTextView * newEditor(void);

@implementation FPTextAreaB

+ (NSString *)archivalClassName;
{
    return @"TextArea";
}

static NSString *editorFrameKey = @"editorFrame";
static NSString *editorTextStorageKey = @"editorTextStorage";
static NSString *autoSizedXArchiveKey = @"autoSizedX";
static NSString *autoSizedYArchiveKey = @"autoSizedY";

- (id)initWithArchivalDictionary:(NSDictionary *)dict
                  inDocumentView:(FPDocumentView *)docView
{
    self = [super initWithArchivalDictionary:dict
                              inDocumentView:docView];
    if (self) {
        _editor = newEditor();
        [_editor setFrame:rectFromArray([dict objectForKey:editorFrameKey])];
        NSData *rtf_data = [[dict objectForKey:editorTextStorageKey]
                            dataUsingEncoding:NSUTF8StringEncoding];
        [_editor replaceCharactersInRange:NSMakeRange(0, 0)
                                  withRTF:rtf_data];
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
        [_editor RTFFromRange:NSMakeRange(0, [[_editor string] length])];
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
        _isPlacing = NO;
        _isEditing = NO;
        _isAutoSizedX = YES;
        _isAutoSizedY = YES;
        _editorScaleFactor = 1.0;
        _gFlags.drawsStroke = NO;
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
    _bounds.size = NSMakeSize(0.0,0.0);
    _naturalBounds.origin = point;
    _naturalBounds.size = NSMakeSize(1.0, 1.0);
    
    // if the next event is mouse up, then the user didn't drag at all
    theEvent = [[_docView window] nextEventMatchingMask:
                (NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
    if ([theEvent type] == NSLeftMouseUp) {
        _isAutoSizedX = _isAutoSizedY = YES;
    } else {
        [self resizeWithEvent:theEvent byKnob:LowerRightKnob];
    }
    _isPlacing = NO;
    return YES;
}

- (void)setBounds:(NSRect)bounds
{
    if (_editor && (!_isPlacing) && (!_isEditing)) {
        [_editor setFrame:bounds];
        _isAutoSizedX = NO;
        _isAutoSizedY = NO;
        [[_editor textContainer] setWidthTracksTextView:YES];
        [_editor setHorizontallyResizable:NO]; //x
        [_editor setMaxSize:NSMakeSize(NSWidth([_editor frame]),
                                       [_editor maxSize].height)];
    }
    [super setBounds:bounds];
}

- (void)draw
{
    if (_gFlags.drawsStroke) {
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:[self bounds]];
        [path setLineWidth:[self lineWidth]];
        [[NSColor blackColor] set];
        [path stroke];
    }
    if (_editor && (!_isEditing)) {
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform scaleXBy:1.0 yBy:-1.0];
        [transform translateXBy:0.0
                            yBy:(-1.0*(NSMinY(_bounds) + NSMaxY(_bounds)))];
        [transform concat];
    
        NSTextStorage *contents = [_editor textStorage];
        if ([contents length] > 0) {
            NSLayoutManager *lm = [_editor layoutManager];
            NSTextContainer *tc = [_editor textContainer];
            NSRange glyphRange;

            //[tc setContainerSize:bounds.size];
            //[contents addLayoutManager:lm];
            // Force layout of the text and find out how much of it fits in
            // the container.
            glyphRange = [lm glyphRangeForTextContainer:tc];

            if (glyphRange.length > 0) {
                [lm drawBackgroundForGlyphRange:glyphRange
                                        atPoint:_bounds.origin];
                [lm drawGlyphsForGlyphRange:glyphRange
                                    atPoint:_bounds.origin];
            }
            //[contents removeLayoutManager:lm];
        }
        [transform invert];
        [transform concat];
    }
}

- (void)documentDidZoom
{
    NSLog(@"document did zoom\n");
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

static NSTextView * newEditor(void) {
    NSTextView *ret =
        [[NSTextView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 40.0, 40.0)];
    [[ret textContainer] setLineFragmentPadding:1.0];
    [ret setDrawsBackground:NO];
    assert(ret);
    return ret;
}

- (void)startEditing
{
    //NSTextStorage *contents = [[NSTextStorage allocWithZone:[self zone]] init];
    NSLog(@"mouse down\n");
    _isEditing = YES;
    if (_editor == nil) {
        NSLog(@"allocating\n");
        _editor = newEditor();
        [_editor setPostsFrameChangedNotifications:YES];
        [_editor setPostsBoundsChangedNotifications:YES];
        [[NSNotificationCenter defaultCenter]
         addObserver:self
            selector:@selector(myFrameChanged:)
                name:NSViewFrameDidChangeNotification
              object:_editor];
        
        [[_editor textContainer] setWidthTracksTextView:NO];
        [[_editor textContainer] setContainerSize:NSMakeSize(300.0, 300.0)];
        [_editor setHorizontallyResizable:YES]; //x
        [_editor setMinSize:NSMakeSize(1.0, 1.0)];
        [_editor setMaxSize:NSMakeSize(1.0e6, 1.0e6)];
        
        [[_editor textContainer] setHeightTracksTextView:NO];
        [_editor setVerticallyResizable:YES]; //x
	}
    [self documentDidZoom];
	
	//if (_isAutoSized) {
		//[[_editor textContainer] setContainerSize:NSMakeSize(300.0, 300.0)];
	//} else {
	//	[[_editor textContainer] setContainerSize:_bounds.size];
	//}
    NSRect frame = _bounds;
    [[_editor layoutManager]
     glyphRangeForTextContainer:[_editor textContainer]];
    frame.size = [[_editor layoutManager]
                  usedRectForTextContainer:[_editor textContainer]].size;
    [self setBounds:frame];
    [_editor setFrame:[_docView convertRect:frame fromPage:_page]];
    //[contents addLayoutManager:[_editor layoutManager]];
    [_docView addSubview:_editor];
    [_editor setDelegate:self];
    [[_docView window] makeFirstResponder:_editor];
}

- (void)textDidChange:(NSNotification *)notification {
    NSLog(@"textDidChange:\n");
    [_docView setNeedsDisplayInRect:[_docView convertRect:[self safeBounds]
                                                 fromPage:_page]];
    NSRect frame = [_editor frame];
    [[_editor layoutManager]
     glyphRangeForTextContainer:[_editor textContainer]];
    frame.size = [[_editor layoutManager]
                  usedRectForTextContainer:[_editor textContainer]].size;
    frame.size.height *= _editorScaleFactor;
    frame.size.width *= _editorScaleFactor;
    [_editor setFrame:frame];
    [self setBounds:[_docView convertRect:frame toPage:_page]];
    /*
    NSSize textSize;
    BOOL fixedWidth = ([[notification object] isHorizontallyResizable] ? NO : YES);
    
    textSize = NSMakeSize(1000.0, 1000.0);
    NSLog(@"textSize: %@\n", NSStringFromSize(textSize));
    
    if ((textSize.width > _bounds.size.width) || (textSize.height > _bounds.size.height)) {
        _bounds = NSMakeRect(_bounds.origin.x, _bounds.origin.y, ((!fixedWidth && (textSize.width > _bounds.size.width)) ? textSize.width : _bounds.size.width), ((textSize.height > _bounds.size.height) ? textSize.height : _bounds.size.height));
    }
     */
//    NSLog(@"used rect tc: %@\n", NSStringFromRect([[_editor layoutManager] usedRectForTextContainer:[_editor textContainer]]));
//    NSLog(@"editor frame:  %@\n", NSStringFromRect([_editor frame]));
//    NSLog(@"editor bounds: %@\n", NSStringFromRect([_editor bounds]));
    [_docView setNeedsDisplayInRect:[_docView convertRect:[self safeBounds]
                                                 fromPage:_page]];
    NSLog(@"new bounds: %@\n", NSStringFromRect([self bounds]));
}

- (void)stopEditing
{
	NSLog(@"stop editing\n");
    assert(_editor);
    [_editor setSelectedRange:NSMakeRange(0, 0)];
    [_editor setDelegate:nil];
	//[[_editor layoutManager] setDelegate:nil];
    [_editor removeFromSuperview];
    _isEditing = NO;
}

@end
