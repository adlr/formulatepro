//
//  FPGraphic.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 7/5/06.
//  Copyright 2006 Andrew de los Reyes. All rights reserved.
//

#import "FPGraphic.h"
#import "FPDocumentView.h"

@implementation FPGraphic

+ (FPGraphic *)graphicInDocumentView:(FPDocumentView *)docView
{
    FPGraphic *ret = [[FPGraphic alloc] initInDocumentView:docView];
    return [ret autorelease];
}

- (id)initInDocumentView:(FPDocumentView *)docView
{
    self = [super init];
    if (self) {
        _hasPage = NO;
        _page = 0;
        _docView = docView;
        _lineWidth = 1.0;
        _knobMask = 0xff; // all knobs
        _gFlags.drawsStroke = YES;
    }
    return self;
}

- (BOOL)placeWithEvent:(NSEvent *)theEvent
{
    for (;;) {
        NSPoint point;
        
        if (_hasPage) { // invalidate where the shape used to be, if anywhere
            [_docView setNeedsDisplayInRect:[_docView convertRect:[self safeBounds] fromPage:_page]];
        }

        _page = [_docView pageForPointFromEvent:theEvent];
        point = [_docView pagePointForPointFromEvent:theEvent page:_page];
        
        _bounds.origin = point;
        _bounds.size = NSMakeSize(1.0,1.0);
        
        // invalidate where the shape is now
        [_docView setNeedsDisplayInRect:[_docView convertRect:[self safeBounds] fromPage:_page]];
        
        // get ready for next iteration of the loop, or break out of loop
        theEvent = [[_docView window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        if ([theEvent type] == NSLeftMouseUp)
            break;
    }
    assert(_hasPage);
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
    BOOL flipX;
    BOOL flipY;
    
    float shiftSlope = 0.0;
    if (_bounds.size.width > 0.0 &&
        _bounds.size.height > 0.0)
        shiftSlope = _bounds.size.height / _bounds.size.width;
    else
        shiftSlope = _naturalBounds.size.height / _naturalBounds.size.width;
    assert(shiftSlope != 0.0);
    
    for (;;) {
        NSRect newBounds = _bounds;
        flipX = NO;
        flipY = NO;
        assert(_bounds.size.width >= 0.0);
        assert(_bounds.size.height >= 0.0);
        
        /*
        NSLog(@"resize x: %.1f y: %.1f w: %.1f h: %.1f\n",
              _bounds.origin.x,
              _bounds.origin.y,
              _bounds.size.width,
              _bounds.size.height);
         */
        
        NSPoint docPoint = [_docView pagePointForPointFromEvent:theEvent
                                                           page:_page];
        [_docView setNeedsDisplayInRect:[_docView convertRect:[self boundsWithKnobs] fromPage:_page]];
        
        if (knob == UpperLeftKnob ||
            knob == UpperMiddleKnob ||
            knob == UpperRightKnob)
            flipY = FPRectSetTopAbs(&newBounds, docPoint.y);
        if (knob == LowerLeftKnob ||
            knob == LowerMiddleKnob ||
            knob == LowerRightKnob)
            flipY = FPRectSetBottomAbs(&newBounds, docPoint.y);
        
        if (knob == UpperLeftKnob ||
            knob == MiddleLeftKnob ||
            knob == LowerLeftKnob)
            flipX = FPRectSetLeftAbs(&newBounds, docPoint.x);
        if (knob == UpperRightKnob ||
            knob == MiddleRightKnob ||
            knob == LowerRightKnob)
            flipX = FPRectSetRightAbs(&newBounds, docPoint.x);
        
        [self setBounds:newBounds];
        
        if (flipY) {
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
            switch (knob) {
                case UpperLeftKnob: knob = UpperRightKnob; break;
                case MiddleLeftKnob: knob = MiddleRightKnob; break;
                case LowerLeftKnob: knob = LowerRightKnob; break;
                case UpperRightKnob: knob = UpperLeftKnob; break;
                case MiddleRightKnob: knob = MiddleLeftKnob; break;
                case LowerRightKnob: knob = LowerLeftKnob; break;
            }
        }
        
        if ([theEvent modifierFlags] & NSShiftKeyMask) {
            BOOL didFlip;
            switch (knob) {
                case LowerRightKnob:
                    didFlip = FPRectSetRightAbs(&_bounds,
                                                _bounds.origin.x + _bounds.size.height);
                    break;
                case UpperLeftKnob:
                    didFlip = FPRectSetLeftAbs(&_bounds,
                                               _bounds.origin.x + _bounds.size.width - _bounds.size.height);
                    break;
                case UpperRightKnob:
                    didFlip = NO;
                    _bounds.size.width = _bounds.size.height;
                    break;
                case LowerLeftKnob:
                    didFlip = FPRectSetLeftAbs(&_bounds,
                                               _bounds.origin.x + _bounds.size.width - _bounds.size.height);
                    break;
                default:
                    assert(0); // XXX need to support shift on middle knobs
            }
            assert(didFlip == NO);
        }
        
        [_docView setNeedsDisplayInRect:[_docView convertRect:[self boundsWithKnobs] fromPage:_page]];

        // get ready for next iteration of the loop, or break out of loop
        theEvent = [[_docView window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        if ([theEvent type] == NSLeftMouseUp)
            break;
    }
    [_docView discardCursorRects];
}

- (void)documentDidZoom { }

- (void)moveGraphicByX:(float)x byY:(float)y
{
    NSRect bounds = _bounds;
    bounds.origin.x += x;
    bounds.origin.y += y;
    [self setBounds:bounds];
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
    q = [_docView convertPoint:p fromPage:_page];
    rect = NSMakeRect(floorf(q.x)+0.5 -2.0,
                      floorf(q.y)+0.5 -2.0,
                      4.0, 4.0);
    pdf_rect = [_docView convertRect:rect toPage:_page];
    NSBezierPath *newpath = [NSBezierPath bezierPathWithRect:pdf_rect];
    [newpath setLineWidth:(1.0/[_docView scaleFactor])];
    [[NSColor whiteColor] set];
    [newpath fill];
    [[NSColor blackColor] set];
    [newpath stroke];
}

#define AVG(a, b) (((a) + (b)) / 2.0)

#define FPAvgX(a) (AVG((a).origin.x, (a).origin.x + (a).size.width))

#define FPAvgY(a) (AVG((a).origin.y, (a).origin.y + (a).size.height))

// returns rect for a knob in page coordinates. remember that there is a 1 screen-pixel thick border
// if isBound is set, returns a bounds rectangle in page coordinates that includes 1 screen-pixel thick border
- (NSRect)pageRectForKnob:(int)knob isBoundRect:(BOOL)isBound
{
    NSPoint p;
    switch (knob) {
        case UpperLeftKnob:
            p = NSMakePoint(NSMinX(_bounds),
                            NSMaxY(_bounds));
            break;
        case UpperMiddleKnob:
            p = NSMakePoint(FPAvgX(_bounds),
                            NSMaxY(_bounds));
            break;
        case UpperRightKnob:
            p = NSMakePoint(NSMaxX(_bounds),
                            NSMaxY(_bounds));
            break;
        case MiddleLeftKnob:
            p = NSMakePoint(NSMinX(_bounds),
                            FPAvgY(_bounds));
            break;
        case MiddleRightKnob:
            p = NSMakePoint(NSMaxX(_bounds),
                            FPAvgY(_bounds));
            break;
        case LowerLeftKnob:
            p = NSMakePoint(NSMinX(_bounds),
                            NSMinY(_bounds));
            break;
        case LowerMiddleKnob:
            p = NSMakePoint(FPAvgX(_bounds),
                            NSMinY(_bounds));
            break;
        case LowerRightKnob:
            p = NSMakePoint(NSMaxX(_bounds),
                            NSMinY(_bounds));
            break;
        default:
            assert(0); // bad knob
    }
    NSPoint window_point = [_docView convertPoint:p fromPage:_page];
    NSRect knobRect = NSMakeRect(floorf(window_point.x)+0.5 -2.0 - (isBound?0.5:0.0),
                                 floorf(window_point.y)+0.5 -2.0 - (isBound?0.5:0.0),
                                 4.0 + (isBound?1.0:0.0),
                                 4.0 + (isBound?1.0:0.0));
    return [_docView convertRect:knobRect toPage:_page];
}

- (void)drawKnobs
{
    int i;
    for (i = 0; i <= 7; i++) {
        if (_knobMask & (1 << i)) {
            NSBezierPath *knobPDFRectPath = [NSBezierPath bezierPathWithRect:[self pageRectForKnob:(1 << i)
                                                                                       isBoundRect:NO]];
            [knobPDFRectPath setLineWidth:(1.0/[_docView scaleFactor])];
            [[NSColor whiteColor] set];
            [knobPDFRectPath fill];
            [[NSColor blackColor] set];
            [knobPDFRectPath stroke];
        }
    }
}

- (int)knobForEvent:(NSEvent *)theEvent
{
    int i;
    NSPoint p = [_docView pagePointForPointFromEvent:theEvent page:_page];
    for (i = 0; i <= 7; i++) {
        if (_knobMask & (1 << i)) {
            NSRect knobBounds = [self pageRectForKnob:(1 << i)
                                          isBoundRect:YES];
            if (NSPointInRect(p, knobBounds))
                return (1 << i);
        }
    }
    return NoKnob;
}

- (unsigned int)page
{
    return _page;
}

- (NSRect)boundsWithKnobs
{
    NSRect bounds = [self safeBounds];
    NSRect knobRect;
    float diff;
    if (_knobMask & (UpperLeftKnob |
                     UpperMiddleKnob |
                     UpperRightKnob)) {
        knobRect = [self pageRectForKnob:UpperMiddleKnob isBoundRect:YES];
        if (NSMaxY(knobRect) > NSMaxY(bounds))
            bounds.size.height += (NSMaxY(knobRect) - NSMaxY(bounds));
    }
    if (_knobMask & (UpperRightKnob |
                     MiddleRightKnob |
                     LowerRightKnob)) {
        knobRect = [self pageRectForKnob:MiddleRightKnob isBoundRect:YES];
        if (NSMaxX(knobRect) > NSMaxX(bounds))
            bounds.size.width += (NSMaxX(knobRect) - NSMaxX(bounds));
    }
    if (_knobMask & (LowerLeftKnob |
                     LowerMiddleKnob |
                     LowerRightKnob)) {
        knobRect = [self pageRectForKnob:LowerMiddleKnob isBoundRect:YES];
        diff = NSMinY(bounds) - NSMinY(knobRect);
        if (diff > 0.0) {
            bounds.size.height += diff;
            bounds.origin.y -= diff;
        }
    }
    if (_knobMask & (UpperLeftKnob |
                     MiddleLeftKnob |
                     LowerLeftKnob)) {
        knobRect = [self pageRectForKnob:MiddleLeftKnob isBoundRect:YES];
        diff = NSMinX(bounds) - NSMinX(knobRect);
        if (diff > 0.0) {
            bounds.size.width += diff;
            bounds.origin.x -= diff;
        }
    }
    return bounds;
}

- (NSRect)safeBounds
{
    float halfWidth = _lineWidth/2.0;
    return NSMakeRect(_bounds.origin.x - halfWidth,
                      _bounds.origin.y - halfWidth,
                      _bounds.size.width + _lineWidth,
                      _bounds.size.height + _lineWidth);
}

- (float)lineWidth
{
    return _lineWidth;
}

- (NSRect)bounds
{
    return _bounds;
}

- (void)setBounds:(NSRect)bounds
{
    assert(bounds.size.width >= 0.0);
    assert(bounds.size.height >= 0.0);
    _bounds = bounds;
}

- (BOOL)isEditable
{
    return NO;
}

- (void)startEditing {}
- (void)stopEditing {}

@end
