//
//  CEConnector.m
//  ClassExtractor
//
//  Created by Elliot on 11/22/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import "CEConnector.h"
#import "CEJSONManipulator.h"

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
