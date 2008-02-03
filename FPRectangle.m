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

//- (BOOL)placeWithEvent:(FPMouseEventProxy *)eventProxy
//{
//    NSRect bounds = NSZeroRect;
//    
//    [self setPage:[eventProxy page]];
//
//    NSPoint origin = [eventProxy point];
//    bounds.origin = origin;
//
//    
//    while ([eventProxy waitForNextEvent]) {
//        NSPoint p = [eventProxy point];
//        if (p.x > origin.x)
//            [self setRightAbs:p.x];
//        else
//            [self setLeftAbs:p.x];
//        if (p.y > origin.y)
//            [self setTopAbs:p.y];
//        else
//            [self setBottomAbs:p.y];
//    }
//    if (([self bounds].size.width < 1.0e-6) && ([self bounds].size.width < 1.0e-6)) {
//        return NO;
//    }
//    return YES;
//}

@end
