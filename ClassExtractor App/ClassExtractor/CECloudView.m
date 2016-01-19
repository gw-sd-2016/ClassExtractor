//
//  CECloudView.m
//  ClassExtractor
//
//  Created by Elliot on 11/25/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import "CECloudView.h"
#import "Constants.h"

// ============================================================
// CECloudView
// ============================================================
@implementation CECloudView
@synthesize representedTopic;

// ------------------------------------------------------------
// initWithTopic:
//
// When setting the position of this cloud view, make sure not
// to change the size.
// ------------------------------------------------------------
- (instancetype) initWithTopic: (CETopic*)topic
{
    self = [super init];
    
    if (self)
    {
        // setup the view from the given topic
        [self setRepresentedTopic: topic];
        const CGSize imporSize = [self calculateSizeFromImportance];
        [self setFrame: CGRectMake(0, 0, imporSize.width, imporSize.height)];
        
        // setup the view's layer
        [self setWantsLayer: true];
        CALayer* layer = [self layer];
        [layer setCornerRadius: imporSize.width / 2];
        NSColor* color = [self setColorFromRGBWithRed: 219 andGreen: 2 andBlue: 2];
        [layer setBackgroundColor: [color CGColor]];

        CETextField* nameField = [[CETextField alloc] initWithCloudView: self];
        [nameField setStringValue: [[[self representedTopic] topicName] capitalizedString]];
        NSLayoutConstraint* yConstraint = [NSLayoutConstraint constraintWithItem: nameField
                                                                       attribute: NSLayoutAttributeCenterY
                                                                       relatedBy: NSLayoutRelationEqual
                                                                          toItem: self
                                                                       attribute: NSLayoutAttributeCenterY
                                                                      multiplier: 1.0f
                                                                        constant: 0.0f];
        [NSLayoutConstraint activateConstraints: @[yConstraint]];

        CETextField* timeField = [[CETextField alloc] initWithCloudView: self];
        [timeField setStringValue: [self formatTime]];
        NSDictionary* viewsForConstraints = @{@"timeField" : timeField,
                                              @"nameField" : nameField};
        NSString* heightFormat = @"V:[nameField][timeField]";
        NSArray* heightConstraint = [NSLayoutConstraint constraintsWithVisualFormat: heightFormat
                                                                            options: NSLayoutFormatAlignAllCenterX
                                                                            metrics: nil
                                                                              views: viewsForConstraints];
        [NSLayoutConstraint activateConstraints: heightConstraint];
        
        // create the ring tracker
        [self setRingTracker: [[CERingTracker alloc] init]];
    }
    
    return self;
}


// ------------------------------------------------------------
// formatTime
//
// Takes the represented topic's time duration and formats it
// nicely in a human readable form (i.e. "4:32 - 6:19").
// ------------------------------------------------------------
- (NSString*) formatTime
{
    const CMTimeRange timeRange = [[self representedTopic] topicRange];
    
    const NSUInteger kSecondsPerMinute = 60;
    const NSUInteger kStartTime = timeRange.start.value;
    const NSUInteger kDuration = timeRange.duration.value;
    const NSUInteger kEndTime = kStartTime + kDuration;
    const NSUInteger kStartMinutes = kStartTime / kSecondsPerMinute;
    const NSUInteger kStartSeconds = kStartTime % kSecondsPerMinute;
    NSString* formattedStartSeconds;
    if (kStartSeconds < 10)
        formattedStartSeconds = [NSString stringWithFormat: @"0%lu", (unsigned long)kStartSeconds];
    else
        formattedStartSeconds = [NSString stringWithFormat: @"%lu", (unsigned long)kStartSeconds];
    const NSUInteger kEndMinutes = kEndTime / kSecondsPerMinute;
    const NSUInteger kEndSeconds = kEndTime % kSecondsPerMinute;
    NSString* formattedEndSeconds;
    if (kEndSeconds < 10)
        formattedEndSeconds = [NSString stringWithFormat: @"0%lu", (unsigned long)kEndSeconds];
    else
        formattedEndSeconds = [NSString stringWithFormat: @"%lu", (unsigned long)kEndSeconds];
    
    NSString* formatString = [NSString stringWithFormat: @"%lu:%@ - %lu:%@",
                              (unsigned long)kStartMinutes,
                              formattedStartSeconds,
                              (unsigned long)kEndMinutes,
                              formattedEndSeconds];
    
    return formatString;
}


