//
//  AppDelegate.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 7/5/06.
//  Copyright 2006 Andrew de los Reyes. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

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

- (IBAction)viewBugList:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:
        [NSURL
         URLWithString:@"http://code.google.com/p/formulatepro/issues/list"]];
}

- (IBAction)fileNewBug:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:
     [NSURL
      URLWithString:@"http://code.google.com/p/formulatepro/issues/entry"]];
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
    DLog(@"reps %d\n", i, [[arrow representations] count]);
    d = [[arrow bestRepresentationForDevice:nil]
        representationUsingType:NSTIFFFileType
                     properties:nil];
    DLog(@"d = %x\n", d);
    pb = [NSPasteboard generalPasteboard];
    [pb declareTypes:[NSArray arrayWithObject:NSTIFFPboardType] owner:nil];
    DLog(@"ok? %d\n", [pb setData:d forType:NSTIFFPboardType]);*/
}

@end
