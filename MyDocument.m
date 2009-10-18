//
//  MyDocument.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 7/4/06.
//  Copyright Andrew de los Reyes 2006 . All rights reserved.
//

#import "MyDocument.h"
#import "FPArchivalDictionaryUpgrader.h"
#import "FPLogging.h"

//static NSString *nativeDocumentFormat = @"FormulatePro Document";

static NSString* MyDocToolbarIdentifier =
    @"info.adlr.formulatepro.documenttoolbaridentifier";
static NSString *MyDocToolbarIdentifierZoomIn =
    @"info.adlr.formulatepro.documenttoolbaridentifier.zoomin";
static NSString *MyDocToolbarIdentifierZoomOut =
    @"info.adlr.formulatepro.documenttoolbaridentifier.zoomout";
static NSString *MyDocToolbarIdentifierOneUpTwoUpBook =
    @"info.adlr.formulatepro.documenttoolbaridentifier.oneuptwoupBook";
static NSString *MyDocToolbarIdentifierSingleContinuous =
    @"info.adlr.formulatepro.documenttoolbaridentifier.singlecontinuous";
static NSString *MyDocToolbarIdentifierNextPage =
    @"info.adlr.formulatepro.documenttoolbaridentifier.nextpage";
static NSString *MyDocToolbarIdentifierPreviousPage =
    @"info.adlr.formulatepro.documenttoolbaridentifier.previouspage";

@interface MyDocument (Private)
- (void)setupToolbar;
@end

@implementation MyDocument

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return
        // nil.
        _pdf_document = nil;
        _tempOverlayGraphics = nil;
        _print_original_pdf = [NSNumber numberWithBool:YES];
    }
    return self;
}

- (void)dealloc
{
    [_originalPDFData release];
    [_one_up_vs_two_up_vs_book release];
    [_single_vs_continuous release];
    [_pdf_document release];
    [super dealloc];
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document
    // supports multiple NSWindowControllers, you should remove this method
    // and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController
    // has loaded the document's window.
    
	// Load PDF.
//	if ([self fileName])
//	{
//        // TODO(adlr): report nsdata error to the user
//        _originalPDFData = [NSData dataWithContentsOfURL:[self fileURL]
//                                                 options:0
//                                                   error:nil];
//        if (nil == _originalPDFData) {
//            // report error.
//            return;
//        }
//        [_originalPDFData retain];
//		_pdf_document = [[PDFDocument alloc] initWithData:_originalPDFData];
//        if (nil == _pdf_document) {
//            // report error.
//            return;
//        }
    if (_pdf_document) {
        [_document_view setPDFDocument:_pdf_document];
        if (_tempOverlayGraphics) {
            if ([FPArchivalDictionaryUpgrader currentVersion] > _tempOverlayGraphicsVersion) {
                [FPArchivalDictionaryUpgrader upgradeGraphicsInPlace:_tempOverlayGraphics
                                                         fromVersion:_tempOverlayGraphicsVersion];
            }
            [_document_view setOverlayGraphicsFromArray:_tempOverlayGraphics];
            [_tempOverlayGraphics release];
        }
	} else {
        assert(0);
    }
    
    // toolbar item views
    [_one_up_vs_two_up_vs_book retain];
    [_one_up_vs_two_up_vs_book removeFromSuperview];

    [_single_vs_continuous retain];
    [_single_vs_continuous removeFromSuperview];
    
//    switch ([_pdf_view displayMode]) {
//        case kPDFDisplaySinglePage:
//            [_pdf_view setDisplaysAsBook:NO];
//            [_one_up_vs_two_up_vs_book setSelectedSegment:0];
//            [_single_vs_continuous setSelectedSegment:0];
//            break;
//        case kPDFDisplaySinglePageContinuous:
//            [_pdf_view setDisplaysAsBook:NO];
//            [_one_up_vs_two_up_vs_book setSelectedSegment:0];
//            [_single_vs_continuous setSelectedSegment:1];
//            break;
//        case kPDFDisplayTwoUp:
//            if ([_pdf_view displaysAsBook]) {
//                [_one_up_vs_two_up_vs_book setSelectedSegment:2];
//                [_single_vs_continuous setSelectedSegment:0];
//            } else {
//                [_one_up_vs_two_up_vs_book setSelectedSegment:1];
//                [_single_vs_continuous setSelectedSegment:0];
//            }
//            break;
//        case kPDFDisplayTwoUpContinuous:
//            if ([_pdf_view displaysAsBook]) {
//                [_one_up_vs_two_up_vs_book setSelectedSegment:2];
//                [_single_vs_continuous setSelectedSegment:1];
//            } else {
//                [_one_up_vs_two_up_vs_book setSelectedSegment:1];
//                [_single_vs_continuous setSelectedSegment:1];
//            }
//            break;
//    }
    
    [self setupToolbar];
}

