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
    // [TODO] If data is nil, provide some useful dialog to the user.
    if (nil != data)
    {
        NSError* error;
        // [TODO] Is NSJSONReadingAllowFragments necessary here? Or can we have kNilOptions?
        NSDictionary* feed = [NSJSONSerialization JSONObjectWithData: data
                                                             options: NSJSONReadingAllowFragments
                                                               error: &error];
        
        // [TODO] If there is an error, provide some useful dialog to the user.
        if (nil == error)
            return feed;
        else
        {
            NSLog(@"%@", error);
            return nil;
        }
    }
    
    NSLog(@"Data argument is nil.");
    return nil;
}

@end