//
//  FPRectangle.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 8/5/06.
//  Copyright 2006 Andrew de los Reyes. All rights reserved.
//

#import "FPRectangle.h"

@implementation FPRectangle

+ (NSString *)archivalClassName;
{
    return @"Rectangle";
}

- (NSDictionary *)archivalDictionary
{
    return [super archivalDictionary];
}

- (void)draw:(BOOL)selected
{
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:[self bounds]];
    [path setLineWidth:[self strokeWidth]];
    if (_gFlags.drawsFill) {
        [_fillColor set];
        [path fill];
    }
    if (_gFlags.drawsStroke) {
        [_strokeColor set];
        [path stroke];
    }
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
    
    // if the next event is mouse up, then the user didn't drag at all, so scrap the shape.
    theEvent = [[_docView window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
    if ([theEvent type] == NSLeftMouseUp)
        return NO;
    // ok, we have a shape, and user is dragging to size it
    [self resizeWithEvent:theEvent byKnob:LowerRightKnob];
    return YES;
}

@end
