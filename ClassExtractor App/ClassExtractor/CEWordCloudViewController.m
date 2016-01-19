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


#pragma mark - ViewController


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


#pragma mark - High Level Cloud Creation


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
    
    // we start at 1 because there's no ring to add the zeroth
    // cloud to
    for (NSUInteger i = 1; i < numViews; ++i)
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
            
            switch (i % kNumCloudsPerRing) {
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


#pragma mark - Cloud Model Creation


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
- (void) createCloudModel: (NSUInteger)index
                withViews: (NSArray<CECloudView*>*)views
{
    static NSUInteger curCenterIndex = 0;

    // ringIndex is only applicable to the current center cloud (i.e. it is meaningless
    // when talking about other clouds)
    // we need to subtract curCenterIndex to keep the index positions the same
    // (otherwise they would rotate around each successive center cloud)
    const NSUInteger ringIndex = (index - curCenterIndex) % kNumCloudsPerRing;

    CECloudView* indexCloudView = [views objectAtIndex: index];
    CECloudView* curCenterCloudView = [views objectAtIndex: curCenterIndex];
    CERingTracker* indexRingTracker = [indexCloudView ringTracker];
    CERingTracker* curCenterRingTracker = [curCenterCloudView ringTracker];

    // keep track of what the index cloud's center cloud is so we can lay out
    // the views later
    [indexRingTracker setCenterCloud: curCenterCloudView];

    // make curCenterIndex aware of index
    [curCenterRingTracker fillInIndex: ringIndex
                             withView: indexCloudView];
    
    // make index aware of curCenterIndex
    [indexRingTracker fillInIndex: [self reverseRingIndexForRingIndex: ringIndex]
                         withView: curCenterCloudView];
    
    // make index aware of index - 1
    // make index - 1 aware of index
    const NSUInteger previousRingIndex = (index - 1 - curCenterIndex) % kNumCloudsPerRing;
    if ([curCenterRingTracker indexFilled: previousRingIndex])
    {
        const NSUInteger newIndex = [self ringIndexOfPreviousCloudForNewIndex: index
                                                                withRingIndex: ringIndex];
        
        [indexRingTracker fillInIndex: newIndex
                             withView: [views objectAtIndex: index - 1]];
    
        [[[views objectAtIndex: index - 1] ringTracker] fillInIndex: [self reverseRingIndexForRingIndex: newIndex]
                                                           withView: indexCloudView];
    }
    
    // make ringIndex + 1 aware of index
    // make index aware of ringIndex + 1
    const NSUInteger nextRingIndex = (index + 1 - curCenterIndex) % kNumCloudsPerRing;
    if ([curCenterRingTracker indexFilled: nextRingIndex])
    {
        const NSUInteger ringIndexRelativeToNewCloud = [self ringIndexOfNextRingCloudForRingIndex: ringIndex];
        
        [indexRingTracker fillInIndex: ringIndexRelativeToNewCloud
                             withView: [views objectAtIndex: index - 5]];
        
        // [TODO] Can we use nextRingIndex as the parameter here?
        CECloudView* nextRingCloud = [curCenterRingTracker cloudViewAtRingIndex: (ringIndex + 1) % kNumCloudsPerRing];
        
        [[nextRingCloud ringTracker] fillInIndex: [self reverseRingIndexForRingIndex: ringIndexRelativeToNewCloud]
                                                                            withView: indexCloudView];
    }
    
    if ([curCenterRingTracker ringFull])
        ++curCenterIndex;
}


// ------------------------------------------------------------
// reverseRingIndexForRingIndex:
//
// Returns the ring index opposite the argument ring index (i.e.
// 1->4, 2->5, 3->6, 4->1, 5->2, 6->3)
// ------------------------------------------------------------
- (NSUInteger) reverseRingIndexForRingIndex: (NSUInteger)ringIndex
{
    const NSUInteger halfRing = kNumCloudsPerRing / 2;
    const NSUInteger newIndex = ringIndex + halfRing;
    return newIndex % kNumCloudsPerRing;
}


// ------------------------------------------------------------
// ringIndexOfPreviousCloudForNewIndex:withRingIndex:
//
// Returns the ring index of the previous cloud within the
// ring of the cloud that was just added. rawIndex is the index
// of the new cloud, ringIndex is the new cloud's ring index
// within it's center ring.
// ------------------------------------------------------------
- (NSUInteger) ringIndexOfPreviousCloudForNewIndex: (NSUInteger)rawIndex
                                     withRingIndex: (NSUInteger)ringIndex
{
    static NSUInteger counter = 5;
    static NSUInteger lastRingIndex = 1;
    
    if (ringIndex != lastRingIndex)
        counter = (counter + 1) % kNumCloudsPerRing;
    
    lastRingIndex = ringIndex;
    
    return counter;
}


// ------------------------------------------------------------
// ringIndexOfNextRingCloudForRingIndex:
//
// Returns the ring index of the next cloud of the array within
// the new cloud's ring (i.e. if 18 was just added, this
// returns the ring index of 7 within 18's ring).
// ------------------------------------------------------------
- (NSUInteger) ringIndexOfNextRingCloudForRingIndex: (NSUInteger)ringIndex
{
    return (ringIndex + 2) % kNumCloudsPerRing;
}


# pragma mark - Levels


// ------------------------------------------------------------
// levelForIndex:
//
// The level is returned as zero-offset.
// ------------------------------------------------------------
- (NSUInteger) levelForIndex: (NSUInteger)rawIndex
{
    NSInteger rawLevel = ceil((double)rawIndex / (double)kNumCloudsPerRing);
    NSUInteger counter = 1;
    
    while (rawLevel > 0)
    {
        rawLevel -= counter;
        ++counter;
    }
    
    return counter - 1;
}


// ------------------------------------------------------------
// totalCloudsForLevel:
//
// Returns the total number of clouds for the argument level and
// all lower levels given that the argument level is filled in
// (and, therefore, that all lower levels are filled in as well).
// ------------------------------------------------------------
- (NSUInteger) totalCloudsForLevel: (NSUInteger)level
{
    // base case: the zeroth level has exactly one cloud,
    // the zeroth cloud
    if (0 == level)
        return 1;
    
    // the number of clouds on each level grows by a factor of 6
    const NSUInteger cloudsOnCurLevel = level * kNumCloudsPerRing;
    
    // return the number of clouds on the current level plus all
    // of the clouds from lower levels
    return cloudsOnCurLevel + [self totalCloudsForLevel: level - 1];
}

@end