//+ (NSArray *)readableTypes
//{
//    return [NSArray arrayWithObjects:nativeDocumentFormat,
//                                     @"PDF Document",
//                                     nil];
//}
//
//+ (NSArray *)writableTypes
//{
//    return [NSArray arrayWithObject:nativeDocumentFormat];
//}
//
//+ (BOOL)isNativeType:(NSString *)aType
//{
//    return [aType isEqualToString:nativeDocumentFormat];
//}

//- (NSData *)dataRepresentationOfType:(NSString *)aType
//{
    // Insert code here to write your document from the given data.  You can
    // also choose to override -fileWrapperRepresentationOfType: or
    // -writeToFile:ofType: instead.
    
    // For applications targeted for Tiger or later systems, you should use
    // the new Tiger API -dataOfType:error:.  In this case you can also choose
    // to override -writeToURL:ofType:error:, -fileWrapperOfType:error:, or
    // -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

//    return nil;
//}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    DLog(@"dataOfType:%@\n", typeName);
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    DLog(@"line %d\n", __LINE__);
    [d setObject:_originalPDFData forKey:@"originalPDFData"];
    DLog(@"line %d\n", __LINE__);
    [d setObject:[_document_view archivalOverlayGraphics]
          forKey:@"archivalOverlayGraphics"];
    DLog(@"line %d\n", __LINE__);
    [d setObject:[NSNumber numberWithInt:[FPArchivalDictionaryUpgrader currentVersion]]
          forKey:@"version"];
    DLog(@"line %d\n", __LINE__);
    

    NSString *errorDesc;
    NSData *ret =
        [NSPropertyListSerialization
         dataFromPropertyList:d
                       format:NSPropertyListXMLFormat_v1_0
             errorDescription:&errorDesc];
    if (nil == ret) {
        DLog(@"error: %@\n", errorDesc);
        [errorDesc release];
        return [NSData data];
    }
    return ret;
}

- (BOOL)readFromData:(NSData *)data
              ofType:(NSString *)typeName
               error:(NSError **)outError
{
    DLog(@"readFromData:0x%08x ofType:%@\n", (unsigned)data, typeName);
    if ([typeName isEqualToString:@"PDF Document"]) {
        _originalPDFData = [data retain];
        [self setFileURL:nil];  // causes document to be "untitled" and otherwise
                                // act like a brand new document. e.g. file->save
                                // pops the save-as dialog
    } else if ([typeName isEqualToString:@"FormulatePro Document"]) {
        NSMutableDictionary *dict =
            [NSPropertyListSerialization
             propertyListFromData:data
                 mutabilityOption:NSPropertyListMutableContainersAndLeaves
                           format:nil
                 errorDescription:nil];
        assert(nil != dict);
        // TODO(adlr): check for error, version, convert these keys to
        // constants
        _originalPDFData = [[dict objectForKey:@"originalPDFData"] retain];
        _tempOverlayGraphics = [[dict objectForKey:@"archivalOverlayGraphics"]
                                retain];
        _tempOverlayGraphicsVersion = [[dict objectForKey:@"version"] intValue];
        if ([FPArchivalDictionaryUpgrader currentVersion] < _tempOverlayGraphicsVersion) {
            *outError = [NSError errorWithDomain:@"info.adlr.FormulatePro.ErrorDomain"
                                            code:1
                                        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                            @"Bad Version.",NSLocalizedDescriptionKey,
                                            @"The file was created with a newer version of "
                                            @"FormulatePro.",NSLocalizedFailureReasonErrorKey,
                                            nil]];
            return NO;
        }
    }
    _pdf_document = [[PDFDocument alloc] initWithData:_originalPDFData];
    if (nil == _pdf_document) {
        // report error
        DLog(@"error with PDF format!\n");
        return NO;
    }
    return YES;
}

