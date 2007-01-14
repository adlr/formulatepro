//
//  NSMutableDictionaryAdditions.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 1/2/07.
//  Copyright 2007 Andrew de los Reyes. All rights reserved.
//

#import "NSMutableDictionaryAdditions.h"


@implementation NSMutableDictionary ( NSMutableDictionaryAdditions )

- (void)setObject:(id)anObject forNonexistentKey:(id)aKey
{
    // TODO(adlr): do something nicer, like throw an exception
    assert(nil == [self objectForKey:aKey]);
    [self setObject:anObject forKey:aKey];
}

@end
