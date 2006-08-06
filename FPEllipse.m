//
//  FPEllipse.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 8/5/06.
//  Copyright 2006 Andrew de los Reyes. All rights reserved.
//

#import "FPEllipse.h"


@implementation FPEllipse

+ (FPGraphic *)graphicInPDFView:(MyPDFView *)pdfView
{
    FPGraphic *ret = [[FPEllipse alloc] initInPDFView:pdfView];
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
