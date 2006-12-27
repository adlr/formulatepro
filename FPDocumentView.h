/* FPDocumentView */

#import <Cocoa/Cocoa.h>
#import <PDFKit/PDFKit.h>

@class FPGraphic;

@interface FPDocumentView : NSView
{
    PDFDocument *_pdf_document;
    PDFDisplayBox _box;
    float _scale_factor;
    BOOL _draws_shadow;
    BOOL _inQuickMove;

    NSMutableArray *_overlayGraphics;
    NSMutableSet *_selectedGraphics;
    FPGraphic *_editingGraphic;
}

- (void)setPDFDocument:(PDFDocument *)pdf_document;

- (void)zoomIn:(id)sender;
- (void)zoomOut:(id)sender;

- (float)scaleFactor;

- (BOOL)shouldEnterQuickMove;
- (void)beginQuickMove:(id)unused;
- (void)endQuickMove:(id)unused;

- (void)deleteKeyPressed;

// place image
- (void)placeImage:(id)sender;

// coordinate transforms
- (unsigned int)pageForPointFromEvent:(NSEvent *)theEvent;
- (NSPoint)pagePointForPointFromEvent:(NSEvent *)theEvent
                                 page:(unsigned int)page;
- (NSRect)convertRect:(NSRect)rect toPage:(unsigned int)page;
- (NSRect)convertRect:(NSRect)rect fromPage:(unsigned int)page;
- (NSPoint)convertPoint:(NSPoint)point toPage:(unsigned int)page;
- (NSPoint)convertPoint:(NSPoint)point fromPage:(unsigned int)page;

// printing
- (FPDocumentView *)printableCopy;
- (NSRect)rectForPage:(int)page; // indexed from 1, not 0

// private
- (NSAffineTransform *)transformForPage:(unsigned int)page;
@end
