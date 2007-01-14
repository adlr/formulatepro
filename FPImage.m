//
//  FPImage.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 12/27/06.
//  Copyright 2006 Andrew de los Reyes. All rights reserved.
//

#import "FPImage.h"
#import "NSMutableDictionaryAdditions.h"


@implementation FPImage

+ (NSString *)archivalClassName;
{
    return @"Image";
}

static NSString *imageArchiveKey = @"image";

- (id)initWithArchivalDictionary:(NSDictionary *)dict
                  inDocumentView:(FPDocumentView *)docView
{
    self = [super initWithArchivalDictionary:dict
                              inDocumentView:docView];
    if (self) {
        _image = [[NSUnarchiver unarchiveObjectWithData:
                   [dict objectForKey:imageArchiveKey]] retain];
    }
    return self;
}

- (NSDictionary *)archivalDictionary
{
    NSMutableDictionary *ret =
        [NSMutableDictionary
         dictionaryWithDictionary:[super archivalDictionary]];
    [ret setObject:[NSArchiver archivedDataWithRootObject:_image]
     forNonexistentKey:imageArchiveKey];
    return ret;
}

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
