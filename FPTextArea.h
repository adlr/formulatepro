//
//  FPTextArea.h
//  FormulatePro
//
//  Created by Andrew de los Reyes on 8/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

// http://www.cocoabuilder.com/archive/message/cocoa/2001/11/29/16511

#import <Cocoa/Cocoa.h>
#import "FPGraphic.h"

@interface FPTextArea : FPGraphic {
    NSTextStorage *_contents;
    NSTextView *_editor;
    BOOL _isPlacing;
    BOOL _isEditing;
	BOOL _isAutoSized;
}

- (void)startEditing;
- (void)stopEditing;

@end
