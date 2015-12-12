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
#include <math.h>

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
    
//    NSMutableArray* views = [[NSMutableArray alloc] init];
//    NSView* view = [self view];
//    
//    // [TODO] This is test code, remove this later.
//    CETopic* topic1 = [[CETopic alloc] init];
//    [topic1 setTopicName: @"Marginal Benefit"];
//    [topic1 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(100, 1), CMTimeMake(417, 1))];
//    [topic1 setImportanceWeighting: 77];
//    CECloudView* cloudView1 = [[CECloudView alloc] initWithTopic: topic1];
//    [view addSubview: cloudView1];
//    [views addObject: cloudView1];
//    
//    CETopic* topic2 = [[CETopic alloc] init];
//    [topic2 setTopicName: @"Supply Curve"];
//    [topic2 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(0, 1), CMTimeMake(110, 1))];
//    [topic2 setImportanceWeighting: 46];
//    CECloudView* cloudView2 = [[CECloudView alloc] initWithTopic: topic2];
//    [view addSubview: cloudView2];
//    [views addObject: cloudView2];
//    
//    CETopic* topic3 = [[CETopic alloc] init];
//    [topic3 setTopicName: @"Demand Curve"];
//    [topic3 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(28, 1), CMTimeMake(110, 1))];
//    [topic3 setImportanceWeighting: 45];
//    CECloudView* cloudView3 = [[CECloudView alloc] initWithTopic: topic3];
//    [view addSubview: cloudView3];
//    [views addObject: cloudView3];
//    
//    CETopic* topic4 = [[CETopic alloc] init];
//    [topic4 setTopicName: @"Marginal Cost"];
//    [topic4 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(402, 1), CMTimeMake(496, 1))];
//    [topic4 setImportanceWeighting: 98];
//    CECloudView* cloudView4 = [[CECloudView alloc] initWithTopic: topic4];
//    [view addSubview: cloudView4];
//    [views addObject: cloudView4];
//    
//    CETopic* topic5 = [[CETopic alloc] init];
//    [topic5 setTopicName: @"Edgeworth's Box"];
//    [topic5 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(450, 1), CMTimeMake(512, 1))];
//    [topic5 setImportanceWeighting: 67];
//    CECloudView* cloudView5 = [[CECloudView alloc] initWithTopic: topic5];
//    [view addSubview: cloudView5];
//    [views addObject: cloudView5];
//
//    CETopic* topic6 = [[CETopic alloc] init];
//    [topic6 setTopicName: @"GDP"];
//    [topic6 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(513, 1), CMTimeMake(604, 1))];
//    [topic6 setImportanceWeighting: 52];
//    CECloudView* cloudView6 = [[CECloudView alloc] initWithTopic: topic6];
//    [view addSubview: cloudView6];
//    [views addObject: cloudView6];
//    
//    CETopic* topic7 = [[CETopic alloc] init];
//    [topic7 setTopicName: @"Australia's Economy"];
//    [topic7 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(602, 1), CMTimeMake(710, 1))];
//    [topic7 setImportanceWeighting: 70];
//    CECloudView* cloudView7 = [[CECloudView alloc] initWithTopic: topic7];
//    [view addSubview: cloudView7];
//    [views addObject: cloudView7];
//    
//    CETopic* topic8 = [[CETopic alloc] init];
//    [topic8 setTopicName: @"The Fed"];
//    [topic8 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(614, 1), CMTimeMake(971, 1))];
//    [topic8 setImportanceWeighting: 44];
//    CECloudView* cloudView8 = [[CECloudView alloc] initWithTopic: topic8];
//    [view addSubview: cloudView8];
//    [views addObject: cloudView8];
//    
//    CETopic* topic9 = [[CETopic alloc] init];
//    [topic9 setTopicName: @"Banks"];
//    [topic9 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(412, 1), CMTimeMake(971, 1))];
//    [topic9 setImportanceWeighting: 100];
//    CECloudView* cloudView9 = [[CECloudView alloc] initWithTopic: topic9];
//    [view addSubview: cloudView9];
//    [views addObject: cloudView9];
    
