/* FPToolPaletteController */

#import <Cocoa/Cocoa.h>

enum {
    FPToolArrow = 0,
    FPToolEllipse,
    FPToolRectangle,
    FPToolSquiggle,
    FPToolText,
    FPToolCheckmark,
    FPToolStamp
};

@interface FPToolPaletteController : NSWindowController
{
    IBOutlet NSButton *arrowToolButton;
    IBOutlet NSButton *ellipseToolButton;
    IBOutlet NSButton *rectangleToolButton;
    IBOutlet NSButton *squiggleToolButton;
    IBOutlet NSButton *textToolButton;
    IBOutlet NSButton *checkmarkToolButton;
    IBOutlet NSButton *stampToolButton;
}
- (IBAction)chooseTool:(id)sender;
@end
