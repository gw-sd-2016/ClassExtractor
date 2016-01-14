//
//  CECloudView.h
//  ClassExtractor
//
//  Created by Elliot on 11/25/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "CETopic.h"

@class CERingTracker;


@interface CECloudView : NSView

@property CETopic* representedTopic;
@property CERingTracker* ringTracker;

- (instancetype) initWithTopic: (CETopic*)topic;

@end


@interface CETextField : NSTextField

- (instancetype) initWithCloudView: (CECloudView*)cloudView;

@end


@interface CERingTracker : NSObject
{
    @private
    NSMutableArray* ringArray;
}

@property CECloudView* centerCloud;

- (void) fillInIndex: (NSUInteger)index withView: (CECloudView*)cloudView;
- (NSUInteger) nextIndex;
- (bool) indexFilled: (NSUInteger)index;
//- (void) setCenterCloudWithCloud: (CECloudView*)inCenterCloud;

@end
