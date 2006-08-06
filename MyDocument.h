//
//  MyDocument.h
//  FormulatePro
//
//  Created by Andrew de los Reyes on 7/4/06.
//  Copyright Andrew de los Reyes 2006 . All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

#import "MyPDFView.h"

@interface MyDocument : NSDocument
{
    IBOutlet MyPDFView *_pdf_view;
    IBOutlet NSWindow *_document_window;
    IBOutlet NSSegmentedControl *_one_up_vs_two_up_vs_book;
    IBOutlet NSSegmentedControl *_single_vs_continuous;
    
}
- (IBAction)zoomIn:(id)sender;
- (IBAction)zoomOut:(id)sender;
- (IBAction)toggleOneUpTwoUpBookMode:(id)sender;
- (IBAction)toggleContinuous:(id)sender;

@end
