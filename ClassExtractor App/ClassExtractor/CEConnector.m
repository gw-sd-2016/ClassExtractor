//
//  CEConnector.m
//  ClassExtractor
//
//  Created by Elliot on 11/22/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import "CEConnector.h"
#import "Constants.h"
#import "CEJSONManipulator.h"
#import "CECalculator.h"

@implementation CEConnector
@synthesize curStrings;
@synthesize totalFiles;
@synthesize curNumFiles;

// ------------------------------------------------------------
// sharedInstance
//
// Sets up (if not already setup) and returns the singleton
// object of this class.
// ------------------------------------------------------------
+ (CEConnector*) sharedInstance
{
    static CEConnector* instance = nil;
    
    if (nil == instance)
    {
        instance = [[CEConnector alloc] init];
        [instance setTotalFiles: 0];
        [instance setCurNumFiles: 0];
        if (nil == [instance curStrings])
            [instance setCurStrings: [[NSMutableArray alloc] init]];
    }
    
    return instance;
}


// ------------------------------------------------------------
// getJSONFromWatson:
//
// Send the parameter's audio file to Watson for transliteration.
//
// [TODO] Investigate into using libcurl here instead of NSTask
// ------------------------------------------------------------
- (void) getJSONFromWatsonAsync: (NSNotification*)notification
{
    dispatch_queue_t globalConcurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalConcurrentQueue, ^{
        NSTask* task = [[NSTask alloc] init];
        [task setLaunchPath: @"/usr/bin/curl"];
        
        NSString* credentials = @"";
        
        NSString* audioPath = [NSString stringWithFormat: @"@%@", [notification object]];
        
        NSArray* arguments = @[@"-u", credentials, @"-X", @"POST", @"--limit-rate", @"40000", @"--header", @"Content-Type: audio/wav", @"--header", @"Transfer-Encoding: chunked", @"--data-binary", audioPath, @"https://stream.watsonplatform.net/speech-to-text/api/v1/recognize?continuous=true"];
        [task setArguments: arguments];
        
        NSPipe* pipe = [NSPipe pipe];
        [task setStandardOutput: pipe];
        
        NSFileHandle* file = [pipe fileHandleForReading];
        
        [task launch];
        
        NSData* audioData = [file readDataToEndOfFile];
        NSString* strData = [[NSString alloc]initWithData: audioData
                                                 encoding: NSUTF8StringEncoding];
        
        if (NSNotFound != [strData rangeOfString: @"<TITLE>Watson Error</TITLE>"].location)
            [self evaluateNumFiles];
        else
            [self watsonFinishedWithData: audioData fromPath: audioPath];
    });
}


// ------------------------------------------------------------
// evaluateNumFiles
//
// curNumFiles tracks the number of files that have either returned
// an error from Watson or have returned a valid JSON response
// with transliterated text.
// ------------------------------------------------------------
- (void) evaluateNumFiles
{
    @synchronized(self)
    {
        ++curNumFiles;
        
        if (curNumFiles == totalFiles)
            [self orderStrings];
    }
}


// ------------------------------------------------------------
// watsonFinishedWithData:fromPath:
//
// Called after each time Watson finishes returning a transcript
// of a file. This function parses out the transcript of this
// file, combines them together, and then stores them for later
// so that all of them can be appended together in the correct
// order.
// ------------------------------------------------------------
- (void) watsonFinishedWithData: (NSData*)audioData fromPath: (NSString*)audioPath
{
    NSString* lastComp = [[NSURL URLWithString: audioPath] lastPathComponent];
    NSString* noTrimmed = [lastComp substringFromIndex: [@"trimmed" length]];
    NSString* noExt = [noTrimmed substringToIndex: [noTrimmed rangeOfString: @"."].location];
    
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    NSNumber* extNumber = [numberFormatter numberFromString: noExt];
    
    NSDictionary* resultDict = [CEJSONManipulator getJSONForData: audioData];
    NSArray* resultsArray = [resultDict objectForKey: @"results"];
    NSMutableString* resultString = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < [resultsArray count]; ++i)
    {
        NSArray* alternatives = [[resultsArray objectAtIndex: i] objectForKey: @"alternatives"];
        NSDictionary* firstAlternative = [alternatives firstObject];
        if (firstAlternative != nil)
            [resultString appendString: [firstAlternative objectForKey: @"transcript"]];
    }
    
    NSDictionary* curDict = @{kTranscriptKey : resultString,
                              @"order" : extNumber};
    [[self curStrings] addObject: curDict];
    
    [self evaluateNumFiles];
}


