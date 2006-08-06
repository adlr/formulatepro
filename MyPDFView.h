//
//  MyPDFView.h
//  FormulatePro
//
//  Created by Andrew de los Reyes on 7/4/06.
//  Copyright 2006 Andrew de los Reyes. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface MyPDFView : PDFView {
    NSMutableArray *_overlay_graphics;
}

// returns point in coordinates of the page 'out_page'. out_page is set to the proper page from the PDFDocument.
- (NSPoint)convertPointFromEvent:(NSEvent *)event toPage:(PDFPage **)out_page;
- (NSPoint)convertPagePointFromEvent:(NSEvent *)event page:(PDFPage *)page;

@end