//    CETopic* topic10 = [[CETopic alloc] init];
//    [topic10 setTopicName: @"Crowding Out"];
//    [topic10 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(110, 1), CMTimeMake(212, 1))];
//    [topic10 setImportanceWeighting: 54];
//    CECloudView* cloudView10 = [[CECloudView alloc] initWithTopic: topic10];
//    [view addSubview: cloudView10];
//    [views addObject: cloudView10];
//    
//    CETopic* topic11 = [[CETopic alloc] init];
//    [topic11 setTopicName: @"Crowding Out"];
//    [topic11 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(110, 1), CMTimeMake(212, 1))];
//    [topic11 setImportanceWeighting: 47];
//    CECloudView* cloudView11 = [[CECloudView alloc] initWithTopic: topic11];
//    [view addSubview: cloudView11];
//    [views addObject: cloudView11];
//    
//    CETopic* topic12 = [[CETopic alloc] init];
//    [topic12 setTopicName: @"Crowding Out"];
//    [topic12 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(110, 1), CMTimeMake(212, 1))];
//    [topic12 setImportanceWeighting: 39];
//    CECloudView* cloudView12 = [[CECloudView alloc] initWithTopic: topic12];
//    [view addSubview: cloudView12];
//    [views addObject: cloudView12];
//    
//    CETopic* topic13 = [[CETopic alloc] init];
//    [topic13 setTopicName: @"Crowding Out"];
//    [topic13 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(110, 1), CMTimeMake(212, 1))];
//    [topic13 setImportanceWeighting: 22];
//    CECloudView* cloudView13 = [[CECloudView alloc] initWithTopic: topic13];
//    [view addSubview: cloudView13];
//    [views addObject: cloudView13];
//    
//    CETopic* topic14 = [[CETopic alloc] init];
//    [topic14 setTopicName: @"Crowding Out"];
//    [topic14 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(110, 1), CMTimeMake(212, 1))];
//    [topic14 setImportanceWeighting: 67];
//    CECloudView* cloudView15 = [[CECloudView alloc] initWithTopic: topic14];
//    [view addSubview: cloudView15];
//    [views addObject: cloudView15];
//    
//    CETopic* topic16 = [[CETopic alloc] init];
//    [topic16 setTopicName: @"Crowding Out"];
//    [topic16 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(110, 1), CMTimeMake(212, 1))];
//    [topic16 setImportanceWeighting: 51];
//    CECloudView* cloudView16 = [[CECloudView alloc] initWithTopic: topic16];
//    [view addSubview: cloudView16];
//    [views addObject: cloudView16];
//    
//    CETopic* topic17 = [[CETopic alloc] init];
//    [topic17 setTopicName: @"Crowding Out"];
//    [topic17 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(110, 1), CMTimeMake(212, 1))];
//    [topic17 setImportanceWeighting: 99];
//    CECloudView* cloudView17 = [[CECloudView alloc] initWithTopic: topic17];
//    [view addSubview: cloudView17];
//    [views addObject: cloudView17];
//    
//    CETopic* topic18 = [[CETopic alloc] init];
//    [topic18 setTopicName: @"Crowding Out"];
//    [topic18 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(110, 1), CMTimeMake(212, 1))];
//    [topic18 setImportanceWeighting: 87];
//    CECloudView* cloudView18 = [[CECloudView alloc] initWithTopic: topic18];
//    [view addSubview: cloudView18];
//    [views addObject: cloudView18];
//    
//    CETopic* topic19 = [[CETopic alloc] init];
//    [topic19 setTopicName: @"Crowding Out"];
//    [topic19 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(110, 1), CMTimeMake(212, 1))];
//    [topic19 setImportanceWeighting: 20];
//    CECloudView* cloudView19 = [[CECloudView alloc] initWithTopic: topic19];
//    [view addSubview: cloudView19];
//    [views addObject: cloudView19];
//    
//    CETopic* topic20 = [[CETopic alloc] init];
//    [topic20 setTopicName: @"Crowding Out"];
//    [topic20 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(110, 1), CMTimeMake(212, 1))];
//    [topic20 setImportanceWeighting: 6];
//    CECloudView* cloudView20 = [[CECloudView alloc] initWithTopic: topic20];
//    [view addSubview: cloudView20];
//    [views addObject: cloudView20];
//    
//    CETopic* topic21 = [[CETopic alloc] init];
//    [topic21 setTopicName: @"Crowding Out"];
//    [topic21 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(110, 1), CMTimeMake(212, 1))];
//    [topic21 setImportanceWeighting: 59];
//    CECloudView* cloudView21 = [[CECloudView alloc] initWithTopic: topic21];
//    [view addSubview: cloudView21];
//    [views addObject: cloudView21];
//    
//    CETopic* topic22 = [[CETopic alloc] init];
//    [topic22 setTopicName: @"Crowding Out"];
//    [topic22 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(110, 1), CMTimeMake(212, 1))];
//    [topic22 setImportanceWeighting: 62];
//    CECloudView* cloudView22 = [[CECloudView alloc] initWithTopic: topic22];
//    [view addSubview: cloudView22];
//    [views addObject: cloudView22];
//    
//    CETopic* topic23 = [[CETopic alloc] init];
//    [topic23 setTopicName: @"Crowding Out"];
//    [topic23 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(110, 1), CMTimeMake(212, 1))];
//    [topic23 setImportanceWeighting: 71];
//    CECloudView* cloudView23 = [[CECloudView alloc] initWithTopic: topic23];
//    [view addSubview: cloudView23];
//    [views addObject: cloudView23];
    
    
    // [TODO] Test what happens if there are two topics of the same importance.
