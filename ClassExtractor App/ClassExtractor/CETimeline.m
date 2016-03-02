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
@synthesize topic1Name;
@synthesize topic2Name;
@synthesize topic3Name;
@synthesize topic4Name;
@synthesize topic5Name;
@synthesize topicNameTextFields;
@synthesize topicLeadingConstraints;
@synthesize topicTrailingConstraints;
@synthesize topic2LeadingConstraint;
@synthesize topic3LeadingConstraint;
@synthesize topic4LeadingConstraint;
@synthesize topic5LeadingConstraint;
@synthesize topic2TrailingConstraint;
@synthesize topic3TrailingConstraint;
@synthesize topic4TrailingConstraint;
@synthesize topic5TrailingConstraint;
@synthesize timelineBar5;
@synthesize timelineBar4;
@synthesize timelineBar3;
@synthesize timelineBar2;
@synthesize timelineBar1;
@synthesize topicTimelines;


// ------------------------------------------------------------
// drawTimeBarsWithTopics:andTotalTime:
// ------------------------------------------------------------
- (void) drawTimeBarsWithTopics: (NSArray<CETopic*>*)topics
                   andTotalTime: (CMTime)totalTime
{
    [totalTimeTextField setStringValue: [self formatTime: totalTime]];
  
    [self organizeUIElements];
    
    NSUInteger counter = 0;
    
    for (NSUInteger i = 0; i < [topics count]; ++i)
    {
        if (i > 4)
            break;
        
        // calculate the start and end times of the new topic
        CETopic* topic = [topics objectAtIndex: i];
        const CMTimeRange kTopicRange = [topic topicRange];
        const CMTimeValue kTopicStartTime = kTopicRange.start.value;
        const CMTimeValue kTopicEndTime = kTopicStartTime + kTopicRange.duration.value;
        
        // calculate the percentage of the total time the start and end times fall at
        const CGFloat kTopicStartTimePercentage = (CGFloat)kTopicStartTime / (CGFloat)totalTime.value;
        const CGFloat kTopicEndTimePercentage = (CGFloat)kTopicEndTime / (CGFloat)totalTime.value;
        
        // calculate the position at which the new topic should start and end
        const CGFloat kTimelineBarWidth = [timelineBar frame].size.width;
        const CGFloat kStartPos = kTimelineBarWidth * kTopicStartTimePercentage;
        const CGFloat kEndPos = kTimelineBarWidth * kTopicEndTimePercentage;
        
        // calculate the constraint constants
        const CGFloat kLeadingConstant = kStartPos + timelineBarHorizConstraint.constant;
        const CGFloat kWindowWidth = [self frame].size.width;
        const CGFloat kTrailingConstant = kWindowWidth - kEndPos;
        
        // set the constants
        [[topicLeadingConstraints objectAtIndex: i] setConstant: kLeadingConstant];
        [[topicTrailingConstraints objectAtIndex: i] setConstant: kTrailingConstant];
        
        // set the name
        [[topicNameTextFields objectAtIndex: i] setStringValue: [topic topicName]];
        
        ++counter;
    }
    
    // we have fewer than 5 topics, so hide the timeline bars that are unused
    if (counter < 4)
    {
        for (NSUInteger i = counter; i <= 4; ++i)
        {
            [[topicTimelines objectAtIndex: i] setHidden: true];
        }
    }
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


// ------------------------------------------------------------
// organizeUIElements
// ------------------------------------------------------------
- (void) organizeUIElements
{
    topicNameTextFields = @[topic1Name,
                            topic2Name,
                            topic3Name,
                            topic4Name,
                            topic5Name];
    
    topicLeadingConstraints = @[topic1LeadingConstraint,
                                topic2LeadingConstraint,
                                topic3LeadingConstraint,
                                topic4LeadingConstraint,
                                topic5LeadingConstraint];
    
    topicTrailingConstraints = @[topic1TrailingConstraint,
                                 topic2TrailingConstraint,
                                 topic3TrailingConstraint,
                                 topic4TrailingConstraint,
                                 topic5TrailingConstraint];
    
    topicTimelines = @[timelineBar1,
                       timelineBar2,
                       timelineBar3,
                       timelineBar4,
                       timelineBar5];
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
    
    CETimelineBarModel* timelineBarModel = [[CETimelineBarModel alloc] initWithTotalTime: CMTimeMake(427, 1)];
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
