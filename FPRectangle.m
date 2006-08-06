//
//  FPRectangle.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 8/5/06.
//  Copyright 2006 Andrew de los Reyes. All rights reserved.
//

#import "FPRectangle.h"


@implementation FPRectangle

+ (FPGraphic *)graphicInPDFView:(MyPDFView *)pdfView
{
    FPGraphic *ret = [[FPRectangle alloc] initInPDFView:pdfView];
    return [ret autorelease];
}

- (void)draw
{
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:[self bounds]];
    [path setLineWidth:[self lineWidth]];
    [[NSColor redColor] set];
    [path fill];
    [[NSColor blackColor] set];
    [path stroke];
}

- (BOOL)placeWithEvent:(NSEvent *)theEvent
{
    NSPoint point;
    
    point = [_pdfView convertPointFromEvent:theEvent toPage:&_page];
    
    _bounds.origin = point;
    _bounds.size = NSMakeSize(0.0,0.0);
    
    // get ready for next iteration of the loop, or break out of loop
    theEvent = [[_pdfView window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
    if ([theEvent type] == NSLeftMouseUp)
        return NO; // XXX delete shape?
    [self resizeWithEvent:theEvent byKnob:LowerRightKnob];
    return YES;
}

@end
