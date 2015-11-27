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
        
        // create a textfield for the name of the topic
        // [TODO] Decide on a good font size.
        NSTextField* nameField = [[NSTextField alloc] init];
        [nameField setStringValue: [[self representedTopic] topicName]];
        [nameField setEditable: false];
        [nameField setBordered: false];
        [nameField setTranslatesAutoresizingMaskIntoConstraints: false];
        [nameField setBackgroundColor: color];
        [self addSubview: nameField];
        
        NSLayoutConstraint* xConstraint = [NSLayoutConstraint constraintWithItem: nameField
                                                                       attribute: NSLayoutAttributeCenterX
                                                                       relatedBy: NSLayoutRelationEqual
                                                                          toItem: self
                                                                       attribute: NSLayoutAttributeCenterX
                                                                      multiplier: 1.0f
                                                                        constant: 0.0f];
        NSLayoutConstraint* yConstraint = [NSLayoutConstraint constraintWithItem: nameField
                                                                       attribute: NSLayoutAttributeCenterY
                                                                       relatedBy: NSLayoutRelationEqual
                                                                          toItem: self
                                                                       attribute: NSLayoutAttributeCenterY
                                                                      multiplier: 1.0f
                                                                        constant: 0.0f];
        
        NSDictionary* constraints = @{@"nameField" : nameField};
        // [TODO] When the font size is decided upon later, this height
        // will have to change.
        NSString* heightFormat = @"V:[nameField(20)]";
        NSArray* heightConstraint = [NSLayoutConstraint constraintsWithVisualFormat: heightFormat options: NSLayoutFormatAlignAllTop metrics: nil views: constraints];
        [NSLayoutConstraint activateConstraints: heightConstraint];
        [NSLayoutConstraint activateConstraints: @[xConstraint, yConstraint]];
    }
    
    return self;
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

@end
