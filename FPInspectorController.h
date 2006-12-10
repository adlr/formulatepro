/* FPInspectorController */

#import <Cocoa/Cocoa.h>

@interface FPInspectorController : NSWindowController
{
    IBOutlet NSButton *_strokeCheckbox;
    IBOutlet NSButton *_fillCheckbox;
    IBOutlet NSColorWell *_fillColorWell;
    IBOutlet NSTextField *_widthLabel;
    IBOutlet NSStepper *_widthStepper;
    IBOutlet NSTextField *_widthTextField;
}
- (IBAction)checkFill:(id)sender;
- (IBAction)checkStroke:(id)sender;
- (IBAction)setStroke:(id)sender;
- (IBAction)stepStroke:(id)sender;

- (void)cascadeEnabledness;
@end
