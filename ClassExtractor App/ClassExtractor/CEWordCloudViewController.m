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
    NSView* view = [self view];
    
    // [TODO] This is test code, remove this later.
    CETopic* topic1 = [[CETopic alloc] init];
    [topic1 setTopicName: @"Marginal Benefit"];
    [topic1 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(100, 1), CMTimeMake(417, 1))];
    [topic1 setImportanceWeighting: 77];
    CECloudView* cloudView1 = [[CECloudView alloc] initWithTopic: topic1];
    [view addSubview: cloudView1];
    [views addObject: cloudView1];
    
    CETopic* topic2 = [[CETopic alloc] init];
    [topic2 setTopicName: @"Supply Curve"];
    [topic2 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(0, 1), CMTimeMake(110, 1))];
    [topic2 setImportanceWeighting: 46];
    CECloudView* cloudView2 = [[CECloudView alloc] initWithTopic: topic2];
    [view addSubview: cloudView2];
    [views addObject: cloudView2];
    
    CETopic* topic3 = [[CETopic alloc] init];
    [topic3 setTopicName: @"Demand Curve"];
    [topic3 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(28, 1), CMTimeMake(110, 1))];
    [topic3 setImportanceWeighting: 46];
    CECloudView* cloudView3 = [[CECloudView alloc] initWithTopic: topic3];
    [view addSubview: cloudView3];
    [views addObject: cloudView3];
    
    CETopic* topic4 = [[CETopic alloc] init];
    [topic4 setTopicName: @"Marginal Cost"];
    [topic4 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(402, 1), CMTimeMake(496, 1))];
    [topic4 setImportanceWeighting: 98];
    CECloudView* cloudView4 = [[CECloudView alloc] initWithTopic: topic4];
    [view addSubview: cloudView4];
    [views addObject: cloudView4];
    
    CETopic* topic5 = [[CETopic alloc] init];
    [topic5 setTopicName: @"Edgeworth's Box"];
    [topic5 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(450, 1), CMTimeMake(512, 1))];
    [topic5 setImportanceWeighting: 67];
    CECloudView* cloudView5 = [[CECloudView alloc] initWithTopic: topic5];
    [view addSubview: cloudView5];
    [views addObject: cloudView5];

    CETopic* topic6 = [[CETopic alloc] init];
    [topic6 setTopicName: @"GDP"];
    [topic6 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(513, 1), CMTimeMake(604, 1))];
    [topic6 setImportanceWeighting: 52];
    CECloudView* cloudView6 = [[CECloudView alloc] initWithTopic: topic6];
    [view addSubview: cloudView6];
    [views addObject: cloudView6];
    
    CETopic* topic7 = [[CETopic alloc] init];
    [topic7 setTopicName: @"Australia's Economy"];
    [topic7 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(602, 1), CMTimeMake(710, 1))];
    [topic7 setImportanceWeighting: 70];
    CECloudView* cloudView7 = [[CECloudView alloc] initWithTopic: topic6];
    [view addSubview: cloudView7];
    [views addObject: cloudView7];
    
    CETopic* topic8 = [[CETopic alloc] init];
    [topic8 setTopicName: @"The Fed"];
    [topic8 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(614, 1), CMTimeMake(971, 1))];
    [topic8 setImportanceWeighting: 34];
    CECloudView* cloudView8 = [[CECloudView alloc] initWithTopic: topic6];
    [view addSubview: cloudView8];
    [views addObject: cloudView8];
    
    CETopic* topic9 = [[CETopic alloc] init];
    [topic9 setTopicName: @"Banks"];
    [topic9 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(412, 1), CMTimeMake(971, 1))];
    [topic9 setImportanceWeighting: 100];
    CECloudView* cloudView9 = [[CECloudView alloc] initWithTopic: topic6];
    [view addSubview: cloudView9];
    [views addObject: cloudView9];
    
    CETopic* topic10 = [[CETopic alloc] init];
    [topic10 setTopicName: @"Crowding Out"];
    [topic10 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(110, 1), CMTimeMake(212, 1))];
    [topic10 setImportanceWeighting: 18];
    CECloudView* cloudView10 = [[CECloudView alloc] initWithTopic: topic6];
    [view addSubview: cloudView10];
    [views addObject: cloudView10];
    
    // [TODO] Test what happens if there are two topics of the same importance.
    NSArray* sortedViews = [self orderViewsByImportance: views];
    NSUInteger totalWidthNeeded = [self calculateTotalWidthFromViews: sortedViews];
    
    CGRect frame = [view frame];
    [view setFrame: CGRectMake(frame.origin.x, frame.origin.y, totalWidthNeeded, frame.size.height)];
    
//    [self layoutCloudsFromArray: sortedViews];
    [self layoutCloudsFromArrayNew: sortedViews];
}


