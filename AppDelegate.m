//
//  AppDelegate.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 7/5/06.
//  Copyright 2006 Andrew de los Reyes. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (Private)
- (void)choosePaletteButton:(NSButton *)button;
@end

@implementation AppDelegate

- (void)awakeFromNib
{
    _lastEnable = YES; // menu items start out enabled in IB
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)application
{
    return NO;
}

- (IBAction)showLicense:(id)sender
{
    NSString *path;
    path = [[NSBundle mainBundle] pathForResource:@"LICENSE" ofType:@"txt"];
    [[NSWorkspace sharedWorkspace] openFile:path];
}

- (IBAction)provideFeedback:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:
        [NSURL URLWithString:@"mailto:formulate@adlr.info"]];
}

- (NSWindow *)renderWindow
{
    return _renderWindow;
}

- (void)applicationDidUpdate:(NSNotification *)aNotification
{
    BOOL enable = NO;
    if ([[NSApp orderedDocuments] count] > 0) {
        enable = YES;
    }
    if (_lastEnable == enable) return;
    [_placeImageMenuItem setAction:(enable ? @selector(placeImage:) : nil)];
    _lastEnable = enable;
}

- (IBAction)placeImage:(id)sender
{
    assert([[NSApp orderedDocuments] count] > 0);
    [[[NSApp orderedDocuments] objectAtIndex:0] placeImage:sender];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    /* // this code copies the arrow cursor image to the clipboard
    NSImage *arrow;
    int i;
    NSData *d;
    NSPasteboard *pb;
    
    [arrowToolButton setImage:[[NSCursor arrowCursor] image]];
    arrow = [[NSCursor arrowCursor] image];
    NSLog(@"reps %d\n", i, [[arrow representations] count]);
    d = [[arrow bestRepresentationForDevice:nil]
        representationUsingType:NSTIFFFileType
                     properties:nil];
    NSLog(@"d = %x\n", d);
    pb = [NSPasteboard generalPasteboard];
    [pb declareTypes:[NSArray arrayWithObject:NSTIFFPboardType] owner:nil];
    NSLog(@"ok? %d\n", [pb setData:d forType:NSTIFFPboardType]);*/
}

@end
