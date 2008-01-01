//
//  FPEllipse.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 8/5/06.
//  Copyright 2006 Andrew de los Reyes. All rights reserved.
//

#import "FPEllipse.h"


@implementation FPEllipse

+ (NSString *)archivalClassName;
{
    return @"Ellipse";
}

- (void)draw:(BOOL)selected
{
    NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:[self bounds]];
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

@end
