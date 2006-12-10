#import "FPInspectorController.h"

@implementation FPInspectorController

- (void)awakeFromNib
{
    [(NSPanel *)[self window] setFloatingPanel:YES];
    [(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];
}

- (void)cascadeEnabledness
{
    BOOL doStroke = ([_strokeCheckbox state] == NSOnState);
    [_widthLabel setEnabled:doStroke];
    [_widthTextField setEnabled:doStroke]; // TODO: fix this
    [_widthStepper setEnabled:doStroke];
}

- (IBAction)checkFill:(id)sender
{
}

- (IBAction)checkStroke:(id)sender
{
    [self cascadeEnabledness];
}

- (IBAction)setStroke:(id)sender
{
}

- (IBAction)stepStroke:(id)sender
{
}

@end
