//
//  FPTextArea.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 8/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "FPTextArea.h"
#import "MyPDFView.h"
#import "AppDelegate.h"
//#import "FPTextRenderingView.h"

@implementation FPTextArea

//static NSLayoutManager *sharedDrawingLayoutManager();

+ (FPGraphic *)graphicInDocumentView:(FPDocumentView *)pdfView
{
    FPGraphic *ret = [[FPTextArea alloc] initInDocumentView:pdfView];
    return [ret autorelease];
}

- (id)initInDocumentView:(FPDocumentView *)pdfView
{
    self = [super initInDocumentView:pdfView];
    if (self) {
        _contents = [[NSTextStorage alloc] init];
        _editor = nil;
        _isPlacing = NO;
        _isEditing = NO;
		_isAutoSized = YES;
    }
    return self;
}

#define ROUND_SIZE 0
#define ROUND_ALL 1

#define ROUND_SCHEME ROUND_ALL

- (void)setBounds:(NSRect)bounds
{
#if (ROUND_SCHEME == ROUND_SIZE)
    bounds.size.width = roundf(bounds.size.width);
    bounds.size.height = roundf(bounds.size.height);
#else
    BOOL moveTop = NSMaxY(_bounds) != NSMaxY(bounds);
    BOOL moveBottom = NSMinY(_bounds) != NSMinY(bounds);
    BOOL moveLeft = NSMinX(_bounds) != NSMinX(bounds);
    BOOL moveRight = NSMaxX(_bounds) != NSMaxX(bounds);

    if (moveTop != moveBottom) {
        if (moveTop) {
            bounds.size.height = roundf(bounds.size.height);
        } else {
            float unused;
            float snap_y_fpart = modff(_bounds.origin.y, &unused);
            float bottom_ipart;
            float bottom_fpart = modff(bounds.origin.y, &bottom_ipart);
            float newY;
            
            if (fabsf(bottom_fpart - snap_y_fpart) <= 0.5) {
                newY = bottom_ipart + snap_y_fpart;
            } else if (bottom_fpart < snap_y_fpart) {
                newY = bottom_ipart - 1.0 + snap_y_fpart;
            } else {
                newY = bottom_ipart + 1.0 + snap_y_fpart;
            }
            
            bounds.size.height += bounds.origin.y - newY;
            bounds.origin.y = newY;
        }
    } else {
        // we are assuming if both bottom and top edge change,
        // that they're moving and so the height will still be an integer
        assert(bounds.size.height == floorf(bounds.size.height));
    }

    // now, the same for the x-axis
    if (moveRight != moveLeft) {
        if (moveRight) {
            bounds.size.width = roundf(bounds.size.width);
        } else {
            float unused;
            float snap_x_fpart = modff(_bounds.origin.x, &unused);
            float left_ipart;
            float left_fpart = modff(bounds.origin.x, &left_ipart);
            float newX;
            
            if (fabsf(left_fpart - snap_x_fpart) <= 0.5) {
                newX = left_ipart + snap_x_fpart;
            } else if (left_fpart < snap_x_fpart) {
                newX = left_ipart - 1.0 + snap_x_fpart;
            } else {
                newX = left_ipart + 1.0 + snap_x_fpart;
            }
            
            bounds.size.width += bounds.origin.x - newX;
            bounds.origin.x = newX;
        }
    } else {
        // we are assuming if both left and right edge change,
        // that they're moving and so the width will still be an integer
        if (bounds.size.width != floorf(bounds.size.width)) {
            NSLog(@"b.s.wid: %f, f(b.s.wid): %f\n",
                  bounds.size.width,
                  floorf(bounds.size.width));
        }
        assert(bounds.size.width == floorf(bounds.size.width));
    }
    
#endif
    assert(bounds.size.width >= 0.0);
    assert(bounds.size.height >= 0.0);
    [super setBounds:bounds];
}

#define PDF_METHOD_A 0
#define PDF_METHOD_B 1

