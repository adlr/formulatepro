
#import <objc/objc-runtime.h>

#import "NSMutableSetAdditions.h"
#import "FPDocumentView.h"
#import "FPDocumentWindow.h"
#import "FPToolPaletteController.h"
#import "FPGraphic.h"
#import "FPImage.h"
#import "FPLogging.h"
#import "MyDocument.h"

NSString *FPDocumentViewGraphicsBindingName = @"graphics";
NSString *FPDocumentViewSelectionIndexesBindingName = @"selectionIndexes";

static NSString *FPDocumentViewGraphicsObservationContext = @"graphicsObservationContext";
static NSString *FPDocumentViewIndividualGraphicObservationContext = @"individualGraphicObservationContext";
static NSString *FPDocumentViewSelectionIndexesObservationContext = @"selectionIndexesObservationContext";

static float getUIScaleFactorForWindow(NSWindow *window)
{
    static BOOL haveRet = NO;
    static float ret;
    if (haveRet)
        return ret;
    NSDictionary *deviceDescription = [window deviceDescription];
    NSValue *resolutionValue = [deviceDescription valueForKey:NSDeviceResolution];
    NSSize sz = [resolutionValue sizeValue];
    ret = sz.width / 72.0;
    return ret;
}

// are a and b very close to each other?
static BOOL floatsEqual(float a, float b)
{
    return (fabsf(a - b)) < 1.0e-4;
}

@implementation FPDocumentView

// Draw this many points around each page. used for the shadow
static const float PageBorderSize = 10.0;
static const float ZoomScaleFactor = 1.3;

- (NSFont *)currentFont
{
    return [(FPDocumentWindow*)[self window] currentFont];
}

// returns number of points
- (NSSize)pageSizeForPage:(unsigned int)page
{
    PDFPage *pg = [_pdf_document pageAtIndex:page];
    NSSize ret = [pg boundsForBox:_box].size;
    if (90 == ([pg rotation] % 180))
        ret = NSMakeSize(ret.height, ret.width);
    return ret;
}

- (NSSize)sizeForPage:(unsigned int)page
{
    return [self pageSizeForPage:page];
//    NSSize ret = [self pageSizeForPage:page];
//    ret.width *= _scale_factor;
//    ret.height *= _scale_factor;
//    return ret;
}

- (NSRect)idealFrame
{
    if (nil == _pdf_document) {
        NSLog(@"small frame\n");
        return NSMakeRect(0.0, 0.0, 10.0, 10.0);
    }
    NSRect ret = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    for (unsigned int i = 0; i < [_pdf_document pageCount]; i++) {
        NSSize sz = [self sizeForPage:i];
        if (sz.width > NSWidth(ret))
            ret.size.width = sz.width;
        ret.size.height += sz.height + PageBorderSize;
    }
    ret.size.width += 2.0 * PageBorderSize;
    ret.size.height += PageBorderSize;
    return ret;
}

//- (FPDocumentView *)printableCopy
//{
//    FPDocumentView *ret = [[FPDocumentView alloc] initWithFrame:[self frame]];
//    ret->_pdf_document = nil;
//    ret->_box = _box;
//    ret->_draws_shadow = NO;
//    ret->_inQuickMove = NO;
//    ret->_is_printing = YES;
//    if (_editingGraphic) {
//        [_editingGraphic stopEditing];
//        _editingGraphic = nil;
//    }
//    ret->_editingGraphic = nil;
//    ret->_doc = _doc;
//    [ret setPDFDocument:_pdf_document];
//    return ret;
//}

#pragma mark -
#pragma mark Initialization and (Un)Archiving

- (void)initMemberVariables
{
    _pdf_document = nil;
    _current_page = 0;
    _box = kPDFDisplayBoxCropBox;
    //_box = kPDFDisplayBoxMediaBox;
    _draws_shadow = YES;
    _inQuickMove = NO;
    _is_printing = NO;

    _graphicsContainer = nil;
    _graphicsKeyPath = nil;
    _selectionIndexesContainer = nil;
    _selectionIndexesKeyPath = nil;

    _editingGraphic = nil;
}

- (void)dealloc {
    DLog(@"FPDocumentView dealloc\n");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_pdf_document release];
    [self unbind:FPDocumentViewGraphicsBindingName];
    [self unbind:FPDocumentViewSelectionIndexesBindingName];
    [super dealloc];
}

- (id)initWithFrame:(NSRect)frameRect
{
    DLog(@"doc view init w/ frame: %@\n", NSStringFromRect(frameRect));
    frameRect = [self frame];
    if ((self = [super initWithFrame:frameRect]) != nil) {
        // Add initialization code here
        [self initMemberVariables];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initMemberVariables];
    [[NSNotificationCenter defaultCenter]
        addObserver:self selector:@selector(beginQuickMove:)
        name:FPBeginQuickMove object:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:self selector:@selector(abortQuickMove:)
        name:FPAbortQuickMove object:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:self selector:@selector(endQuickMove:)
        name:FPEndQuickMove object:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:self selector:@selector(toolChosen:)
               name:FPToolChosen object:nil];
    
    [[self superview] setPostsBoundsChangedNotifications:YES];
    [[self superview] setPostsFrameChangedNotifications:YES];
    
//    // for always knowing which page we're on
//    [[NSNotificationCenter defaultCenter]
//       addObserver:self
//          selector:@selector(viewingRectChanged:)
//              name:NSViewBoundsDidChangeNotification
//            object:[self superview]];
//    [[NSNotificationCenter defaultCenter]
//       addObserver:self
//          selector:@selector(viewingRectChanged:)
//              name:NSViewFrameDidChangeNotification
//            object:[self superview]];


    [[NSNotificationCenter defaultCenter]
       addObserver:self
          selector:@selector(windowWillClose:)
              name:NSWindowWillCloseNotification
            object:[self window]];
}

