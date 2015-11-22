//
//  CEConnector.m
//  ClassExtractor
//
//  Created by Elliot on 11/22/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import "CEConnector.h"

@implementation CEConnector


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
        instance = [[CEConnector alloc] init];
    
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
        
        NSLog(@"%@", strData);
    });
}


// ------------------------------------------------------------
// getConceptsJSON:
//
// Use the Mashape api ( https://market.mashape.com/aylien/text-analysis )
// to talk to the Aylien api for concept extraction.
//
// [TODO] Investigate into using libcurl here instead of NSTask
// ------------------------------------------------------------
- (void) getConceptsJSONAsync: (NSString*)rawString
{
    dispatch_queue_t globalConcurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalConcurrentQueue, ^{
        NSTask* task = [[NSTask alloc] init];
        [task setLaunchPath: @"/usr/bin/curl"];
        
        NSString* credentials = @"";
        NSString* formattedString = [rawString stringByReplacingOccurrencesOfString: @" " withString: @"+"];
        
        NSArray* arguments = @[@"--get", @"--include", [NSString stringWithFormat: @"https://aylien-text.p.mashape.com/concepts?language=en&text=%@", formattedString], @"-H", [NSString stringWithFormat: @"X-Mashape-Key: %@", credentials], @"-H", @"Accept: application/json"];
        [task setArguments: arguments];
        
        NSPipe* pipe = [NSPipe pipe];
        [task setStandardOutput: pipe];
        
        NSFileHandle* file = [pipe fileHandleForReading];
        
        [task launch];
        
        NSData* audioData = [file readDataToEndOfFile];
        
        NSString* strData = [[NSString alloc]initWithData: audioData
                                                 encoding: NSUTF8StringEncoding];
        
        NSLog(@"%@", strData);
    });
}

@end
