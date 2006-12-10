/* FPDocumentView */

#import <Cocoa/Cocoa.h>
#import <PDFKit/PDFKit.h>

@interface FPDocumentView : NSView
{
    PDFDocument *_pdf_document;
    PDFDisplayBox _box;
}

- (void)setPDFDocument:(PDFDocument *)pdf_document;

@end
