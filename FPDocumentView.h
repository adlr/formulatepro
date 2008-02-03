/* FPDocumentView */

#import <Cocoa/Cocoa.h>
#import <PDFKit/PDFKit.h>

@class FPGraphic;
@class MyDocument;

// this can be bound to an (ordered) collection of FPGraphic objects and to an index set.
extern NSString *FPDocumentViewGraphicsBindingName;
extern NSString *FPDocumentViewSelectionIndexesBindingName;

//#define FPSelectionChangedNotification @"FPSelectionChangedNotification"

@interface FPDocumentView : NSView
{
    PDFDocument *_pdf_document;  // STRONG
    unsigned int _current_page;
    PDFDisplayBox _box;
    BOOL _draws_shadow;
    BOOL _inQuickMove;
    BOOL _is_printing;

    NSObject *_graphicsContainer;
    NSString *_graphicsKeyPath;
    NSObject *_selectionIndexesContainer;
    NSString *_selectionIndexesKeyPath;

    FPGraphic *_editingGraphic;
    
    // For zooming
    IBOutlet NSScrollView *_scrollView;
}

// frame size
- (NSRect)idealFrame;

// Bindings

- (void)bind:(NSString *)bindingName
    toObject:(id)observableObject
 withKeyPath:(NSString *)observableKeyPath
     options:(NSDictionary *)options;

- (void)unbind:(NSString *)bindingName;

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(NSObject *)observedObject
                        change:(NSDictionary *)change
                       context:(void *)context;

- (void)startObservingGraphics:(NSArray *)graphics;
- (void)stopObservingGraphics:(NSArray *)graphics;

// convenience

// never returns nil
- (NSArray *)graphics;
// never returns nil
- (NSMutableArray *)mutableGraphics;
// never returns nil
- (NSIndexSet *)selectionIndexes;

// drawing

- (void)drawRect:(NSRect)rect;
- (void)drawHandleAtPoint:(NSPoint)point;

// Other methods

- (void)setPDFDocument:(PDFDocument *)pdf_document;

//- (void)zoomIn:(id)sender;
//- (void)zoomOut:(id)sender;

//- (void)nextPage;
//- (void)previousPage;
//- (void)scrollToPage:(unsigned int)page;

//- (float)scaleFactor;

//- (void)stopEditing;

//- (BOOL)shouldEnterQuickMove;
//- (void)beginQuickMove:(id)unused;
//- (void)endQuickMove:(id)unused;

//- (unsigned int)getViewingMidpointToPage:(unsigned int*)page pagePoint:(NSPoint*)pagePoint;
//- (void)scrollToMidpointOnPage:(unsigned int)page point:(NSPoint)midPoint;

// place image
//- (IBAction)placeImage:(id)sender;

// coordinate transforms
//- (unsigned int)pageForPointFromEvent:(NSEvent *)theEvent;
//- (unsigned int)pageForPoint:(NSPoint)point;
//- (NSPoint)pagePointForPointFromEvent:(NSEvent *)theEvent
//                                 page:(unsigned int)page;
//- (NSRect)convertRect:(NSRect)rect toPage:(unsigned int)page;
//- (NSRect)convertRect:(NSRect)rect fromPage:(unsigned int)page;
//- (NSPoint)convertPoint:(NSPoint)point toPage:(unsigned int)page;
//- (NSPoint)convertPoint:(NSPoint)point fromPage:(unsigned int)page;

// printing
//- (FPDocumentView *)printableCopy;
//- (NSRect)rectForPage:(int)page; // indexed from 1, not 0

// opening and saving
//- (NSArray *)archivalOverlayGraphics;
//- (void)setOverlayGraphicsFromArray:(NSArray *)arr;

// font
- (NSFont *)currentFont;

// private
- (NSAffineTransform *)transformForPage:(unsigned int)page;
@end
