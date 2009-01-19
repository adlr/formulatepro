//
//  FPTipsController.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 9/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "FPTipsController.h"
#import "FPLogging.h"

static NSString *kFPShowTipsAtStartup = @"FPShowTipsAtStartup";
static NSString *kFPNextToolTip = @"FPNextToolTip";

@implementation FPTipsController

+ (void)initialize
{
    NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithBool:YES],kFPShowTipsAtStartup,
        [NSNumber numberWithUnsignedInt:0],kFPNextToolTip,
        nil,nil];
    [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaults];
}

- (unsigned int)getNextTipIndexFromDefaults
{
    id dict = [[NSUserDefaultsController sharedUserDefaultsController] values];
    return [(NSNumber*)[dict valueForKey:kFPNextToolTip] unsignedIntValue];
}

- (void)setNextTipIndexToDefaults:(unsigned int)nextTip;
{
//    NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
//        [NSNumber numberWithUnsignedInt:nextTip],kFPNextToolTip,
//        nil,nil];
    id values = [[NSUserDefaultsController sharedUserDefaultsController] values];
    [values setValue:[NSNumber numberWithUnsignedInt:nextTip] forKey:kFPNextToolTip];
//    [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaults];
//    DLog(@"about to save\n");
//    [(NSUserDefaultsController*)[NSUserDefaultsController sharedUserDefaultsController] save:self];
//    DLog(@"saved\n");
}

- (void)displayTip:(unsigned int)tip
{
    if (tip >= [_tips count])
        tip = 0;
    [_tipTextField setStringValue:[_tips objectAtIndex:tip]];
    tip++;
    if (tip >= [_tips count])
        tip = 0;
    [self setNextTipIndexToDefaults:tip];
}

- (void)awakeFromNib
{
    _tips = nil;
    id values = [[NSUserDefaultsController sharedUserDefaultsController] values];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"tips" ofType:@"plist"];
    if (nil == path) {
        NSLog(@"unable to locate tips.plist\n");
        return;
    }
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (nil == data) {
        NSLog(@"unable to load tips.plist\n");
        return;
    }
    _tips = [NSPropertyListSerialization propertyListFromData:data
                                            mutabilityOption:NSPropertyListImmutable
                                                      format:nil
                                            errorDescription:nil];
    [_tips retain];
    _tipOnDisplay = [self getNextTipIndexFromDefaults];
    [self displayTip:_tipOnDisplay];
    if (NO == [[values valueForKey:kFPShowTipsAtStartup] boolValue])
        return;
    [_tipWindow center];
    [_tipWindow makeKeyAndOrderFront:self];
}

- (IBAction)nextTip:(id)sender
{
    _tipOnDisplay++;
    if (_tipOnDisplay >= [_tips count])
        _tipOnDisplay = 0;
    [self displayTip:_tipOnDisplay];
}

- (IBAction)previousTip:(id)sender
{
    if (_tipOnDisplay == 0)
        _tipOnDisplay = [_tips count];
    _tipOnDisplay--;
    [self displayTip:_tipOnDisplay];
}

- (IBAction)showExportAsPDFTip:(id)sender
{
    [self displayTip:2];
    [_tipWindow center];
    [_tipWindow makeKeyAndOrderFront:self];
}

- (void)windowWillClose:(NSNotification *)aNotification
{
}

@end