//    NSArray* sortedViews = [self orderViewsByImportance: views];
//    NSUInteger totalWidthNeeded = [self calculateTotalWidthFromViews: sortedViews];
//    
//    CGRect frame = [view frame];
//    [view setFrame: CGRectMake(frame.origin.x, frame.origin.y, totalWidthNeeded, frame.size.height)];
//    
//    [self layoutCloudsFromArray: sortedViews];
    
//    [self layoutCloudsFromArrayNew: sortedViews];
}


// ------------------------------------------------------------
// cloudWindowOpened:
// ------------------------------------------------------------
- (void) cloudWindowOpened: (NSNotification*)notification
{
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
        [topic setImportanceWeighting: [curTopicFrequency integerValue]];
        CECloudView* cloudView = [[CECloudView alloc] initWithTopic: topic];
        [view addSubview: cloudView];
        [views addObject: cloudView];
    }
    
//    NSArray* sortedViews = [self orderViewsByImportance: views];
    NSUInteger totalWidthNeeded = [self calculateTotalWidthFromViews: views];
    
    CGRect frame = [view frame];
    [view setFrame: CGRectMake(frame.origin.x, frame.origin.y, totalWidthNeeded, frame.size.height)];
    
    // [TODO] Clouds are being laid out in reverse order, fix.
    [self layoutCloudsFromArray: views];
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
    NSUInteger numViews = [views count];
    
    for (NSUInteger i = 0; i < numViews; ++i)
    {
        CECloudView* view = [views objectAtIndex: i];
        const CGFloat diameter = [view frame].size.width; // the view is a circle, so the width and height are equal
        const CGPoint center = [self calculateCenterOfCloudWithIndex: i withViewDiameter: diameter withViews: views];
        [view setFrame: CGRectMake(center.x, center.y, diameter, diameter)];
    }
}


