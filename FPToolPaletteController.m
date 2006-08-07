#import "FPToolPaletteController.h"

#import "FPRectangle.h"
#import "FPEllipse.h"
#import "FPSquiggle.h"

@implementation FPToolPaletteController

static FPToolPaletteController *_sharedController;

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

- (void)awakeFromNib
{
    _sharedController = self;
}

+ (FPToolPaletteController *)sharedToolPaletteController
{
    return _sharedController;
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
    if ([arrowToolButton state] == NSOnState) return FPToolArrow;
    if ([ellipseToolButton state] == NSOnState) return FPToolEllipse;
    if ([squiggleToolButton state] == NSOnState) return FPToolSquiggle;
    return FPToolRectangle;
}

- (Class)classForCurrentTool
{
    switch ([self currentTool]) {
        case FPToolEllipse: NSLog(@"ellispe\n"); return [FPEllipse class];
        case FPToolRectangle: NSLog(@"rect\n"); return [FPRectangle class];
        case FPToolSquiggle: NSLog(@"squiggle\n"); return [FPSquiggle class];
    }
    return [FPRectangle class];
}

@end
