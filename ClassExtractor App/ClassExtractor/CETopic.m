//
//  CETopic.m
//  ClassExtractor
//
//  Created by Elliot on 11/25/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import "CETopic.h"

@implementation CETopic
@synthesize topicName;
@synthesize importanceWeighting;
@synthesize topicRange;

// ------------------------------------------------------------
// description
// ------------------------------------------------------------
- (NSString*) description
{
    return [NSString stringWithFormat: @"(CETopic: name = %@, weighting = %lu)", [self topicName], (unsigned long)[self importanceWeighting]];
}

@end
