//
//  FPArchivalDictionaryUpgrader.h
//  FormulatePro
//
//  Created by Andrew de los Reyes on 4/7/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FPArchivalDictionaryUpgrader : NSObject { }


+ (int)currentVersion;
+ (NSDictionary *)upgradeDictionary:(NSDictionary*)dict
                        fromVersion:(int)old_version;
+ (void)upgradeGraphicsInPlace:(NSMutableArray *)arr
                   fromVersion:(int)old_version;

@end
