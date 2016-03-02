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

@interface CETimelineBarModel : NSObject

@property CMTime totalTime;
@property NSMutableArray<CETopic*>* topics;

- (void) addTopic: (CETopic*)newTopic;

@end

@interface CETimelineBarView : NSView

// it is assumed that the horizontal leading and trailing constraints of the
// timeline bar will always be equal
@property (strong) IBOutlet NSLayoutConstraint* timelineBarHorizConstraint;
@property (strong) IBOutlet NSLayoutConstraint* topic1TrailingConstraint;
@property (strong) IBOutlet NSLayoutConstraint* topic1LeadingConstraint;
@property (strong) IBOutlet NSBox* timelineBar;
@property (strong) IBOutlet NSTextField* totalTimeTextField;

- (void) drawTimeBarsWithTopics: (NSArray<CETopic*>*)topics
                   andTotalTime: (CMTime)totalTime;

@end

@interface CETimelineBarViewController : NSViewController

@property CETimelineBarModel* timelineModel;

@end