#define PDF_METHOD PDF_METHOD_B

#define DRAW_WITH_PDF 0
#define DRAW_WITH_BITMAP 1
#define DRAW_METHOD DRAW_WITH_PDF

- (void)draw
{
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSInsetRect(_bounds, 0.0, 0.0)];
    [[NSColor blueColor] set];
    [path stroke];
    if (_isPlacing || _isEditing) return;
    if (_editor && [[_editor textStorage] length] > 0) {
        NSWindow *w = [(AppDelegate *)[NSApp delegate] renderWindow];
        [w setContentSize:_bounds.size];
        [w setContentView:_editor];
        [_editor setFrameSize:_bounds.size];
        [[_editor textContainer] setContainerSize:_bounds.size];
        [_editor setDrawsBackground:NO];
        [_editor lockFocus];
#if (DRAW_METHOD == DRAW_WITH_PDF)
        NSData *pdfData = [_editor dataWithPDFInsideRect:[_editor bounds]];
#else
        NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect:[_editor bounds]];
#endif
        [_editor unlockFocus];
        
#if (DRAW_METHOD == DRAW_WITH_PDF)
        //[pdfData writeToFile:@"/tmp/foo.pdf" atomically:YES];
        NSImage *image = [[NSImage alloc] initWithData:pdfData];
#if (PDF_METHOD == PDF_METHOD_A)
        NSPDFImageRep *rep = [[image representations] objectAtIndex:0];
        [rep drawInRect:_bounds];
#else
        NSLog(@"img size: %@, bnd size: %@\n",
              NSStringFromSize([image size]),
              NSStringFromSize(_bounds.size));
        //[image drawInRect:_bounds
        //         fromRect:NSMakeRect(0.0, 0.0, [image size].width+1, [image size].height+1)
        //        operation:NSCompositeSourceOver
        //         fraction:1.0];
        //[image drawAtPoint:NSMakePoint(_bounds.origin.x + 0.5,_bounds.origin.y + 0.5)];
        [image setCacheMode:NSImageCacheNever];
        [image drawInRect:NSMakeRect(_bounds.origin.x + 1.0,
                                     _bounds.origin.y + 1.0,
                                     _bounds.size.width - 3.0,
                                     _bounds.size.height - 3.0)
                 fromRect:NSMakeRect(1.0, 1.0,
                                     _bounds.size.width - 2.0,
                                     _bounds.size.height - 2.0)
                operation:NSCompositeSourceOver
                 fraction:1.0];
#endif // PDF_METHOD
        
#else // DRAW_METHOD
        [bitmap drawAtPoint:NSMakePoint(_bounds.origin.x + 0.5,_bounds.origin.y + 0.5)];
#endif // DRAW_METHOD
    }
        
//        NSLayoutManager *lm = sharedDrawingLayoutManager();
//        NSTextContainer *tc = [[lm textContainers] objectAtIndex:0];
//        NSRange glyphRange;
//        
//        [tc setContainerSize:_bounds.size];
//        [_contents addLayoutManager:lm];
//        // Force layout of the text and find out how much of it fits in the container.
//        glyphRange = [lm glyphRangeForTextContainer:tc];
//        
//        if (glyphRange.length > 0) {
//            /*
//            NSRect pageBounds = [_page boundsForBox:kPDFDisplayBoxCropBox];
//            NSAffineTransform* xform = [NSAffineTransform transform];
//            
//            // Add the transformations
//            [xform scaleXBy:1.0 yBy:-1.0];
//            [xform translateXBy:0.0 yBy:pageBounds.size.height];
//            [xform concat];
//            */
//            
//            //NSAutoreleasePool *localPool = [[NSAutoreleasePool alloc] init];
            //NSGraphicsContext *savedContext = [NSGraphicsContext currentContext];
            
            
            //[NSGraphicsContext setCurrentContext: [NSGraphicsContext graphicsContextWithGraphicsPort: [savedContext graphicsPort] flipped:YES]];
            
            //[_contents drawInRect:_bounds];
            
            
            //[NSGraphicsContext setCurrentContext: savedContext];
            //[localPool release];