// ------------------------------------------------------------
// setColorFromRGBWithRed:andGreen:andBlue:
//
// A convenience method for creating an NSColor and setting it
// as the fill and stroke colors in the current drawing context.
// ------------------------------------------------------------
- (NSColor*) setColorFromRGBWithRed: (unsigned char)red andGreen: (unsigned char)green andBlue: (unsigned char)blue
{
    NSColor* calibratedColor = [NSColor colorWithCalibratedRed: (red   / 255.0f)
                                                         green: (green / 255.0f)
                                                          blue: (blue  / 255.0f)
                                                         alpha: 1.0];
    
    [calibratedColor set];
    
    return calibratedColor;
}


// ------------------------------------------------------------
// calculateSizeFromImportance
//
// Calculates the diameter of the circle based on the
// importance of the represented topic. The diameter is double
// the importance rating plus the multiplier times the reciprocal
// of the importance rating. We factor in the reciprocal to favor
// less important topics, as otherwise a very important topic
// might have a diameter of 200, while a not so important topic
// may only have a diameter of 10. Factoring in the reciprocal
// avoids that.
// ------------------------------------------------------------
- (CGSize) calculateSizeFromImportance
{
    const NSUInteger multiplier = 50;
    const NSUInteger weighting = [[self representedTopic] importanceWeighting];
    
    // [TODO] The weightings need a better formula, as right now they're just from
    // frequencies of each topic, which might be only 2 or 3.
    NSUInteger inflatedWeighting;
    if (weighting == 0)
        inflatedWeighting = 100;
    else if (weighting == 1)
        inflatedWeighting = 130;
    else if (weighting == 2)
        inflatedWeighting = 150;
    else if (weighting <= 5)
        inflatedWeighting = weighting * 50;
    else
        inflatedWeighting = weighting * 20;
    
    const NSUInteger baseCalculation = inflatedWeighting * 2;
    const double reciprocal = 1 / (double)inflatedWeighting;
    const double offsetDiameter = multiplier * reciprocal;
    const double diameter = baseCalculation + offsetDiameter;
    
    return CGSizeMake(diameter, diameter);
}


// ------------------------------------------------------------
// description
// ------------------------------------------------------------
- (NSString*) description
{
    return [NSString stringWithFormat: @"CECloudView: %@\r     %@", [self representedTopic], [self ringTracker]];
}

@end


// ============================================================
// CETextField
// ============================================================
@implementation CETextField

// ------------------------------------------------------------
// initWithCloudView:
//
// Must be sure to not create a strong reference to cloudView.
// ------------------------------------------------------------
- (instancetype) initWithCloudView: (CECloudView*)cloudView
{
    self = [super init];
    
    if (self)
    {
        // create a textfield for the name of the topic
        // [TODO] Decide on a good font size (the font size
        // should be a function of how big the cloud is).
        [self setEditable: false];
        [self setBordered: false];
        [self setTranslatesAutoresizingMaskIntoConstraints: false];
        [self setBackgroundColor: [NSColor colorWithCGColor: [[cloudView layer] backgroundColor]]];
        [cloudView addSubview: self];

        NSLayoutConstraint* xConstraint = [NSLayoutConstraint constraintWithItem: self
                                                                       attribute: NSLayoutAttributeCenterX
                                                                       relatedBy: NSLayoutRelationEqual
                                                                          toItem: cloudView
                                                                       attribute: NSLayoutAttributeCenterX
                                                                      multiplier: 1.0f
                                                                        constant: 0.0f];
        [NSLayoutConstraint activateConstraints: @[xConstraint]];
        
        NSDictionary* viewsForConstraints = @{@"self" : self};
        // [TODO] When the font size is decided upon later, this height
        // will have to change.
        const NSUInteger height = 20;
        NSString* heightFormat = [NSString stringWithFormat: @"V:[self(%lu)]", (unsigned long)height];
        NSArray* heightConstraint = [NSLayoutConstraint constraintsWithVisualFormat: heightFormat
                                                                            options: NSLayoutFormatAlignAllTop
                                                                            metrics: nil
                                                                              views: viewsForConstraints];
        [NSLayoutConstraint activateConstraints: heightConstraint];
    }
    
    return self;
}

