//
//  CECalculator.m
//  ClassExtractor
//
//  Created by Elliot on 11/17/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import "CECalculator.h"
#import "Constants.h"

@implementation CECalculator


// ------------------------------------------------------------
// calculateFrequencyOfWords:inString:
//
// Returns an array of dictionaries whose only key/value pair
// is each word with its number of occurrences. The array is
// ordered from most frequent to least frequent.
//
// [TODO] Since getJSONFromWatson in ViewController.m is broken
// right now, this function hasn't been fully tested. Make sure
// that frequencies are correct and that the sorting method
// sorts the frequencies from most to least frequent.
//
// [TODO] Add temporal information into this array, so that it
// not only keeps track of how many times something is said, but
// also when it is said.
//
// [TODO] After completing the above [TODO], add a sorting ability
// by time.
//
// [TODO] When we separate the components of the string by spaces,
// we get each word *with any surrounding punctuation*. This means
// that if the professor says "demand" in the middle of a sentence
// and at the end of a sentence (where there's a period), it will
// be counted as two different words. Investigate if Aylien
// is able to see those two words as the same thing, and if not,
// account for the punctuation here. Check also for capitalization
// differences (for if the word comes at the beginning of a
// sentence).
// ------------------------------------------------------------
- (NSArray*) calculateFrequencyOfWords: (NSArray*)words inString: (NSString*)text
{
    NSMutableArray* frequencies = [[NSMutableArray alloc] init];
    NSArray* textWords = [text componentsSeparatedByString: @" "];
    
    // iterate through the concepts, as determined by Aylien
    for (NSUInteger i = 0; i < [words count]; ++i)
    {
        NSUInteger curWordCount = 0;
        
        // iterate through the original lecture text
        for (NSUInteger j = 0; j < [textWords count]; ++j)
        {
            if ([[words objectAtIndex: i] isEqualToString: [textWords objectAtIndex: j]])
                ++curWordCount;
        }
        
        // the key is the word and the value is its frequency
        NSDictionary* curWordDict = @{[words objectAtIndex: i] : [NSNumber numberWithInteger: curWordCount]};
        [frequencies addObject: curWordDict];
    }
    
    // order the frequencies
    NSArray* sortedFreqs = [frequencies sortedArrayUsingComparator: ^NSComparisonResult(NSDictionary* firstDict, NSDictionary* secondDict) {
        NSNumber* firstNum = [[firstDict allValues] firstObject];
        NSNumber* secondNum = [[secondDict allValues] firstObject];
        return [firstNum compare: secondNum];
    }];
    
    return sortedFreqs;
}


// ------------------------------------------------------------
// joinArrayOfFrequencies:withOtherArrayOfFrequencies:
//
// Watson returns to us text in five minute segments, since we
// send the audio clips to it that way. As such, to calculate
// the total frequencies of the topics discussed in a lecture,
// we must combine those arrays, making sure to account for
// duplicates (i.e. if the professor said "marginal utility" in
// both the first segment and the third segment, we should tally
// up and combine both of those frequencies).
//
// [TODO] Since getJSONFromWatson in ViewController.m is broken
// right now, this function hasn't been fully tested. Make sure
// that duplicate detection is correct and that the newly created
// frequency dictionary has the right value.
// ------------------------------------------------------------
- (NSArray*) joinArrayOfFrequencies: (NSArray*)firstFreqs withOtherArrayOfFrequencies: (NSArray*)secondFreqs
{
    NSMutableArray* allFreqs = [firstFreqs mutableCopy];
    [allFreqs addObjectsFromArray: secondFreqs];
    
    for (NSUInteger i = 0; i < [allFreqs count]; ++i)
    {
        for (NSUInteger j = i + 1; j < [allFreqs count]; ++j)
        {
            NSDictionary* origDict = [allFreqs objectAtIndex: i];
            NSDictionary* repeatDict = [allFreqs objectAtIndex: j];
            NSString* origString = [[origDict allKeys] firstObject];
            
            if ([origString isEqualToString: [[repeatDict allKeys] firstObject]])
            {
                // When a repeat word is found, we remove the repeat dictionary from the array, add the repeat frequency
                // to the original frequency, remove the original dictionary from the array, and then create a new
                // dictionary with the old key and the new value and insert that at the index where the old dictionary
                // used to be.
                [allFreqs removeObjectAtIndex: j];
                NSUInteger repeatValue = [[[repeatDict allValues] firstObject] unsignedIntegerValue];
                NSUInteger origValue = [[[origDict allValues] firstObject] unsignedIntegerValue];
                NSUInteger totalValue = repeatValue + origValue;
                [allFreqs removeObjectAtIndex: i];
                [allFreqs insertObject: @{origString : [NSNumber numberWithInteger: totalValue]} atIndex: i];
            }
        }
    }
    
    return allFreqs;
}

@end
