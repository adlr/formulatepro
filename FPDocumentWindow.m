//
//  FPDocumentWindow.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 12/17/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "FPDocumentWindow.h"


@implementation FPDocumentWindow

- (void)keyDown:(NSEvent *)theEvent
{
    //if ([theEvent modifierFlags]) return;
    //[theEvent keyCode]
    NSLog(@"fp doc window got keys: [%@][%x][%x]\n", [theEvent charactersIgnoringModifiers],
    (unsigned)[[theEvent charactersIgnoringModifiers] characterAtIndex:0],
    (unsigned)NSDeleteFunctionKey);
}

- (void)flagsChanged:(NSEvent *)theEvent
{
    NSLog(@"flags changed\n");
    if (([theEvent modifierFlags] & NSAlternateKeyMask) &&
        ([theEvent modifierFlags] & NSCommandKeyMask)) {
        NSLog(@"got apple-option\n");
    } else {
        NSLog(@"don't got apple-option\n");
    }
}

@end
