//
//  FPEllipse.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 8/5/06.
//  Copyright 2006 Andrew de los Reyes. All rights reserved.
//

#import "FPEllipse.h"


@implementation FPEllipse

+ (FPGraphic *)graphicInDocumentView:(FPDocumentView *)docView
{
    FPGraphic *ret = [[FPEllipse alloc] initInDocumentView:docView];
    return [ret autorelease];
}

- (void)draw
{
    NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:[self bounds]];
    [path setLineWidth:[self lineWidth]];
    [[NSColor redColor] set];
    [path fill];
    [[NSColor blackColor] set];
    [path stroke];
}

@end
