//
//  CEWordCloudViewController.m
//  ClassExtractor
//
//  Created by Elliot on 11/24/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import "CEWordCloudViewController.h"
#import "CECloudView.h"

// ============================================================
// CEWordCloudViewController
// ============================================================
@implementation CEWordCloudViewController

// ------------------------------------------------------------
// viewDidLoad
// ------------------------------------------------------------
- (void) viewDidLoad
{
    [super viewDidLoad];

    NSMutableArray* views = [[NSMutableArray alloc] init];
    
    // [TODO] This is test code, remove this later.
    CETopic* topic1 = [[CETopic alloc] init];
    [topic1 setTopicName: @"Marginal Benefit"];
    [topic1 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(100, 1), CMTimeMake(417, 1))];
    [topic1 setImportanceWeighting: 77];
    CECloudView* cloudView1 = [[CECloudView alloc] initWithTopic: topic1];
    [[self view] addSubview: cloudView1];
    [views addObject: cloudView1];
    
    CETopic* topic2 = [[CETopic alloc] init];
    [topic2 setTopicName: @"Supply Curve"];
    [topic2 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(0, 1), CMTimeMake(110, 1))];
    [topic2 setImportanceWeighting: 46];
    CECloudView* cloudView2 = [[CECloudView alloc] initWithTopic: topic2];
    [[self view] addSubview: cloudView2];
    [views addObject: cloudView2];
    
    CETopic* topic3 = [[CETopic alloc] init];
    [topic3 setTopicName: @"Demand Curve"];
    [topic3 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(28, 1), CMTimeMake(110, 1))];
    [topic3 setImportanceWeighting: 46];
    CECloudView* cloudView3 = [[CECloudView alloc] initWithTopic: topic3];
    [[self view] addSubview: cloudView3];
    [views addObject: cloudView3];
    
    CETopic* topic4 = [[CETopic alloc] init];
    [topic4 setTopicName: @"Marginal Cost"];
    [topic4 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(402, 1), CMTimeMake(496, 1))];
    [topic4 setImportanceWeighting: 98];
    CECloudView* cloudView4 = [[CECloudView alloc] initWithTopic: topic4];
    [[self view] addSubview: cloudView4];
    [views addObject: cloudView4];
    
    CETopic* topic5 = [[CETopic alloc] init];
    [topic5 setTopicName: @"Edgeworth's Box"];
    [topic5 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(450, 1), CMTimeMake(512, 1))];
    [topic5 setImportanceWeighting: 67];
    CECloudView* cloudView5 = [[CECloudView alloc] initWithTopic: topic5];
    [[self view] addSubview: cloudView5];
    [views addObject: cloudView5];

    CETopic* topic6 = [[CETopic alloc] init];
    [topic6 setTopicName: @"GDP"];
    [topic6 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(513, 1), CMTimeMake(604, 1))];
    [topic6 setImportanceWeighting: 52];
    CECloudView* cloudView6 = [[CECloudView alloc] initWithTopic: topic6];
    [[self view] addSubview: cloudView6];
    [views addObject: cloudView6];
    
    NSArray* sortedViews = [self orderViewsByImportance: views];
    NSUInteger totalWidthNeeded = [self calculateTotalWidthFromViews: sortedViews];
    
    CGRect frame = [[self view] frame];
    [[self view] setFrame: CGRectMake(frame.origin.x, frame.origin.y, totalWidthNeeded, frame.size.height)];
    
    [self layoutCloudsFromArray: sortedViews];
}


// ------------------------------------------------------------
// orderViewsByImportance:
//
// Selection sort.
// ------------------------------------------------------------
- (NSArray*) orderViewsByImportance: (NSArray<CECloudView*>*)unsorted
{
    NSMutableArray* mutableUnsorted = [unsorted mutableCopy];
    for (NSUInteger i = 1; i < [mutableUnsorted count]; ++i)
    {
        NSUInteger j = i;
        while (j > 0 && [[[mutableUnsorted objectAtIndex: j-1] representedTopic] importanceWeighting] > [[[mutableUnsorted objectAtIndex: j] representedTopic] importanceWeighting])
        {
            [mutableUnsorted exchangeObjectAtIndex: j withObjectAtIndex: j-1];
            --j;
        }
    }
    
    return [mutableUnsorted copy];
}


// ------------------------------------------------------------
// calculateTotalWidthFromViews:
// ------------------------------------------------------------
- (NSUInteger) calculateTotalWidthFromViews: (NSArray<CECloudView*>*)views
{
    NSUInteger totalWidth = 0;
    
    for (NSUInteger i = 0; i < [views count]; ++i)
    {
        totalWidth += [[views objectAtIndex: i] frame].size.width;
    }
    
    return totalWidth;
}


// ------------------------------------------------------------
// layoutCloudsFromArray:
// ------------------------------------------------------------
- (void) layoutCloudsFromArray: (NSArray<CECloudView*>*)views
{
    NSUInteger totalX = 0;
    for (NSUInteger i = 0; i < [views count]; ++i)
    {
        CECloudView* curCloud = [views objectAtIndex: i];
        [curCloud setFrame: CGRectMake(totalX, 0, [curCloud frame].size.width, [curCloud frame].size.height)];
        
        totalX += [curCloud frame].size.width;
    }
}

@end
