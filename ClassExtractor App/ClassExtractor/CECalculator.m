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
// ascending by number of occurrences.
//
// [TODO] Hook up this function to Watson's output.
//
// [TODO] Add temporal information into this array, so that it
// not only keeps track of how many times something is said, but
// also when it is said.
//
// [TODO] After completing the above [TODO], add a sorting ability
// by time.
// ------------------------------------------------------------
+ (NSArray*) calculateFrequencyOfWords: (NSArray<NSString*>*)words inString: (NSString*)text
{
    NSMutableArray* frequencies = [[NSMutableArray alloc] init];
    NSString* compText = [[NSString stringWithString: text] lowercaseString];
    
    for (NSUInteger i = 0; i < [words count]; ++i)
    {
        NSUInteger curWordCount = 0;
        NSString* curWord = [[words objectAtIndex: i] lowercaseString];
        NSRange compTextRange = [compText rangeOfString: curWord];
        
        // check if there are any more occurrences of the word in
        // the original string
        while (NSNotFound != compTextRange.location)
        {
            ++curWordCount;
            
            // create a new string that starts from where the word ends
            compText = [compText substringFromIndex: compTextRange.location + compTextRange.length];
            compTextRange = [compText rangeOfString: curWord];
        }
        
        // the key is the word and the value is its frequency
        NSDictionary* curWordDict = @{curWord : [NSNumber numberWithInteger: curWordCount]};
        [frequencies addObject: curWordDict];
    }
    
    return [CECalculator sortFrequencyArray: frequencies];
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
// up and combine both of those frequencies). The combined
// array is ascending by number of occurrences.
// ------------------------------------------------------------
+ (NSArray*) joinArrayOfFrequencies: (NSArray<NSDictionary*>*)firstFreqs withOtherArrayOfFrequencies: (NSArray<NSDictionary*>*)secondFreqs
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
    
    return [CECalculator sortFrequencyArray: allFreqs];
}


// ------------------------------------------------------------
// sortFrequencyArray:
//
// Sorts the argument array in descending order by order of
// occurrences of each word.
// ------------------------------------------------------------
+ (NSArray*) sortFrequencyArray: (NSArray<NSDictionary*>*)unsorted
{
    if (nil == unsorted || nil == [unsorted firstObject])
        return nil;
    
    if (1 == [unsorted count])
        return unsorted;
    
    NSArray* sorted = [unsorted sortedArrayUsingComparator: ^NSComparisonResult(NSDictionary* firstDict, NSDictionary* secondDict) {
        NSNumber* firstNum = [[firstDict allValues] firstObject];
        NSNumber* secondNum = [[secondDict allValues] firstObject];
        return [secondNum compare: firstNum];
    }];
    
    return sorted;
}

@end
