//
//  FPImage.h
//  FormulatePro
//
//  Created by Andrew de los Reyes on 12/27/06.
//  Copyright 2006 Andrew de los Reyes. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FPDocumentView.h"
#import "FPGraphic.h"

@interface FPImage : FPGraphic {
    NSImage *_image;
}

- (id)initInDocumentView:(FPDocumentView *)docView
               withImage:(NSImage *)image;

@end
