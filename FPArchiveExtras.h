//
//  FPArchiveExtras.h
//  FormulatePro
//
//  Created by Andrew de los Reyes on 1/2/07.
//  Copyright 2007 Andrew de los Reyes. All rights reserved.
//

static inline NSArray *arrayFromRect(NSRect r)
{
    return [NSArray arrayWithObjects:[NSNumber numberWithFloat:r.origin.x],
                                     [NSNumber numberWithFloat:r.origin.y],
                                     [NSNumber numberWithFloat:r.size.width],
                                     [NSNumber numberWithFloat:r.size.height],
                                     nil];
}

static inline NSRect rectFromArray(NSArray *a)
{
    return NSMakeRect([[a objectAtIndex:0] floatValue],
                      [[a objectAtIndex:1] floatValue],
                      [[a objectAtIndex:2] floatValue],
                      [[a objectAtIndex:3] floatValue]);
}
