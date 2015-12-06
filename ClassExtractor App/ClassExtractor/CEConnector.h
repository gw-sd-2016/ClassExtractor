//
//  CEConnector.h
//  ClassExtractor
//
//  Created by Elliot on 11/22/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CEConnector : NSObject

@property NSMutableArray* curStrings;
@property NSUInteger totalFiles;
@property NSUInteger curNumFiles;

+ (CEConnector*) sharedInstance;
- (void) getJSONFromWatsonAsync: (NSNotification*)notification;
- (void) getConceptsJSONAsync: (NSString*)rawString;

@end
