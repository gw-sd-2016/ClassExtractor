//
//  CEJSONManipulator.h
//  ClassExtractor
//
//  Created by Elliot on 11/22/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CEJSONManipulator : NSObject

+ (NSDictionary*) getJSONForData: (NSData*)data;

@end
