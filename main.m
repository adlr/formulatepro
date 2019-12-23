//
//  main.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 7/4/06.
//  Copyright Andrew de los Reyes 2006. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
    // before anything else, set the appcast url
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if (3 == argc && !strcmp("--feedUrl", argv[1])) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithUTF8String:argv[2]]
                                                  forKey:@"SUFeedURL"];
    } else {
        NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];

        NSString* major = [NSString stringWithFormat:@"%ld", version.majorVersion];
        NSString* minor = [NSString stringWithFormat:@"%ld", version.minorVersion];

        NSString *feedURL;
        NSString *appVersion =
            [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];

        feedURL = [NSString stringWithFormat:
                   @"http://adlr.info/appcasts/formulatepro-%@%@-v%@.xml", major, minor, appVersion];
        NSLog(@"feed url: %@\n", feedURL);
        [[NSUserDefaults standardUserDefaults] setObject:feedURL
                                                  forKey:@"SUFeedURL"];
    }
    
    [pool release];
    return NSApplicationMain(argc, (const char **) argv);
}
