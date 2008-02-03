//
//  FPMouseEventProxy.h
//  FormulatePro
//
//  Created by Andrew de los Reyes on 1/21/08.
//  Copyright 2008 Andrew de los Reyes. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FPMouseEventProxy : NSObject {

}

// when fixedToInitialPage is YES, the inital page will always
// be the page, and the point will be on the page, even if
// normally it would be on another page. This is useful since
// when creating graphics with the mouse, the mouse even stream
// should be fixed to a page.
- (id)initFixedToInitialPage:(BOOL)fixedToInitialPage;

// returns true if another usable event came in
- (BOOL)waitForNextEvent;

- (NSPoint)point;
- (unsigned int)page;

@end