#pragma mark -
#pragma mark Bindings

- (void)bind:(NSString *)bindingName
    toObject:(id)observableObject
 withKeyPath:(NSString *)observableKeyPath
     options:(NSDictionary *)options
{
    if ([bindingName isEqualToString:FPDocumentViewGraphicsBindingName]) {
        assert([options count] == 0);
        // if bound, unbind
        if (_graphicsContainer || _graphicsKeyPath)
            [self unbind:FPDocumentViewGraphicsBindingName];
        
        // record info about binding
        _graphicsContainer = [observableObject retain];
        _graphicsKeyPath = [observableKeyPath copy];
        
        // start observing
        [_graphicsContainer addObserver:self
                             forKeyPath:_graphicsKeyPath
                                options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                                context:FPDocumentViewGraphicsObservationContext];

        // we observe the container and all the elements
        [self startObservingGraphics:[_graphicsContainer valueForKeyPath:_graphicsKeyPath]];
        
        [self setNeedsDisplay:YES];
    } else if ([bindingName isEqualToString:FPDocumentViewSelectionIndexesBindingName]) {
        assert([options count] == 0);

        // if bound, unbind
        if (_selectionIndexesContainer || _selectionIndexesKeyPath)
            [self unbind:FPDocumentViewSelectionIndexesBindingName];
        
        // record info about binding
        _selectionIndexesContainer = [observableObject retain];
        _selectionIndexesKeyPath = [observableKeyPath retain];
        
        // start observing
        [_selectionIndexesContainer addObserver:self
                                     forKeyPath:_selectionIndexesKeyPath
                                        options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                                        context:FPDocumentViewSelectionIndexesObservationContext];
        [self setNeedsDisplay:YES];
        DLog(@"got to here\n");
    } else {
        [super bind:bindingName
           toObject:observableObject
        withKeyPath:observableKeyPath
            options:options];
    }
}

- (void)unbind:(NSString *)bindingName
{
    if ([bindingName isEqualToString:FPDocumentViewGraphicsBindingName]) {
        // stop observing graphics and stop observing graphic container
        [self stopObservingGraphics:[self graphics]];
        [_graphicsContainer removeObserver:self forKeyPath:_graphicsKeyPath];
        [_graphicsContainer release];
        _graphicsContainer = nil;
        [_graphicsKeyPath release];
        _graphicsKeyPath = nil;
        [self setNeedsDisplay:YES];
    } else if ([bindingName isEqualToString:FPDocumentViewSelectionIndexesBindingName]) {
        [_selectionIndexesContainer removeObserver:self forKeyPath:_selectionIndexesKeyPath];
        [_selectionIndexesContainer release];
        _selectionIndexesContainer = nil;
        [_selectionIndexesKeyPath release];
        _selectionIndexesKeyPath = nil;
        [self setNeedsDisplay:YES];
    } else {
        [super unbind:bindingName];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(NSObject *)observedObject
                        change:(NSDictionary *)change
                       context:(void *)context
{
    DLog(@"observed a change at %@\n", keyPath);
    if (context == FPDocumentViewGraphicsObservationContext) {
        // graphics container changed
        if (![[change objectForKey:NSKeyValueChangeOldKey] isEqual:[NSNull null]]) {
            NSArray *oldGraphics = [change objectForKey:NSKeyValueChangeOldKey];
            [self stopObservingGraphics:oldGraphics];
            for (unsigned int i = 0; i < [oldGraphics count]; i++) {
                //set needs display for old graphic's drawing bounds
                FPGraphic *gr = [oldGraphics objectAtIndex:i];
                [self setNeedsDisplayInRect:[gr drawingBounds]];
            }

            // if we're deleting the editing graphic, stop editing
            if (_editingGraphic && [oldGraphics containsObject:_editingGraphic])
                ;
                //[self stopEditing];
        }
        
        if (![[change objectForKey:NSKeyValueChangeNewKey] isEqual:[NSNull null]]) {
            NSArray *newGraphics = [change objectForKey:NSKeyValueChangeNewKey];
            [self startObservingGraphics:newGraphics];
            for (unsigned int i = 0; i < [newGraphics count]; i++) {
                // set needs display in new graphics's drawing bounds
                FPGraphic *gr = [newGraphics objectAtIndex:i];
                [self setNeedsDisplayInRect:[gr drawingBounds]];
            }
        }
    } else if (context == FPDocumentViewIndividualGraphicObservationContext) {
        // a property of an individual graphic changed
        if ([keyPath isEqualToString:FPGraphicDrawingBoundsKey]) {
            // redraw old and new locations of the graphic
            NSRect oldLocation = [[change objectForKey:NSKeyValueChangeOldKey] rectValue];
            NSRect newLocation = [[change objectForKey:NSKeyValueChangeNewKey] rectValue];
            [self setNeedsDisplayInRect:oldLocation];
            [self setNeedsDisplayInRect:newLocation];
        } else if ([keyPath isEqualToString:FPGraphicDrawingContentsKey]) {
            FPGraphic *graphic = (FPGraphic *)observedObject;
            NSRect loc = [graphic drawingBounds];
            [self setNeedsDisplayInRect:loc];
        } else {
            DLog(@"got here for key path: %@\n", keyPath);
            assert(0);  // should never get here
        }
    } else if (context == FPDocumentViewSelectionIndexesObservationContext) {
        // selection changed
        // redraw graphics that have become selected or deselected. in Sketch, they
        // note that if the binding has changed completely and old or new values
        // will be null, and the whole view should be redrawn. I'm not sure when
        // that would occur, but I'll follow along.
        NSIndexSet *oldIndexes = [change objectForKey:NSKeyValueChangeOldKey];
        NSIndexSet *newIndexes = [change objectForKey:NSKeyValueChangeNewKey];
        if (![oldIndexes isEqual:[NSNull null]] && ![newIndexes isEqual:[NSNull null]]) {
            for (unsigned int i = [oldIndexes firstIndex];
                 i != NSNotFound;
                 i = [oldIndexes indexGreaterThanIndex:i]) {
                if (![newIndexes containsIndex:i]) {
                    FPGraphic *gr = [[self graphics] objectAtIndex:i];
                    [self setNeedsDisplayInRect:[gr drawingBounds]];
                }
            }
            for (unsigned int i = [newIndexes firstIndex];
                 i != NSNotFound;
                 i = [newIndexes indexGreaterThanIndex:i]) {
                if (![oldIndexes containsIndex:i]) {
                    FPGraphic *gr = [[self graphics] objectAtIndex:i];
                    [self setNeedsDisplayInRect:[gr drawingBounds]];
                }
            }
        } else {
            DLog(@"selection indexes binding changed completely\n");
            [self setNeedsDisplay:YES];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:observedObject change:change context:context];
    }
}

- (void)startObservingGraphics:(NSArray *)graphics {
    // a graphic's drawingBounds key will be KVO-triggered whenever any property that affects
    // location changes, so we only need to monitor that one, but be aware that the whole
    // graphic needs re-drawing when it changes
    NSIndexSet *allGraphicsIndexes =
        [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [graphics count])];
    [graphics addObserver:self
       toObjectsAtIndexes:allGraphicsIndexes
               forKeyPath:FPGraphicDrawingBoundsKey
                  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                  context:FPDocumentViewIndividualGraphicObservationContext];
    // FPGraphicDrawingContentsKey is triggered when the graphic changes, but doesn't move
    [graphics addObserver:self
       toObjectsAtIndexes:allGraphicsIndexes
               forKeyPath:FPGraphicDrawingContentsKey
                  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                  context:FPDocumentViewIndividualGraphicObservationContext];
}

- (void)stopObservingGraphics:(NSArray *)graphics {
    NSIndexSet *allGraphicsIndexes =
        [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [graphics count])];
    [graphics removeObserver:self
        fromObjectsAtIndexes:allGraphicsIndexes
                  forKeyPath:FPGraphicDrawingBoundsKey];
    [graphics removeObserver:self
        fromObjectsAtIndexes:allGraphicsIndexes
                  forKeyPath:FPGraphicDrawingContentsKey];
}

