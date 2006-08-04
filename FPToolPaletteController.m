#import "FPToolPaletteController.h"

@implementation FPToolPaletteController

- (void)windowDidLoad {
    [super windowDidLoad];
    [arrowToolButton setRefusesFirstResponder:YES];
    [ellipseToolButton setRefusesFirstResponder:YES];
    [rectangleToolButton setRefusesFirstResponder:YES];
    [squiggleToolButton setRefusesFirstResponder:YES];
    [textToolButton setRefusesFirstResponder:YES];
    [(NSPanel *)[self window] setFloatingPanel:YES];
    [(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];
}

- (IBAction)chooseTool:(id)sender
{
    [arrowToolButton setState:NSOffState];
    [ellipseToolButton setState:NSOffState];
    [rectangleToolButton setState:NSOffState];
    [squiggleToolButton setState:NSOffState];
    [textToolButton setState:NSOffState];
    [checkmarkToolButton setState:NSOffState];
    [stampToolButton setState:NSOffState];
    [sender setState:NSOnState];
}

- (unsigned int)currentTool
{
    return 0;
}

@end