//            
//            
//            // Draw content...
//            [lm drawBackgroundForGlyphRange:glyphRange
//                                    atPoint:NSMakePoint(0.0, _bounds.size.height)];
//                                                        
//            [lm drawGlyphsForGlyphRange:glyphRange
//                                atPoint:NSMakePoint(0.0, _bounds.size.height)];
//            // Remove the transformations by applying the inverse transform.
//            /*
//            [xform invert];
//            [xform concat];
//            */
//        }
//        [_contents removeLayoutManager:lm];
//
//        NSData *pdfData = [rendView dataWithPDFInsideRect:[rendView bounds]];
//        [pdfData writeToFile:@"/tmp/foo.pdf" atomically:YES];
//        //NSImage *image = [[NSImage alloc] initWithData:
//            //[rendView dataWithPDFInsideRect:[rendView bounds]]];
//        //[rendView unlockFocus];
        
}

- (BOOL)placeWithEvent:(NSEvent *)theEvent
{
    NSPoint point;
    
    _page = [_docView pageForPointFromEvent:theEvent];
    point = [_docView pagePointForPointFromEvent:theEvent page:_page];
    
    _bounds.origin = point;
    _bounds.size = NSMakeSize(0.0,0.0);
    _naturalBounds.origin = point;
    _naturalBounds.size = NSMakeSize(1.0, 1.0);
    
    // if the next event is mouse up, then we're auto-sized
    theEvent = [[_docView window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
    if ([theEvent type] != NSLeftMouseUp) {
        // ok, we have a shape, and user is dragging to size it
		_isAutoSized = NO;
        _isPlacing = YES;
        [self resizeWithEvent:theEvent byKnob:LowerRightKnob];
        _isPlacing = NO;
    } else {
		_isAutoSized = YES;
	}
    return YES;
}

/*
static NSTextView *newEditor() {
    // This method returns an NSTextView whose NSLayoutManager has a refcount of 1.  It is the caller's responsibility to release the NSLayoutManager.  This function is only for the use of the following method.
    NSLayoutManager *lm = [[NSLayoutManager alloc] init];
    NSTextContainer *tc = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(1.0e6, 1.0e6)];
    NSTextView *tv = [[NSTextView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 100.0, 100.0) textContainer:nil];
    
    [lm addTextContainer:tc];
    [tc release];
    
    [tv setTextContainerInset:NSMakeSize(0.0, 0.0)];
    [tv setDrawsBackground:NO];
    [tv setAllowsUndo:YES];
    [tc setTextView:tv];
    [tv release];
    
    return tv;
}
*/

static void
printSubviews(NSView *view, int level)
{
    int i;
    NSArray *subs;
    for (i = 0; i < level; i++) {
        printf("  ");
    }
    NSLog(@"view: %@\n", view);
    subs = [view subviews];
    for (i = 0; i < [subs count]; i++) {
        printSubviews([subs objectAtIndex:i], level+1);
    }
}

static NSView *
documentViewForPDFView(PDFView *p)
{
    NSView *scrollView;
    NSArray *pdfSubviews;
    int i;
    
    pdfSubviews = [p subviews];
    for (i = 0; i < [pdfSubviews count]; i++) {
        scrollView = [pdfSubviews objectAtIndex:i];
        if ([scrollView class] != [NSScrollView class]) break; // we didn't get the scrollview
        return [((NSScrollView*)scrollView) documentView];
    }
    assert(0);
}

@class PDFDisplayView;

static NSView *
PDFDisplayViewForMatteView(NSView *p)
{
    NSArray *subviews;
    int i;
    
    subviews = [p subviews];
    for (i = 0; i < [subviews count]; i++) {
        if ([[subviews objectAtIndex:i] class] == [PDFDisplayView class])
            return [subviews objectAtIndex:i];
    }
    assert(0);
}

- (BOOL)isEditable
{
    return YES;
}

- (void)startEditing
{
	NSLog(@"start editing\n");
    NSRect frame;
    if (_editor == nil) {
        _editor = [[NSTextView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 40.0, 40.0)];
		[[_editor textContainer] setLineFragmentPadding:1.0];
	}

    [[_editor textContainer] setWidthTracksTextView:NO];
    [_editor setHorizontallyResizable:NO]; //x

    [[_editor textContainer] setHeightTracksTextView:NO];
    [_editor setVerticallyResizable:NO]; //x
	
	if (_isAutoSized) {
		[[_editor textContainer] setContainerSize:NSMakeSize(300.0, 300.0)];
	} else {
		[[_editor textContainer] setContainerSize:_bounds.size];
	}
    [_editor setMinSize:NSMakeSize(10.0, 15.0)];
    [_editor setMaxSize:NSMakeSize(1.0e6, 1.0e6)];
    
	if (_isAutoSized) {
		_bounds.size = [[_editor layoutManager] usedRectForTextContainer:[_editor textContainer]].size;
		[[_editor layoutManager] setDelegate:self];
	}

    frame = [_docView convertRect:[_docView convertRect:_bounds fromPage:_page] toView:PDFDisplayViewForMatteView(documentViewForPDFView(_docView))];
    NSLog(@"frame: %@\n", NSStringFromRect(frame));
    [_editor setFrame:frame];
    
    /*
    [_contents addLayoutManager:[_editor layoutManager]];
    [_editor setSelectedRange:NSMakeRange(0, [_contents length])];
     */
    [PDFDisplayViewForMatteView(documentViewForPDFView(_docView)) addSubview:_editor];
    [_editor setDelegate:self];
    
    // Make sure we redisplay
    [_docView setNeedsDisplay:YES];
    
    [[_docView window] makeFirstResponder:_editor];
    _isEditing = YES;
}

- (NSSize)containerSizeOfString:(NSString*)text withFontname:(NSString*)fontname fontSize:(float)fontSize
{
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:text];
    [textStorage addAttribute:NSFontAttributeName value:[NSFont fontWithName:fontname size:fontSize] range:NSMakeRange(0,[textStorage length])];
 
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(300.0,300.0)];
 
    [textContainer setLineFragmentPadding:0.0];
    [layoutManager addTextContainer:textContainer];
    [layoutManager glyphRangeForTextContainer:textContainer];
    NSRect rect = [layoutManager usedRectForTextContainer:textContainer];
    [textContainer release];
    [layoutManager release];
    [textStorage release];
    return NSMakeSize(rect.size.width,rect.size.height);
}