// ------------------------------------------------------------
// calculateStartIndexForLevel:
//
// Returns the starting index of a given level. This index is
// the first index of this level (so the cloud at this level is
// *on* this level).
// ------------------------------------------------------------
- (NSUInteger) startIndexForLevel: (NSUInteger)level
{
    // The starting index is determined by the level squared
    // for even levels and the level squared plus one for odd levels.
    return level * level + (level % 2 == 0);
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
- (NSUInteger) levelForIndex: (NSUInteger)index
{
    NSUInteger curLevel = 0;
    bool foundLevel = false;
    
    while (!foundLevel)
    {
        foundLevel = [self startIndexForLevel: ++curLevel] > index;
    }
    
    return curLevel-1;
}


// ------------------------------------------------------------
// numLevelsForNumClouds:
// ------------------------------------------------------------
- (NSUInteger) numLevelsForNumClouds: (NSUInteger)numClouds
{
    return [self levelForIndex: numClouds];
}


// ------------------------------------------------------------
// totalCloudsPerQuadrantForLevel:
// ------------------------------------------------------------
- (NSUInteger) totalCloudsPerQuadrantForLevel: (NSUInteger)level
{
    const NSUInteger startIndex = [self startIndexForLevel: level];
    const NSUInteger nextStartIndex = [self startIndexForLevel: level+1];
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
    const NSUInteger level = [self levelForIndex: cloudIndex];
    const NSUInteger cloudsPerQuadrant = [self totalCloudsPerQuadrantForLevel: level];
    
    if (cloudsPerQuadrant == 0)
        return 0;
    
    const NSUInteger startIndex = [self startIndexForLevel: level];
    const NSUInteger numCloudsBetweenStartAndCurCloud = cloudIndex - startIndex;
    return numCloudsBetweenStartAndCurCloud / cloudsPerQuadrant;
}


- (NSUInteger) offsetWithinQuadrantForIndex: (NSUInteger)index
{
    const NSUInteger level = [self levelForIndex: index];
    const NSUInteger startIndex = [self startIndexForLevel: level];
    return index - startIndex;
}

// indices are zero offset
- (NSArray<NSNumber*>*) surroundingIndicesForIndex: (NSUInteger)index
{
    const NSUInteger indexOffset = [self offsetWithinQuadrantForIndex: index];
    NSUInteger secondIndexOffset = indexOffset + 1;
    const NSUInteger curLevel = [self levelForIndex: index];
    
    if (secondIndexOffset >= [self numCloudsForLevel: curLevel])
        secondIndexOffset = 0;
    
    return @[[NSNumber numberWithInteger: indexOffset], [NSNumber numberWithInteger: secondIndexOffset]];
}

// the parameter order should be the correct index order of the clouds
//- (CGFloat) radiusBetweenCloud: (CECloudView*)firstCloud andCloud: (CECloudView*)secondCloud
//{
//    return fabs([firstCloud frame].origin.x - [secondCloud frame].origin.x);
//}

// the parameter order should be the correct index order of the clouds
- (CGPoint) newCloudCenterFromFirstCloud: (CECloudView*)firstCloud andSecondCloud: (CECloudView*)secondCloud andCurIndex: (NSUInteger)curIndex
{
    const CGPoint firstOrigin = [firstCloud frame].origin;
    const CGPoint secondOrigin = [secondCloud frame].origin;
    const CGFloat radius = fabs((secondOrigin.x - firstOrigin.x)) / 2;
    const NSUInteger quadrant = [self quadrantForCloudIndex: curIndex];
    
    if (quadrant == 0)
        return CGPointMake(firstOrigin.x + radius, secondOrigin.y + radius);
    else if (quadrant == 1)
        return CGPointMake(firstOrigin.y - radius, secondOrigin.x + radius);
    else if (quadrant == 2)
        return CGPointMake(firstOrigin.x - radius, secondOrigin.y - radius);
    else
        return CGPointMake(firstOrigin.y + radius, secondOrigin.x - radius);
}

- (NSUInteger) rawIndexFromOffset: (NSUInteger)indexOffset AndLevel: (NSUInteger)level
{
    NSUInteger totalClouds = 0;
    for (NSUInteger i = 0; i <= level; ++i)
    {
        totalClouds += [self numCloudsForLevel: i];
    }
    
    totalClouds += indexOffset;
    
    return totalClouds;
}

// ------------------------------------------------------------
// calculateCenterOfCloud:withIndex:
//
// index is the index of this cloud in the array if ordered
// clouds.
// ------------------------------------------------------------
- (CGPoint) calculateCenterOfCloudWithIndex: (NSUInteger)index withViewDiameter: (CGFloat)curCloudDiameter withViews: (NSArray<CECloudView*>*)views
{
    const NSUInteger levelMultiplier = 300;
    const NSUInteger curLevel = [self levelForIndex: index];
    const NSUInteger curQuadrant = [self quadrantForCloudIndex: index];
    
    bool shouldReverse = false;
    
    CGFloat xPos = 0;
    CGFloat yPos = 0;
    if (index <= 4)
    {
        // [TODO] These should be calculated such that the circles are all the same distance from touching the central circle
        switch (index) {
            case 0:
                xPos += 600;
                yPos += 250;
                break;
            case 1:
                yPos += 200;
                xPos += 600;
                yPos += 250;
                break;
            case 2:
                xPos += 200;
                xPos += 600;
                yPos += 250;
                break;
            case 3:
                yPos -= 200;
                xPos += 600;
                yPos += 250;
                break;
            default: // 4
                xPos -= 200;
                xPos += 600;
                yPos += 250;
                break;
        }
    }
    else if (index > 4)
    {
//        shouldReverse = true;
        NSArray* surroundingIndices = [self surroundingIndicesForIndex: index];
        const NSUInteger firstIndex = [[surroundingIndices objectAtIndex: 0] integerValue];
        const NSUInteger secondIndex = [[surroundingIndices objectAtIndex: 1] integerValue];
        const NSUInteger rawIndex = [self rawIndexFromOffset: firstIndex AndLevel: curLevel - 1];
        const NSUInteger secondRawIndex = [self rawIndexFromOffset: secondIndex AndLevel: curLevel - 1];
        const CGRect firstFrame = [[views objectAtIndex: rawIndex] frame];
        const CGRect secondFrame = [[views objectAtIndex: secondRawIndex] frame];
        const CGPoint cloudCenter = [self newCloudCenterFromFirstCloud: [views objectAtIndex: rawIndex] andSecondCloud: [views objectAtIndex: secondRawIndex] andCurIndex: index];
        xPos = cloudCenter.x;
        yPos = cloudCenter.y;
        // FIRST QUADRANT:
        // ✓ // radius should the radius of the circle created by the two circles it should be between
            // ✓ // need some way of getting the two circles it should be between
        // ✓ // radius can be calculated by taking the difference of the two x positions of the circle's centers
        // ✓ // Calculate circle center (do this before negation)
            // ✓ // add x to first circle, subtract y from second circle
        // center of cloud should be center of circle
        // Add some small constant to the x and y of center to push cloud out a little bit to prevent clouds from overlapping
            // Really, should figure out if they do overlap, and if they do, push the new cloud out just enough so they don't overlap
//        const NSUInteger numCloudsOnCurLevel = [self numCloudsForLevel: curLevel];
//        const NSUInteger anglesCreatedByClouds = numCloudsOnCurLevel;
//        const NSUInteger degreesPerCloud = 90 / anglesCreatedByClouds;
//        const CGFloat radians = degreesPerCloud * M_PI / 180;
//        const NSUInteger curLevelDiameter = curLevel * levelMultiplier;
//        xPos = cos(radians) * curLevelDiameter / 2;
//        yPos = sin(radians) * curLevelDiameter / 2;
    }
    // [TODO] Account for positions within a quadrant per level, instead of just the level itself.
    // [TODO] Tighten the spiral; the varying sizes of the circles makes it so we don't currently
    // take into account the differently sized spaces between the circles of different levels.
//    NSInteger x = xPos + curLevel * levelMultiplier;
//    NSInteger y = yPos + curLevel * levelMultiplier;
    NSInteger x = xPos;
    NSInteger y = yPos;
    
//    const NSUInteger radiusOffset = curCloudDiameter / 2;
//    y += radiusOffset;
//    x += radiusOffset;
    
    if (shouldReverse)
    {
        if (curQuadrant == 1)
            y = -y;
        else if (curQuadrant == 2)
        {
            x = -x;
            y = -y;
        }
        else if (curQuadrant == 3)
            x = -x;
    }
//    const NSUInteger originOffset = 600;
//    y += 250;
//    x += originOffset;
    


    return CGPointMake(x, y);
}


//- (CGPoint) calculateExactPoint: (NSUInteger)index
//{
//    
//    return CGPointMake(0, 0);
//}

@end
