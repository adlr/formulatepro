//
//  FPGraphic.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 7/5/06.
//  Copyright 2006 Andrew de los Reyes. All rights reserved.
//

#import "FPGraphic.h"
#import "FPDocumentView.h"
#import "FPArchiveExtras.h"

#import "FPRectangle.h"
#import "FPEllipse.h"
#import "FPSquiggle.h"
#import "FPCheckmark.h"
#import "FPImage.h"
#import "FPTextAreaB.h"

@implementation FPGraphic

#pragma mark Initialization and Archival functions

static const int graphicArchiveVersion = 1;

static NSString *graphicClassArchiveKey = @"Graphic Class";
static NSString *boundsArchiveKey = @"bounds";
static NSString *naturalBoundsArchiveKey = @"naturalBounds";
static NSString *drawsFillArchiveKey = @"drawsFill";
static NSString *drawsStrokeArchiveKey = @"drawsStroke";
static NSString *strokeWidthArchiveKey = @"lineWidth";
static NSString *fillColorArchiveKey = @"fillColor";
static NSString *strokeColorArchiveKey = @"strokeColor";
static NSString *knobMaskArchiveKey = @"knobMask";
static NSString *hideWhenPrintingArchiveKey = @"hideWhenPrinting";
static NSString *pageArchiveKey = @"page";
static NSString *versionArchiveKey = @"version";

+ (FPGraphic *)graphicInDocumentView:(FPDocumentView *)docView
{
    FPGraphic *ret = [[[self class] alloc] initInDocumentView:docView];
    return [ret autorelease];
}

- (id)copyWithZone:(NSZone *)zone
{
    id ret = [[[self class] allocWithZone:zone] initWithGraphic:self];
    return ret;
}

- (id)initWithGraphic:(FPGraphic *)graphic
{
    self = [super init];
    if (self) {
        _bounds = graphic->_bounds;
        _naturalBounds = graphic->_naturalBounds;
        _origBounds = graphic->_origBounds;
        _gFlags = graphic->_gFlags;
        _strokeWidth = graphic->_strokeWidth;
        _fillColor = [graphic->_fillColor copy];
        _strokeColor = [graphic->_strokeColor copy];
        _knobMask = graphic->_knobMask;
        _gFlags.hidesWhenPrinting = graphic->_gFlags.hidesWhenPrinting;
        _docView = graphic->_docView;
        _hasPage = graphic->_hasPage;
        _page = graphic->_page;
    }
    return self;
}

- (id)initInDocumentView:(FPDocumentView *)docView
{
    self = [super init];
    if (self) {
        _hasPage = NO;
        _page = 0;
        _docView = docView;
        _strokeWidth = 1.0;
        _fillColor = [[NSColor redColor] retain];
        _strokeColor = [[docView defaultStrokeColor] retain];
        _knobMask = 0xff; // all knobs
        _gFlags.drawsStroke = YES;
        _gFlags.drawsFill = NO;
        _gFlags.hidesWhenPrinting = NO;
    }
    return self;
}

+ (FPGraphic *)graphicFromArchivalDictionary:(NSDictionary *)dict
                              inDocumentView:(FPDocumentView *)docView
{
    Class graphicClasses[] = {[FPRectangle class],
                              [FPEllipse class],
                              [FPSquiggle class],
                              [FPCheckmark class],
                              [FPImage class],
                              [FPTextAreaB class]};
    const unsigned graphicClassesLen =
        sizeof(graphicClasses) / sizeof(graphicClasses[0]);

    Class c;
    NSString *cstr = [dict objectForKey:@"Graphic Class"];
    BOOL foundClass = NO;
    
    for (unsigned int i = 0; i < graphicClassesLen; i++) {
        if ([[graphicClasses[i] archivalClassName] isEqualToString:cstr]) {
            c = graphicClasses[i];
            foundClass = YES;
            break;
        }
    }
    if (!foundClass) {
        assert(0);
        return nil;
    }

    return [[[c alloc] initWithArchivalDictionary:dict
                                   inDocumentView:docView] autorelease];
}

