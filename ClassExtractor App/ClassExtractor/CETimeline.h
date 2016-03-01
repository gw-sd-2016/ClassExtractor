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

@end

@interface CETimelineBarViewController : NSViewController

@end
