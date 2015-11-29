//
//  CEWordCloudViewController.m
//  ClassExtractor
//
//  Created by Elliot on 11/24/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import "CEWordCloudViewController.h"
#import "CECloudView.h"

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

    // [TODO] This is test code, remove this later.
    CETopic* topic = [[CETopic alloc] init];
    [topic setTopicName: @"Marginal Benefit"];
    [topic setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(100, 1), CMTimeMake(417, 1))];
    [topic setImportanceWeighting: 77];
    
    CECloudView* cloudView = [[CECloudView alloc] initWithTopic: topic];
    [[self view] addSubview: cloudView];
}

@end
