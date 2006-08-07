//
//  MyPDFView.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 7/4/06.
//  Copyright 2006 Andrew de los Reyes. All rights reserved.
//

#import "MyPDFView.h"
#import "FPGraphic.h"
#import "FPToolPaletteController.h"
#import "FPEllipse.h"

@implementation MyPDFView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        _overlayGraphics = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}

- (void)awakeFromNib
{
    _overlayGraphics = [[NSMutableArray alloc] initWithCapacity:1];
}

- (void)drawPage:(PDFPage *)page
{
    [super drawPage:page];
    
    int count;
    int i;
    
    count = [_overlayGraphics count];
    for (i = 0; i < count; i++) {
        FPGraphic *g;
        g = [_overlayGraphics objectAtIndex:i];
        if ([g page] == page)
            [g draw];
    }
    if (_selectedGraphic)
        [_selectedGraphic drawKnobs];
}

- (NSPoint)convertPointFromEvent:(NSEvent *)event toPage:(PDFPage **)out_page
{
    NSPoint loc_in_window;
    NSPoint loc_in_view;
    NSPoint loc_in_page;
    PDFPage *page;
    
    loc_in_window = [event locationInWindow];
    loc_in_window.x += 0.5;
    loc_in_window.y -= 0.5; // correct for coordinates being between pixels
    loc_in_view = [[[self window] contentView] convertPoint:loc_in_window toView:self];
    page = [self pageForPoint:loc_in_view nearest:YES];
    loc_in_page = [self convertPoint:loc_in_view toPage:page];
    *out_page = page;
    return loc_in_page;
}

- (NSPoint)convertPagePointFromEvent:(NSEvent *)event page:(PDFPage *)page
{
    NSPoint loc_in_window;
    NSPoint loc_in_view;
    NSPoint loc_in_page;
    
    loc_in_window = [event locationInWindow];
    loc_in_window.x += 0.5;
    loc_in_window.y -= 0.5; // correct for coordinates being between pixels
    loc_in_view = [[[self window] contentView] convertPoint:loc_in_window toView:self];
    loc_in_page = [self convertPoint:loc_in_view toPage:page];
    return loc_in_page;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    FPGraphic *graphic;
    BOOL keep;
    unsigned int tool = [[FPToolPaletteController sharedToolPaletteController] currentTool];

    if (tool == FPToolArrow) {
        int i;
        NSPoint point;
        
        if (_selectedGraphic) {
            int knob = [_selectedGraphic knobForEvent:theEvent];
            if (knob != NoKnob) {
                [_selectedGraphic resizeWithEvent:theEvent byKnob:knob];
                return;
            }
        }
        
        for (i = [_overlayGraphics count] - 1; i >= 0; i--) {
            FPGraphic *graphic = [_overlayGraphics objectAtIndex:i];
            _selectedGraphic = nil;
            point = [self convertPagePointFromEvent:theEvent page:[graphic page]];
            if (NSPointInRect(point, [graphic safeBounds])) {
                _selectedGraphic = graphic;
                break;
            }
        }
        if (_selectedGraphic) {
            //[graphic moveWithEvent:theEvent];
        }
        //[self setNeedsDisplayInRect:[graphic knobBounds]];
        [self setNeedsDisplay:YES];
        return;
    }
    
    graphic = [[[FPToolPaletteController sharedToolPaletteController] classForCurrentTool] graphicInPDFView:self];
    assert(graphic);
    [_overlayGraphics addObject:graphic];
    keep = [graphic placeWithEvent:theEvent];
    if (keep == NO) {
        [_overlayGraphics removeLastObject];
    }
}

@end
