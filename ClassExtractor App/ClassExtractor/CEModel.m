//
//  CEModel.m
//  ClassExtractor
//
//  Created by Elliot on 3/22/16.
//  Copyright © 2016 ECL. All rights reserved.
//

#import "CEModel.h"
#import "Constants.h"

@implementation CEModel
@synthesize topics;
@synthesize totalTime;


// ------------------------------------------------------------
// sharedInstance
// ------------------------------------------------------------
+ (instancetype) sharedInstance
{
    static CEModel* model = nil;
    
    if (model == nil)
    {
        model = [[CEModel alloc] init];
        [model setTopics: [[NSMutableArray<CETopic*> alloc] init]];
        
#if DEMO
        const CMTime time = CMTimeMake(3000, 1);
        [model setTotalTime: time];
#endif
    }
    
    return model;
}


// ------------------------------------------------------------
// addTopic:
//
// Inserts the argument topic into the topics array in descending
// order (by importance), also increasing the total amount of time.
// ------------------------------------------------------------
- (void) addTopic: (CETopic*)newTopic
{
    @synchronized(topics)
    {
#if !DEMO
        // [TODO] We need to get the length from the audio file, not calculating
        // it this way.
        totalTime.value += [newTopic topicRange].duration.value;
#endif
        
        const NSUInteger kNumTopics = [topics count];
        
        if (kNumTopics == 0)
            [topics addObject: newTopic];
        else
        {
            const NSUInteger kWeighting = [newTopic importanceWeighting];
            
            // [TODO] This can be binary search.
            // insert the newTopic into the array in ascending order
            for (NSUInteger i = 0; i < kNumTopics; ++i)
            {
                if ([[topics objectAtIndex: i] importanceWeighting] < kWeighting)
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
