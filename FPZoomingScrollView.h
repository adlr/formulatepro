//
//  FPZoomingScrollView.h
//  FormulatePro
//
//  Created by Andrew de los Reyes on 2/2/08.
//  Copyright 2008 Andrew de los Reyes. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FPZoomingScrollView : NSScrollView {
    NSPopUpButton *_factorPopUpButton;
    float _factor;
}

- (IBAction)zoomIn:(id)sender;
- (IBAction)zoomOut:(id)sender;
- (IBAction)factorButtonChanged:(id)sender;

@end
