//
//  CEJSONManipulator.m
//  ClassExtractor
//
//  Created by Elliot on 11/22/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import "CEJSONManipulator.h"

// ============================================================
// CEJSONManipulator
// ============================================================
@implementation CEJSONManipulator


// ------------------------------------------------------------
// getJSONForData:
//
// Given an NSData object, serialize the data into an
// NSDictionary and return that object.
// ------------------------------------------------------------
+ (NSDictionary*) getJSONForData: (NSData*)data
{
    NSError* error;
    NSDictionary* feed = [NSJSONSerialization JSONObjectWithData: data
                                                         options: kNilOptions
                                                           error: &error];
    
    if (nil == error)
        return feed;
    else
    {
        NSLog(@"%@", error);
        return nil;
    }
}

@end