#pragma mark -
#pragma mark Convenience

- (NSArray *)graphics
{
    // should never return nil
    NSArray *ret = [_graphicsContainer valueForKeyPath:_graphicsKeyPath];
    return ret ? ret : [NSArray array];
}

- (NSMutableArray *)mutableGraphics
{
    // it's programmer error to try to mutate graphics when not bound
    assert(_graphicsContainer);
    assert(_graphicsKeyPath);

    NSMutableArray *ret = [_graphicsContainer mutableArrayValueForKeyPath:_graphicsKeyPath];
    assert(ret);
    return ret;
}

- (NSIndexSet *)selectionIndexes
{
    // should never return nil
    NSIndexSet *ret = [_selectionIndexesContainer valueForKeyPath:_selectionIndexesKeyPath];
    return ret ? ret : [NSIndexSet indexSet];
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
    NSGraphicsContext* theContext = [NSGraphicsContext currentContext];
    DLog(@"draw rect %@\n", NSStringFromRect(rect));
    DLog(@"my frame: %@\n", NSStringFromRect([self frame]));

    if (nil == _pdf_document)
        return;
    
    // draw the shadow and white page backgrounds, and pdf pages
    float how_far_down = PageBorderSize;
    NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
    [shadow setShadowColor:[NSColor blackColor]];
    [shadow setShadowBlurRadius:5.0];
    [shadow setShadowOffset:NSMakeSize(0.0, -2.0)];
    for (unsigned int i = 0; i < [_pdf_document pageCount]; i++) {
        NSSize sz = [self sizeForPage:i];
        NSRect page_rect = NSMakeRect(PageBorderSize, how_far_down,
                                      sz.width, sz.height);
        if (!NSIntersectsRect(rect, page_rect)) goto loop_end;
        if (_draws_shadow) {
            [theContext saveGraphicsState]; // for the shadow
            [shadow set];
        }
        [[NSColor whiteColor] set];
        NSRectFill(page_rect);
        if (_draws_shadow)
            [theContext restoreGraphicsState];
        
        [NSGraphicsContext saveGraphicsState]; // for the clipping rect
        NSRectClip(page_rect);
        
        NSAffineTransform *at = [self transformForPage:i];
        [at concat];

        //if (!_is_printing || [_doc drawsOriginalPDF])
            [[_pdf_document pageAtIndex:i] drawWithBox:_box];

        for (unsigned int j = 0; j < [[self graphics] count]; j++) {
            FPGraphic *g;
            g = [[self graphics] objectAtIndex:j];
            if ([g page] == i)
                [g draw:[[self selectionIndexes] containsIndex:j]];
            {
                NSBezierPath *path = [NSBezierPath bezierPathWithRect:[self centerScanRect:[g bounds]]];
//                [path setLineWidth:lineWidth];
                [[NSColor blackColor] set];
                [path stroke];
            }
        }
        for (unsigned int j = 0; j < [[self graphics] count]; j++) {
            FPGraphic *g;
            g = [[self graphics] objectAtIndex:j];
            if (([g page] == i) && ([[self selectionIndexes] containsIndex:j]))
                [self drawHandleAtPoint:([g bounds].origin)];
        }
//        for (unsigned int j = 0; j < [[self graphics] count]; j++) {
//            FPGraphic *g;
//            g = [_overlayGraphics objectAtIndex:j];
//            if ((_editingGraphic != g) &&
//                ([g page] == i) &&
//                [[self selectionIndexes] containsIndex:j])
//                [g drawKnobs];
//        }

        [at invert];
        [at concat];
        [NSGraphicsContext restoreGraphicsState]; // undo page clipping rect
      loop_end:
        how_far_down += NSHeight(page_rect) + PageBorderSize;
    }
}