- (IBAction)zoomIn:(id)sender
{
    [_document_view zoomIn:sender];
}

- (IBAction)zoomOut:(id)sender
{
    [_document_view zoomOut:sender];
}

- (IBAction)toggleContinuous:(id)sender
{
//    PDFDisplayMode new_mode = kPDFDisplaySinglePage;
//    
//    if (sender == _single_vs_continuous) {
//        int ss = [_single_vs_continuous selectedSegment];
//        switch([_pdf_view displayMode]) {
//            case kPDFDisplaySinglePage: // fall through
//            case kPDFDisplaySinglePageContinuous:
//                new_mode =
//                    (ss==1?kPDFDisplaySinglePageContinuous:
//                           kPDFDisplaySinglePage); break;
//            case kPDFDisplayTwoUp: // fall through
//            case kPDFDisplayTwoUpContinuous:
//                new_mode = (ss==1?kPDFDisplayTwoUpContinuous:
//                                  kPDFDisplayTwoUp); break;
//        }
//    } else {
//        switch([_pdf_view displayMode]) {
//            case kPDFDisplaySinglePage:
//                new_mode = kPDFDisplaySinglePageContinuous; break;
//            case kPDFDisplaySinglePageContinuous:
//                new_mode = kPDFDisplaySinglePage; break;
//            case kPDFDisplayTwoUp:
//                new_mode = kPDFDisplayTwoUpContinuous; break;
//            case kPDFDisplayTwoUpContinuous:
//                new_mode = kPDFDisplayTwoUp; break;
//        }
//    }
//    [_pdf_view setDisplayMode:new_mode];    
}

- (IBAction)toggleOneUpTwoUpBookMode:(id)sender
{
//    PDFDisplayMode new_up_mode = kPDFDisplaySinglePage;
//    BOOL book_mode = NO;
//    int sc_idx = 0;
//    
//    if (sender == _one_up_vs_two_up_vs_book) {
//        int cont =
//            [_pdf_view displayMode] == kPDFDisplaySinglePageContinuous ||
//            [_pdf_view displayMode] == kPDFDisplayTwoUpContinuous;
//        if ([_one_up_vs_two_up_vs_book selectedSegment] == 0) {
//            if (cont)
//                new_up_mode = kPDFDisplaySinglePageContinuous;
//            else
//                new_up_mode = kPDFDisplaySinglePage;
//        } else {
//            if (cont)
//                new_up_mode = kPDFDisplayTwoUpContinuous;
//            else
//                new_up_mode = kPDFDisplayTwoUp;
//        }
//        [_pdf_view setDisplaysAsBook:
//         ([_one_up_vs_two_up_vs_book selectedSegment] == 2)];
//        [_pdf_view setDisplayMode:new_up_mode];
//        return;
//    }
//    
//    switch([_pdf_view displayMode]) {
//        case kPDFDisplaySinglePage:
//            new_up_mode = kPDFDisplayTwoUp;
//            book_mode = NO;
//            sc_idx = 1;
//            break;
//        case kPDFDisplaySinglePageContinuous:
//            new_up_mode = kPDFDisplayTwoUpContinuous;
//            book_mode = NO;
//            sc_idx = 1;
//            break;
//        case kPDFDisplayTwoUp:
//            if ([_pdf_view displaysAsBook] == NO) {
//                new_up_mode = [_pdf_view displayMode];
//                book_mode = YES;
//                sc_idx = 2;
//            } else {
//                new_up_mode = kPDFDisplaySinglePage;
//                book_mode = NO;
//                sc_idx = 3;
//            }
//            break;
//        case kPDFDisplayTwoUpContinuous:
//            if ([_pdf_view displaysAsBook] == NO) {
//                new_up_mode = [_pdf_view displayMode];
//                book_mode = YES;
//                sc_idx = 2;
//            } else {
//                new_up_mode = kPDFDisplaySinglePageContinuous;
//                book_mode = NO;
//                sc_idx = 3;
//            }
//            break;
//            
//    }
//    [_pdf_view setDisplayMode:new_up_mode];
//    if ([_pdf_view displaysAsBook] != book_mode)
//        [_pdf_view setDisplaysAsBook:book_mode];
//    [_one_up_vs_two_up_vs_book setSelectedSegment:sc_idx];
}