// ------------------------------------------------------------
// orderStrings
//
// Orders all of the transliterated strings that Watson returns.
// The strings are returned from Watson in an unpredictable
// order (since we're sending concurrent requests to it), so we
// must order them afterwards to be able to provide a coherent
// interpretation of them later.
// ------------------------------------------------------------
- (void) orderStrings
{
    // [TODO] Show the user some useful error dialog
    if (nil == curStrings || nil == [curStrings firstObject])
        return;
    
    if (1 == [curStrings count])
        [self getConceptsJSONAsync: [[curStrings firstObject] objectForKey: kTranscriptKey]];
    
    NSArray* sorted = [curStrings sortedArrayUsingComparator: ^NSComparisonResult(NSDictionary* firstDict, NSDictionary* secondDict) {
        NSNumber* firstNum = [[firstDict allValues] objectAtIndex: 1];
        NSNumber* secondNum = [[secondDict allValues] objectAtIndex: 1];
        return [firstNum compare: secondNum];
    }];
    
    NSMutableString* stringBuilder = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < [sorted count]; ++i)
    {
        [stringBuilder appendString: [[sorted objectAtIndex: i] objectForKey: kTranscriptKey]];
    }
    
    [self getConceptsJSON: stringBuilder];
}


// ------------------------------------------------------------
// getConceptsJSONAsync:
//
// Use the Mashape API ( https://market.mashape.com/aylien/text-analysis )
// to talk to the Aylien API for concept extraction. For now,
// the only supported language is English.
// ------------------------------------------------------------
- (void) getConceptsJSON: (NSString*)rawString
{
    NSString* credentials = @"";
    NSString* basePath = @"https://aylien-text.p.mashape.com/concepts?language=en&text=";
    NSString* formattedString = [rawString stringByReplacingOccurrencesOfString: @" " withString: @"+"];
    
    // [TODO] Check which of these characters actually causes the URL to return null (all of them
    // are thought to, but none are actually confirmed).
    // this regex checks for the last character not being a letter (guarding against there being
    // a last "+" in our string, which replaced a space above) and any invalid characters that
    // don't play nice with URL formatting
    NSString* regexPattern = @"([^A-Za-z]+$|(’*‘*'*\"*:*,*;*\\?*!*”*“*\\.*(%HESITATION)*)*)";
    NSError* error;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: regexPattern
                                                                           options: 0
                                                                             error: &error];
    
    // [TODO] Show the user some useful error dialog here
    if (error)
        NSLog(@"Error creating regex: %s", __PRETTY_FUNCTION__);
    else
    {
        NSString* cleanString = [regex stringByReplacingMatchesInString: formattedString
                                                              options: 0
                                                                range: NSMakeRange(0, [formattedString length])
                                                         withTemplate: @""];
    
        // [TODO] Figure out a good max character count, and if that count is exceeded,
        // splice the strings accordingly.
        NSString* shorter = cleanString;
        const NSUInteger maxCharCount = 5500;
        if ([cleanString length] > maxCharCount)
            shorter = [cleanString substringToIndex: maxCharCount]; // [TODO] Check to see if last character of
                                                                    // the truncated string is a plus.
    
        NSString* fullPath = [NSString stringWithFormat: @"%@%@", basePath, shorter];
        NSURL* fullURL = [NSURL URLWithString: fullPath];
    
        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        [sessionConfig setHTTPAdditionalHeaders: @{@"X-Mashape-Key" : credentials,
                                                   @"Accept": @"application/json"}];
    
        NSURLSession* urlSession = [NSURLSession sessionWithConfiguration: sessionConfig];
        NSURLRequest* urlRequest = [NSURLRequest requestWithURL: fullURL];
    
        NSURLSessionDataTask* dataTask = [urlSession dataTaskWithRequest: urlRequest completionHandler: ^(NSData* data, NSURLResponse* response, NSError* error) {
            // [TODO] If there's an error, provide some useful dialog to the user.
            if (nil == error)
            {
                NSDictionary* jsonDict = [CEJSONManipulator getJSONForData: data];
                if (nil == jsonDict)
                    NSLog(@"JSON dictionary is nil: %s", __PRETTY_FUNCTION__);
                else
                {
                    NSDictionary* concepts = [jsonDict objectForKey: @"concepts"];
                    NSArray* conceptKeys = [concepts allKeys];
                    NSMutableArray<NSString*>* conceptStrings = [[NSMutableArray alloc] init];
                    for (NSUInteger i = 0; i < [conceptKeys count]; ++i)
                    {
                        NSDictionary* conceptDict = [concepts objectForKey: [conceptKeys objectAtIndex: i]];
                        NSDictionary* surfaceForms = [[conceptDict objectForKey: @"surfaceForms"] firstObject];
                        NSString* conceptString = [surfaceForms objectForKey: @"string"];
                        [conceptStrings addObject: conceptString];
                    }
    
                    NSString* originalString = [jsonDict objectForKey: @"text"];
                    NSArray* frequencies = [CECalculator calculateFrequencyOfWords: [conceptStrings copy] inString: originalString];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName: kShowWordCloud object: frequencies];
                    });
                }
            }
            else
                NSLog(@"%@: %s", error, __PRETTY_FUNCTION__);
        }];
        [dataTask resume];
    }
}

@end
