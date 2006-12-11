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
        _selectedGraphics = [[NSMutableSet alloc] initWithCapacity:1];
        _editingGraphic = nil;
    }
    return self;
}

- (void)awakeFromNib
{
    _overlayGraphics = [[NSMutableArray alloc] initWithCapacity:1];
    _selectedGraphics = [[NSMutableSet alloc] initWithCapacity:1];
    _editingGraphic = nil;
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
    for (i = 0; i < count; i++) {
        FPGraphic *g;
        g = [_overlayGraphics objectAtIndex:i];
        if ([g page] == page && [_selectedGraphics containsObject:g])
            [g drawKnobs];
    }
    /*
    NSLog(@"annotations:\n");
    NSArray *ann = [page annotations];
    for (i = 0 ; i < [ann count]; i++) {
        //NSLog(@"annotation: %@\n", [[ann objectAtIndex:i] type]);
        NSBezierPath *box = [NSBezierPath bezierPathWithRect:[[ann objectAtIndex:i] bounds]];
        [[NSColor redColor] set];
        [box stroke];
    }*/
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

- (NSPoint)pagePointForPointFromEvent:(NSEvent *)event page:(PDFPage *)page
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

    if (_editingGraphic) {
        [_editingGraphic stopEditing];
        _editingGraphic = nil;
    }
    
    if (tool == FPToolArrow) {
        int i;
        NSPoint point;
        
        // if we hit a knob, resize that shape by its knob
        if ([_selectedGraphics count]) {
            for (i = [_overlayGraphics count] - 1; i >= 0; i--) {
                graphic = [_overlayGraphics objectAtIndex:i];
                if (![_selectedGraphics containsObject:graphic]) continue;
                int knob = [graphic knobForEvent:theEvent];
                if (knob != NoKnob) {
                    [_selectedGraphics removeAllObjects];
                    [_selectedGraphics addObject:graphic];
                    [self setNeedsDisplay:YES]; // to fix which knobs are showing
                    [graphic resizeWithEvent:theEvent byKnob:knob];
                    return;
                }
            }
        }
        
        // if we hit a shape, then:
        // if holding shift: add or remove shape from selection
        // if not holding shift:
        //   if shape is selected, do nothing
        //   else make shape the only selected shape
        for (i = [_overlayGraphics count] - 1; i >= 0; i--) {
            graphic = [_overlayGraphics objectAtIndex:i];
            point = [self pagePointForPointFromEvent:theEvent page:[graphic page]];
            if (NSPointInRect(point, [graphic safeBounds])) {
                if ([theEvent modifierFlags] & NSShiftKeyMask) {
                    if ([_selectedGraphics containsObject:graphic])
                        [_selectedGraphics removeObject:graphic];
                    else
                        [_selectedGraphics addObject:graphic];
                } else {
                    if (![_selectedGraphics containsObject:graphic]) {
                        [_selectedGraphics removeAllObjects];
                        [_selectedGraphics addObject:graphic];
                    }
                }
                break;
            }
        }
        if (i < 0) { // point didn't hit any shape
            [_selectedGraphics removeAllObjects];
        }
        if ([_selectedGraphics count]) {
            [self setNeedsDisplay:YES];
            [self moveSelectionWithEvent:theEvent];
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
    } else {
        if ([graphic isEditable]) {
            _editingGraphic = graphic;
            [graphic startEditing];
        }
    }
}

- (void)moveSelectionWithEvent:(NSEvent *)theEvent
{
    NSPoint oldPoint;
    NSPoint newPoint;
    float deltaX, deltaY;
    PDFPage *page;
    int i;
    
    NSArray *selectedGraphics = [_selectedGraphics allObjects];
    
    oldPoint = [self convertPointFromEvent:theEvent toPage:&page];
    
    for (;;) {
        // get ready for next iteration of the loop, or break out of loop
        theEvent = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        if ([theEvent type] == NSLeftMouseUp)
            break;
        
        // main loop body
        newPoint = [self pagePointForPointFromEvent:theEvent
                                              page:page];
        
        deltaX = newPoint.x - oldPoint.x;
        deltaY = newPoint.y - oldPoint.y;
        
        // move the graphics. invalide view for before and after positions
        for (i = 0; i < [selectedGraphics count]; i++) {
            FPGraphic *g = [selectedGraphics objectAtIndex:i];
            [self setNeedsDisplayInRect:[self convertRect:[g boundsWithKnobs] fromPage:[g page]]];
            [g moveGraphicByX:deltaX byY:deltaY];
            [self setNeedsDisplayInRect:[self convertRect:[g boundsWithKnobs] fromPage:[g page]]];
        }
        
        oldPoint = newPoint;
    }
}

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
    NSLog(@"performKeyEquivalent [%@]\n", [theEvent charactersIgnoringModifiers]);
    if ([[theEvent charactersIgnoringModifiers] characterAtIndex:0] == NSBackspaceCharacter) {
        NSLog(@"bye bye\n");
    }
    return NO;
}

- (void)setCursorForAreaOfInterest:(PDFAreaOfInterest)area
{
    // no cursor rects!
}

@end
