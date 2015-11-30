//
//  CECloudView.m
//  ClassExtractor
//
//  Created by Elliot on 11/25/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import "CECloudView.h"

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
        [nameField setStringValue: [[self representedTopic] topicName]];
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
    const NSUInteger kEndMinutes = kEndTime / kSecondsPerMinute;
    const NSUInteger kEndSeconds = kEndTime % kSecondsPerMinute;
    NSString* formattedEndSeconds;
    if (kEndSeconds < 10)
        formattedEndSeconds = [NSString stringWithFormat: @"0%lu", (unsigned long)kEndSeconds];
    else
        formattedEndSeconds = [NSString stringWithFormat: @"%lu", (unsigned long)kEndSeconds];
    
    NSString* formatString = [NSString stringWithFormat: @"%lu:%lu - %lu:%@",
                              (unsigned long)kStartMinutes,
                              (unsigned long)kStartSeconds,
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
    
    const NSUInteger baseCalculation = weighting * 2;
    const double reciprocal = 1 / (double)weighting;
    const double offsetDiameter = multiplier * reciprocal;
    const double diameter = baseCalculation + offsetDiameter;
    
    return CGSizeMake(diameter, diameter);
}


// ------------------------------------------------------------
// description
// ------------------------------------------------------------
- (NSString*) description
{
    return [NSString stringWithFormat: @"CECloudView: %@", [self representedTopic]];
}

@end


// ============================================================
// CETextField
// ============================================================
@implementation CETextField

// ------------------------------------------------------------
// initWithCloudView:
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