@end


// ============================================================
// CERingTracker
// ============================================================
@implementation CERingTracker
@synthesize centerCloud;
@synthesize ringFull;

// ------------------------------------------------------------
// init
// ------------------------------------------------------------
- (instancetype) init
{
    self = [super init];
    
    if (self)
        ringArray = [[NSMutableArray alloc] init];
    
    return self;
}


// ------------------------------------------------------------
// fillInIndex:
//
// Fills in the argument index with the argument cloud view.
// ------------------------------------------------------------
- (void) fillInIndex: (NSUInteger)index withView: (CECloudView*)cloudView
{
    // if an index greater than five is given, reject it
    if (index > 5)
        return;
    
    @synchronized(ringArray)
    {
        // [TODO] Change this to binary search, since ringArray is sorted.
        for (NSUInteger i = 0; i < [ringArray count]; ++i)
        {
            if ([[[[ringArray objectAtIndex: i] allKeys] firstObject] integerValue] == index)
                return;
        }
        
//        [ringArray addObject: @{[NSNumber numberWithUnsignedInteger: index] : [NSNumber numberWithBool: true]}];
        [ringArray addObject: @{[NSNumber numberWithUnsignedInteger: index] : cloudView}];
        
        ringArray = [[ringArray sortedArrayUsingComparator: ^NSComparisonResult(NSDictionary* firstDict, NSDictionary* secondDict) {
            NSNumber* firstNum = [[firstDict allKeys] firstObject];
            NSNumber* secondNum = [[secondDict allKeys] firstObject];
            return [firstNum compare: secondNum]; // ascending
        }] mutableCopy];
    }
    
    if ([ringArray count] == kNumCloudsPerRing)
        ringFull = true;
}


// ------------------------------------------------------------
// indexFilled:
//
// Returns whether or not the argument index has already been
// filled in.
// ------------------------------------------------------------
- (bool) indexFilled: (NSUInteger)index
{
    // if an index greater than five is given, reject it
    if (index > 5)
        return false;
    
    // iterate through the array, if a key is present that matches
    // the argument index, then that index has been filled in
    for (NSUInteger i = 0; i < [ringArray count]; ++i)
    {
        if ([[[[ringArray objectAtIndex: i] allKeys] firstObject] integerValue] == index)
            return true;
    }
    
    return false;
}


// ------------------------------------------------------------
// cloudViewAtRingIndex:
// ------------------------------------------------------------
- (CECloudView*) cloudViewAtRingIndex: (NSUInteger)ringIndex
{
    NSDictionary* cloudDict = [ringArray objectAtIndex: ringIndex];
    NSArray* valueArray = [cloudDict allValues];
    return [valueArray firstObject];
}


// ------------------------------------------------------------
// description
// ------------------------------------------------------------
- (NSString*) description
{
    NSMutableString* ringArrayDesc = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < [ringArray count]; ++i)
    {
        [ringArrayDesc appendString: [NSString stringWithFormat: @"%lu", [[[[ringArray objectAtIndex: i] allKeys] firstObject] integerValue]]];
    }
//    NSString* ringTrackerDesc = [NSString stringWithFormat: @"CERingTracker: %@", ringArray];
    
    // -description doesn't handle "\n" correctly, so swap those with "\r" (when printing,
    // arrays have a newline character for every index)
    return [ringArrayDesc stringByReplacingOccurrencesOfString: @"\n" withString: @"\r"];
}

@end
