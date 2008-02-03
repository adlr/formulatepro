//
//  FPZoomingScrollView.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 2/2/08.
//  Copyright 2008 Andrew de los Reyes. All rights reserved.
//

#import "FPZoomingScrollView.h"
#import "FPLogging.h"

static const float zoomScaleFactor = 1.3;
static const float factors[] =
    {0.1f, 0.25f, 0.5f, 0.75f, 1.0f, 1.25f, 1.5f, 2.0f, 4.0f, 8.0f, 16.0f};
static const int builtinFactorCount = sizeof(factors)/sizeof(factors[0]);

@implementation FPZoomingScrollView

- (void)awakeFromNib
{
    DLog(@"zoom tile awake from nib\n");
    _factorPopUpButton = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
    NSPopUpButtonCell *cell = [_factorPopUpButton cell];
    [cell setArrowPosition:NSPopUpArrowAtBottom];
    [cell setBezelStyle:NSShadowlessSquareBezelStyle]; // NSSmallSquareBezelStyle (10.5 only...)
    [_factorPopUpButton setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];

    for (int i = 0; i < builtinFactorCount; i++) {
        NSString *title = [NSString stringWithFormat:@"%.0f%%",(factors[i] * 100.0)];
        [_factorPopUpButton addItemWithTitle:title];
    }
    // add a disabled "Other" menu at the bottom
    [_factorPopUpButton addItemWithTitle:@"Other"];
    [[_factorPopUpButton itemAtIndex:builtinFactorCount] setEnabled:NO];
    [_factorPopUpButton sizeToFit];

    [_factorPopUpButton setTarget:self];
    [_factorPopUpButton setAction:@selector(factorButtonChanged:)];

    // adding as a subview causes retain to be sent, so we can safely release
    [self addSubview:_factorPopUpButton];
    [_factorPopUpButton release];

    _factor = 1.0f;
}

- (void)applyFactor
{
    int idx = builtinFactorCount;
    for (int i = 0; i < builtinFactorCount; i++) {
        if (factors[i] == _factor) {
            idx = i;
            break;
        }
    }
    [_factorPopUpButton selectItemAtIndex:idx];

    NSView *clipView = [[self documentView] superview];
    NSSize clipViewFrameSize = [clipView frame].size;
    [clipView setBoundsSize:NSMakeSize((clipViewFrameSize.width / _factor), (clipViewFrameSize.height / _factor))];
}

- (IBAction)zoomIn:(id)sender
{
    _factor *= zoomScaleFactor;
    [self applyFactor];
}

- (IBAction)zoomOut:(id)sender
{
    _factor /= zoomScaleFactor;
    [self applyFactor];
}

- (IBAction)factorButtonChanged:(id)sender
{
    int idx = [_factorPopUpButton indexOfSelectedItem];
    if (idx < builtinFactorCount) {
        _factor = factors[idx];
        [self applyFactor];
    }
}

- (void)tile
{
    assert([self hasHorizontalScroller]);

    // let it tile, get horizontal frame
    [super tile];
    NSScroller *horizontalScroller = [self horizontalScroller];
    NSRect horizontalScrollerFrame = [horizontalScroller frame];
    [_factorPopUpButton sizeToFit];
    
    NSRect factorPopUpFrame = [_factorPopUpButton frame];
    //factorPopUpFrame.size.width = 150.0;
    factorPopUpFrame.origin.x = horizontalScrollerFrame.origin.x;
    factorPopUpFrame.origin.y = horizontalScrollerFrame.origin.y;
    factorPopUpFrame.size.height = horizontalScrollerFrame.size.height;
    [_factorPopUpButton setFrame:factorPopUpFrame];
    
    horizontalScrollerFrame.origin.x += factorPopUpFrame.size.width;
    horizontalScrollerFrame.size.width -= factorPopUpFrame.size.width;
    [horizontalScroller setFrame:horizontalScrollerFrame];
    [self applyFactor];
}

@end
