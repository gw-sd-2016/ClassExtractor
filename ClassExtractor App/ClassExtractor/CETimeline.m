//
//  CETimelineBarModel.m
//  ClassExtractor
//
//  Created by Elliot on 3/1/16.
//  Copyright © 2016 ECL. All rights reserved.
//

#import "CEModel.h"
#import "CETimeline.h"
#import "Constants.h"


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
// awakeFromNib
// ------------------------------------------------------------
- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(drawTimeBars)
                                                 name: kDrawTimelineBars
                                               object: nil];
}


// ------------------------------------------------------------
// drawTimeBars:
// ------------------------------------------------------------
- (void) drawTimeBars
{
    CEModel* model = [CEModel sharedInstance];
    NSArray* topics = [model topics];
    const CMTime totalTime = [model totalTime];
    
    [totalTimeTextField setStringValue: [self formatTime: totalTime]];
  
    [self organizeUIElements];
    
    NSUInteger counter = 0;
    
    for (NSInteger i = [topics count] - 1; i >= 0 ; --i)
    {
        if (i < [topics count] - 5)
            break;
        
        NSInteger reverseIndex = [topics count] - 1 - i;
        
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
        [[topicLeadingConstraints objectAtIndex: reverseIndex] setConstant: kLeadingConstant];
        [[topicTrailingConstraints objectAtIndex: reverseIndex] setConstant: kTrailingConstant];
        
        // set the name
        [[topicNameTextFields objectAtIndex: reverseIndex] setStringValue: [topic topicName]];
        
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

