//
//  FPArchivalDictionaryUpgrader.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 4/7/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "FPArchivalDictionaryUpgrader.h"


@implementation FPArchivalDictionaryUpgrader

+ (int)currentVersion
{
    return 2;
}

+ (NSDictionary *)upgradeDictionary:(NSDictionary*)dict
                        fromVersion:(int)old_version
{
    NSMutableDictionary *ret = [dict mutableCopy];
    if (([[dict objectForKey:@"Graphic Class"] isEqualToString:@"Rectangle"]) ||
        ([[dict objectForKey:@"Graphic Class"] isEqualToString:@"Rectangle"])) {
        if (2 > old_version) {
            [ret setObject:[NSNumber numberWithBool:YES] forKey:@"drawsFill"];
            [ret setObject:[NSNumber numberWithBool:YES] forKey:@"drawsStroke"];
        }
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