// ------------------------------------------------------------
// orderViewsByImportance:
//
// Selection sort.
// Orders array in terms of decreasing importance.
// ------------------------------------------------------------
- (NSArray*) orderViewsByImportance: (NSArray<CECloudView*>*)unsorted
{
    NSMutableArray* mutableUnsorted = [unsorted mutableCopy];
    for (NSUInteger i = 1; i < [mutableUnsorted count]; ++i)
    {
        NSUInteger j = i;
        while (j > 0 && [[[mutableUnsorted objectAtIndex: j-1] representedTopic] importanceWeighting] < [[[mutableUnsorted objectAtIndex: j] representedTopic] importanceWeighting])
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
    const NSUInteger viewCount = [views count];
    
    for (NSUInteger i = 0; i < viewCount; ++i)
    {
        CECloudView* curCloud = [views objectAtIndex: i];
        const NSSize curCloudSize = [curCloud frame].size;
        [curCloud setFrame: CGRectMake(totalX, 0, curCloudSize.width, curCloudSize.height)];
        
        totalX += curCloudSize.width;
    }
}


// ------------------------------------------------------------
// layoutCloudsFromArrayNew:
//
// The array of clouds are guaranteed to be in ordered by
// decreasing importance.
// ------------------------------------------------------------
- (void) layoutCloudsFromArrayNew: (NSArray<CECloudView*>*)views
{
    for (NSUInteger i = 0; i < [views count]; ++i)
    {
        CECloudView* view = [views objectAtIndex: i];
        const CGPoint center = [self calculateCenterOfCloudWithIndex: i withView: view];
        const CGSize size = [view frame].size;
        [view setFrame: CGRectMake(center.x, center.y, size.width, size.height)];
    }
}


// ------------------------------------------------------------
// calculateStartIndexForLevel:
// ------------------------------------------------------------
- (NSUInteger) calculateStartIndexForLevel: (NSUInteger)level
{
    NSUInteger startingIndex;
    
    if (level == 0)
        startingIndex = 0;
    else if (level % 2 == 0)
        startingIndex = level * level + 1;
    else
        startingIndex = level * level;
    
    return startingIndex;
}


// ------------------------------------------------------------
// numCloudsForLevel:
// ------------------------------------------------------------
- (NSUInteger) numCloudsForLevel: (NSUInteger)level
{
    return level * level;
}


// ------------------------------------------------------------
// getLevelForNum:
//
// Levels are zero offset.
// ------------------------------------------------------------
- (NSUInteger) getLevelForNum: (NSUInteger)num
{
    NSUInteger curLevel = 0;
    bool foundLevel = false;
    
    while (!foundLevel)
    {
        foundLevel = [self calculateStartIndexForLevel: curLevel+1] > num;
        ++curLevel;
    }
    
    return curLevel-1;
}


// ------------------------------------------------------------
// numLevelsForNumClouds:
// ------------------------------------------------------------
- (NSUInteger) numLevelsForNumClouds: (NSUInteger)numClouds
{
    return [self getLevelForNum: numClouds];
}


// ------------------------------------------------------------
// totalCloudsPerQuadrantForLevel:
// ------------------------------------------------------------
- (NSUInteger) totalCloudsPerQuadrantForLevel: (NSUInteger)level
{
    const NSUInteger startIndex = [self calculateStartIndexForLevel: level];
    const NSUInteger nextStartIndex = [self calculateStartIndexForLevel: level+1];
    const NSUInteger cloudsOnCurLevel = nextStartIndex - startIndex;
    const NSUInteger cloudsPerQuadrant = cloudsOnCurLevel / 4;
    
    return cloudsPerQuadrant;
}


// ------------------------------------------------------------
// quadrantForCloudIndex:
//
// Quadrants are zero offset.
// ------------------------------------------------------------
- (NSUInteger) quadrantForCloudIndex: (NSUInteger)cloudIndex
{
    const NSUInteger level = [self getLevelForNum: cloudIndex];
    const NSUInteger cloudsPerQuadrant = [self totalCloudsPerQuadrantForLevel: level];
    
    if (cloudsPerQuadrant == 0)
        return 0;
    
    const NSUInteger startIndex = [self calculateStartIndexForLevel: level];
    const NSUInteger numCloudsBetweenStartAndCurCloud = cloudIndex - startIndex;
    return numCloudsBetweenStartAndCurCloud / cloudsPerQuadrant;
}


// ------------------------------------------------------------
// calculateCenterOfCloud:withIndex:
//
// index is the index of this cloud in the array if ordered
// clouds.
// ------------------------------------------------------------
- (CGPoint) calculateCenterOfCloudWithIndex: (NSUInteger)index withView: (CECloudView*)cloudView
{
    const NSUInteger levelMultiplier = 150;
    const NSUInteger curLevel = [self getLevelForNum: index];
    const NSUInteger curQuadrant = [self quadrantForCloudIndex: index];
    
    // [TODO] Account for positions within a quadrant per level, instead of just the level itself.
    NSInteger y = curLevel * levelMultiplier;
    NSInteger x = curLevel * levelMultiplier;
    
    if (curQuadrant == 1)
        y = -y;
    else if (curQuadrant == 2)
    {
        x = -x;
        y = -y;
    }
    else if (curQuadrant == 3)
        x = -x;
    
    const NSUInteger originOffset = 250;
    y += originOffset;
    x += originOffset;
    
    // the views are circles, so the width and height are the same
    const NSUInteger cloudCenterOffset = [cloudView frame].size.width / 2;
    y -= cloudCenterOffset;
    x -= cloudCenterOffset;

    
    return CGPointMake(x, y);
}

@end
