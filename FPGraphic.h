//
//  FPGraphic.h
//  FormulatePro
//
//  Created by Andrew de los Reyes on 7/5/06.
//  Copyright 2006 Andrew de los Reyes. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FPDocumentView.h"

@class MyPDFView;
@class PDFPage;

enum {
    NoKnob = 0,
    UpperLeftKnob   = 1 << 0,
    UpperMiddleKnob = 1 << 1,
    UpperRightKnob  = 1 << 2,
    MiddleLeftKnob  = 1 << 3,
    MiddleRightKnob = 1 << 4,
    LowerLeftKnob   = 1 << 5,
    LowerMiddleKnob = 1 << 6,
    LowerRightKnob  = 1 << 7,
};

@interface FPGraphic : NSObject {
    NSRect _bounds;
    NSRect _naturalBounds;
    NSRect _origBounds; // for bulk move operations
    struct __gFlags {
        unsigned int drawsFill:1;
        unsigned int drawsStroke:1;
        unsigned int manipulatingBounds:1;
        unsigned int horizontallyFlipped:1;
        unsigned int verticallyFlipped:1;
        unsigned int hidesWhenPrinting:1;
        unsigned int _pad:26;
    } _gFlags;
    float _strokeWidth;
    NSColor *_fillColor;  // STRONG
    NSColor *_strokeColor;  // STRONG
    int _knobMask;
    
    FPDocumentView *_docView;
    BOOL _hasPage;
    unsigned int _page;
}

- (id)copyWithZone:(NSZone *)zone;
+ (FPGraphic *)graphicInDocumentView:(FPDocumentView *)docView;
- (id)initWithGraphic:(FPGraphic *)graphic;
- (id)initInDocumentView:(FPDocumentView *)docView;
+ (FPGraphic *)graphicFromArchivalDictionary:(NSDictionary *)dict
                              inDocumentView:(FPDocumentView *)docView;
- (id)initWithArchivalDictionary:(NSDictionary *)dict
                  inDocumentView:(FPDocumentView *)docView;
+ (NSString *)archivalClassName;
- (NSDictionary *)archivalDictionary;

- (BOOL)placeWithEvent:(NSEvent *)theEvent;
- (void)resizeWithEvent:(NSEvent *)theEvent byKnob:(int)knob;
- (void)moveGraphicByX:(float)x byY:(float)y;
- (void)reassignToPage:(unsigned int)page;

- (void)documentDidZoom;

- (unsigned int)page;

- (void)draw:(BOOL)selected;
- (void)drawKnobs;
- (int)knobForEvent:(NSEvent *)theEvent;
- (NSRect)pageRectForKnob:(int)knob isBoundRect:(BOOL)isBound;

- (BOOL)drawsStroke;
- (void)setDrawsStroke:(BOOL)drawsStroke;
- (NSRect)bounds;
- (void)setBounds:(NSRect)bounds;
- (NSRect)safeBounds;
- (NSRect)boundsWithKnobs;
- (float)strokeWidth;
- (void)setStrokeWidth:(float)strokeWidth;
- (NSColor *)strokeColor;
- (void)setStrokeColor:(NSColor *)strokeColor;
- (BOOL)drawsFill;
- (void)setDrawsFill:(BOOL)drawsFill;
- (NSColor *)fillColor;
- (void)setFillColor:(NSColor *)fillColor;
- (BOOL)isHorizontallyFlipped;
- (void)setIsHorizontallyFlipped:(BOOL)isHorizontallyFlipped;
- (BOOL)isVerticallyFlipped;
- (void)setIsVerticallyFlipped:(BOOL)isVerticallyFlipped;
- (BOOL)hidesWhenPrinting;
- (void)setHidesWhenPrinting:(BOOL)hidesWhenPrinting;

- (BOOL)isEditable;
- (void)startEditing;
- (void)stopEditing;

@end
