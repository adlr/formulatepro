//
//  FPGraphic.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 7/5/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
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

- (void)placeWithEvent:(NSEvent *)theEvent
{
    for (;;) {
        NSPoint point;
        
        NSLog(@"in loop\n");
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
}

- (void)draw
{
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:_bounds];
    [path setLineWidth:_lineWidth];
    NSLog(@"draw graphic\n");
    [[NSColor redColor] set];
    [path fill];
    [[NSColor blackColor] set];
    [path stroke];
}

- (PDFPage*)page
{
    return _page;
}

- (NSRect)safeBounds
{
    float halfWidth = _lineWidth/2.0;
    return NSMakeRect(_bounds.origin.x - halfWidth,
                      _bounds.origin.y - halfWidth,
                      _bounds.size.width + _lineWidth,
                      _bounds.size.height + _lineWidth);
}

/*
- (NSBezierPath *)bezierPath {
    // Subclasses that just have a simple path override this to return it.  The basic drawInView:isSelected: implementation below will stroke and fill this path.  Subclasses that need more complex drawing will just override drawInView:isSelected:.
    return nil;
}

- (void)setBounds:(NSRect)bounds {
    if (!NSEqualRects(bounds, _bounds)) {
        if (!_gFlags.manipulatingBounds) {
            // Send the notification before and after so that observers who invalidate display in views will wind up invalidating both the original rect and the new one.
            [self didChange];
            [[[self undoManager] prepareWithInvocationTarget:self] setBounds:_bounds];
        }
        _bounds = bounds;
        if (!_gFlags.manipulatingBounds) {
            [self didChange];
        }
    }
}

- (void)startBoundsManipulation {
    // Save the original bounds.
    _gFlags.manipulatingBounds = YES;
    _origBounds = _bounds;
}

- (void)stopBoundsManipulation {
    if (_gFlags.manipulatingBounds) {
        // Restore the original bounds, the set the new bounds.
        if (!NSEqualRects(_origBounds, _bounds)) {
            NSRect temp;
            
            _gFlags.manipulatingBounds = NO;
            temp = _bounds;
            _bounds = _origBounds;
            [self setBounds:temp];
        } else {
            _gFlags.manipulatingBounds = NO;
        }
    }
}

- (NSRect)bounds {
    return _bounds;
}

- (int)resizeByMovingKnob:(int)knob toPoint:(NSPoint)point maintainAspectRatio:(BOOL)maintain_ar {
    NSRect bounds = [self bounds];
    
    if ((knob == UpperLeftKnob) || (knob == MiddleLeftKnob) || (knob == LowerLeftKnob)) {
        // Adjust left edge
        bounds.size.width = NSMaxX(bounds) - point.x;
        bounds.origin.x = point.x;
    } else if ((knob == UpperRightKnob) || (knob == MiddleRightKnob) || (knob == LowerRightKnob)) {
        // Adjust left edge
        bounds.size.width = point.x - bounds.origin.x;
    }
    if (bounds.size.width < 0.0) {
        knob = [SKTGraphic flipKnob:knob horizontal:YES];
        bounds.size.width = -bounds.size.width;
        bounds.origin.x -= bounds.size.width;
        [self flipHorizontally];
    }
    
    if ((knob == UpperLeftKnob) || (knob == UpperMiddleKnob) || (knob == UpperRightKnob)) {
        // Adjust top edge
        bounds.size.height = NSMaxY(bounds) - point.y;
        bounds.origin.y = point.y;
    } else if ((knob == LowerLeftKnob) || (knob == LowerMiddleKnob) || (knob == LowerRightKnob)) {
        // Adjust bottom edge
        bounds.size.height = point.y - bounds.origin.y;
    }
    if (bounds.size.height < 0.0) {
        knob = [SKTGraphic flipKnob:knob horizontal:NO];
        bounds.size.height = -bounds.size.height;
        bounds.origin.y -= bounds.size.height;
        [self flipVertically];
    }
    [self setBounds:bounds];
    return knob;
}

- (void)drawInView:(SKTGraphicView *)view isSelected:(BOOL)flag {
    NSBezierPath *path = [self bezierPath];
    if (path) {
        if ([self drawsFill]) {
            [[self fillColor] set];
            [path fill];
        }
        if ([self drawsStroke]) {
            [[self strokeColor] set];
            [path stroke];
        }
    }
    if (flag) {
        [self drawHandlesInView:view];
    }
}

- (BOOL)createWithEvent:(NSEvent *)theEvent inView:(MyPDFView *)view {
    // default implementation tracks until mouseUp: just setting the bounds of the new graphic.
    NSPoint point = [view convertPoint:[theEvent locationInWindow] fromView:nil];
    int knob = LowerRightKnob;
    NSRect bounds;
    BOOL snapsToGrid = [view snapsToGrid];
    float spacing = [view gridSpacing];
    BOOL echoToRulers = [[view enclosingScrollView] rulersVisible];
    
    [self startBoundsManipulation];
    if (snapsToGrid) {
        point.x = floor((point.x / spacing) + 0.5) * spacing;
        point.y = floor((point.y / spacing) + 0.5) * spacing;
    }
    [self setBounds:NSMakeRect(point.x, point.y, 0.0, 0.0)];
    if (echoToRulers) {
        [view beginEchoingMoveToRulers:[self bounds]];
    }
    while (1) {
        theEvent = [[view window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        NSLog(@"tracking graphic creation\n");
        point = [view convertPoint:[theEvent locationInWindow] fromView:nil];
        if (snapsToGrid) {
            point.x = floor((point.x / spacing) + 0.5) * spacing;
            point.y = floor((point.y / spacing) + 0.5) * spacing;
        }
        [view setNeedsDisplayInRect:[self drawingBounds]];
        knob = [self resizeByMovingKnob:knob toPoint:point];
        [view setNeedsDisplayInRect:[self drawingBounds]];
        if ([theEvent type] == NSLeftMouseUp) {
            break;
        }
    }

    [self stopBoundsManipulation];
    
    bounds = [self bounds];
    if ((bounds.size.width > 0.0) || (bounds.size.height > 0.0)) {
        return YES;
    } else {
        return NO;
    }
}
*/
@end
