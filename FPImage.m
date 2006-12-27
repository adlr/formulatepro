//
//  FPImage.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 12/27/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "FPImage.h"


@implementation FPImage

- (id)initInDocumentView:(FPDocumentView *)docView
               withImage:(NSImage *)image;
{
    self = [super initInDocumentView:docView];
    if (self) {
        _image = image;
        [_image setCacheMode:NSImageCacheNever];
        _page = 0;
        [self setBounds:NSMakeRect(10.0,10.0,10.0,10.0)];
    }
    return self;
}

- (void)dealloc
{
    [_image release];
    [super dealloc];
}

- (void)draw
{
    [_image drawInRect:[self bounds]
              fromRect:NSZeroRect
             operation:NSCompositeSourceOver
              fraction:1.0]; // 1.0 means fully opaque
}


@end
