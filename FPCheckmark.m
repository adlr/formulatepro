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
        _lineWidth *= 2.0;
    }
    return self;
}

- (void)draw
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path setLineWidth:[self lineWidth]];
    [[NSColor blackColor] set];
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
    NSPoint point;
    
    _page = [_docView pageForPointFromEvent:theEvent];
    point = [_docView pagePointForPointFromEvent:theEvent page:_page];
    
    _bounds.size = NSMakeSize(10.0, 10.0);
    _bounds.origin = NSMakePoint(point.x - NSWidth(_bounds) / 2,
                                 point.y - NSHeight(_bounds) / 2);
    _naturalBounds = _bounds;
    [_docView setNeedsDisplayInRect:
        [_docView convertRect:[self safeBounds] fromPage:_page]];
    
    return YES;
}

@end