#if MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_5
// Note: these four methods will go away when 10.4 is no longer supported
// also, resolution independence is only supported on 10.5 systems.
- (NSPoint)convertPointFromBase:(NSPoint)aPoint
{
    return [self convertPoint:aPoint fromView:nil];
}

- (NSPoint)convertPointToBase:(NSPoint)aPoint
{   
    return [self convertPoint:aPoint toView:nil];
}

- (NSRect)convertRectToBase:(NSRect)aRect
{
    return [self convertRect:aRect toView:nil];
}

- (NSRect)convertRectFromBase:(NSRect)aRect
{
    return [self convertRect:aRect fromView:nil];
}
#endif  // MAC_OS_X_VERSION_MIN_REQUIRED < MAC_OS_X_VERSION_10_5

// called by graphics, so origin is the page origin
- (void)drawHandleAtPoint:(NSPoint)point
{
    float lineWidth = 1.0;
    float windowScaleFactor = getUIScaleFactorForWindow([self window]);
    float handleSize = 6.0;
    if (floatsEqual(windowScaleFactor, 1.25)) {
        lineWidth = 1.0 / 1.25;
        handleSize = 8.0;
    } else if (floatsEqual(windowScaleFactor, 1.5)) {
        lineWidth = 1.0 / 1.5;
        handleSize = 10.0;
    } else if (windowScaleFactor > 1.5) {
        handleSize = 6.0 * windowScaleFactor;
    }

    NSPoint basePoint = [self convertPointToBase:point];
    NSRect handleRectInWindow = NSMakeRect(basePoint.x - handleSize/2.0, basePoint.y - handleSize/2.0, handleSize, handleSize);
    float unused;
    if (!floatsEqual(0.0, modff(windowScaleFactor/2.0, &unused))) {
        // if the line we draw occupies an odd number of pixels on screen,
        // we must offset the center of the line
        handleRectInWindow.origin.x = floorf(handleRectInWindow.origin.x);
        if (!floatsEqual(1.25, windowScaleFactor))
            // bug in NSView for 1.25 scaling it seems
            handleRectInWindow.origin.x += 0.5;
        handleRectInWindow.origin.y = floorf(handleRectInWindow.origin.y) + 0.5;
    }

    NSRect handleRectInSelf = [self convertRectFromBase:handleRectInWindow];
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:handleRectInSelf];
    [path setLineWidth:lineWidth];
    [[NSColor whiteColor] set];
    [path fill];
    [[NSColor blackColor] set];
    [path stroke];
}

#pragma mark -
#pragma mark Member methods

- (void)windowWillClose:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setPDFDocument:(PDFDocument *)pdf_document
{
    DLog(@"set pdf doc called\n");
    if (_pdf_document == pdf_document)
        return;
    [_pdf_document release];
    _pdf_document = [pdf_document retain];
    DLog(@"set pdf doc\n");
    [self setFrame:[self frame]];
    [self setNeedsDisplay:YES];
}

//- (unsigned int)getViewingMidpointToPage:(unsigned int*)page pagePoint:(NSPoint*)pagePoint
//{
//    NSPoint midpoint = NSMakePoint(NSMidX([_scrollView documentVisibleRect]),
//                                   NSMidY([_scrollView documentVisibleRect]));
//    unsigned int ret = [self pageForPoint:midpoint];
//    if (page)
//        *page = ret;
//    if (pagePoint)
//        *pagePoint = [self convertPoint:midpoint toPage:*page];
//    return ret;
//}

//- (void)scrollToMidpointOnPage:(unsigned int)page point:(NSPoint)midPoint
//{
//    float viewWidth = NSWidth([[_scrollView contentView] documentVisibleRect]);
//    float viewHeight = NSHeight([[_scrollView contentView] documentVisibleRect]);
//    NSPoint viewPoint = [self convertPoint:midPoint fromPage:page];
//    NSPoint viewOrigin = NSMakePoint(floorf(viewPoint.x - viewWidth/2.0),
//                                     floorf(viewPoint.y - viewHeight/2.0));
//    [[_scrollView contentView] scrollToPoint:
//        [[_scrollView contentView] constrainScrollPoint:viewOrigin]];
//    [_scrollView reflectScrolledClipView:[_scrollView contentView]];
//}

//- (void)zoomIn:(id)sender
//{
//    NSPoint pagePoint;
//    unsigned int page;
//    DLog(@"old frame: %@\n", NSStringFromRect([self frame]));
//    [self getViewingMidpointToPage:&page pagePoint:&pagePoint];
//
//    _scale_factor *= ZoomScaleFactor;
//    [self setFrame:[self frame]];
//    [self setNeedsDisplay:YES];
//
//    [self scrollToMidpointOnPage:page point:pagePoint];
//    
//    // tell an editing graphic (which may have a view), that doc zoomed
//    DLog(@"new frame: %@\n", NSStringFromRect([self frame]));
//    if (_editingGraphic)
//        [_editingGraphic documentDidZoom];
//}
//
//- (void)zoomOut:(id)sender
//{
//    NSPoint pagePoint;
//    unsigned int page;
//    DLog(@"old frame: %@\n", NSStringFromRect([self frame]));
//    [self getViewingMidpointToPage:&page pagePoint:&pagePoint];
//    
//    _scale_factor /= ZoomScaleFactor;
//    [self setFrame:[self frame]];
//    [self setNeedsDisplay:YES];
//    
//    [self scrollToMidpointOnPage:page point:pagePoint];
//
//    // tell an editing graphic (which may have a view), that doc zoomed
//    DLog(@"new frame: %@\n", NSStringFromRect([self frame]));
//    if (_editingGraphic)
//        [_editingGraphic documentDidZoom];
//}

