//
//  FPGraphic.h
//  FormulatePro
//
//  Created by Andrew de los Reyes on 7/5/06.
//  Copyright 2006 Andrew de los Reyes. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MyPDFView.h"

enum {
    NoKnob = 0,
    UpperLeftKnob,
    UpperMiddleKnob,
    UpperRightKnob,
    MiddleLeftKnob,
    MiddleRightKnob,
    LowerLeftKnob,
    LowerMiddleKnob,
    LowerRightKnob,
};

@interface FPGraphic : NSObject {
    NSRect _bounds;
    NSRect _origBounds; // for bulk move operations
    struct __gFlags {
        unsigned int drawsFill:1;
        unsigned int drawsStroke:1;
        unsigned int manipulatingBounds:1;
        unsigned int _pad:29;
    } _gFlags;
    float _lineWidth;
    NSColor *_fillColor;
    NSColor *_strokeColor;
    
    MyPDFView *_pdfView;
    PDFPage *_page;
}

+ (FPGraphic *)graphicInPDFView:(MyPDFView *)pdfView;
- (FPGraphic *)initInPDFView:(MyPDFView *)pdfView;

- (BOOL)placeWithEvent:(NSEvent *)theEvent;

- (PDFPage *)page;
- (void)draw;
- (NSRect)safeBounds;
- (float)lineWidth;
- (NSRect)bounds;

- (void)resizeWithEvent:(NSEvent *)theEvent byKnob:(int)knob;

//- (void)setBounds:(NSRect)bounds;
//- (NSRect)bounds;
//- (int)resizeByMovingKnob:(int)knob toPoint:(NSPoint)point maintainAspectRatio:(BOOL)maintain_ar;

@end
