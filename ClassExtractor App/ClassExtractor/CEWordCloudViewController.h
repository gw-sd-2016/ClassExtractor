//
//  CEWordCloudViewController.h
//  ClassExtractor
//
//  Created by Elliot on 11/24/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CEWordCloudViewController : NSViewController

@property NSArray* topics;
@property NSMutableArray<NSNumber*>* centerClouds;

@end
