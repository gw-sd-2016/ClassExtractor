//
//  CECloudViewScrollView.m
//  ClassExtractor
//
//  Created by Elliot on 3/22/16.
//  Copyright © 2016 ECL. All rights reserved.
//

#import "CECloudView.h"
#import "CECloudViewScrollView.h"
#import "CETopic.h"
#import "Constants.h"

@implementation CECloudViewScrollView
@synthesize centerClouds;


// ------------------------------------------------------------
// awakeFromNib
// ------------------------------------------------------------
- (void) awakeFromNib
{
    [super awakeFromNib];
    
    centerClouds = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(createClouds:)
                                                 name: kCloudWindowOpened
                                               object: nil];
}


// ------------------------------------------------------------
// createClouds:
// ------------------------------------------------------------
- (void) createClouds: (NSNotification*)notification
{
    NSArray* topics = [notification object];
    
    [self setWantsLayer: true];
    [self setHasVerticalScroller: true];
    [self setHasHorizontalScroller: true];
    
    NSMutableArray* views = [[NSMutableArray alloc] init];
    
    [self setTranslatesAutoresizingMaskIntoConstraints: false];
    
    NSClipView* contentView = [[NSClipView alloc] init];
    [self setContentView: contentView];
    
    for (NSUInteger i = 0; i < [topics count]; ++i)
    {
        CETopic* curTopic = [topics objectAtIndex: i];
        CECloudView* cloudView = [[CECloudView alloc] initWithTopic: curTopic];
        [contentView addSubview: cloudView];
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


#if CLOUDING
// ------------------------------------------------------------
// layoutCloudsInCloudingFormationWithArray:
//
// Lays out the cloud views in a word cloud, with the most
// important cloud at the center, and decreasingly important
// clouds spiraling clockwise outwards.
// ------------------------------------------------------------
- (void) layoutCloudsInCloudingFormationWithArray: (NSArray<CECloudView*>*)views
{
    NSView* documentView = [[NSView alloc] init];
    [documentView setFrame: CGRectMake(0, 0, 1400, 2000)];
    [self setDocumentView: documentView];
    
    NSUInteger numViews = [views count];
    
    if (numViews > 1)
        [centerClouds addObject: [NSNumber numberWithUnsignedInteger: 0]];
    
    // we start at 1 because there's no ring to add the zeroth
    // cloud to
    for (NSUInteger i = 1; i < numViews; ++i)
    {
        [self createCloudModel: i withViews: views];
    }
    
    const NSUInteger numCenterClouds = [centerClouds count];
    for (NSUInteger i = 0; i < numCenterClouds; ++i)
    {
        CECloudView* view = [views objectAtIndex: i];
        
        if (i == 0)
        {
            const CGFloat centerDiameter = [view frame].size.width; // the view is a circle, so the width and height are equal
            [view setFrame: CGRectMake([[self documentView] frame].size.width / 2, [[self documentView] frame].size.height / 2, centerDiameter, centerDiameter)];
        }
        
        CERingTracker* viewRingTracker = [view ringTracker];
        NSArray* filledIndices = [viewRingTracker filledIndices];
        const NSUInteger numFilledIndices = [filledIndices count];
        
        for (NSUInteger j = 0; j < numFilledIndices; ++j)
        {
            NSNumber* ringIndexValue = [filledIndices objectAtIndex: j];
            NSUInteger ringIndex = [ringIndexValue integerValue];
            CECloudView* ringCloud = [viewRingTracker cloudViewAtRingIndex: ringIndex];
            
            if (ringCloud && ![ringCloud layedOut])
            {
                const CGFloat diameter = [ringCloud frame].size.width; // the view is a circle, so the width and height are equal
                const CGFloat offset = diameter + 10;
                const CGPoint centerOrigin = [view frame].origin;
                
                switch (ringIndex) {
                    case 0:
                        [ringCloud setFrame: CGRectMake(centerOrigin.x - offset / 2, centerOrigin.y + offset, diameter, diameter)];
                        break;
                    case 1:
                        [ringCloud setFrame: CGRectMake(centerOrigin.x + offset / 2, centerOrigin.y + offset, diameter, diameter)];
                        break;
                    case 2:
                        [ringCloud setFrame: CGRectMake(centerOrigin.x + offset, centerOrigin.y, diameter, diameter)];
                        break;
                    case 3:
                        [ringCloud setFrame: CGRectMake(centerOrigin.x + offset / 2, centerOrigin.y - offset, diameter, diameter)];
                        break;
                    case 4:
                        [ringCloud setFrame: CGRectMake(centerOrigin.x - offset / 2, centerOrigin.y - offset, diameter, diameter)];
                        break;
                    case 5:
                        [ringCloud setFrame: CGRectMake(centerOrigin.x - offset, centerOrigin.y, diameter, diameter)];
                        break;
                    default:
                        // since this should never happen, we can simply use "false" here
                        NSAssert1(false, @"Invalid ring index value: %lu", ringIndex);
                        break;
                }
                
                [ringCloud setLayedOut: true];
            }
        }
    }
}


#else
// ------------------------------------------------------------
// layoutCloudsInLineFormationWithArray:
//
// Lays out the cloud views in a straight line along the bottom
// of the scroll view, ordered by descending importance.
// ------------------------------------------------------------
- (void) layoutCloudsInLineFormationWithArray: (NSArray<CECloudView*>*)views
{
    const CGFloat kBuffer = 20;
    CGFloat totalWidthSoFar;
    
    for (NSUInteger i = 0; i < [views count]; ++i)
    {
        CECloudView* cloud = [views objectAtIndex: i];
        const CGFloat cloudDiameter = [cloud frame].size.width;
        [cloud setFrame: CGRectMake(totalWidthSoFar + kBuffer, kBuffer, cloudDiameter, cloudDiameter)];
        totalWidthSoFar += cloudDiameter + kBuffer;
    }
    
    // we have to use 2 * kBuffer here so that we can guarantee a buffer at the top
    // and bottom of the tallest cloud
    const CGFloat kTallestHeight = [[views firstObject] frame].size.height + 2 * kBuffer;
    NSView* documentView = [[NSView alloc] init];
    [documentView setFrame: CGRectMake(0, 0, totalWidthSoFar + kBuffer, kTallestHeight)];
    [self setDocumentView: documentView];
}
#endif


// ------------------------------------------------------------
// layoutCloudsWithArray:
//
// The array of clouds are guaranteed to be in ordered by
// decreasing importance.
// ------------------------------------------------------------
- (void) layoutCloudsWithArray: (NSArray<CECloudView*>*)views
{
#if CLOUDING
    [self layoutCloudsInCloudingFormationWithArray: views];
#else
    [self layoutCloudsInLineFormationWithArray: views];
#endif
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
        
        CECloudView* nextRingCloud = [curCenterRingTracker cloudViewAtRingIndex: nextRingIndex];
        
        [[nextRingCloud ringTracker] fillInIndex: [self reverseRingIndexForRingIndex: ringIndexRelativeToNewCloud]
                                        withView: indexCloudView];
    }
    
    if ([curCenterRingTracker ringFull])
    {
        ++curCenterIndex;
        [centerClouds addObject: [NSNumber numberWithUnsignedInteger: curCenterIndex]];
    }
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