//- (void)previousPage
//{
//    if (0 == _current_page)
//        return;
//    _current_page--;
//    [self scrollToPage:_current_page];
//}
//
//- (void)nextPage
//{
//    if ((_current_page + 1) == [_pdf_document pageCount])
//        return;
//    _current_page++;
//    [self scrollToPage:_current_page];
//}

//- (void)viewingRectChanged:(id)sender
//{
//    _current_page = [self getViewingMidpointToPage:nil pagePoint:nil];
//}

//- (void)scrollToPage:(unsigned int)page
//{
//    NSSize sz = [self pageSizeForPage:page];
//    NSRect fullPageRect = NSMakeRect(0, 0, sz.width, sz.height);
//    [self scrollRectToVisible:[self convertRect:fullPageRect fromPage:page]];
//}

//- (float)scaleFactor
//{
//    return _scale_factor;
//}

- (void)deleteSelectedGraphics
{
    [[self mutableGraphics] removeObjectsAtIndexes:[self selectionIndexes]];
}

//- (unsigned int)pageForPointFromEvent:(NSEvent *)theEvent
//{
//    NSPoint loc_in_window = [theEvent locationInWindow];
//    loc_in_window.x += 0.5;
//    loc_in_window.y -= 0.5; // correct for coordinates being between pixels
//    NSPoint loc_in_view =
//        [[[self window] contentView] convertPoint:loc_in_window toView:self];
//
//    return [self pageForPoint:loc_in_view];
//}
//
//- (unsigned int)pageForPoint:(NSPoint)point
//{
//    if (nil == _pdf_document)
//        return 0;
//    float bottom_border = PageBorderSize / 2.0;
//    for (unsigned int i = 0; i < [_pdf_document pageCount]; i++) {
//        NSSize sz = [self sizeForPage:i];
//        bottom_border += sz.height + PageBorderSize;
//        if (point.y < bottom_border) return i;
//    }
//    return [_pdf_document pageCount] - 1;
//}

// thre returned transform works in the following direction:
// page-coordinate ==(transform)==> doc-view-coordinate
- (NSAffineTransform *)transformForPage:(unsigned int)page
{
    assert(_pdf_document);
    assert(page < [_pdf_document pageCount]);

    NSAffineTransform *at = [NSAffineTransform transform];
    [at scaleXBy:1.0 yBy:-1.0];
    float yTranslate = 0.0;
    for (unsigned int i = 0; i <= page; i++) {
        NSSize sz = [self sizeForPage:i];
        yTranslate -= (PageBorderSize + sz.height);
    }
    [at translateXBy:PageBorderSize yBy:yTranslate];
    //[at scaleXBy:_scale_factor yBy:_scale_factor];
    return at;
}

- (NSPoint)convertPoint:(NSPoint)point toPage:(unsigned int)page
{
    NSAffineTransform *transform = [self transformForPage:page];
    [transform invert];
    return [transform transformPoint:point];
}

- (NSPoint)convertPoint:(NSPoint)point fromPage:(unsigned int)page
{
    NSAffineTransform *transform = [self transformForPage:page];
    return [transform transformPoint:point];
}

- (NSRect)convertRect:(NSRect)rect toPage:(unsigned int)page
{
    assert(rect.size.width >= 0.0);
    assert(rect.size.height >= 0.0);
    NSPoint bottomLeft = NSMakePoint(NSMinX(rect), NSMaxY(rect));
    NSPoint upperRight = NSMakePoint(NSMaxX(rect), NSMinY(rect));
    NSPoint newBottomLeft = [self convertPoint:bottomLeft toPage:page];
    NSPoint newUpperRight = [self convertPoint:upperRight toPage:page];
    NSRect ret;
    ret.origin = newBottomLeft;
    ret.size = NSMakeSize(newUpperRight.x - newBottomLeft.x,
                          newUpperRight.y - newBottomLeft.y);
    assert(ret.size.width >= 0.0);
    assert(ret.size.height >= 0.0);
    return ret;
}

- (NSRect)convertRect:(NSRect)rect fromPage:(unsigned int)page
{
    assert(rect.size.width >= 0.0);
    assert(rect.size.height >= 0.0);
    NSPoint bottomLeft = rect.origin;
    NSPoint upperRight = NSMakePoint(NSMaxX(rect), NSMaxY(rect));
    NSPoint newBottomLeft = [self convertPoint:bottomLeft fromPage:page];
    NSPoint newUpperRight = [self convertPoint:upperRight fromPage:page];
    NSRect ret;
    ret.origin.x = newBottomLeft.x;
    ret.origin.y = newUpperRight.y;
    ret.size.width = newUpperRight.x - newBottomLeft.x;
    ret.size.height = newBottomLeft.y - newUpperRight.y;
    assert(ret.size.width >= 0.0);
    assert(ret.size.height >= 0.0);
    return ret;
}

- (NSPoint)pagePointForPointFromEvent:(NSEvent *)theEvent
                                 page:(unsigned int)page
{
    NSPoint loc_in_window = [theEvent locationInWindow];
    loc_in_window.x += 0.5;
    loc_in_window.y -= 0.5; // correct for coordinates being between pixels
    NSPoint loc_in_view =
        [[[self window] contentView] convertPoint:loc_in_window toView:self];
    NSPoint loc_in_page = [self convertPoint:loc_in_view toPage:page];
    DLog(@"W: %@, V: %@, :P %@\n", NSStringFromPoint(loc_in_window), NSStringFromPoint(loc_in_view), NSStringFromPoint(loc_in_page));
    return loc_in_page;
}

