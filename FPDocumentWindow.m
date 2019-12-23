//
//  FPDocumentWindow.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 12/17/06.
//  Copyright 2006 Andrew de los Reyes. All rights reserved.
//

#import "FPDocumentWindow.h"
#import "FPLogging.h"
#import "FPToolPaletteController.h"

NSString *FPBeginQuickMove = @"FPBeginQuickMove";
NSString *FPAbortQuickMove = @"FPAbortQuickMove";
NSString *FPEndQuickMove = @"FPEndQuickMove";

enum {FPDeleteKey = 0x7f};

@implementation FPDocumentWindow

- (void)changeFont:(id)sender
{
    DLog(@"font changed.\n");
    //NSFont *oldFont = [self selectionFont];
    NSFont *newFont = [sender convertFont:_defaultFont];
    DLog(@"old %@, new %@\n", _defaultFont, newFont);
    
    if (_defaultFont != newFont) {
        [_defaultFont release];
        _defaultFont = [newFont retain];
    }
    return;
}

- (void)changeColor:(id)sender
{
  if ([_docView handleColorChange:[sender color]])
    return;
  DLog(@"default color changed. doc win\n");
  NSColor *newColor = [sender color];
  if (_defaultColor != newColor) {
    [_defaultColor release];
    _defaultColor = [newColor retain];
  }
}

- (NSColor *)currentColor {
  return _defaultColor;
}

- (FPDocumentView *)docView
{
    return _docView;
}

- (NSFont *)currentFont
{
    return _defaultFont;
}
    
- (BOOL)becomeFirstResponder
{
    DLog(@"becomeFirstResponder\n");
    return YES;
}

- (void)awakeFromNib
{
    _sentQuickMove = NO;
    _defaultFont = [[NSFont userFontOfSize:0.0] retain];
    _defaultColor = [[NSColor blackColor] retain];
}

- (void)keyDown:(NSEvent *)theEvent
{
    //if ([theEvent modifierFlags]) return;
    //[theEvent keyCode]
    DLog(@"fp doc window got keys: [%@][%x][%x]\n",
          [theEvent charactersIgnoringModifiers],
    (unsigned)[[theEvent charactersIgnoringModifiers] characterAtIndex:0],
    (unsigned)NSDeleteFunctionKey);
    if (FPDeleteKey ==
        [[theEvent charactersIgnoringModifiers] characterAtIndex:0]) {
        [_docView deleteSelectedGraphics];
    } else {
        // perhaps it's a keypress to select a tool
        [[FPToolPaletteController sharedToolPaletteController] keyDown:theEvent];
    }
}

- (void)flagsChanged:(NSEvent *)theEvent
{
    DLog(@"flags changed\n");
    if ((NO == _sentQuickMove) &&
        ([theEvent modifierFlags] & NSEventModifierFlagOption) &&
        ([theEvent modifierFlags] & NSEventModifierFlagCommand) &&
        ([_docView shouldEnterQuickMove])) {
        DLog(@"got apple-option\n");
        [[NSNotificationCenter defaultCenter] postNotification:
            [NSNotification notificationWithName:FPBeginQuickMove
                                          object:self]];
        _sentQuickMove = YES;
    } else if (YES == _sentQuickMove) {
        DLog(@"don't got apple-option\n");
        [[NSNotificationCenter defaultCenter] postNotification:
            [NSNotification notificationWithName:FPEndQuickMove object:self]];
        _sentQuickMove = NO;
    }
}

@end
