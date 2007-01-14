//
//  NSMutableDictionaryAdditions.h
//  FormulatePro
//
//  Created by Andrew de los Reyes on 1/2/07.
//  Copyright 2007 Andrew de los Reyes. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSMutableDictionary ( NSMutableDictionaryAdditions )

- (void)setObject:(id)anObject forNonexistentKey:(id)aKey;

@end
