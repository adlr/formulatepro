//
//  FPSquiggle.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 8/5/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "FPSquiggle.h"


@implementation FPSquiggle

+ (FPGraphic *)graphicInPDFView:(MyPDFView *)pdfView
{
    FPGraphic *ret = [[FPSquiggle alloc] initInPDFView:pdfView];
    return [ret autorelease];
}

- (void)draw
{
    [[NSColor blackColor] set];
    [_path stroke];
}

// this function not tested ever
- (NSPoint)windowToPagePoint:(NSPoint)windowPoint
{
    return [_pdfView convertPoint:
        [[[_pdfView window] contentView] convertPoint:windowPoint
                                               toView:_pdfView]
                           toPage:_page];
}

- (NSPoint)pageToWindowPoint:(NSPoint)pagePoint
{
    return [[[_pdfView window] contentView] convertPoint:[_pdfView convertPoint:pagePoint
                                                                       fromPage:_page]
                                                fromView:_pdfView];
}

- (BOOL)placeWithEvent:(NSEvent *)theEvent
{
    NSPoint point;
    NSGraphicsContext *gc;
    
    point = [_pdfView convertPointFromEvent:theEvent toPage:&_page];
    
    _bounds.origin = point;
    _bounds.size = NSMakeSize(0.0,0.0);
    
    _path = [[NSBezierPath bezierPath] retain];
    [_path moveToPoint:point];

    gc = [NSGraphicsContext graphicsContextWithWindow:[_pdfView window]];
    [NSGraphicsContext setCurrentContext:gc];
    [NSBezierPath setDefaultLineWidth:[_pdfView scaleFactor]];
    [_path setLineWidth:1.0];
    [_path setLineJoinStyle:NSBevelLineJoinStyle];
    
    for (;;) {
        NSPoint new_point;
        
        new_point = [_pdfView convertPagePointFromEvent:theEvent page:_page];
        [_path lineToPoint:new_point];
        if (NSPointInRect([self pageToWindowPoint:point], [[[_pdfView window] contentView] frame]) &&
            NSPointInRect([self pageToWindowPoint:new_point], [[[_pdfView window] contentView] frame])) {
            [NSBezierPath strokeLineFromPoint:[self pageToWindowPoint:point]
                                      toPoint:[self pageToWindowPoint:new_point]];
            [gc flushGraphics];
        }

        //[_pdfView setNeedsDisplayInRect:[_pdfView convertRect:[_path bounds] fromPage:_page]];

        // get ready for next iteration of the loop, or break out of loop
        point = new_point;
        
        theEvent = [[_pdfView window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        if ([theEvent type] == NSLeftMouseUp)
            break;
    }
    _bounds = [_path bounds];
    [NSGraphicsContext restoreGraphicsState];
    [[[_pdfView window] contentView] setNeedsDisplay:YES];
    return YES;
}
@end
