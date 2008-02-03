//
//  FPTipsController.h
//  FormulatePro
//
//  Created by Andrew de los Reyes on 9/3/07.
//  Copyright 2007 Andrew de los Reyes. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FPTipsController : NSObject {
    NSArray *_tips;
    unsigned int _tipOnDisplay;
    IBOutlet NSTextField *_tipTextField;
    IBOutlet NSWindow *_tipWindow;
}

- (IBAction)nextTip:(id)sender;
- (IBAction)previousTip:(id)sender;

@end
