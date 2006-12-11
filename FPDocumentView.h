/* FPDocumentView */

#import <Cocoa/Cocoa.h>
#import <PDFKit/PDFKit.h>

@class FPGraphic;

@interface FPDocumentView : NSView
{
    PDFDocument *_pdf_document;
    PDFDisplayBox _box;
    float _scale_factor;

    NSMutableArray *_overlayGraphics;
    NSMutableSet *_selectedGraphics;
    FPGraphic *_editingGraphic;
}

- (void)setPDFDocument:(PDFDocument *)pdf_document;

- (void)zoomIn:(id)sender;
- (void)zoomOut:(id)sender;

- (float)scaleFactor;

// coordinate transforms
- (unsigned int)pageForPointFromEvent:(NSEvent *)theEvent;
- (NSPoint)pagePointForPointFromEvent:(NSEvent *)theEvent page:(unsigned int)page;
- (NSRect)convertRect:(NSRect)rect toPage:(unsigned int)page;
- (NSRect)convertRect:(NSRect)rect fromPage:(unsigned int)page;
- (NSPoint)convertPoint:(NSPoint)point toPage:(unsigned int)page;
- (NSPoint)convertPoint:(NSPoint)point fromPage:(unsigned int)page;

// private
- (NSAffineTransform *)transformForPage:(unsigned int)page;
@end
