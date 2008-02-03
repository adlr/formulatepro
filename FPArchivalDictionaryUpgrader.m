//
//  FPArchivalDictionaryUpgrader.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 4/7/07.
//  Copyright 2007 Andrew de los Reyes. All rights reserved.
//

#import "FPArchivalDictionaryUpgrader.h"


@implementation FPArchivalDictionaryUpgrader

+ (int)currentVersion
{
    return 3;
}

+ (NSDictionary *)upgradeDictionary:(NSDictionary*)dict
                        fromVersion:(int)old_version
{
    NSMutableDictionary *ret = [dict mutableCopy];
    // upgrade from 1 -> 2 if necessary
    if (2 > old_version) {
        // in version 1, drawsFill and drawsStroke were set to NO, but they
        // were, in fact, drawn. here we change them to yes
        if (([[dict objectForKey:@"Graphic Class"] isEqualToString:@"Rectangle"]) ||
            ([[dict objectForKey:@"Graphic Class"] isEqualToString:@"Rectangle"])) {
            [ret setObject:[NSNumber numberWithBool:YES] forKey:@"drawsFill"];
            [ret setObject:[NSNumber numberWithBool:YES] forKey:@"drawsStroke"];
        }
    }
    // upgrade from 2 -> 3 if necessary
    if (3 > old_version) {
        // in versions 1 and 2, all graphics were sent to the printer.
        // staring in version 3, there is a BOOL to decide if graphics
        // get printed
        [ret setObject:[NSNumber numberWithBool:NO] forKey:@"hideWhenPrinting"];
    }
    return ret;
}

+ (void)upgradeGraphicsInPlace:(NSMutableArray *)arr
                   fromVersion:(int)old_version
{
    for (int i = 0; i < [arr count]; i++)
        [arr replaceObjectAtIndex:i withObject:
            [FPArchivalDictionaryUpgrader upgradeDictionary:[arr objectAtIndex:i]
                                                fromVersion:old_version]];
}

@end
