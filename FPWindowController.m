//
//  FPWindowController.m
//  FormulatePro
//
//  Created by Andrew de los Reyes on 1/21/08.
//  Copyright 2008 Andrew de los Reyes. All rights reserved.
//

#import "FPWindowController.h"
#import "MyDocument.h"
#import "FPLogging.h"


@implementation FPWindowController

- (id)init {

    self = [super initWithWindowNibName:@"MyDocument"];
    if (self) {
        // do stuff
    }
    return self;
}

#pragma mark -
#pragma mark Overrides of NSWindowController Methods

- (void)setDocument:(NSDocument *)document
{
    [super setDocument:document];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    DLog(@"FPWindowController: windowDidLoad called\n");
    
    [_graphicsView bind:FPDocumentViewSelectionIndexesBindingName
               toObject:_graphicsController
            withKeyPath:@"selectionIndexes"
                options:nil];
    [_graphicsView bind:FPDocumentViewGraphicsBindingName
               toObject:self
            withKeyPath:[NSString stringWithFormat:@"%@.%@", @"document", @"overlayGraphics"]
                options:nil];
    [_graphicsView setPDFDocument:[(MyDocument*)[self document] pdfDocument]];
    [_graphicsView setFrame:[_graphicsView idealFrame]];
}

- (id)valueForUndefinedKey:(NSString *)key
{
    return [super valueForUndefinedKey:key];
}

#pragma mark -
#pragma mark NSToolbar methods

