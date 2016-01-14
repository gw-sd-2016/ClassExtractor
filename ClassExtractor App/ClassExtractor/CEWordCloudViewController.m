//
//  CEWordCloudViewController.m
//  ClassExtractor
//
//  Created by Elliot on 11/24/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import "CEWordCloudViewController.h"
#import "CECloudView.h"
#import "Constants.h"

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

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(cloudWindowOpened:)
                                                 name: kCloudWindowOpened
                                               object: nil];
}


// ------------------------------------------------------------
// viewDidAppear
// ------------------------------------------------------------
- (void) viewDidAppear
{
    [super viewDidAppear];
    
    [[[self view] window] setTitle: @"Word Cloud"];
}


// ------------------------------------------------------------
// cloudWindowOpened:
// ------------------------------------------------------------
- (void) cloudWindowOpened: (NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    NSMutableArray* views = [[NSMutableArray alloc] init];
    NSView* view = [self view];
    
    NSArray* topics = [notification object];
    
    for (NSUInteger i = 0; i < [topics count]; ++i)
    {
        NSDictionary* curTopic = [topics objectAtIndex: i];
        NSString* curTopicString = [[curTopic allKeys] firstObject];
        NSNumber* curTopicFrequency = [[curTopic allValues] firstObject];
        
        CETopic* topic = [[CETopic alloc] init];
        [topic setTopicName: curTopicString];
//        [topic setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(100, 1), CMTimeMake(417, 1))];
        
        // [TODO] Add robust handling for if the importance weighting is 0.
        [topic setImportanceWeighting: [curTopicFrequency integerValue]];
        CECloudView* cloudView = [[CECloudView alloc] initWithTopic: topic];
        [view addSubview: cloudView];
        [views addObject: cloudView];
    }
    
    NSArray* sortedViews = [self orderViewsByImportance: views];
    [self layoutCloudsWithArray: sortedViews];
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
// layoutCloudsWithArray:
//
// The array of clouds are guaranteed to be in ordered by
// decreasing importance.
// ------------------------------------------------------------
- (void) layoutCloudsWithArray: (NSArray<CECloudView*>*)views
{
    NSUInteger numViews = [views count];
    
    for (NSUInteger i = 0; i < numViews; ++i)
    {
        [self createCloudModel: i withViews: views];
    }
    
    for (NSUInteger i = 0; i < numViews; ++i)
    {
        CECloudView* view = [views objectAtIndex: i];
        CECloudView* centerCloud = [[view ringTracker] centerCloud];
        
        const CGFloat diameter = [view frame].size.width; // the view is a circle, so the width and height are equal
        
        if (i == 0)
            [view setFrame: CGRectMake(200, 200, diameter, diameter)];
        else
        {
            const CGFloat offset = 300;
            const CGPoint centerOrigin = [centerCloud frame].origin;
            
            switch (i % 6) {
                case 1:
                    [view setFrame: CGRectMake(centerOrigin.x + offset / 2, centerOrigin.y + offset, diameter, diameter)];
                    break;
                case 2:
                    [view setFrame: CGRectMake(centerOrigin.x + offset, centerOrigin.y, diameter, diameter)];
                    break;
                case 3:
                    [view setFrame: CGRectMake(centerOrigin.x + offset / 2, centerOrigin.y - offset, diameter, diameter)];
                    break;
                case 4:
                    [view setFrame: CGRectMake(centerOrigin.x - offset / 2, centerOrigin.y - offset, diameter, diameter)];
                    break;
                case 5:
                    [view setFrame: CGRectMake(centerOrigin.x - offset, centerOrigin.y, diameter, diameter)];
                    break;
                default: // 0
                    [view setFrame: CGRectMake(centerOrigin.x - offset / 2, centerOrigin.y + offset, diameter, diameter)];
                    break;
            }
        }
    }
}


// ------------------------------------------------------------
// ringIndexOfPastCloudForCenterIndex:
// ------------------------------------------------------------
- (NSUInteger) ringIndexOfPastCloudForCenterIndex: (NSUInteger)centerIndex
{
    static NSUInteger lastCenter = 2;
    static NSUInteger indexCounter = 3;
    
    if (lastCenter == centerIndex)
        indexCounter = (indexCounter + 1) % 6;
    
    lastCenter = centerIndex;
    
    return indexCounter;
}


// ------------------------------------------------------------
// ringIndexForOldRingWithCenterIndex:andRawIndex:andCurCenterIndex:
//
// This function is to be used to make the previous cloud
// aware of the new cloud when adding a cloud when curCenter
// is not 0.
// ------------------------------------------------------------
- (NSUInteger) ringIndexForOldRingWithCenterIndex: (NSUInteger)centerIndex
                                      andRawIndex: (NSUInteger)rawIndex
                                andCurCenterIndex: (NSUInteger)curCenterIndex
{
    static NSUInteger lastRawRingIndex = 1;
    static NSUInteger lastCenterIndex = 7;
    static NSUInteger counter = 2;
    
    if (lastRawRingIndex == curCenterIndex)
    {
        if (centerIndex == lastCenterIndex)
            counter = (counter + 1) % 6;
    }
    
    lastRawRingIndex = curCenterIndex;
    lastCenterIndex = centerIndex;
    
    return counter;
}


// ------------------------------------------------------------
// ringIndexForNewRingWithCenterIndex:andRawIndex:andCurCenterIndex:
//
// This function is to be used to make the new cloud aware of
// the previous cloud when adding a cloud when curCenter
// is not 0.
// ------------------------------------------------------------
- (NSUInteger) ringIndexForNewRingWithCenterIndex: (NSUInteger)centerIndex
                                andCurCenterIndex: (NSUInteger)curCenterIndex
{
    static NSUInteger lastCenterIndex = 1;
    static NSUInteger counter = 4;
    
    if (lastCenterIndex == curCenterIndex)
        counter = (counter + 1) % 6;

    lastCenterIndex = curCenterIndex;
    
    return counter;
}


// the center is equivalent to curCenterIndex, and rawRingIndex is the raw index for which we are
// trying to calculate the ring index for
- (NSUInteger) ringIndexForCenterIndex: (NSUInteger)centerIndex andRingRawIndex: (NSUInteger)rawRingIndex andCurCenterIndex: (NSUInteger)curCenterIndex
{
    if (centerIndex > 6)
    {
        static NSUInteger lastRawRingIndex = 1;
        static NSUInteger lastCenterIndex = 7;
        static NSUInteger counter = 2;
        
        if (lastRawRingIndex == curCenterIndex)
        {
            if (centerIndex == lastCenterIndex)
                counter = (counter + 1) % 6;
        }
        
        lastRawRingIndex = curCenterIndex;
        lastCenterIndex = centerIndex;
        
        return counter;
    }
    
    NSUInteger test = rawRingIndex - centerIndex;
    
    if (test == NSUIntegerMax && rawRingIndex != 0)
        test = rawRingIndex - 1;
    else if (rawRingIndex == 0)
    {
        test = 1;
        return (centerIndex % 6 + 3) % 6;
    }
    
    const NSUInteger modTest = test % 6;
    
    return modTest;
}

- (NSUInteger) calculateRingIndexForRawIndex: (NSUInteger)rawIndex andCenterIndex: (NSUInteger)centerIndex
{
    return (rawIndex - centerIndex + 3) % 6;
}

- (NSUInteger) reverseRingIndex: (NSUInteger)rawIndex
{
    return (rawIndex + 3) % 6;
}


// ------------------------------------------------------------
// createCloudModel:withViews:
//
// "index" (also referred to as the "raw index" in some comments)
// is the index for the current view we are working with among
// all of the views of the "views" array. "curCenterIndex" is
// the index of the cloud we are currently making a ring around.
// "ringIndex" is the offset of the current cloud within the
// "curCenterIndex" cloud.
// ------------------------------------------------------------
- (void) createCloudModel: (NSUInteger)index withViews: (NSArray<CECloudView*>*)views
{
    static NSUInteger curCenterIndex = 0;
    
    if (11 == index)
        NSLog(@"%@", views);
    
    // a center cloud should not be added to its own ring (or to other rings - it is
    // added to other rings while evaluating those rings' center)
    if (curCenterIndex != index)
    {
        // ringIndex is only applicable to the current center cloud (i.e. it is meaningless
        // when talking about other clouds)
        // we need to subtract curCenterIndex to keep the index positions the same
        // (otherwise they would rotate around each successive center cloud)
        const NSUInteger ringIndex = index % 6 - curCenterIndex;
        
        CECloudView* indexCloudView = [views objectAtIndex: index];
        CECloudView* curCenterCloudView = [views objectAtIndex: curCenterIndex];
        CERingTracker* indexRingTracker = [indexCloudView ringTracker];
        CERingTracker* curCenterRingTracker = [curCenterCloudView ringTracker];
        
        // keep track of what the index cloud's center cloud is so we can lay out
        // the views later
        [indexRingTracker setCenterCloud: curCenterCloudView];
        
        // fill in the ring for the current center cloud
        if (curCenterIndex == 0)
            // if curCenterIndex equals 0, then -nextIndex would return 0, even though we want to
            // start from 1
            [curCenterRingTracker fillInIndex: index % 6
                                     withView: indexCloudView];
        else
            [curCenterRingTracker fillInIndex: [curCenterRingTracker nextIndex]
                                     withView: indexCloudView];
        
        // fill in the ring for the index cloud (the clouds to be filled in for this ring are
        // the current center cloud, as well as the previous cloud if this isn't the first index)
        if (index < 6)
        [indexRingTracker fillInIndex: [self ringIndexForCenterIndex: index
                                                     andRingRawIndex: curCenterIndex
                                                   andCurCenterIndex: curCenterIndex]
                             withView: curCenterCloudView];
        else
            [indexRingTracker fillInIndex: [self calculateRingIndexForRawIndex: index
                                                                andCenterIndex: curCenterIndex]
                                 withView: curCenterCloudView];
        
        // we do, however, want to fill in the last cloud if this is the first index
        // in the event that the zeroth index cloud was created before the first index
        // cloud (such as when creating the eighth cloud, the seventh cloud was already
        // created (seven has a ringIndex of 0 and eight of 1 when the curCenterIndex is 1))
        if (ringIndex != 1 || (ringIndex == 1 && [curCenterRingTracker indexFilled: 5]))
        {
            if (index < 6)
                [indexRingTracker fillInIndex: [self ringIndexForCenterIndex: index
                                                             andRingRawIndex: index - 1
                                                           andCurCenterIndex: curCenterIndex]
                                     withView: [views objectAtIndex: index - 1]];
            else
                [indexRingTracker fillInIndex: [self ringIndexForNewRingWithCenterIndex: index
                                                                      andCurCenterIndex: curCenterIndex]
                                     withView: [views objectAtIndex: index - 1]];
        }
        
        // fill in the ring for the previous cloud (and, if this cloud completes the ring (i.e. is
        // zeroth index when curCenterIndex equals 0), then also fill in the ring for the first index)
        if (ringIndex == 0)
        {
            // fill in the ring for the previous cloud
            if (index < 6)
                [[[views objectAtIndex: index - 1] ringTracker] fillInIndex: [self ringIndexForCenterIndex: index - 1
                                                                                           andRingRawIndex: index
                                                                                         andCurCenterIndex: curCenterIndex]
                                                                   withView: indexCloudView];
            else
                [[[views objectAtIndex: index - 1] ringTracker] fillInIndex: [self ringIndexForOldRingWithCenterIndex: index - 1
                                                                                                          andRawIndex: index
                                                                                                    andCurCenterIndex: curCenterIndex]
                                                                   withView: indexCloudView];
            
            if ([curCenterRingTracker indexFilled: 1])
            {
                // fill in the first index's ring
                [[[views objectAtIndex: index - 5] ringTracker] fillInIndex: [self ringIndexForCenterIndex: index - 5
                                                                                           andRingRawIndex: index
                                                                                         andCurCenterIndex: curCenterIndex]
                                                                   withView: indexCloudView];
                
                // make the zeroth index aware of the first index
                [indexRingTracker fillInIndex: 2
                                     withView: [views objectAtIndex: index - 5]];
            }
        }
        // check if this is the first index, as if it is, there will not be a zeroth index yet
        else if (curCenterIndex == 0 && ringIndex != 1)
        {
            if (index == 9)
                NSLog(@"");
            // fill in the last ring index
            [[[views objectAtIndex: index - 1] ringTracker] fillInIndex: [self ringIndexOfPastCloudForCenterIndex: curCenterIndex]
                                                               withView: indexCloudView];
        }
        
        // the case where we haven't filled in the previous circle with the new cloud (i.e. making 7 aware of 8)
        if (index > 0 && curCenterIndex != 0)
        {
            if (![[[views objectAtIndex: index - 1] ringTracker] indexFilled: ringIndex + 1])
                [[[views objectAtIndex: index - 1] ringTracker] fillInIndex: ringIndex + 1
                                                                   withView: indexCloudView];
        }
        
        // the case where a cloud is being created with two center clouds (i.e. 9 - it has 1 and 2 as center clouds)
        if (index > 6 && [curCenterRingTracker indexFilled: (ringIndex + 1) % 6])
        {
            CECloudView* otherCenterCloud = [views objectAtIndex: curCenterIndex + 1];
            const NSUInteger ringIndexForSecondCenter = [self calculateRingIndexForRawIndex: index andCenterIndex: curCenterIndex + 1];
            
            // fill in the ring for index
            [indexRingTracker fillInIndex: ringIndexForSecondCenter  withView: otherCenterCloud];
            
            // fill in the ring for the other center
            [[otherCenterCloud ringTracker] fillInIndex: [self reverseRingIndex: ringIndexForSecondCenter] withView: indexCloudView];
        }

        if (kRingFull == [curCenterRingTracker nextIndex])
            ++curCenterIndex;
    }
}

@end
