//
//  FPGraphic.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 7/5/06.
//  Copyright 2006 Andrew de los Reyes. All rights reserved.
//

#import "FPGraphic.h"


@implementation FPGraphic

+ (FPGraphic *)graphicInPDFView:(MyPDFView *)pdfView
{
    FPGraphic *ret = [[FPGraphic alloc] initInPDFView:pdfView];
    return [ret autorelease];
}

- (FPGraphic *)initInPDFView:(MyPDFView *)pdfView
{
    self = [super init];
    if (self) {
        _page = nil;
        _pdfView = pdfView;
        _lineWidth = 1.0;
    }
    return self;
}

- (BOOL)placeWithEvent:(NSEvent *)theEvent
{
    for (;;) {
        NSPoint point;
        
        if (_page) { // invalidate where the shape used to be, if anywhere
            [_pdfView setNeedsDisplayInRect:[_pdfView convertRect:[self safeBounds] fromPage:_page]];
        }

        point = [_pdfView convertPointFromEvent:theEvent toPage:&_page];
        
        _bounds.origin = point;
        _bounds.size = NSMakeSize(10.0,10.0);
        
        // invalidate where the shape is now
        [_pdfView setNeedsDisplayInRect:[_pdfView convertRect:[self safeBounds] fromPage:_page]];
        
        // get ready for next iteration of the loop, or break out of loop
        theEvent = [[_pdfView window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        if ([theEvent type] == NSLeftMouseUp)
            break;
    }
    assert(_page);
    return YES;
}

// returns YES if flipped
BOOL FPRectSetTopAbs(NSRect *rect, float top)
{
    BOOL flip = top < rect->origin.y;
    if (flip) {
        rect->size.height = rect->origin.y - top;
        rect->origin.y = top;
    } else {
        rect->size.height = top - rect->origin.y;
    }
    return flip;
}

// returns YES if flipped
BOOL FPRectSetRightAbs(NSRect *rect, float right)
{
    BOOL flip = right < rect->origin.x;
    if (flip) {
        rect->size.width = rect->origin.x - right;
        rect->origin.x = right;
    } else {
        rect->size.width = right - rect->origin.x;
    }
    return flip;
}

// returns YES if flipped
BOOL FPRectSetBottomAbs(NSRect *rect, float bottom)
{
    BOOL flip = bottom > (rect->origin.y + rect->size.height);
    if (flip) {
        rect->origin.y += rect->size.height;
        rect->size.height = bottom - rect->origin.y;
    } else {
        rect->size.height += (rect->origin.y - bottom);
        rect->origin.y = bottom;
    }
    return flip;
}

// returns YES if flipped
BOOL FPRectSetLeftAbs(NSRect *rect, float left)
{
    BOOL flip = left > (rect->origin.x + rect->size.width);
    if (flip) {
        rect->origin.x += rect->size.width;
        rect->size.width = left - rect->origin.x;
    } else {
        rect->size.width += (rect->origin.x - left);
        rect->origin.x = left;
    }
    return flip;
}

- (void)resizeWithEvent:(NSEvent *)theEvent byKnob:(int)knob
{
    assert(knob == LowerRightKnob);
    BOOL flipX;
    BOOL flipY;
    
    for (;;) {
        flipX = NO;
        flipY = NO;
        assert(_bounds.size.width >= 0.0);
        assert(_bounds.size.height >= 0.0);
        
        NSLog(@"resize x: %.1f y: %.1f w: %.1f h: %.1f\n",
              _bounds.origin.x,
              _bounds.origin.y,
              _bounds.size.width,
              _bounds.size.height);
        
        NSPoint docPoint = [_pdfView convertPagePointFromEvent:theEvent
                                                          page:_page];
        [_pdfView setNeedsDisplayInRect:[_pdfView convertRect:[self safeBounds] fromPage:_page]];
        
        if (knob == UpperLeftKnob ||
            knob == UpperMiddleKnob ||
            knob == UpperRightKnob)
            flipY = FPRectSetTopAbs(&_bounds, docPoint.y);
        if (knob == LowerLeftKnob ||
            knob == LowerMiddleKnob ||
            knob == LowerRightKnob)
            flipY = FPRectSetBottomAbs(&_bounds, docPoint.y);
        
        if (knob == UpperLeftKnob ||
            knob == MiddleLeftKnob ||
            knob == LowerLeftKnob)
            flipX = FPRectSetLeftAbs(&_bounds, docPoint.x);
        if (knob == UpperRightKnob ||
            knob == MiddleRightKnob ||
            knob == LowerRightKnob)
            flipX = FPRectSetRightAbs(&_bounds, docPoint.x);
        
        [_pdfView setNeedsDisplayInRect:[_pdfView convertRect:[self safeBounds] fromPage:_page]];

        if (flipY) {
            NSLog(@"FLIP Y\n");
            switch (knob) {
                case UpperLeftKnob: knob = LowerLeftKnob; break;
                case UpperMiddleKnob: knob = LowerMiddleKnob; break;
                case UpperRightKnob: knob = LowerRightKnob; break;
                case LowerLeftKnob: knob = UpperLeftKnob; break;
                case LowerMiddleKnob: knob = UpperMiddleKnob; break;
                case LowerRightKnob: knob = UpperRightKnob; break;
            }
        }
        if (flipX) {
            NSLog(@"FLIP X\n");
            switch (knob) {
                case UpperLeftKnob: knob = UpperRightKnob; break;
                case MiddleLeftKnob: knob = MiddleRightKnob; break;
                case LowerLeftKnob: knob = LowerRightKnob; break;
                case UpperRightKnob: knob = UpperLeftKnob; break;
                case MiddleRightKnob: knob = MiddleLeftKnob; break;
                case LowerRightKnob: knob = LowerLeftKnob; break;
            }
        }
        
        // get ready for next iteration of the loop, or break out of loop
        theEvent = [[_pdfView window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        if ([theEvent type] == NSLeftMouseUp)
            break;
    }

}

- (void)draw
{
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:_bounds];
    [path setLineWidth:_lineWidth];
    [[NSColor redColor] set];
    [path fill];
    [[NSColor blackColor] set];
    [path stroke];

    NSPoint p = NSMakePoint(_bounds.origin.x + _bounds.size.width+_lineWidth/2.0,
                            _bounds.origin.y + _bounds.size.height+_lineWidth/2.0);
    NSPoint q;
    NSRect rect;
    NSRect pdf_rect;
    q = [_pdfView convertPoint:p fromPage:_page];
    rect = NSMakeRect(floorf(q.x)+0.5 -2.0,
                      floorf(q.y)+0.5 -2.0,
                      4.0, 4.0);
    pdf_rect = [_pdfView convertRect:rect toPage:_page];
    NSBezierPath *newpath = [NSBezierPath bezierPathWithRect:pdf_rect];
    [newpath setLineWidth:(1.0/[_pdfView scaleFactor])];
    [[NSColor whiteColor] set];
    [newpath fill];
    [[NSColor blackColor] set];
    [newpath stroke];
}

- (PDFPage*)page
{
    return _page;
}

- (NSRect)safeBounds
{
    float halfWidth = _lineWidth/2.0;
    return NSMakeRect(_bounds.origin.x - halfWidth - 1.0,
                      _bounds.origin.y - halfWidth - 1.0,
                      _bounds.size.width + _lineWidth + 2.0,
                      _bounds.size.height + _lineWidth + 2.0);
}

- (float)lineWidth
{
    return _lineWidth;
}

- (NSRect)bounds
{
    return _bounds;
}

@end
