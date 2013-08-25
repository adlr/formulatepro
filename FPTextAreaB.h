//
//  FPTextAreaB.h
//  FormulatePro
//
//  Created by Andrew de los Reyes on 12/12/06.
//  Copyright 2006 Andrew de los Reyes. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FPGraphic.h"

@interface FPTextAreaB : FPGraphic <NSTextViewDelegate> {
    NSTextView *_editor;
    
    NSTextStorage *_textStorage;
    BOOL _isPlacing;
    BOOL _isEditing;
	BOOL _isAutoSizedX;
	BOOL _isAutoSizedY;
    
    float _editorScaleFactor;
}

- (void)documentDidZoom;

- (void)myFrameChanged:(NSTextView *)foo;
@end
