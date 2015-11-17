//
//  CECalculator.h
//  ClassExtractor
//
//  Created by Elliot on 11/17/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CECalculator : NSObject

- (NSArray*) calculateFrequencyOfWords: (NSArray*)words inString: (NSString*)text;
- (NSArray*) joinArrayOfFrequencies: (NSArray*)firstFreqs withOtherArrayOfFrequencies: (NSArray*)secondFreqs;

@end
