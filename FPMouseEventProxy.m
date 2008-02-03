//
//  FPMouseEventProxy.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 1/21/08.
//  Copyright 2008 Andrew de los Reyes. All rights reserved.
//

#import "FPMouseEventProxy.h"


@implementation FPMouseEventProxy

- (id)initFixedToInitialPage:(BOOL)fixedToInitialPage
{
    return [super init];
}

// returns true if another usable event came in
- (BOOL)waitForNextEvent
{
    return false;
}

- (NSPoint)point
{
    return NSMakePoint(0.0, 0.0);
}
- (unsigned int)page
{
    return 0;
}


@end
