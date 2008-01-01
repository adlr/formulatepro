/* FPInspectorController */

#import <Cocoa/Cocoa.h>

#import "FPDocumentWindow.h"
#import "MyDocument.h"

@interface FPInspectorController : NSWindowController
{
    IBOutlet NSButton *_strokeCheckbox;
    IBOutlet NSColorWell *_strokeColorWell;
    IBOutlet NSButton *_fillCheckbox;
    IBOutlet NSColorWell *_fillColorWell;
    IBOutlet NSTextField *_widthLabel;
    IBOutlet NSStepper *_widthStepper;
    IBOutlet NSTextField *_widthTextField;
    IBOutlet NSButton *_hideWhenPrinting;

    FPDocumentWindow *_main_window;
}
- (IBAction)checkFill:(id)sender;
- (IBAction)checkStroke:(id)sender;
- (IBAction)setStroke:(id)sender;
- (IBAction)stepStroke:(id)sender;
- (IBAction)checkHideWhenPrinting:(id)sender;

- (void)cascadeEnabledness;

//- (void)windowDidBecomeKey:(id)sender;
@end
