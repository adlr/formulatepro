//
//  MyPDFView.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 7/4/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "MyPDFView.h"
#import "FPGraphic.h"

@implementation MyPDFView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    NSLog(@"initWithFrame\n");
    if (self) {
        // Initialization code here.
        _overlay_graphics = [[NSMutableArray alloc] initWithCapacity:5];
        NSLog(@"initWithFrame 2\n");
    }
    return self;
}

- (void)awakeFromNib
{
    _overlay_graphics = [[NSMutableArray alloc] initWithCapacity:5];
}

- (void)drawPage:(PDFPage *)page
{
    [super drawPage:page];
    
    int count;
    int i;
    
    count = [_overlay_graphics count];
    NSLog(@"pdf draw cnt: %d\n", count);
    for (i = 0; i < count; i++) {
        FPGraphic *g;
        g = [_overlay_graphics objectAtIndex:i];
        NSLog(@"pdf page: 0x%08x, graphic page: 0x%08x\n", page, [g page]);
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
    loc_in_view = [[[self window] contentView] convertPoint:loc_in_window toView:self];
    page = [self pageForPoint:loc_in_view nearest:YES];
    loc_in_page = [self convertPoint:loc_in_view toPage:page];
    *out_page = page;
    return loc_in_page;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    FPGraphic *graphic;
    
    NSLog(@"making graphic\n");
    graphic = [FPGraphic graphicInPDFView:self];
    assert(graphic);
    [_overlay_graphics addObject:graphic];
    [graphic placeWithEvent:theEvent];
    NSLog(@"made graphic cnt: %d\n", [_overlay_graphics count]);
}

@end
