//
//  FPWindowController.h
//  FormulatePro
//
//  Created by Andrew de los Reyes on 1/21/08.
//  Copyright 2008 Andrew de los Reyes. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FPDocumentView.h"


@interface FPWindowController : NSWindowController {
    IBOutlet NSArrayController *_graphicsController;
    
    IBOutlet FPDocumentView *_graphicsView;
}

@end