//- (IBAction)goToNextPage:(id)sender
//{
//    //[_document_view nextPage];
//}
//
//- (IBAction)goToPreviousPage:(id)sender
//{
//    //[_document_view previousPage];
//}
//
//- (void) setupToolbar {
//    // Create a new toolbar instance, and attach it to our document window 
//    NSToolbar *toolbar =
//        [[[NSToolbar alloc] initWithIdentifier:MyDocToolbarIdentifier]
//         autorelease];
//    
//    // Set up toolbar properties: Allow customization, give a default display
//    // mode, and remember state in user defaults 
//    [toolbar setAllowsUserCustomization:YES];
//    [toolbar setAutosavesConfiguration:YES];
//    [toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
//    
//    // We are the delegate
//    [toolbar setDelegate: self];
//    
//    // Attach the toolbar to the document window 
//    [_document_window setToolbar:toolbar];
//}
//
//- (NSToolbarItem *) toolbar:(NSToolbar *)toolbar
//      itemForItemIdentifier:(NSString *)itemIdent
//  willBeInsertedIntoToolbar:(BOOL)willBeInserted {
//    // Required delegate method:  Given an item identifier, this method
//    // returns an item. The toolbar will use this method to obtain toolbar
//    // items that can be displayed in the customization sheet, or in the
//    // toolbar itself 
//    NSToolbarItem *toolbarItem = nil;
//    
//    if ([itemIdent isEqual: MyDocToolbarIdentifierZoomIn]) {
//        toolbarItem =
//            [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdent]
//             autorelease];
//        
//        // Set the text label to be displayed in the toolbar and customization
//        // palette 
//        [toolbarItem setLabel: @"Zoom In"];
//        [toolbarItem setPaletteLabel: @"Zoom In"];
//        
//        // Set up a reasonable tooltip, and image   Note, these aren't
//        // localized, but you will likely want to localize many of the item's
//        // properties 
//        [toolbarItem setToolTip: @"Zoom In"];
//        [toolbarItem setImage: [NSImage imageNamed: @"viewmag+"]];
//        
//        // Tell the item what message to send when it is clicked 
//        [toolbarItem setTarget: self];
//        [toolbarItem setAction: @selector(zoomIn:)];
//    } else if ([itemIdent isEqual: MyDocToolbarIdentifierZoomOut]) {
//        toolbarItem =
//            [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent]
//             autorelease];
//        
//        // Set the text label to be displayed in the toolbar and customization
//        // palette 
//        [toolbarItem setLabel: @"Zoom Out"];
//        [toolbarItem setPaletteLabel: @"Zoom Out"];
//        
//        // Set up a reasonable tooltip, and image   Note, these aren't
//        // localized, but you will likely want to localize many of the item's
//        // properties 
//        [toolbarItem setToolTip: @"Zoom Out"];
//        [toolbarItem setImage: [NSImage imageNamed: @"viewmag-"]];
//        
//        // Tell the item what message to send when it is clicked 
//        [toolbarItem setTarget: self];
//        [toolbarItem setAction: @selector(zoomOut:)];
//    } else if ([itemIdent isEqual: MyDocToolbarIdentifierOneUpTwoUpBook]) {
//        toolbarItem =
//            [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent]
//             autorelease];
//        
//        // Set the text label to be displayed in the toolbar and customization
//        // palette 
//        [toolbarItem setLabel: @"One Up, Two Up, Book Mode"];
//        [toolbarItem setPaletteLabel: @"One Up, Two Up, Book Mode"];
//        
//        // Set up a reasonable tooltip, and image   Note, these aren't
//        // localized, but you will likely want to localize many of the item's
//        // properties 
//        [toolbarItem setToolTip: @"One Up, Two Up, Book Mode"];
//        //[toolbarItem setImage:
//        //    [NSImage imageNamed:@"SaveDocumentItemImage"]];
//        [toolbarItem setView:_one_up_vs_two_up_vs_book];
//        [toolbarItem setMinSize:
//            NSMakeSize(NSWidth([_one_up_vs_two_up_vs_book frame]),
//                       NSHeight([_one_up_vs_two_up_vs_book frame]))];
//        [toolbarItem setMaxSize:
//            NSMakeSize(NSWidth([_one_up_vs_two_up_vs_book frame]),
//                       NSHeight([_one_up_vs_two_up_vs_book frame]))];
//        
//        // Tell the item what message to send when it is clicked 
//        [toolbarItem setTarget: self];
//        [toolbarItem setAction: @selector(toggleOneUpTwoUpBookMode:)];
//    } else if ([itemIdent isEqual: MyDocToolbarIdentifierSingleContinuous]) {
//        toolbarItem =
//            [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent]
//             autorelease];
//        
//        // Set the text label to be displayed in the toolbar and customization
//        // palette 
//        [toolbarItem setLabel: @"(Non) Continuous"];
//        [toolbarItem setPaletteLabel: @"(Non) Continuous"];
//        
//        // Set up a reasonable tooltip, and image   Note, these aren't
//        // localized, but you will likely want to localize many of the item's
//        // properties 
//        [toolbarItem setToolTip:
//            @"Display the entire document or just current spread"];
//        //[toolbarItem setImage:
//        //    [NSImage imageNamed: @"SaveDocumentItemImage"]];
//        [toolbarItem setView:_single_vs_continuous];
//        [toolbarItem setMinSize:
//            NSMakeSize(NSWidth([_single_vs_continuous frame]),
//                       NSHeight([_single_vs_continuous frame]))];
//        [toolbarItem setMaxSize:
//            NSMakeSize(NSWidth([_single_vs_continuous frame]),
//                       NSHeight([_single_vs_continuous frame]))];
//        [toolbarItem setAutovalidates:YES];
//        
//        // Tell the item what message to send when it is clicked 
//        [toolbarItem setTarget: self];
//        [toolbarItem setAction: @selector(toggleContinuous:)];
//    } else if ([itemIdent isEqual: MyDocToolbarIdentifierNextPage]) {
//        toolbarItem =
//            [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent]
//             autorelease];
//        
//        // Set the text label to be displayed in the toolbar and customization
//        // palette 
//        [toolbarItem setLabel: @"Next Page"];
//        [toolbarItem setPaletteLabel: @"Next Page"];
//        
//        // Set up a reasonable tooltip, and image   Note, these aren't
//        // localized, but you will likely want to localize many of the item's
//        // properties 
//        [toolbarItem setToolTip: @"Next Page"];
//        [toolbarItem setImage: [NSImage imageNamed: @"next"]];
//        
//        // Tell the item what message to send when it is clicked 
//        [toolbarItem setTarget: self];
//        [toolbarItem setAction: @selector(goToNextPage:)];
//    } else if ([itemIdent isEqual: MyDocToolbarIdentifierPreviousPage]) {
//        toolbarItem =
//            [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdent]
//             autorelease];
//        
//        // Set the text label to be displayed in the toolbar and customization
//        // palette 
//        [toolbarItem setLabel: @"Previous Page"];
//        [toolbarItem setPaletteLabel: @"Previous Page"];
//        
//        // Set up a reasonable tooltip, and image   Note, these aren't
//        // localized, but you will likely want to localize many of the item's
//        // properties
//        [toolbarItem setToolTip: @"Previous Page"];
//        [toolbarItem setImage: [NSImage imageNamed: @"previous"]];
//        
//        // Tell the item what message to send when it is clicked 
//        [toolbarItem setTarget: self];
//        [toolbarItem setAction: @selector(goToPreviousPage:)];
//    } else {
//        // itemIdent refered to a toolbar item that is not provide or
//        // supported by us or cocoa. Returning nil will inform the toolbar
//        // this kind of item is not supported 
//        toolbarItem = nil;
//    }
//    return toolbarItem;
//}
//
//- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar {
//    // Required delegate method:  Returns the ordered list of items to be
//    // shown in the toolbar by default. If during the toolbar's
//    // initialization, no overriding values are found in the user defaults, or
//    // if the user chooses to revert to the default items this set will be
//    // used
//    return [NSArray arrayWithObjects:
//        MyDocToolbarIdentifierZoomIn,
//        MyDocToolbarIdentifierZoomOut,
//        NSToolbarSeparatorItemIdentifier,
//        NSToolbarFlexibleSpaceItemIdentifier,
//        NSToolbarCustomizeToolbarItemIdentifier,
//        nil];
//}
//
//- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar {
//    // Required delegate method:  Returns the list of all allowed items by
//    // identifier.  By default, the toolbar does not assume any items are
//    // allowed, even the separator.  So, every allowed item must be explicitly
//    // listed. The set of allowed items is used to construct the customization
//    // palette 
//    return [NSArray arrayWithObjects:
//        MyDocToolbarIdentifierZoomIn,
//        MyDocToolbarIdentifierZoomOut,
//        //MyDocToolbarIdentifierOneUpTwoUpBook,
//        //MyDocToolbarIdentifierSingleContinuous,
//        MyDocToolbarIdentifierPreviousPage,
//        MyDocToolbarIdentifierNextPage,
//        
//        NSToolbarCustomizeToolbarItemIdentifier,
//        NSToolbarFlexibleSpaceItemIdentifier,
//        NSToolbarSpaceItemIdentifier,
//        NSToolbarSeparatorItemIdentifier,
//        nil];
//}

@end