- (IBAction)goToNextPage:(id)sender
{
    [_document_view nextPage];
}

- (IBAction)goToPreviousPage:(id)sender
{
    [_document_view previousPage];
}

#pragma mark -
#pragma mark NSToolbar methods

- (void) setupToolbar {
    // Create a new toolbar instance, and attach it to our document window 
    NSToolbar *toolbar =
        [[[NSToolbar alloc] initWithIdentifier:MyDocToolbarIdentifier]
         autorelease];
    
    // Set up toolbar properties: Allow customization, give a default display
    // mode, and remember state in user defaults 
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
    [toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
    
    // We are the delegate
    [toolbar setDelegate: self];
    
    // Attach the toolbar to the document window 
    [_document_window setToolbar:toolbar];
}

- (NSToolbarItem *) toolbar:(NSToolbar *)toolbar
      itemForItemIdentifier:(NSString *)itemIdent
  willBeInsertedIntoToolbar:(BOOL)willBeInserted {
    // Required delegate method:  Given an item identifier, this method
    // returns an item. The toolbar will use this method to obtain toolbar
    // items that can be displayed in the customization sheet, or in the
    // toolbar itself 
    NSToolbarItem *toolbarItem = nil;
    
    if ([itemIdent isEqual: MyDocToolbarIdentifierZoomIn]) {
        toolbarItem =
            [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdent]
             autorelease];
        
        // Set the text label to be displayed in the toolbar and customization
        // palette 
        [toolbarItem setLabel: @"Zoom In"];
        [toolbarItem setPaletteLabel: @"Zoom In"];
        
        // Set up a reasonable tooltip, and image   Note, these aren't
        // localized, but you will likely want to localize many of the item's
        // properties 
        [toolbarItem setToolTip: @"Zoom In"];
        [toolbarItem setImage: [NSImage imageNamed: @"viewmag+"]];
        
        // Tell the item what message to send when it is clicked 
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(zoomIn:)];
    } else if ([itemIdent isEqual: MyDocToolbarIdentifierZoomOut]) {
        toolbarItem =
            [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent]
             autorelease];
        
        // Set the text label to be displayed in the toolbar and customization
        // palette 
        [toolbarItem setLabel: @"Zoom Out"];
        [toolbarItem setPaletteLabel: @"Zoom Out"];
        
        // Set up a reasonable tooltip, and image   Note, these aren't
        // localized, but you will likely want to localize many of the item's
        // properties 
        [toolbarItem setToolTip: @"Zoom Out"];
        [toolbarItem setImage: [NSImage imageNamed: @"viewmag-"]];
        
        // Tell the item what message to send when it is clicked 
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(zoomOut:)];
    } else if ([itemIdent isEqual: MyDocToolbarIdentifierOneUpTwoUpBook]) {
        toolbarItem =
            [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent]
             autorelease];
        
        // Set the text label to be displayed in the toolbar and customization
        // palette 
        [toolbarItem setLabel: @"One Up, Two Up, Book Mode"];
        [toolbarItem setPaletteLabel: @"One Up, Two Up, Book Mode"];
        
        // Set up a reasonable tooltip, and image   Note, these aren't
        // localized, but you will likely want to localize many of the item's
        // properties 
        [toolbarItem setToolTip: @"One Up, Two Up, Book Mode"];
        //[toolbarItem setImage:
        //    [NSImage imageNamed:@"SaveDocumentItemImage"]];
        [toolbarItem setView:_one_up_vs_two_up_vs_book];
        [toolbarItem setMinSize:
            NSMakeSize(NSWidth([_one_up_vs_two_up_vs_book frame]),
                       NSHeight([_one_up_vs_two_up_vs_book frame]))];
        [toolbarItem setMaxSize:
            NSMakeSize(NSWidth([_one_up_vs_two_up_vs_book frame]),
                       NSHeight([_one_up_vs_two_up_vs_book frame]))];
        
        // Tell the item what message to send when it is clicked 
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(toggleOneUpTwoUpBookMode:)];
    } else if ([itemIdent isEqual: MyDocToolbarIdentifierSingleContinuous]) {
        toolbarItem =
            [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent]
             autorelease];
        
        // Set the text label to be displayed in the toolbar and customization
        // palette 
        [toolbarItem setLabel: @"(Non) Continuous"];
        [toolbarItem setPaletteLabel: @"(Non) Continuous"];
        
        // Set up a reasonable tooltip, and image   Note, these aren't
        // localized, but you will likely want to localize many of the item's
        // properties 
        [toolbarItem setToolTip:
            @"Display the entire document or just current spread"];
        //[toolbarItem setImage:
        //    [NSImage imageNamed: @"SaveDocumentItemImage"]];
        [toolbarItem setView:_single_vs_continuous];
        [toolbarItem setMinSize:
            NSMakeSize(NSWidth([_single_vs_continuous frame]),
                       NSHeight([_single_vs_continuous frame]))];
        [toolbarItem setMaxSize:
            NSMakeSize(NSWidth([_single_vs_continuous frame]),
                       NSHeight([_single_vs_continuous frame]))];
        [toolbarItem setAutovalidates:YES];
        
        // Tell the item what message to send when it is clicked 
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(toggleContinuous:)];
    } else if ([itemIdent isEqual: MyDocToolbarIdentifierNextPage]) {
        toolbarItem =
            [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent]
             autorelease];
        
        // Set the text label to be displayed in the toolbar and customization
        // palette 
        [toolbarItem setLabel: @"Next Page"];
        [toolbarItem setPaletteLabel: @"Next Page"];
        
        // Set up a reasonable tooltip, and image   Note, these aren't
        // localized, but you will likely want to localize many of the item's
        // properties 
        [toolbarItem setToolTip: @"Next Page"];
        [toolbarItem setImage: [NSImage imageNamed: @"next"]];
        
        // Tell the item what message to send when it is clicked 
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(goToNextPage:)];
    } else if ([itemIdent isEqual: MyDocToolbarIdentifierPreviousPage]) {
        toolbarItem =
            [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent]
             autorelease];
        
        // Set the text label to be displayed in the toolbar and customization
        // palette 
        [toolbarItem setLabel: @"Previous Page"];
        [toolbarItem setPaletteLabel: @"Previous Page"];
        
        // Set up a reasonable tooltip, and image   Note, these aren't
        // localized, but you will likely want to localize many of the item's
        // properties
        [toolbarItem setToolTip: @"Previous Page"];
        [toolbarItem setImage: [NSImage imageNamed: @"previous"]];
        
        // Tell the item what message to send when it is clicked 
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(goToPreviousPage:)];
    } else {
        // itemIdent refered to a toolbar item that is not provide or
        // supported by us or cocoa. Returning nil will inform the toolbar
        // this kind of item is not supported 
        toolbarItem = nil;
    }
    return toolbarItem;
}

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar {
    // Required delegate method:  Returns the ordered list of items to be
    // shown in the toolbar by default. If during the toolbar's
    // initialization, no overriding values are found in the user defaults, or
    // if the user chooses to revert to the default items this set will be
    // used
    return [NSArray arrayWithObjects:
        MyDocToolbarIdentifierZoomIn,
        MyDocToolbarIdentifierZoomOut,
        NSToolbarSeparatorItemIdentifier,
        NSToolbarFlexibleSpaceItemIdentifier,
        NSToolbarCustomizeToolbarItemIdentifier,
        nil];
}

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar {
    // Required delegate method:  Returns the list of all allowed items by
    // identifier.  By default, the toolbar does not assume any items are
    // allowed, even the separator.  So, every allowed item must be explicitly
    // listed. The set of allowed items is used to construct the customization
    // palette 
    return [NSArray arrayWithObjects:
        MyDocToolbarIdentifierZoomIn,
        MyDocToolbarIdentifierZoomOut,
        //MyDocToolbarIdentifierOneUpTwoUpBook,
        //MyDocToolbarIdentifierSingleContinuous,
        MyDocToolbarIdentifierPreviousPage,
        MyDocToolbarIdentifierNextPage,
        
        NSToolbarCustomizeToolbarItemIdentifier,
        NSToolbarFlexibleSpaceItemIdentifier,
        NSToolbarSpaceItemIdentifier,
        NSToolbarSeparatorItemIdentifier,
        nil];
}