- (BOOL)isFlipped
{
    return YES;
}

//- (void)moveSelectionWithEvent:(NSEvent *)theEvent
//{
//    NSPoint oldPoint;
//    NSPoint newPoint;
//    float deltaX, deltaY;
//    unsigned int oldPage;
//    unsigned int newPage;
//    int i;
//    
//    NSArray *selectedGraphics = [_selectedGraphics allObjects];
//    
//    oldPage = [self pageForPointFromEvent:theEvent];
//    oldPoint = [self pagePointForPointFromEvent:theEvent page:oldPage];
//    
//    for (;;) {
//        // get ready for next iteration of the loop, or break out of loop
//        theEvent =
//            [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask |
//                                                  NSLeftMouseUpMask)];
//        if ([theEvent type] == NSLeftMouseUp)
//            break;
//        
//        // main loop body
//        newPage = [self pageForPointFromEvent:theEvent];
//        if (newPage != oldPage) {
//            for (i = 0; i < [selectedGraphics count]; i++) {
//                FPGraphic *g = [selectedGraphics objectAtIndex:i];
//                [self setNeedsDisplayInRect:
//                    [self convertRect:[g boundsWithKnobs] fromPage:[g page]]];
//                [g reassignToPage:newPage];
//                [self setNeedsDisplayInRect:
//                    [self convertRect:[g boundsWithKnobs] fromPage:[g page]]];
//            }
//            // reassign oldPoint to the newPage
//            oldPoint = [self convertPoint:[self convertPoint:oldPoint
//                                                    fromPage:oldPage]
//                                   toPage:newPage];
//            oldPage = newPage;
//        }
//
//        newPoint = [self pagePointForPointFromEvent:theEvent
//                                               page:oldPage];
//        
//        deltaX = newPoint.x - oldPoint.x;
//        deltaY = newPoint.y - oldPoint.y;
//        
//        // move the graphics. invalide view for before and after positions
//        for (i = 0; i < [selectedGraphics count]; i++) {
//            FPGraphic *g = [selectedGraphics objectAtIndex:i];
//            [self setNeedsDisplayInRect:
//                [self convertRect:[g boundsWithKnobs] fromPage:[g page]]];
//            [g moveGraphicByX:deltaX byY:deltaY];
//            [self setNeedsDisplayInRect:
//                [self convertRect:[g boundsWithKnobs] fromPage:[g page]]];
//        }
//        
//        oldPoint = newPoint;
//    }
//    [_doc updateChangeCount:NSChangeDone];
//}

- (void)sendAbortQuickMove
{
    if (_inQuickMove)
        [[NSNotificationCenter defaultCenter] postNotification:
         [NSNotification notificationWithName:FPAbortQuickMove
                                       object:self]];
}