- (id)initWithArchivalDictionary:(NSDictionary *)dict
                  inDocumentView:(FPDocumentView *)docView
{
    self = [super init];
    if (self) {
        // for now, we only accept the current version. in the future,
        // we'll convert old versions to the current version.
        // TODO(adlr): convert this to user feedback
        assert([[dict objectForKey:versionArchiveKey] intValue] ==
               graphicArchiveVersion);
        
        _hasPage = YES;
        _docView = docView;

        _bounds = rectFromArray([dict objectForKey:boundsArchiveKey]);
        _naturalBounds =
            rectFromArray([dict objectForKey:naturalBoundsArchiveKey]);
        _gFlags.drawsFill =
            [[dict objectForKey:drawsFillArchiveKey] boolValue];
        _gFlags.drawsStroke =
            [[dict objectForKey:drawsStrokeArchiveKey] boolValue];
        _strokeWidth =
            [[dict objectForKey:strokeWidthArchiveKey] floatValue];
        _fillColor =
            [[NSUnarchiver
              unarchiveObjectWithData:
              [dict objectForKey:fillColorArchiveKey]] retain];
        _strokeColor =
            [[NSUnarchiver
              unarchiveObjectWithData:
              [dict objectForKey:strokeColorArchiveKey]] retain];
        _knobMask =
            [[dict objectForKey:knobMaskArchiveKey] intValue];
        _gFlags.hidesWhenPrinting =
            [[dict objectForKey:hideWhenPrintingArchiveKey] boolValue];
        _page =
            [[dict objectForKey:pageArchiveKey] unsignedIntValue];
    }
    return self;
}

- (NSDictionary *)archivalDictionary
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    [ret setObject:arrayFromRect(_bounds) forKey:boundsArchiveKey];
    [ret setObject:arrayFromRect(_naturalBounds)
            forKey:naturalBoundsArchiveKey];
    [ret setObject:[NSNumber numberWithBool:_gFlags.drawsFill]
            forKey:drawsFillArchiveKey];
    [ret setObject:[NSNumber numberWithBool:_gFlags.drawsStroke]
            forKey:drawsStrokeArchiveKey];
    [ret setObject:[NSNumber numberWithFloat:_strokeWidth]
            forKey:strokeWidthArchiveKey];
    [ret setObject:[NSArchiver archivedDataWithRootObject:_fillColor]
            forKey:fillColorArchiveKey];
    [ret setObject:[NSArchiver archivedDataWithRootObject:_strokeColor]
            forKey:strokeColorArchiveKey];
    [ret setObject:[NSNumber numberWithInt:_knobMask]
            forKey:knobMaskArchiveKey];
    [ret setObject:[NSNumber numberWithBool:_gFlags.hidesWhenPrinting]
            forKey:hideWhenPrintingArchiveKey];
    [ret setObject:[NSNumber numberWithUnsignedInt:_page]
            forKey:pageArchiveKey];
    [ret setObject:[[self class] archivalClassName]
            forKey:graphicClassArchiveKey];
    [ret setObject:[NSNumber numberWithInt:graphicArchiveVersion]
            forKey:versionArchiveKey];
    return ret;
}

+ (NSString *)archivalClassName;
{
    return @"Graphic";
}

#pragma mark -
#pragma mark generic functions for docView interaction

