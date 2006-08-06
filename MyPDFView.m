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
        _overlay_graphics = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}

- (void)awakeFromNib
{
    _overlay_graphics = [[NSMutableArray alloc] initWithCapacity:1];
}

- (void)drawPage:(PDFPage *)page
{
    [super drawPage:page];
    
    int count;
    int i;
    
    count = [_overlay_graphics count];
    for (i = 0; i < count; i++) {
        FPGraphic *g;
        g = [_overlay_graphics objectAtIndex:i];
        if ([g page] == page)
            [g draw];
    }
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
    
    graphic = [[[FPToolPaletteController sharedToolPaletteController] classForCurrentTool] graphicInPDFView:self];
    assert(graphic);
    [_overlay_graphics addObject:graphic];
    keep = [graphic placeWithEvent:theEvent];
    if (keep == NO) {
        [_overlay_graphics removeLastObject];
    }
}

@end
