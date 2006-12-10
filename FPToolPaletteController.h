/* FPToolPaletteController */

#import <Cocoa/Cocoa.h>

enum {
    FPToolArrow = 0,
    FPToolEllipse,
    FPToolRectangle,
    FPToolSquiggle,
    FPToolTextArea,
	FPToolTextField,
    FPToolCheckmark,
    FPToolStamp
};

@interface FPToolPaletteController : NSWindowController
{
    IBOutlet NSButton *arrowToolButton;
    IBOutlet NSButton *ellipseToolButton;
    IBOutlet NSButton *rectangleToolButton;
    IBOutlet NSButton *squiggleToolButton;
    IBOutlet NSButton *textAreaToolButton;
	IBOutlet NSButton *textFieldToolButton;
    IBOutlet NSButton *checkmarkToolButton;
    IBOutlet NSButton *stampToolButton;
}
+ (FPToolPaletteController*)sharedToolPaletteController;
- (IBAction)chooseTool:(id)sender;
- (unsigned int)currentTool;
- (Class)classForCurrentTool;
@end
