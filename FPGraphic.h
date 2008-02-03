//
//  FPGraphic.h
//  FormulatePro
//
//  Created by Andrew de los Reyes on 7/5/06.
//  Copyright 2006 Andrew de los Reyes. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FPDocumentView.h"

// KVC keys
extern NSString *FPGraphicBoundsKey;
extern NSString *FPGraphicPageKey;
extern NSString *FPGraphicDrawsFillKey;
extern NSString *FPGraphicDrawsStrokeKey;
extern NSString *FPGraphicHorizontallyFlippedKey;
extern NSString *FPGraphicVerticallyFlippedKey;
extern NSString *FPGraphicHidesWhenPrintingKey;
extern NSString *FPGraphicStrokeWidthKey;
extern NSString *FPGraphicFillColorKey;
extern NSString *FPGraphicStrokeColorKey;

// listeners on FPGraphicDrawingBoundsKey will be KVO-triggered
// whenever any property of the object changes that causes it
// to move.
extern NSString *FPGraphicDrawingBoundsKey;
// listeners on FPGraphicDrawingContentsKey will be KVO-triggered
// when the content changes, but the graphic doesn't move
extern NSString *FPGraphicDrawingContentsKey;

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
    BOOL _assignedToPage;
    NSRect _bounds;  // bounds on page
    unsigned int _page;  // which page

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
}

- (id)copyWithZone:(NSZone *)zone;
+ (FPGraphic *)graphic;
- (id)initWithGraphic:(FPGraphic *)graphic;
- (id)init;
+ (FPGraphic *)graphicFromArchivalDictionary:(NSDictionary *)dict;
- (id)initWithArchivalDictionary:(NSDictionary *)dict;
+ (NSString *)archivalClassName;
- (NSDictionary *)archivalDictionary;

- (NSString *)className;

// Utility functions
// these will trigger KVO notifications for KVC keys

//- (BOOL)placeWithEvent:(FPMouseEventProxy *)eventProxy;
//- (void)resizeWithEvent:(NSEvent *)theEvent byKnob:(int)knob;
- (void)moveGraphicByX:(float)x byY:(float)y;
- (void)setOrigin:(NSPoint)origin;

// these functions return YES if the set caused the graphic to flip
- (BOOL)setLeftAbs:(float)position;
- (BOOL)setRightAbs:(float)position;
- (BOOL)setTopAbs:(float)position;
- (BOOL)setBottomAbs:(float)position;

- (int)knobMask;

// called so subclasses can cope. default implementation does nothing
- (void)documentDidZoom;

- (unsigned int)page;
- (void)setPage:(unsigned int)page;

- (void)draw:(BOOL)selected;
//- (void)drawKnobs;
//- (int)knobForEvent:(NSEvent *)theEvent;
//- (NSRect)pageRectForKnob:(int)knob isBoundRect:(BOOL)isBound;

- (NSRect)safeBounds;

// KVC compliant setters/getters

- (BOOL)drawsStroke;
- (void)setDrawsStroke:(BOOL)drawsStroke;
- (NSRect)bounds;
- (void)setBounds:(NSRect)bounds;
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

// only for getting, not setting
- (NSRect)drawingBounds;

// Editing

- (BOOL)isEditable;
- (void)startEditing;
- (void)stopEditing;

@end
