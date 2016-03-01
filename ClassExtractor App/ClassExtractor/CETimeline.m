//
//  CETimelineBarModel.m
//  ClassExtractor
//
//  Created by Elliot on 3/1/16.
//  Copyright © 2016 ECL. All rights reserved.
//

#import "CETimeline.h"

// ============================================================
// CETimelineBarModel
// ============================================================
@implementation CETimelineBarModel
@synthesize totalTime;
@synthesize topics;


// ------------------------------------------------------------
// initWithTotalTime:
// ------------------------------------------------------------
- (instancetype) initWithTotalTime: (CMTime)inTotalTime
{
    self = [super init];
    
    if (self)
    {
        [self setTotalTime: inTotalTime];
        [self setTopics: [[NSMutableArray<CETopic*> alloc] init]];
    }
    
    return self;
}


// ------------------------------------------------------------
// addTopic:
//
// Inserts the argument topic into the topics array in ascending
// order.
// ------------------------------------------------------------
- (void) addTopic: (CETopic*)newTopic
{
    @synchronized(topics)
    {
        const NSUInteger kNumTopics = [topics count];
        
        if (kNumTopics == 0)
            [topics addObject: newTopic];
        else
        {
            const CMTimeValue kNewTopicTimeValue = [newTopic topicRange].start.value;
            
            // insert the newTopic into the array in ascending order
            for (NSUInteger i = 0; i < kNumTopics; ++i)
            {
                if ([[topics objectAtIndex: i] topicRange].start.value > kNewTopicTimeValue)
                {
                    [topics insertObject: newTopic atIndex: i];
                    return;
                }
            }
            
            // the newTopic is at the end of the array
            [topics addObject: newTopic];
        }
    }
}

@end


@implementation CETimelineBarView

@end

@implementation CETimelineBarViewController

@end
