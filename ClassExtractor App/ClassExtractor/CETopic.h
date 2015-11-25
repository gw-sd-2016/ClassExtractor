//
//  CETopic.h
//  ClassExtractor
//
//  Created by Elliot on 11/25/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface CETopic : NSObject

@property NSString* topicName;
@property NSUInteger importanceWeighting;
@property CMTimeRange topicRange;

@end
