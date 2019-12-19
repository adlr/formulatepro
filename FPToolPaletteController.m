#import "FPToolPaletteController.h"
#import "FPDocumentWindow.h"

#import "FPRectangle.h"
#import "FPEllipse.h"
#import "FPSquiggle.h"
#import "FPTextAreaB.h"
#import "FPCheckmark.h"

NSString *FPToolChosen = @"FPToolChosen";

@implementation FPToolPaletteController

static FPToolPaletteController *_sharedController;

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [_buttonArray
        makeObjectsPerformSelector:@selector(setRefusesFirstResponder:)
                        withObject:(id)YES];
    
//    [arrowToolButton setRefusesFirstResponder:YES];
//    [ellipseToolButton setRefusesFirstResponder:YES];
//    [rectangleToolButton setRefusesFirstResponder:YES];
//    [squiggleToolButton setRefusesFirstResponder:YES];
//    [textAreaToolButton setRefusesFirstResponder:YES];
//    [(NSPanel *)[self window] setFloatingPanel:YES];
    [(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];
}

- (void)awakeFromNib
{
    [(NSPanel *)[self window] setFloatingPanel:YES];
    [(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];
    _buttonArray = [NSArray arrayWithObjects:arrowToolButton,
                                             ellipseToolButton,
                                             rectangleToolButton,
                                             squiggleToolButton,
                                             textAreaToolButton,
                                             textFieldToolButton,
                                             checkmarkToolButton,
                                             stampToolButton,
                                             nil];
    [_buttonArray retain];
    assert([_buttonArray count] > 0);
    _sharedController = self;
    _inQuickMove = NO;
    _toolBeforeQuickMove = 0;
    [[NSNotificationCenter defaultCenter]
        addObserver:self selector:@selector(beginQuickMove:)
        name:FPBeginQuickMove object:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:self selector:@selector(abortQuickMove:)
        name:FPAbortQuickMove object:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:self selector:@selector(endQuickMove:)
        name:FPEndQuickMove object:nil];
}

+ (FPToolPaletteController *)sharedToolPaletteController
{
    return _sharedController;
}

- (IBAction)chooseTool:(id)sender
{
/*
 DEPRECATED
 'NSOffState' is deprecated: first deprecated in macOS 10.14
 'NSOnState' is deprecated: first deprecated in macOS 10.14
 */
    [_buttonArray makeObjectsPerformSelector:@selector(setState:)
                                  withObject:(id)NSControlStateValueOff];
    [sender setState:NSControlStateValueOn];
    [[NSNotificationCenter defaultCenter] postNotification:
        [NSNotification notificationWithName:FPToolChosen
                                      object:self]];
}

- (unsigned int)currentTool
{
/*
 DEPRECATED
 'NSOnState' is deprecated: first deprecated in macOS 10.14
 */
    for (unsigned int i = 0; i < [_buttonArray count]; i++) {
        NSButton *b = [_buttonArray objectAtIndex:i];
        DLog(@"button = 0x%08x\n", (unsigned)b);
        if ([[_buttonArray objectAtIndex:i] state] == NSControlStateValueOn)
            return i;
    }
    assert(0);
    return FPToolRectangle;
}

- (Class)classForCurrentTool
{
    switch ([self currentTool]) {
        case FPToolEllipse: DLog(@"ellispe\n"); return [FPEllipse class];
        case FPToolRectangle: DLog(@"rect\n"); return [FPRectangle class];
        case FPToolSquiggle: DLog(@"squiggle\n"); return [FPSquiggle class];
        case FPToolTextArea: DLog(@"text area\n"); return [FPTextAreaB class];
        case FPToolCheckmark: DLog(@"checkmark\n"); return [FPCheckmark class];
        //case FPToolTextField: DLog(@"text field\n"); return [FPTextField class];
    }
    return [FPRectangle class];
}

- (void)keyDown:(NSEvent *)theEvent
{
    if (1 != [[theEvent charactersIgnoringModifiers] length])
        return;
    // we don't want any modifiers, except numeric pad is okay
/*
 DEPRECATED
 'NSDeviceIndependentModifierFlagsMask' is deprecated: first deprecated in macOS 10.12
 'NSNumericPadKeyMask' is deprecated: first deprecated in macOS 10.12
 */
    if ((NSEventModifierFlagDeviceIndependentFlagsMask ^ NSEventModifierFlagNumericPad) & [theEvent modifierFlags]) {
        return;
    }
    unichar c = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    switch (c) {
        case 't':
            [self chooseTool:textAreaToolButton];
            break;
        case 'm':
            [self chooseTool:arrowToolButton];
            break;
        case 'e':
            [self chooseTool:ellipseToolButton];
            break;
        case 'u':
            [self chooseTool:rectangleToolButton];
            break;
        case 'p':
            [self chooseTool:squiggleToolButton];
            break;
        case 'x':
            [self chooseTool:checkmarkToolButton];
            break;
    }
}

- (void)beginQuickMove:(id)unused
{
    _toolBeforeQuickMove = [self currentTool];
    [_buttonArray makeObjectsPerformSelector:@selector(setEnabled:)
                                  withObject:(id)NO];
    [arrowToolButton setEnabled:YES];
    [self chooseTool:arrowToolButton];
    _inQuickMove = YES;
}

- (void)abortQuickMove:(id)unused
{
    [_buttonArray makeObjectsPerformSelector:@selector(setEnabled:)
                                  withObject:(id)YES];
    [self chooseTool:[_buttonArray objectAtIndex:FPToolArrow]];
    _inQuickMove = NO;
}

- (void)endQuickMove:(id)unused
{
    if (NO == _inQuickMove) return;
    [_buttonArray makeObjectsPerformSelector:@selector(setEnabled:)
                                  withObject:(id)YES];
    [self chooseTool:[_buttonArray objectAtIndex:_toolBeforeQuickMove]];
}

@end
