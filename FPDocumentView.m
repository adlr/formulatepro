#import "FPDocumentView.h"

@implementation FPDocumentView

// Draw this many pixels around each page. used for the shadow
static const float PageBorderSize = 10.0;

- (NSRect)frame
{
    if (nil == _pdf_document) {
        NSLog(@"small frame\n");
        return NSMakeRect(0.0, 0.0, 10.0, 10.0);
    }
    NSRect ret = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    for (unsigned int i = 0; i < [_pdf_document pageCount]; i++) {
        PDFPage *pg = [_pdf_document pageAtIndex:i];
        NSRect bounds = [pg boundsForBox:_box];
        if (NSWidth(bounds) > NSWidth(ret))
            ret.size.width = NSWidth(bounds);
        ret.size.height += (NSHeight(bounds) + PageBorderSize);
    }
    ret.size.width += 2.0 * PageBorderSize;
    ret.size.height += PageBorderSize;
    return ret;
}

- (id)initWithFrame:(NSRect)frameRect
{
    NSLog(@"init w/ frame: %@\n", NSStringFromRect(frameRect));
    frameRect = [self frame];
    if ((self = [super initWithFrame:frameRect]) != nil) {
        // Add initialization code here
        _pdf_document = nil;
        _box = kPDFDisplayBoxCropBox;
    }
    return self;
}

- (void)setPDFDocument:(PDFDocument *)pdf_document
{
    [_pdf_document release];
    _pdf_document = pdf_document;
    NSLog(@"set pdf doc\n");
    [self setFrame:[self frame]];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect
{
    NSGraphicsContext* theContext = [NSGraphicsContext currentContext];
    NSLog(@"draw rect\n");
    [[NSColor grayColor] set];
    NSRectFill([self frame]);
    if (nil == _pdf_document) return;
    [[NSColor whiteColor] set];
    float how_far_down = PageBorderSize;
    NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
    [shadow setShadowColor:[NSColor blackColor]];
    [shadow setShadowBlurRadius:5.0];
    [shadow setShadowOffset:NSMakeSize(0.0, -2.0)];
    for (unsigned int i = 0; i < [_pdf_document pageCount]; i++) {
        PDFPage *pg = [_pdf_document pageAtIndex:i];
        NSSize sz = [pg boundsForBox:_box].size;
        NSRect page_rect = NSMakeRect(PageBorderSize, how_far_down,
                              sz.width, sz.height);
        [theContext saveGraphicsState];
        [shadow set];
        NSRectFill(page_rect);
        [theContext restoreGraphicsState];
        NSAffineTransform *at = [NSAffineTransform transform];
        [at scaleXBy:1.0 yBy:(-1.0)];
        [at translateXBy:PageBorderSize yBy:(-1.0*(how_far_down + NSHeight(page_rect)))];
        //[at translateXBy:30.0 yBy:30.0];
        [at concat];
        [pg drawWithBox:_box];
        [at invert];
        [at concat];

        how_far_down += NSHeight(page_rect) + PageBorderSize;
    }
}

static NSTextView *newEditor() {
    // This method returns an NSTextView whose NSLayoutManager has a refcount of 1.  It is the caller's responsibility to release the NSLayoutManager.  This function is only for the use of the following method.
    NSLayoutManager *lm = [[NSLayoutManager allocWithZone:NULL] init];
    NSTextContainer *tc = [[NSTextContainer allocWithZone:NULL] initWithContainerSize:NSMakeSize(1.0e6, 1.0e6)];
    NSTextView *tv = [[NSTextView allocWithZone:NULL] initWithFrame:NSMakeRect(0.0, 0.0, 100.0, 100.0) textContainer:nil];

    [lm addTextContainer:tc];
    [tc release];

    [tv setTextContainerInset:NSMakeSize(0.0, 0.0)];
    [tv setDrawsBackground:NO];
    [tv setAllowsUndo:YES];
    [tc setTextView:tv];
    [tv release];

    return tv;
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    static NSTextView *_editor = nil;
    NSTextStorage *contents = [[NSTextStorage allocWithZone:[self zone]] init];
    NSLog(@"mouse down\n");
    if (_editor == nil) {
        NSLog(@"allocating\n");
        //_editor = [[NSTextView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 40.0, 40.0)];
		//[[_editor textContainer] setLineFragmentPadding:1.0];
        _editor = newEditor();
        assert(_editor);
	}
    [[_editor textContainer] setWidthTracksTextView:NO];
    [[_editor textContainer] setContainerSize:NSMakeSize(300.0, 300.0)];
    [_editor setHorizontallyResizable:YES]; //x
    [_editor setMinSize:NSMakeSize(10.0, 15.0)];
    [_editor setMaxSize:NSMakeSize(1.0e6, 1.0e6)];

    [[_editor textContainer] setHeightTracksTextView:NO];
    [_editor setVerticallyResizable:YES]; //x
	
	//if (_isAutoSized) {
		//[[_editor textContainer] setContainerSize:NSMakeSize(300.0, 300.0)];
	//} else {
	//	[[_editor textContainer] setContainerSize:_bounds.size];
	//}
    [_editor setFrame:NSMakeRect(30,100,10,15)];
    [contents addLayoutManager:[_editor layoutManager]];
    [self addSubview:_editor];
    //[_editor setDelegate:self];
    [[self window] makeFirstResponder:_editor];
}

- (void)textDidChange:(NSNotification *)notification {
    NSSize textSize;
    NSRect myBounds = NSMakeRect(30, 100, 0, 0);
    BOOL fixedWidth = ([[notification object] isHorizontallyResizable] ? NO : YES);
    
    //textSize = [self requiredSize:(fixedWidth ? NSWidth(myBounds) : 1.0e6)];
    textSize = NSMakeSize(800,1000);
    
    if ((textSize.width > myBounds.size.width) || (textSize.height > myBounds.size.height)) {
        [self setBounds:NSMakeRect(myBounds.origin.x, myBounds.origin.y, ((!fixedWidth && (textSize.width > myBounds.size.width)) ? textSize.width : myBounds.size.width), ((textSize.height > myBounds.size.height) ? textSize.height : myBounds.size.height))];
        // MF: For multiple editors we must fix up the others...  but we don't support multiple views of a document yet, and that's the only way we'd ever have the potential for multiple editors.
    }
}

@end
