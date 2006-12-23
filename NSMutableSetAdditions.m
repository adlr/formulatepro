//
//  NSMutableSetAdditions.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 12/22/06.
//  Copyright 2006 Andrew de los Reyes. All rights reserved.
//

#import "NSMutableSetAdditions.h"


@implementation NSMutableSet ( NSMutableSetAdditions )

- (void)invertMembershipForObject:(id)anObject
{
    if ([self containsObject:anObject])
        [self removeObject:anObject];
    else
        [self addObject:anObject];
}

@end