- (void)layoutManager:(NSLayoutManager *)aLayoutManager
didCompleteLayoutForTextContainer:(NSTextContainer *)aTextContainer
atEnd:(BOOL)flag
{
	NSLog(@"layoutManager:didCompleteLayoutForTextContainer:atEnd:\n");
	NSLog(@"Test: size: %@\n", NSStringFromSize([self containerSizeOfString:@"a\nb"
		withFontname:@"Helvetica"
		fontSize:12.0]));
	//NSTextContainer tempContainer = [[[NSTextContainer alloc] initWithContainerSize:NSMakeSize(300.0,300.0)] autorelease];
	//NSLayoutManger tempLayoutManager = [[[NSLayoutManager alloc] init] autorelease];
	
	NSRect frame;
	_bounds.size = [[_editor layoutManager] usedRectForTextContainer:[_editor textContainer]].size;
	//[[_editor textContainer] containerSize];
    frame = [_docView convertRect:[_docView convertRect:_bounds fromPage:_page] toView:PDFDisplayViewForMatteView(documentViewForPDFView(_docView))];
	[_editor setFrame:frame];
	NSLog(@"setting frame to : %@\n", NSStringFromRect(frame));
}

/*
static NSFont *
flippedFont(NSFont * font)
{
    int size = [font pointSize];
    float matrix[6];
    
    bzero(matrix,sizeof(float)*6);
    matrix[0] = size;
    matrix[3] = -size;
    
    return [NSFont fontWithName:[font fontName] matrix:matrix];
}
*/