// this is possibly the harriest method in the whole program. This receives
// all mouse clicks in the view, except clicks inside an editing view. We
// must handle both clicks in a double click, and when we get the first click
// of the double click, we don't even know if a second click will come yet
//
// One invariant is that if you are in a QuickMove, only one piece can be
// selected, and that has to be the one piece that was being edited before
// the QuickMove.
//- (void)mouseDown:(NSEvent *)theEvent
//{
//    [_doc updateChangeCount:NSChangeDone];
//    BOOL justStoppedEditing = NO;
//    if (_editingGraphic) {
//        [_editingGraphic stopEditing];
//        assert([_selectedGraphics count] == 1);
//        _editingGraphic = nil;
//        justStoppedEditing = YES;
//    }
//    
//    unsigned int tool =
//        [[FPToolPaletteController sharedToolPaletteController] currentTool];
//
//    unsigned int page = [self pageForPointFromEvent:theEvent];
//    NSPoint pagePoint =
//        [self pagePointForPointFromEvent:theEvent page:page];
//        
//    if (_inQuickMove) {
//        assert(1 == [_selectedGraphics count]);
//        // see if we hit a selected graphic's knob
//        FPGraphic *graphic = [_selectedGraphics anyObject];
//        int knob = [graphic knobForEvent:theEvent];
//        if (NoKnob != knob) { // hit a knob
//            [graphic resizeWithEvent:theEvent byKnob:knob];
//            return;
//        }
//        
//        // see if we hit the shape
//        if ([graphic page] == page) {
//            NSPoint pagePoint =
//                [self pagePointForPointFromEvent:theEvent page:page];
//            if (NSPointInRect(pagePoint, [graphic safeBounds])) {
//                [self moveSelectionWithEvent:theEvent];
//                return;
//            }
//        }
//        // let's get out of quick move mode
//        [self sendAbortQuickMove];
//    }
//
//    if (tool == FPToolArrow) {
//        // if we hit a knob, resize that shape by its knob
//        if ([_selectedGraphics count]) {
//            for (int i = [_overlayGraphics count] - 1; i >= 0; i--) {
//                FPGraphic *graphic = [_overlayGraphics objectAtIndex:i];
//                if (![_selectedGraphics containsObject:graphic]) continue;
//                int knob = [graphic knobForEvent:theEvent];
//                if (knob != NoKnob) {
//                    [_selectedGraphics removeAllObjects];
//                    [_selectedGraphics addObject:graphic];
//                    [[NSNotificationCenter defaultCenter] postNotificationName:FPSelectionChangedNotification
//                                                                        object:[self window]
//                                                                      userInfo:nil];
//                    [self setNeedsDisplay:YES]; // to fix which knobs are
//                                                // showing
//                    [graphic resizeWithEvent:theEvent byKnob:knob];
//                    return;
//                }
//            }
//        }
//        
//        // if we hit a shape, then:
//        // if holding shift: add or remove shape from selection
//        // if not holding shift:
//        //   if shape is selected, do nothing
//        //   else make shape the only selected shape
//        int i;
//        for (i = [_overlayGraphics count] - 1; i >= 0; i--) {
//            FPGraphic *graphic = [_overlayGraphics objectAtIndex:i];
//            if (([graphic page] == page) &&
//                NSPointInRect(pagePoint, [graphic safeBounds])) {
//                // we hit 'graphic'
//                if ([theEvent modifierFlags] & NSShiftKeyMask) {
//                    [_selectedGraphics invertMembershipForObject:graphic];
//                    [[NSNotificationCenter defaultCenter] postNotificationName:FPSelectionChangedNotification
//                                                                        object:[self window]
//                                                                      userInfo:nil];                    
//                    [self setNeedsDisplay:YES];
//                    return;
//                } else {
//                    if ([theEvent clickCount] == 2) {
//                        if ([graphic isEditable]) {
//                            assert(nil == _editingGraphic);
//                            _editingGraphic = graphic;
//                            [_selectedGraphics removeAllObjects];
//                            [_selectedGraphics addObject:_editingGraphic];
//                            [[NSNotificationCenter defaultCenter] postNotificationName:FPSelectionChangedNotification
//                                                                                object:[self window]
//                                                                              userInfo:nil];                            
//                            [_editingGraphic startEditing];
//                            [self setNeedsDisplay:YES];
//                            return;
//                        }
//                    } else if (![_selectedGraphics containsObject:graphic]) {
//                        [_selectedGraphics removeAllObjects];
//                        [_selectedGraphics addObject:graphic];
//                        [[NSNotificationCenter defaultCenter] postNotificationName:FPSelectionChangedNotification
//                                                                            object:[self window]
//                                                                          userInfo:nil];                        
//                    }
//                }
//                break;
//            }
//        }
//        if (i < 0) { // point didn't hit any shape
//            // if we just stopped editing a shape, keep that selected,
//            // otherwise, select none
//            if (justStoppedEditing == NO) {
//                [_selectedGraphics removeAllObjects];
//                [[NSNotificationCenter defaultCenter] postNotificationName:FPSelectionChangedNotification
//                                                                    object:[self window]
//                                                                  userInfo:nil];                
//            }
//        } else {
//            if ([_selectedGraphics count]) {
//                [self setNeedsDisplay:YES];
//                if ([theEvent modifierFlags] & NSAlternateKeyMask) {
//                    DLog(@"will copy\n");
//                    // if option key is down, and a drag is begun, 
//                    // copy the elements and drag those new ones
//                    NSMutableArray *newGraphics = [NSMutableArray array];
//                    for (int i = 0; i < [_overlayGraphics count]; i++) {
//                        FPGraphic *gr = [_overlayGraphics objectAtIndex:i];
//                        if ([_selectedGraphics containsObject:gr]) {
//                            [newGraphics addObject:[gr copy]];
//                        }
//                    }
//                    assert([newGraphics count] == [_selectedGraphics count]);
//                    [_overlayGraphics addObjectsFromArray:newGraphics];
//                    [_selectedGraphics removeAllObjects];
//                    [_selectedGraphics addObjectsFromArray:newGraphics];
//                    DLog(@"done copying\n");
//                    [[NSNotificationCenter defaultCenter] postNotificationName:FPSelectionChangedNotification
//                                                                        object:[self window]
//                                                                      userInfo:nil];                    
//                }
//                DLog(@"will move\n");
//                [self moveSelectionWithEvent:theEvent];
//                DLog(@"done w/ move\n");
//            }
//        }
//        [self setNeedsDisplay:YES];
//        return;
//    }
//    
//    // we aren't the arrow tool. if we hit a graphic that's editable, and the
//    // tool is that class, edit that graphic. otherwise make a new graphic
//    // and get it up and running.
//    Class toolClass = [[FPToolPaletteController sharedToolPaletteController] 
//        classForCurrentTool];
//    int i;
//    for (i = [_overlayGraphics count] - 1; i >= 0; i--) {
//        FPGraphic *gr = [_overlayGraphics objectAtIndex:i];
//        if ([gr isEditable] && ([gr class] == toolClass) &&
//            ([gr page] == page) &&
//            NSPointInRect(pagePoint, [gr safeBounds])) {
//            if (_editingGraphic)
//                [_editingGraphic stopEditing];
//            _editingGraphic = gr;
//            [_selectedGraphics removeAllObjects];
//            [_selectedGraphics addObject:_editingGraphic];
//            [[NSNotificationCenter defaultCenter] postNotificationName:FPSelectionChangedNotification
//                                                                object:[self window]
//                                                              userInfo:nil];            
//            [_editingGraphic startEditing];
//            [self setNeedsDisplay:YES];
//            break;
//        }
//    }
//    if (i < 0) {  // didn't start editing a graphic
//        FPGraphic *graphic =
//            [[[FPToolPaletteController sharedToolPaletteController] 
//                classForCurrentTool] graphicInDocumentView:self];
//        assert(graphic);
//        [_overlayGraphics addObject:graphic];
//        BOOL keep = [graphic placeWithEvent:theEvent];
//        if (keep == NO) {
//            [_overlayGraphics removeLastObject];
//        } else {
//            if ([graphic isEditable]) {
//                [_selectedGraphics removeAllObjects];
//                assert(nil == _editingGraphic);
//                _editingGraphic = graphic;
//                [_selectedGraphics removeAllObjects];
//                [_selectedGraphics addObject:_editingGraphic];
//                [[NSNotificationCenter defaultCenter] postNotificationName:FPSelectionChangedNotification
//                                                                    object:[self window]
//                                                                  userInfo:nil];                
//                [_editingGraphic startEditing];
//                [self setNeedsDisplay:YES];
//            }
//        }
//    }
//}