- (IBAction)placeImage:(id)sender;
{
    DLog(@"MyDocument's plageImage\n");
    [_document_view placeImage:sender];
}

#pragma mark -
#pragma mark Printing Methods

// This method will only be invoked on Mac 10.4 and later. If you're writing
// an application that has to run on 10.3.x and earlier you should override
// -printShowingPrintPanel: instead.
- (NSPrintOperation *)printOperationWithSettings:(NSDictionary *)printSettings
                                           error:(NSError **)outError {
    DLog(@"print operations\n");
    // Create a view that will be used just for printing.
    //NSSize documentSize = [self documentSize];
    //SKTRenderingView *renderingView = [[SKTRenderingView alloc]
    //    initWithFrame:NSMakeRect(0.0, 0.0, documentSize.width,
    //                             documentSize.height)
    //         graphics:[self graphics]];
    FPDocumentView *printView = [_document_view printableCopy];
    
    // Create a print operation.
    NSPrintOperation *printOperation =
        [NSPrintOperation printOperationWithView:printView
                                       printInfo:[self printInfo]];
    [printView release];
    
    // Specify that the print operation can run in a separate thread. This
    // will cause the print progress panel to appear as a sheet on the
    // document window.
    [printOperation setCanSpawnSeparateThread:YES];
    
    // Set any print settings that might have been specified in a Print
    // Document Apple event. We do it this way because we shouldn't be
    // mutating the result of [self printInfo] here, and using the result of
    // [printOperation printInfo], a copy of the original print info, means we
    // don't have to make yet another temporary copy of [self printInfo].
    [[[printOperation printInfo] dictionary]
        addEntriesFromDictionary:printSettings];
    //[[[printOperation printInfo] dictionary]
    //    setValue:[NSNumber numberWithInt:[_pdf_document pageCount]]
    //      forKey:@"NSPagesAcross"];
    [[[printOperation printInfo] dictionary]
        setValue:[NSNumber numberWithInt:[_pdf_document pageCount]]
          forKey:@"NSLastPage"];
    
    // add option for (not) printing original PDF
    // this uses deprecated method b/c the replacement method is 10.5 only
    [printOperation setAccessoryView:_print_accessory_view];
    
    // We don't have to autorelease the print operation because
    // +[NSPrintOperation printOperationWithView:printInfo:] of course already
    // autoreleased it. Nothing in this method can fail, so we never return
    // nil, so we don't have to worry about setting *outError.
    return printOperation;
}

- (void)setPrintInfo:(NSPrintInfo *)printInfo
{
    DLog(@"setPrintInfo\n");
    DLog(@"print info dict: %@\n", [printInfo dictionary]);
    [super setPrintInfo:printInfo];
}

- (BOOL)drawsOriginalPDF
{
    return [_print_original_pdf boolValue];
}

@end
