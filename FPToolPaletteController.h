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

extern NSString *FPToolChosen;

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
    
    NSArray *_buttonArray;
    BOOL _inQuickMove;
    unsigned int _toolBeforeQuickMove;
}
+ (FPToolPaletteController*)sharedToolPaletteController;
- (IBAction)chooseTool:(id)sender;
- (unsigned int)currentTool;
- (Class)classForCurrentTool;

- (void)keyDown:(NSEvent *)theEvent;

- (void)beginQuickMove:(id)unused;
- (void)endQuickMove:(id)unused;

@end
