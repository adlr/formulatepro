//
//  AOSegmentedControl.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 8/15/06.
//  Copyright 2006 Andrew de los Reyes. All rights reserved.
//

#import "AOSegmentedControl.h"


#define NSSegmentedCellAquaStyle 1    // Like the tabs in an NSTabView.
#define NSSegmentedCellMetalStyle 2    // Like the Safari and Finder buttons.

@interface NSSegmentedCell ( Private )
- (void)_setSegmentedCellStyle:(int)style;
@end

@implementation AOSegmentedControl

- (void)awakeFromNib
{
    // 26 is the height of normal-sized segmented control:
    [self setFrameSize:NSMakeSize([self frame].size.width, 26)];
}

- (NSCell *)cell
{
    NSSegmentedCell *cell = [super cell];
    //[cell setControlSize:NSRegularControlSize];
    [cell _setSegmentedCellStyle:NSSegmentedCellMetalStyle];
    return cell;
}

@end