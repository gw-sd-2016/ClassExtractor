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
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(orderStrings)
                                                     name: kAllFilesTransliterated
                                                   object: self];
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
        
        // [TODO] Start testing from this point.
        [self watsonFinishedWithData: audioData fromPath: audioPath];
    });
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
        [resultString appendString: [[[[resultsArray objectAtIndex: i] objectForKey: @"alternatives"] objectAtIndex: 1] objectForKey: @"transcript"]];
    }
    
    NSDictionary* curDict = @{kTranscriptKey : resultString,
                              @"order" : extNumber};
    [[self curStrings] addObject: curDict];
    
    ++curNumFiles;
    if (curNumFiles == totalFiles)
        [[NSNotificationCenter defaultCenter] postNotificationName: kAllFilesTransliterated object: self];
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
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
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
    
    [self getConceptsJSONAsync: stringBuilder];
}


// ------------------------------------------------------------
// getConceptsJSONAsync:
//
// Use the Mashape API ( https://market.mashape.com/aylien/text-analysis )
// to talk to the Aylien API for concept extraction. For now,
// the only supported language is English.
// ------------------------------------------------------------
- (void) getConceptsJSONAsync: (NSString*)rawString
{
    NSString* credentials = @"";
    NSString* basePath = @"https://aylien-text.p.mashape.com/concepts?language=en&text=";
    NSString* formattedString = [rawString stringByReplacingOccurrencesOfString: @" " withString: @"+"];
    NSString* fullPath = [NSString stringWithFormat: @"%@%@", basePath, formattedString];
    NSURL* fullURL = [NSURL URLWithString: fullPath];
    
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders: @{@"X-Mashape-Key" : credentials,
                                               @"Accept": @"application/json"}];
    
    NSURLSession* urlSession = [NSURLSession sessionWithConfiguration: sessionConfig];
    NSURLRequest* urlRequest = [NSURLRequest requestWithURL: fullURL];
    
    NSURLSessionDataTask* dataTask = [urlSession dataTaskWithRequest: urlRequest completionHandler: ^(NSData* data, NSURLResponse* response, NSError* error) {
        if (nil == error)
        {
            if (0 != [data length])
            {
                NSDictionary* jsonDict = [CEJSONManipulator getJSONForData: data];
                NSLog(@"%@", jsonDict);
            }
            else
                NSLog(@"Data Error: Data is nil or data length is 0.");
        }
        else
            NSLog(@"%@", error);
    }];
    [dataTask resume];
}

@end
