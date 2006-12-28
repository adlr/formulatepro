//
//  FPImage.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 12/27/06.
//  Copyright 2006 Andrew de los Reyes. All rights reserved.
//

#import "FPImage.h"


@implementation FPImage

- (id)initInDocumentView:(FPDocumentView *)docView
               withImage:(NSImage *)image;
{
    self = [super initInDocumentView:docView];
    if (self) {
        _image = [image retain];
        [_image setCacheMode:NSImageCacheNever];
        _page = 0;

        _bounds.size = [_image size];
        _bounds.origin = NSMakePoint(50.0, 50.0);
        _naturalBounds = _bounds;
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
