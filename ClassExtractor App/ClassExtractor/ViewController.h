//
//  ViewController.h
//  ClassExtractor
//
//  Created by Elliot on 10/14/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController
@end


@interface CEJSONManipulator : NSObject

+ (NSDictionary*) getJSONForData: (NSData*)data;

@end