- (void)stopEditing
{
	NSLog(@"stop editing\n");
    assert(_editor);
    [_editor setDelegate:nil];
	[[_editor layoutManager] setDelegate:nil];
    [_editor removeFromSuperview];
    _isEditing = NO;
    /*
    [[_editor layoutManager] release]; // XXX release _editor?
    _editor = nil;
    _isEditing = NO;
    
    // flip the fonts
    NSRange range;
    unsigned int index = 0;
    while (index < [_contents length]) {
        NSFont *font;
        font = [_contents attribute:NSFontAttributeName
                            atIndex:index
                     effectiveRange:&range];
        [_contents setAttributes:[NSDictionary dictionaryWithObject:flippedFont(font)
                                                             forKey:NSFontAttributeName]
                           range:range];
        
        // prepare for next loop iteration
        index = NSMaxRange(range);
    }
     */
}

/*
static NSLayoutManager *sharedDrawingLayoutManager() {
    // This method returns an NSLayoutManager that can be used to draw the contents of a SKTTextArea.
    static NSLayoutManager *sharedLM = nil;
    if (!sharedLM) {
        NSTextContainer *tc = [[NSTextContainer allocWithZone:NULL] initWithContainerSize:NSMakeSize(1.0e6, 1.0e6)];
        
        sharedLM = [[NSLayoutManager allocWithZone:NULL] init];
        
        [tc setWidthTracksTextView:NO];
        [tc setHeightTracksTextView:NO];
        [sharedLM addTextContainer:tc];
        [tc release];
    }
    return sharedLM;
}
*/

/*
- (NSSize)requiredSize:(float)maxWidth {
    NSTextStorage *contents = _contents;
    NSSize minSize = NSMakeSize(10.0, 15.0);
    NSSize maxSize = NSMakeSize(400.0, 400.0);
    unsigned len = [contents length];
    
    if (len > 0) {
        NSLayoutManager *lm = sharedDrawingLayoutManager();
        NSTextContainer *tc = [[lm textContainers] objectAtIndex:0];
        NSRange glyphRange;
        NSSize requiredSize;
        
        [tc setContainerSize:NSMakeSize(((maxSize.width < maxWidth) ? maxSize.width : maxWidth), maxSize.height)];
        [contents addLayoutManager:lm];
        // Force layout of the text and find out how much of it fits in the container.
        glyphRange = [lm glyphRangeForTextContainer:tc];
        
        requiredSize = [lm usedRectForTextContainer:tc].size;
        requiredSize.width += 1.0;
        
        if (requiredSize.width < minSize.width) {
            requiredSize.width = minSize.width;
        }
        if (requiredSize.height < minSize.height) {
            requiredSize.height = minSize.height;
        }
        
        [contents removeLayoutManager:lm];
        
        return requiredSize;
    } else {
        return minSize;
    }
}
*/

- (void)textDidChange:(NSNotification *)notification {
    /*
    NSSize textSize;
    BOOL fixedWidth = ([[notification object] isHorizontallyResizable] ? NO : YES);
    
    textSize = NSMakeSize(1000.0, 1000.0);
    NSLog(@"textSize: %@\n", NSStringFromSize(textSize));
    
    if ((textSize.width > _bounds.size.width) || (textSize.height > _bounds.size.height)) {
        _bounds = NSMakeRect(_bounds.origin.x, _bounds.origin.y, ((!fixedWidth && (textSize.width > _bounds.size.width)) ? textSize.width : _bounds.size.width), ((textSize.height > _bounds.size.height) ? textSize.height : _bounds.size.height));
    }
     */
    NSLog(@"editor frame:  %@\n", NSStringFromRect([_editor frame]));
    NSLog(@"editor bounds: %@\n", NSStringFromRect([_editor bounds]));
}

@end
