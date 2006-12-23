//
//  FPDocumentWindow.h
//  FormulatePro
//
//  Created by Andrew de los Reyes on 12/17/06.
//  Copyright 2006 Andrew de los Reyes. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FPDocumentView.h"

extern NSString *FPBeginQuickMove;
extern NSString *FPAbortQuickMove;
extern NSString *FPEndQuickMove;

@interface FPDocumentWindow : NSWindow {
    IBOutlet FPDocumentView *_docView;
    BOOL _sentQuickMove;
}

@end