- (BOOL)placeWithEvent:(NSEvent *)theEvent
{
    for (;;) {
        NSPoint point;
        
        if (_hasPage) { // invalidate where the shape used to be, if anywhere
            [_docView setNeedsDisplayInRect:
                [_docView convertRect:[self safeBounds] fromPage:_page]];
        }

        _page = [_docView pageForPointFromEvent:theEvent];
        point = [_docView pagePointForPointFromEvent:theEvent page:_page];
        
        _bounds.origin = point;
        _bounds.size = NSMakeSize(1.0,1.0);
        
        // invalidate where the shape is now
        [_docView setNeedsDisplayInRect:
            [_docView convertRect:[self safeBounds] fromPage:_page]];
        
        // get ready for next iteration of the loop, or break out of loop
        theEvent = [[_docView window] nextEventMatchingMask:
                    (NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        if ([theEvent type] == NSLeftMouseUp)
            break;
    }
    assert(_hasPage);
    return YES;
}

// returns YES if flipped
BOOL FPRectSetTopAbs(NSRect *rect, float top)
{
    BOOL flip = top < rect->origin.y;
    if (flip) {
        rect->size.height = rect->origin.y - top;
        rect->origin.y = top;
    } else {
        rect->size.height = top - rect->origin.y;
    }
    return flip;
}

// returns YES if flipped
BOOL FPRectSetRightAbs(NSRect *rect, float right)
{
    BOOL flip = right < rect->origin.x;
    if (flip) {
        rect->size.width = rect->origin.x - right;
        rect->origin.x = right;
    } else {
        rect->size.width = right - rect->origin.x;
    }
    return flip;
}

// returns YES if flipped
BOOL FPRectSetBottomAbs(NSRect *rect, float bottom)
{
    BOOL flip = bottom > (rect->origin.y + rect->size.height);
    if (flip) {
        rect->origin.y += rect->size.height;
        rect->size.height = bottom - rect->origin.y;
    } else {
        rect->size.height += (rect->origin.y - bottom);
        rect->origin.y = bottom;
    }
    return flip;
}

// returns YES if flipped
BOOL FPRectSetLeftAbs(NSRect *rect, float left)
{
    BOOL flip = left > (rect->origin.x + rect->size.width);
    if (flip) {
        rect->origin.x += rect->size.width;
        rect->size.width = left - rect->origin.x;
    } else {
        rect->size.width += (rect->origin.x - left);
        rect->origin.x = left;
    }
    return flip;
}

- (void)resizeWithEvent:(NSEvent *)theEvent byKnob:(int)knob
{
    BOOL flipX;
    BOOL flipY;
    
    float shiftSlope = 0.0;
    if (_bounds.size.width > 0.0 &&
        _bounds.size.height > 0.0)
        shiftSlope = _bounds.size.height / _bounds.size.width;
    else
        shiftSlope = _naturalBounds.size.height / _naturalBounds.size.width;
    assert(shiftSlope != 0.0);
    
    for (;;) {
        // print event info for now
        NSLog(@"event info:\n");
        NSLog(@"  pressure:           %f\n", [theEvent pressure]);
        NSLog(@"  tangentialPressure: %f\n", [theEvent tangentialPressure]);
        NSLog(@"  tilt: %@\n", NSStringFromPoint([theEvent tilt]));
        NSLog(@"  loc: %@\n", NSStringFromPoint([theEvent locationInWindow]));
        NSLog(@"  absolute X: %d\n", [theEvent absoluteX]);
        NSLog(@"  absolute Y: %d\n", [theEvent absoluteY]);
        NSLog(@"  absolute Z: %d\n", [theEvent absoluteZ]);
    
    
        NSRect newBounds = _bounds;
        flipX = NO;
        flipY = NO;
        assert(_bounds.size.width >= 0.0);
        assert(_bounds.size.height >= 0.0);
        
        /*
        NSLog(@"resize x: %.1f y: %.1f w: %.1f h: %.1f\n",
              _bounds.origin.x,
              _bounds.origin.y,
              _bounds.size.width,
              _bounds.size.height);
         */
        
        NSPoint docPoint = [_docView pagePointForPointFromEvent:theEvent
                                                           page:_page];
        [_docView setNeedsDisplayInRect:
            [_docView convertRect:[self boundsWithKnobs] fromPage:_page]];
        
        if (knob == UpperLeftKnob ||
            knob == UpperMiddleKnob ||
            knob == UpperRightKnob)
            flipY = FPRectSetTopAbs(&newBounds, docPoint.y);
        if (knob == LowerLeftKnob ||
            knob == LowerMiddleKnob ||
            knob == LowerRightKnob)
            flipY = FPRectSetBottomAbs(&newBounds, docPoint.y);
        
        if (knob == UpperLeftKnob ||
            knob == MiddleLeftKnob ||
            knob == LowerLeftKnob)
            flipX = FPRectSetLeftAbs(&newBounds, docPoint.x);
        if (knob == UpperRightKnob ||
            knob == MiddleRightKnob ||
            knob == LowerRightKnob)
            flipX = FPRectSetRightAbs(&newBounds, docPoint.x);
        
        [self setBounds:newBounds];
        
        if (flipY) {
            switch (knob) {
                case UpperLeftKnob: knob = LowerLeftKnob; break;
                case UpperMiddleKnob: knob = LowerMiddleKnob; break;
                case UpperRightKnob: knob = LowerRightKnob; break;
                case LowerLeftKnob: knob = UpperLeftKnob; break;
                case LowerMiddleKnob: knob = UpperMiddleKnob; break;
                case LowerRightKnob: knob = UpperRightKnob; break;
            }
        }
        if (flipX) {
            switch (knob) {
                case UpperLeftKnob: knob = UpperRightKnob; break;
                case MiddleLeftKnob: knob = MiddleRightKnob; break;
                case LowerLeftKnob: knob = LowerRightKnob; break;
                case UpperRightKnob: knob = UpperLeftKnob; break;
                case MiddleRightKnob: knob = MiddleLeftKnob; break;
                case LowerRightKnob: knob = LowerLeftKnob; break;
            }
        }
        
        if ([theEvent modifierFlags] & NSShiftKeyMask) {
            BOOL didFlip;
            switch (knob) {
                case UpperRightKnob:
                case LowerRightKnob:
                    didFlip = FPRectSetRightAbs(&_bounds,
                                                _bounds.origin.x +
                                                (_bounds.size.height /
                                                 shiftSlope));
                    break;
                case LowerLeftKnob:
                case UpperLeftKnob:
                    didFlip = FPRectSetLeftAbs(&_bounds,
                                               _bounds.origin.x +
                                               _bounds.size.width -
                                               (_bounds.size.height /
                                                shiftSlope));
                    break;
                default:
                    assert(0); // TODO(adlr): need to support shift on middle
                               // knobs
            }
            assert(didFlip == NO);
        }
        
        [_docView setNeedsDisplayInRect:
            [_docView convertRect:[self boundsWithKnobs] fromPage:_page]];

        // get ready for next iteration of the loop, or break out of loop
        theEvent = [[_docView window] nextEventMatchingMask:
                    (NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        if ([theEvent type] == NSLeftMouseUp)
            break;
    }
    [_docView discardCursorRects];
}

- (void)documentDidZoom { }

- (void)moveGraphicByX:(float)x byY:(float)y
{
    NSRect bounds = _bounds;
    bounds.origin.x += x;
    bounds.origin.y += y;
    [self setBounds:bounds];
}

- (void)reassignToPage:(unsigned int)page
{
    [self setBounds:[_docView convertRect:[_docView convertRect:[self bounds]
                                                       fromPage:_page]
                                   toPage:page]];
    _page = page;
}

- (void)draw:(BOOL)selected
{
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:_bounds];
    [path setLineWidth:_strokeWidth];
    [[NSColor redColor] set];
    [path fill];
    [[NSColor blackColor] set];
    [path stroke];

    NSPoint p = NSMakePoint(_bounds.origin.x + _bounds.size.width +
                            _strokeWidth/2.0,
                            _bounds.origin.y + _bounds.size.height +
                            _strokeWidth/2.0);
    NSPoint q;
    NSRect rect;
    NSRect pdf_rect;
    q = [_docView convertPoint:p fromPage:_page];
    rect = NSMakeRect(floorf(q.x)+0.5 -2.0,
                      floorf(q.y)+0.5 -2.0,
                      4.0, 4.0);
    pdf_rect = [_docView convertRect:rect toPage:_page];
    NSBezierPath *newpath = [NSBezierPath bezierPathWithRect:pdf_rect];
    [newpath setLineWidth:(1.0/[_docView scaleFactor])];
    [[NSColor whiteColor] set];
    [newpath fill];
    [[NSColor blackColor] set];
    [newpath stroke];
}

#define AVG(a, b) (((a) + (b)) / 2.0)

#define FPAvgX(a) (AVG((a).origin.x, (a).origin.x + (a).size.width))

#define FPAvgY(a) (AVG((a).origin.y, (a).origin.y + (a).size.height))

const float knobSize = 6.0;

// returns rect for a knob in page coordinates. remember that there is a 1
// screen-pixel thick border if isBound is set, returns a bounds rectangle in
// page coordinates that includes 1 screen-pixel thick border
- (NSRect)pageRectForKnob:(int)knob isBoundRect:(BOOL)isBound
{
    NSPoint p;
    switch (knob) {
        case UpperLeftKnob:
            p = NSMakePoint(NSMinX(_bounds),
                            NSMaxY(_bounds));
            break;
        case UpperMiddleKnob:
            p = NSMakePoint(FPAvgX(_bounds),
                            NSMaxY(_bounds));
            break;
        case UpperRightKnob:
            p = NSMakePoint(NSMaxX(_bounds),
                            NSMaxY(_bounds));
            break;
        case MiddleLeftKnob:
            p = NSMakePoint(NSMinX(_bounds),
                            FPAvgY(_bounds));
            break;
        case MiddleRightKnob:
            p = NSMakePoint(NSMaxX(_bounds),
                            FPAvgY(_bounds));
            break;
        case LowerLeftKnob:
            p = NSMakePoint(NSMinX(_bounds),
                            NSMinY(_bounds));
            break;
        case LowerMiddleKnob:
            p = NSMakePoint(FPAvgX(_bounds),
                            NSMinY(_bounds));
            break;
        case LowerRightKnob:
            p = NSMakePoint(NSMaxX(_bounds),
                            NSMinY(_bounds));
            break;
        default:
            assert(0); // bad knob
    }
    NSPoint window_point = [_docView convertPoint:p fromPage:_page];
    NSRect knobRect = NSMakeRect(floorf(window_point.x)+0.5 -(knobSize/2.0)
                                 -(isBound?0.5:0.0),
                                 floorf(window_point.y)+0.5 -(knobSize/2.0) 
                                 -(isBound?0.5:0.0),
                                 knobSize + (isBound?1.0:0.0),
                                 knobSize + (isBound?1.0:0.0));
    return [_docView convertRect:knobRect toPage:_page];
}

- (void)drawKnobs
{
    int i;
    for (i = 0; i <= 7; i++) {
        if (_knobMask & (1 << i)) {
            NSBezierPath *knobPDFRectPath = [NSBezierPath bezierPathWithRect:
                                             [self pageRectForKnob:(1 << i)
                                                       isBoundRect:NO]];
            [knobPDFRectPath setLineWidth:(1.0/[_docView scaleFactor])];
            [[NSColor whiteColor] set];
            [knobPDFRectPath fill];
            [[NSColor blackColor] set];
            [knobPDFRectPath stroke];
        }
    }
}

- (int)knobForEvent:(NSEvent *)theEvent
{
    int i;
    NSPoint p = [_docView pagePointForPointFromEvent:theEvent page:_page];
    for (i = 0; i <= 7; i++) {
        if (_knobMask & (1 << i)) {
            NSRect knobBounds = [self pageRectForKnob:(1 << i)
                                          isBoundRect:YES];
            if (NSPointInRect(p, knobBounds))
                return (1 << i);
        }
    }
    return NoKnob;
}

- (unsigned int)page
{
    return _page;
}

- (NSRect)boundsWithKnobs
{
    NSRect bounds = [self safeBounds];
    NSRect knobRect;
    float diff;
    if (_knobMask & (UpperLeftKnob |
                     UpperMiddleKnob |
                     UpperRightKnob)) {
        knobRect = [self pageRectForKnob:UpperMiddleKnob isBoundRect:YES];
        if (NSMaxY(knobRect) > NSMaxY(bounds))
            bounds.size.height += (NSMaxY(knobRect) - NSMaxY(bounds));
    }
    if (_knobMask & (UpperRightKnob |
                     MiddleRightKnob |
                     LowerRightKnob)) {
        knobRect = [self pageRectForKnob:MiddleRightKnob isBoundRect:YES];
        if (NSMaxX(knobRect) > NSMaxX(bounds))
            bounds.size.width += (NSMaxX(knobRect) - NSMaxX(bounds));
    }
    if (_knobMask & (LowerLeftKnob |
                     LowerMiddleKnob |
                     LowerRightKnob)) {
        knobRect = [self pageRectForKnob:LowerMiddleKnob isBoundRect:YES];
        diff = NSMinY(bounds) - NSMinY(knobRect);
        if (diff > 0.0) {
            bounds.size.height += diff;
            bounds.origin.y -= diff;
        }
    }
    if (_knobMask & (UpperLeftKnob |
                     MiddleLeftKnob |
                     LowerLeftKnob)) {
        knobRect = [self pageRectForKnob:MiddleLeftKnob isBoundRect:YES];
        diff = NSMinX(bounds) - NSMinX(knobRect);
        if (diff > 0.0) {
            bounds.size.width += diff;
            bounds.origin.x -= diff;
        }
    }
    return bounds;
}

- (NSRect)safeBounds
{
    float halfWidth = _strokeWidth/2.0;
    return NSMakeRect(_bounds.origin.x - halfWidth,
                      _bounds.origin.y - halfWidth,
                      _bounds.size.width + _strokeWidth,
                      _bounds.size.height + _strokeWidth);
}

- (float)strokeWidth
{
    return _strokeWidth;
}

- (NSRect)bounds
{
    return _bounds;
}

- (void)setBounds:(NSRect)bounds
{
    assert(bounds.size.width >= 0.0);
    assert(bounds.size.height >= 0.0);
    _bounds = bounds;
}

- (BOOL)drawsStroke
{
    return _gFlags.drawsStroke;
}

- (void)setDrawsStroke:(BOOL)drawsStroke
{
    _gFlags.drawsStroke = drawsStroke;
}

- (void)setStrokeWidth:(float)strokeWidth
{
    _strokeWidth = strokeWidth;
}

- (NSColor *)strokeColor
{
    return _strokeColor;
}

- (void)setStrokeColor:(NSColor *)strokeColor
{
    if (_strokeColor)
        [_strokeColor autorelease];
    _strokeColor = [strokeColor retain];    
    [_docView setNeedsDisplayInRect:
            [_docView convertRect:[self boundsWithKnobs] fromPage:_page]];
}

- (BOOL)drawsFill
{
    return _gFlags.drawsFill;
}

- (void)setDrawsFill:(BOOL)drawsFill
{
    _gFlags.drawsFill = drawsFill;
}

- (NSColor *)fillColor
{
    return _fillColor;
}

- (void)setFillColor:(NSColor *)fillColor
{
    if (_fillColor)
        [_fillColor autorelease];
    _fillColor = [fillColor retain];
}

- (BOOL)isHorizontallyFlipped
{
    return _gFlags.horizontallyFlipped;
}

- (void)setIsHorizontallyFlipped:(BOOL)isHorizontallyFlipped
{
    _gFlags.horizontallyFlipped = isHorizontallyFlipped;
}

- (BOOL)isVerticallyFlipped
{
    return _gFlags.verticallyFlipped;
}

- (void)setIsVerticallyFlipped:(BOOL)isVerticallyFlipped
{
    _gFlags.verticallyFlipped = isVerticallyFlipped;
}

- (BOOL)hidesWhenPrinting
{
    return _gFlags.hidesWhenPrinting;
}

- (void)setHidesWhenPrinting:(BOOL)hidesWhenPrinting
{
    _gFlags.hidesWhenPrinting = hidesWhenPrinting;
}

- (BOOL)isEditable
{
    return NO;
}

- (void)startEditing {}
- (void)stopEditing {}

@end
