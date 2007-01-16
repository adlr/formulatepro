//
//  AppDelegate.h
//  FormulatePro
//
//  Created by Andrew de los Reyes on 7/5/06.
//  Copyright 2006 Andrew de los Reyes. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "FPTextRenderingView.h"

@interface AppDelegate : NSObject {
    IBOutlet NSWindow *_renderWindow;
    IBOutlet NSPanel *_inspectorWindow;
    IBOutlet NSMenuItem *_placeImageMenuItem;
    
    BOOL _lastEnable; // for _placeImageMenuItem
}
- (IBAction)showLicense:(id)sender;
- (IBAction)provideFeedback:(id)sender;
- (IBAction)viewBugList:(id)sender;
- (IBAction)fileNewBug:(id)sender;
- (NSWindow *)renderWindow;

- (IBAction)placeImage:(id)sender;

@end
