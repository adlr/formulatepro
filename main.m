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
    // SInt32 os_version;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if (3 == argc && !strcmp("--feedUrl", argv[1])) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithUTF8String:argv[2]]
                                                  forKey:@"SUFeedURL"];
/*
 DEPRECATED
 'Gestalt' is deprecated: first deprecated in macOS 10.8
 'gestaltSystemVersion' is deprecated: first deprecated in macOS 10.8 - Use NSProcessInfo's operatingSystemVersion property instead.
 } else if (Gestalt(gestaltSystemVersion, &os_version) == noErr) {

 */
    } else {
        NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];

        NSString* major = [NSString stringWithFormat:@"%ld", version.majorVersion];
        NSString* minor = [NSString stringWithFormat:@"%ld", version.minorVersion];

        NSString *feedURL;
        NSString *appVersion =
            [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
/*
        char buf[5];
        sprintf(buf, "%0x", (unsigned)os_version);
        buf[3] = '\0'; // chop off minor version number
*/
        feedURL = [NSString stringWithFormat:
                   @"http://adlr.info/appcasts/formulatepro-%@%@-v%@.xml", major, minor, appVersion];
        NSLog(@"feed url: %@\n", feedURL);
        [[NSUserDefaults standardUserDefaults] setObject:feedURL
                                                  forKey:@"SUFeedURL"];
    }
    
    [pool release];
    return NSApplicationMain(argc, (const char **) argv);
}
