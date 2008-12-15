//
//  FPCheckmark.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 12/22/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "FPCheckmark.h"


@implementation FPCheckmark

+ (NSString *)archivalClassName;
{
    return @"Checkmark";
}

- (id)initInDocumentView:(FPDocumentView *)docView
{
    self = [super initInDocumentView:docView];
    if (self) {
        _strokeWidth *= 2.0;
    }
    return self;
}

- (void)draw:(BOOL)selected
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path setLineWidth:[self strokeWidth]];
    [_strokeColor set];
    [path moveToPoint:NSMakePoint(NSMinX([self bounds]),
                                  NSMinY([self bounds]))];
    [path lineToPoint:NSMakePoint(NSMaxX([self bounds]),
                                  NSMaxY([self bounds]))];
    [path moveToPoint:NSMakePoint(NSMinX([self bounds]),
                                  NSMaxY([self bounds]))];
    [path lineToPoint:NSMakePoint(NSMaxX([self bounds]),
                                  NSMinY([self bounds]))];
    [path stroke];
}

- (BOOL)placeWithEvent:(NSEvent *)theEvent
{
    _bounds.size = NSMakeSize(10.0, 10.0);
    _naturalBounds = _bounds;
    
    for (;;) {
        _page = [_docView pageForPointFromEvent:theEvent];
        NSPoint point = [_docView pagePointForPointFromEvent:theEvent page:_page];

        // invalidate old bounds
        [_docView setNeedsDisplayInRect:
            [_docView convertRect:[self safeBounds] fromPage:_page]];
        _bounds.origin = NSMakePoint(point.x - NSWidth(_bounds) / 2,
                                     point.y - NSHeight(_bounds) / 2);
        // invalidate new bounds
        [_docView setNeedsDisplayInRect:
            [_docView convertRect:[self safeBounds] fromPage:_page]];

        // get ready for next iteration of the loop, or break out of loop
        theEvent = [[_docView window] nextEventMatchingMask:
            (NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        if ([theEvent type] == NSLeftMouseUp)
            break;
    }

    return YES;
}

@end
