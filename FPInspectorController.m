#import "FPInspectorController.h"
#import "FPDocumentView.h"
#import "FPLogging.h"

@implementation FPInspectorController

- (void)awakeFromNib
{
    [(NSPanel *)[self window] setFloatingPanel:YES];
    [(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];
    [self cascadeEnabledness];
    
//    [[NSNotificationCenter defaultCenter]
//        addObserver:self
//           selector:@selector(windowDidBecomeKey:)
//               name:NSWindowDidBecomeKeyNotification
//             object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mainWindowChanged:)
                                                 name:NSWindowDidBecomeMainNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mainWindowResigned:)
                                                 name:NSWindowDidResignMainNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectionChangedNotification:)
                                                 name:FPSelectionChangedNotification
                                               object:nil];    
    
    _main_window = nil;
}

- (void)cascadeEnabledness
{
    BOOL doStroke = ([_strokeCheckbox state] == NSOnState);
    [_widthTextField setEnabled:doStroke];
    [_widthStepper setEnabled:doStroke];
    [_strokeColorWell setEnabled:doStroke];
    if (doStroke) {
        [_widthTextField setTextColor:[NSColor blackColor]];
        [_widthLabel setTextColor:[NSColor blackColor]];
    } else {
        [_widthTextField setTextColor:[NSColor grayColor]];
        [_widthLabel setTextColor:[NSColor grayColor]];
    }
    
    BOOL doFill = ([_fillCheckbox state] == NSOnState);
    [_fillColorWell setEnabled:doFill];
}

- (IBAction)checkFill:(id)sender
{
    [self cascadeEnabledness];
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

- (IBAction)checkHideWhenPrinting:(id)sender;
{
}

- (void)disableAllGraphics
{
    [_strokeCheckbox setEnabled:NO];
    [_strokeColorWell setEnabled:NO];
    [_fillCheckbox setEnabled:NO];
    [_fillColorWell setEnabled:NO];
    [_widthLabel setTextColor:[NSColor grayColor]];
    [_widthStepper setEnabled:NO];
    [_widthTextField setEnabled:NO];
    [_hideWhenPrinting setEnabled:NO];
}

- (void)enableAllGraphics
{
    [_strokeCheckbox setEnabled:YES];
    [_strokeColorWell setEnabled:YES];
    [_fillCheckbox setEnabled:YES];
    [_fillColorWell setEnabled:YES];
    [_widthLabel setTextColor:[NSColor blackColor]];
    [_widthStepper setEnabled:YES];
    [_widthTextField setEnabled:YES];
    [_hideWhenPrinting setEnabled:YES];
}

- (void)updateFromSelectedGraphics
{
    if (!_main_window) {
        // disable all controls
        [self disableAllGraphics];
        return;
    }
    NSSet *selectedGraphics = [[_main_window docView] selectedGraphics];
    if (0 == [selectedGraphics count]) {
        // disable all controls
        [self disableAllGraphics];
        return;
    }
    if (1 == [selectedGraphics count]) {
        // enable all controls
        [self enableAllGraphics];
        
//        FPGraphic *graphic = [selectedGraphics anyObject];
        
        return;
    }
}

- (void)selectionOrMainWindowChanged
{
    DLog(@"there are %d graphics selected", [[[_main_window docView] selectedGraphics] count]);
    [self updateFromSelectedGraphics];
}

- (void)selectionChangedNotification:(NSNotification *)notification
{
    DLog(@"selection did change\n");
    assert([FPDocumentWindow class] == [[notification object] class]);
    FPDocumentWindow *window = [notification object];
    if (window == _main_window)
        [self selectionOrMainWindowChanged];
}

//- (void)windowDidBecomeKey:(id)sender
//{
//    DLog(@"window did become key: 0x%08x\n", (int)sender);
//    
//    DLog(@"docs:\n");
//    NSArray *docs = [NSApp orderedDocuments];
//    for (int i = 0; i < [docs count]; i++) {
//        DLog(@"%i of %i: 0x%08x\n", i, [docs count], [docs objectAtIndex:i]);
//    }
//    
//    MyDocument *new_frontmost_doc = nil;
////    if ([docs count])
////        new_frontmost_doc = [docs objectAtIndex:0];
//    if ([NSApp mainWindow])
//        new_frontmost_doc = [[[NSApp mainWindow] windowController] document];
//    
//    if (new_frontmost_doc != _frontmost_document) {
//        _frontmost_document = new_frontmost_doc;
//        [self selectionDidChange];
//    }
//}

- (void)mainWindowChanged:(NSNotification *)notification
{
    DLog(@"got main window: 0x%08x\n", [notification object]);
    if ([FPDocumentWindow class] == [[notification object] class]) {
        _main_window = (FPDocumentWindow *)[notification object];
        [self selectionOrMainWindowChanged];
    }
}

- (void)mainWindowResigned:(NSNotification *)notification
{
    DLog(@"lost main window: 0x%08x\n", [notification object]);
    if ([FPDocumentWindow class] == [[notification object] class]) {
        _main_window = nil;
        [self selectionOrMainWindowChanged];
    }
}

@end
