//
//  CEModel.h
//  ClassExtractor
//
//  Created by Elliot on 3/22/16.
//  Copyright © 2016 ECL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CETopic.h"

@interface CEModel : NSObject

@property NSMutableArray<CETopic*>* topics;
@property CMTime totalTime;

+ (instancetype) sharedInstance;
- (void) addTopic: (CETopic*)newTopic;

@end
