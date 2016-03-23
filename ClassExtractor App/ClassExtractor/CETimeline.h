//
//  CETimelineBarModel.h
//  ClassExtractor
//
//  Created by Elliot on 3/1/16.
//  Copyright © 2016 ECL. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import "CETopic.h"

@interface CETimelineBarView : NSView
@property (strong) IBOutlet NSTextField* topic1Name;
@property (strong) IBOutlet NSTextField* topic2Name;
@property (strong) IBOutlet NSTextField* topic3Name;
@property (strong) IBOutlet NSTextField* topic4Name;
@property (strong) IBOutlet NSTextField* topic5Name;
@property (strong) IBOutlet NSLayoutConstraint* topic2LeadingConstraint;
@property (strong) IBOutlet NSLayoutConstraint* topic3LeadingConstraint;
@property (strong) IBOutlet NSLayoutConstraint* topic4LeadingConstraint;
@property (strong) IBOutlet NSLayoutConstraint* topic5LeadingConstraint;
@property (strong) IBOutlet NSLayoutConstraint *topic2TrailingConstraint;
@property (strong) IBOutlet NSLayoutConstraint *topic3TrailingConstraint;
@property (strong) IBOutlet NSLayoutConstraint *topic4TrailingConstraint;
@property (strong) IBOutlet NSLayoutConstraint *topic5TrailingConstraint;
@property (strong) IBOutlet NSBox *timelineBar5;
@property (strong) IBOutlet NSBox *timelineBar4;
@property (strong) IBOutlet NSBox *timelineBar3;
@property (strong) IBOutlet NSBox *timelineBar2;
@property (strong) IBOutlet NSBox *timelineBar1;

// it is assumed that the horizontal leading and trailing constraints of the
// timeline bar will always be equal
@property (strong) IBOutlet NSLayoutConstraint* timelineBarHorizConstraint;
@property (strong) IBOutlet NSLayoutConstraint* topic1TrailingConstraint;
@property (strong) IBOutlet NSLayoutConstraint* topic1LeadingConstraint;
@property (strong) IBOutlet NSBox* timelineBar;
@property (strong) IBOutlet NSTextField* totalTimeTextField;

@property NSArray<NSTextField*>* topicNameTextFields;
@property NSArray<NSLayoutConstraint*>* topicLeadingConstraints;
@property NSArray<NSLayoutConstraint*>* topicTrailingConstraints;
@property NSArray<NSBox*>* topicTimelines;

- (void) drawTimeBarsWithTopics: (NSArray<CETopic*>*)topics
                   andTotalTime: (CMTime)totalTime;

@end
