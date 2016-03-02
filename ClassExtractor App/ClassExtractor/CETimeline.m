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


// ============================================================
// CETimelineBarViewController
// ============================================================
@implementation CETimelineBarView
@synthesize totalTimeTextField;
@synthesize timelineBar;
@synthesize topic1LeadingConstraint;
@synthesize topic1TrailingConstraint;
@synthesize timelineBarHorizConstraint;


// ------------------------------------------------------------
// drawTimeBarsWithTopics:andTotalTime:
// ------------------------------------------------------------
- (void) drawTimeBarsWithTopics: (NSArray<CETopic*>*)topics
                   andTotalTime: (CMTime)totalTime
{
    [totalTimeTextField setStringValue: [self formatTime: totalTime]];
    
    // calculate the start and end times of the new topic
    CETopic* topic1 = [topics objectAtIndex: 0];
    const CMTimeRange kTopic1Range = [topic1 topicRange];
    const CMTimeValue kTopic1StartTime = kTopic1Range.start.value;
    const CMTimeValue kTopic1EndTime = kTopic1StartTime + kTopic1Range.duration.value;
    
    // calculate the percentage of the total time the start and end times fall at
    const CGFloat kTopic1StartTimePercentage = (CGFloat)kTopic1StartTime / (CGFloat)totalTime.value;
    const CGFloat kTopic1EndTimePercentage = (CGFloat)kTopic1EndTime / (CGFloat)totalTime.value;
    
    // calculate the position at which the new topic should start and end
    const CGFloat kTimelineBarWidth = [timelineBar frame].size.width;
    const CGFloat kStartPos = kTimelineBarWidth * kTopic1StartTimePercentage;
    const CGFloat kEndPos = kTimelineBarWidth * kTopic1EndTimePercentage;
    
    // calculate the constraint constants
    const CGFloat kLeadingConstant = kStartPos + timelineBarHorizConstraint.constant;
    const CGFloat kWindowWidth = [self frame].size.width;
    const CGFloat kTrailingConstant = kWindowWidth - kEndPos;
    
    // set the constants
    [topic1LeadingConstraint setConstant: kLeadingConstant];
    [topic1TrailingConstraint setConstant: kTrailingConstant];
}


// ------------------------------------------------------------
// formatTime:
//
// Formats a CMTime in a nice, human-readable format, such as
// 12:46.
// ------------------------------------------------------------
- (NSString*) formatTime: (CMTime)inTime
{
    const NSUInteger kSecondsPerMinute = 60;
    const NSUInteger kTime = inTime.value;
    const NSUInteger kMinutes = kTime / kSecondsPerMinute;
    const NSUInteger kSeconds = kTime % kSecondsPerMinute;
    NSString* formattedStartSeconds;
    if (kSeconds < 10)
        formattedStartSeconds = [NSString stringWithFormat: @"0%lu", (unsigned long)kSeconds];
    else
        formattedStartSeconds = [NSString stringWithFormat: @"%lu", (unsigned long)kSeconds];
    
    NSString* formatString = [NSString stringWithFormat: @"%lu:%@",
                              (unsigned long)kMinutes,
                              formattedStartSeconds];
    
    return formatString;
}

@end


// ============================================================
// CETimelineBarViewController
// ============================================================
@implementation CETimelineBarViewController
@synthesize timelineModel;


// ------------------------------------------------------------
// awakeFromNib
// ------------------------------------------------------------
- (void) awakeFromNib
{
    // test code
    CETopic* topic1 = [[CETopic alloc] init];
    [topic1 setTopicName: @"Marginal Benefit"];
    CMTimeRange timeRange1;
    timeRange1.start = CMTimeMake(27, 1);
    timeRange1.duration = CMTimeMake(100, 1);
    [topic1 setTopicRange: timeRange1];
    CETopic* topic2 = [[CETopic alloc] init];
    [topic2 setTopicName: @"Price Gouging"];
    CMTimeRange timeRange2;
    timeRange2.start = CMTimeMake(78, 1);
    timeRange2.duration = CMTimeMake(257, 1);
    [topic2 setTopicRange: timeRange2];
    CETopic* topic3 = [[CETopic alloc] init];
    [topic3 setTopicName: @"Ricardo-Barro Effect"];
    CMTimeRange timeRange3;
    timeRange3.start = CMTimeMake(145, 1);
    timeRange3.duration = CMTimeMake(200, 1);
    [topic3 setTopicRange: timeRange3];
    
    CETimelineBarModel* timelineBarModel = [[CETimelineBarModel alloc] initWithTotalTime: CMTimeMake(327, 1)];
    [timelineBarModel addTopic: topic1];
    [timelineBarModel addTopic: topic2];
    [timelineBarModel addTopic: topic3];
    [self setTimelineModel: timelineBarModel];
    
    // not test code
    CETimelineBarView* timelineBarView = (CETimelineBarView*)[self view];
    [timelineBarView drawTimeBarsWithTopics: [timelineModel topics]
                               andTotalTime: [timelineModel totalTime]];
}

@end
