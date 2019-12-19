//
//  FPSquiggle.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 8/5/06.
//  Copyright 2006 Andrew de los Reyes. All rights reserved.
//

#import "FPSquiggle.h"
#import "NSMutableDictionaryAdditions.h"

@implementation FPSquiggle

+ (NSString *)archivalClassName;
{
    return @"Squiggle";
}

- (id)initWithGraphic:(FPGraphic *)graphic
{
    self = [super initWithGraphic:graphic];
    assert([graphic class] == [FPSquiggle class]);
    if (self) {
        FPSquiggle *gr = (FPSquiggle *)graphic;
        self->_path = [gr->_path copy];
    }
    return self;
}

static NSString *pathArchiveKey = @"path";

- (id)initWithArchivalDictionary:(NSDictionary *)dict
                  inDocumentView:(FPDocumentView *)docView
{
    self = [super initWithArchivalDictionary:dict
                              inDocumentView:docView];
    if (self) {
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path setLineWidth:1.0];
        [path setLineJoinStyle:NSBevelLineJoinStyle];
        NSArray *arr = [dict objectForKey:pathArchiveKey];
        for (int i = 0; i < [arr count]; i++) {
            NSPoint pt = NSPointFromString([arr objectAtIndex:i]);
            if (0 == i)
                [path moveToPoint:pt];
            else
                [path lineToPoint:pt];
        }
        _path = [path retain];
        _bounds = [_path bounds];
    }
    return self;
}

- (NSDictionary *)archivalDictionary
{
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < [_path elementCount]; i++) {
        NSPoint p[3];
        NSBezierPathElement t;
        t = [_path elementAtIndex:i associatedPoints:p];
        if (0 == i)
            assert(NSMoveToBezierPathElement == t);
        else
            assert(NSLineToBezierPathElement == t);
        [arr addObject:NSStringFromPoint(p[0])];
    }
    NSMutableDictionary *ret =
        [NSMutableDictionary
         dictionaryWithDictionary:[super archivalDictionary]];
    [ret setObject:arr forNonexistentKey:pathArchiveKey];
    return ret;
}

- (id)initInDocumentView:(FPDocumentView *)docView
{
    self = [super initInDocumentView:docView];
    if (self) {
        _path = nil;
    }
    return self;
}

- (void)draw:(BOOL)selected
{
    NSBezierPath *tempPath = [[_path copy] autorelease];
    NSAffineTransform *scaleTransform = [NSAffineTransform transform];
	NSSize tempSize = [tempPath bounds].size;
	[scaleTransform scaleXBy:(tempSize.width > 1.0e-6) ?
							     (_bounds.size.width/tempSize.width) : 1.0
	                     yBy:(tempSize.height > 1.0e-6) ?
						         (_bounds.size.height/tempSize.height) : 1.0];
    [tempPath transformUsingAffineTransform:scaleTransform];
    NSAffineTransform *translateTransform = [NSAffineTransform transform];
    [translateTransform
     translateXBy:(_bounds.origin.x - [tempPath bounds].origin.x)
              yBy:(_bounds.origin.y - [tempPath bounds].origin.y)];
    [tempPath transformUsingAffineTransform:translateTransform];
    [_strokeColor set];
    [tempPath stroke];
}

// this function not tested ever
- (NSPoint)windowToPagePoint:(NSPoint)windowPoint
{
    return [_docView convertPoint:
        [[[_docView window] contentView] convertPoint:windowPoint
                                               toView:_docView]
                           toPage:_page];
}

- (NSPoint)pageToWindowPoint:(NSPoint)pagePoint
{
    return [[[_docView window] contentView]
            convertPoint:[_docView convertPoint:pagePoint fromPage:_page]
                fromView:_docView];
}

- (BOOL)placeWithEvent:(NSEvent *)theEvent
{
    NSPoint point;
    NSGraphicsContext *gc;
    
    _page = [_docView pageForPointFromEvent:theEvent];
    point = [_docView pagePointForPointFromEvent:theEvent page:_page];
    
    _bounds.origin = point;
    _bounds.size = NSMakeSize(0.0,0.0);
    
    _path = [[NSBezierPath bezierPath] retain];
    [_path moveToPoint:point];

    gc = [NSGraphicsContext graphicsContextWithWindow:[_docView window]];
    [NSGraphicsContext setCurrentContext:gc];
    [NSBezierPath setDefaultLineWidth:[_docView scaleFactor]];
    [_path setLineWidth:1.0];
    [_path setLineJoinStyle:NSBevelLineJoinStyle];
    [_strokeColor set];
    
    for (;;) {
        NSPoint new_point;
        
        new_point = [_docView pagePointForPointFromEvent:theEvent page:_page];
        [_path lineToPoint:new_point];
        if (NSPointInRect([self pageToWindowPoint:point],
                          [[[_docView window] contentView] frame]) &&
            NSPointInRect([self pageToWindowPoint:new_point],
                          [[[_docView window] contentView] frame])) {
            [NSBezierPath strokeLineFromPoint:[self pageToWindowPoint:point]
             toPoint:[self pageToWindowPoint:new_point]];
            [gc flushGraphics];
        }

        // get ready for next iteration of the loop, or break out of loop
        point = new_point;
/*
 DEPRECATED
 'NSLeftMouseDraggedMask' is deprecated: first deprecated in macOS 10.12
 'NSLeftMouseUpMask' is deprecated: first deprecated in macOS 10.12
 'NSLeftMouseUp' is deprecated: first deprecated in macOS 10.12
 */
        theEvent = [[_docView window] nextEventMatchingMask:
                    (NSEventMaskLeftMouseDragged | NSEventMaskLeftMouseUp)];
        if ([theEvent type] == NSEventTypeLeftMouseUp)
            break;
    }
    _bounds = [_path bounds];
    [NSGraphicsContext restoreGraphicsState];
    [[[_docView window] contentView] setNeedsDisplay:YES];
    return YES;
}
@end