//- (BOOL)shouldEnterQuickMove
//{
//    return (nil != _editingGraphic);
//}
//
//- (void)beginQuickMove:(id)unused
//{
//    NSLog(@"beginQuickMove\n");
//    if (_editingGraphic) {
//        [_editingGraphic stopEditing];
//        _editingGraphic = nil;
//    }
//    [self setNeedsDisplay:YES];
//    _inQuickMove = YES;
//}
//
//- (void)abortQuickMove:(id)unused
//{
//    _inQuickMove = NO;
//    [_selectedGraphics removeAllObjects];
//    _editingGraphic = nil;
//    [[NSNotificationCenter defaultCenter] postNotificationName:FPSelectionChangedNotification
//                                                        object:[self window]
//                                                      userInfo:nil];    
//    [self setNeedsDisplay:YES];
//}
//
//- (void)endQuickMove:(id)unused
//{
//    if (NO == _inQuickMove) return;
//    NSLog(@"endQuickMove\n");
//    _inQuickMove = NO;
//
//    _editingGraphic = [_selectedGraphics anyObject];
//    [self setNeedsDisplay:YES];
//    [_editingGraphic startEditing];
//}

- (void)toolChosen:(id)unused
{
    if (_editingGraphic) {
        [_editingGraphic stopEditing];
        _editingGraphic = nil;
        [self setNeedsDisplay:YES];
    }
    //[[self window] makeFirstResponder:[self window]];
}

- (IBAction)placeImage:(id)sender
{
    NSLog(@"DocView's plageImage\n");
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel beginSheetForDirectory:nil
                             file:nil
                            types:nil
                   modalForWindow:[self window]
                    modalDelegate:self
                   didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:)
                      contextInfo:nil];
}

//- (void)openPanelDidEnd:(NSOpenPanel *)panel
//             returnCode:(int)returnCode
//            contextInfo:(void *)contextInfo
//{
//    if (NSOKButton != returnCode) return;
//
//    NSImage *image = [[[NSImage alloc]
//                       initWithContentsOfFile:[panel filename]] autorelease];
//
//    if (nil == image) {
//        // failed to open
//        // TODO(adlr): notify user that open failed
//        return;
//    }
//    FPImage *img = [[FPImage alloc] initInDocumentView:self
//                                             withImage:image];
//
//    [_overlayGraphics addObject:img];
//    [self setNeedsDisplay:YES];
//}

//#pragma mark -
//#pragma mark Printing Methods
//
//- (BOOL)knowsPageRange:(NSRangePointer)range
//{
//    range->location = 1;
//    range->length = [_pdf_document pageCount];
//    NSLog(@"page range: %d,%d\n", range->location, range->length);
//    return YES;
//}
//
//// indexed from 1, not 0
//- (NSRect)rectForPage:(int)page
//{
//    assert(page >= 1);
//    assert(page <= [_pdf_document pageCount]);
//    page--; // now indexed from 0
//    // PageBorderSize
//    NSRect ret;
//    ret.size = [self sizeForPage:page];
//    ret.origin.x = PageBorderSize;
//    ret.origin.y = PageBorderSize;
//    for (int i = 0; i < page; i++) {
//        ret.origin.y += [self sizeForPage:i].height + PageBorderSize;
//    }
//    return ret;
//}
//
//// for now, we'll scale the document as a whole such that each page will fit
//// in the printer sized page, and we'll scale up as much as possible
//
//- (void)beginDocument
//{
//    // first calculate the max page size in the PDF w/o using the scaling
//    // factor
//    NSSize maxPageSize = NSMakeSize(0.0, 0.0);
//    for (unsigned int i = 0; i < [_pdf_document pageCount]; i++) {
//        PDFPage *pg = [_pdf_document pageAtIndex:i];
//        NSSize sz = [pg boundsForBox:_box].size;
//        if (90 == ([pg rotation] % 180))
//            sz = NSMakeSize(sz.height, sz.width);
//        if (sz.width > maxPageSize.width)
//            maxPageSize.width = sz.width;
//        if (sz.height > maxPageSize.height)
//            maxPageSize.height = sz.height;
//    }
//    // now, how big is the printed page?
//    NSSize printSize = [[_doc printInfo] paperSize];
//    // printed page is how many times as big as the pdf?
//    float heightRatio =  printSize.height / maxPageSize.height;
//    float widthRatio =  printSize.width / maxPageSize.width;
//    float maxRatio = MIN(heightRatio, widthRatio);
//    _scale_factor = maxRatio;
//    [self setFrame:[self frame]];
//    [super beginDocument];
//}


//#pragma mark -
//#pragma mark Opening and Saving Methods

//- (NSArray *)archivalOverlayGraphics
//{
//    NSMutableArray *arr = [NSMutableArray array];
//    for (unsigned int i = 0; i < [_overlayGraphics count]; i++) {
//        [arr
//         addObject:[[_overlayGraphics objectAtIndex:i] archivalDictionary]];
//    }
//    return arr;
//}
//
//- (void)setOverlayGraphicsFromArray:(NSArray *)arr
//{
//    [_overlayGraphics removeAllObjects];
//    for (unsigned int i = 0; i < [arr count]; i++) {
//        [_overlayGraphics addObject:
//            [FPGraphic graphicFromArchivalDictionary:[arr objectAtIndex:i]
//                                      inDocumentView:self]];
//    }
//}

@end
