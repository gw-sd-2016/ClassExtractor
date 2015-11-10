//
//  ViewController.m
//  ClassExtractor
//
//  Created by Elliot on 10/14/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import "ViewController.h"

// ============================================================
// ViewController
// ============================================================
@implementation ViewController


// ------------------------------------------------------------
// viewDidLoad
// ------------------------------------------------------------
- (void) viewDidLoad
{
    [super viewDidLoad];

    // this is a hardcoded test input for now, and since this function doesn't really
    // do anything useful at the moment, just keep it here for now
    audioPlayer = [CEAudioHandler playAudioFile: @"/Users/elliot/Desktop/test.mp3"];
    
    NSURL* pathToAudio = [NSURL fileURLWithPath: @"/Users/elliot/Desktop/test2.wav"];
    AVURLAsset* audioAsset = [[AVURLAsset alloc] initWithURL: pathToAudio options: nil];
    [CEAudioHandler chopUpLargeAudioFile: audioAsset withStartTime: CMTimeMake(0, 1) toFilePath: @"/Users/elliot/Desktop/trimmed.m4a"];
    
    // hardcode the audioPath for now
    // [TODO] this should pick up the wav dropped off in the resource directory by +convertToWav
    NSString* audioPath = @"@/Users/elliot/Library/Mobile Documents/com~apple~CloudDocs/GW/Senior Year/Fall/Senior Design/ClassExtractor/ClassExtractor App/ClassExtractor/WatsonTest.flac";
    [self getJSONFromWatsonAsync: audioPath];
}


// ------------------------------------------------------------
// getJSONFromWatson
//
// Send the parameter's audio file to Watson for transliteration.
//
// [TODO] Investigate into using libcurl here instead of NSTask
// ------------------------------------------------------------
- (void) getJSONFromWatsonAsync: (NSString*)audioPath
{
    dispatch_queue_t globalConcurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalConcurrentQueue, ^{
        NSTask* task = [[NSTask alloc] init];
        [task setLaunchPath: @"/usr/bin/curl"];
        
        NSString* credentials = @"";
        
        NSArray* arguments = @[@"-u", credentials, @"-X", @"POST", @"--limit-rate", @"40000", @"--header", @"Content-Type: audio/flac", @"--header", @"Transfer-Encoding: chunked", @"--data-binary", audioPath, @"https://stream.watsonplatform.net/speech-to-text/api/v1/recognize?continuous=true"];
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


// ============================================================
// CEJSONManipulator
// ============================================================
@implementation CEJSONManipulator


// ------------------------------------------------------------
// getJSONForData
//
// Given an NSData object, serialize the data into an
// NSDictionary and return that object.
// ------------------------------------------------------------
+ (NSDictionary*) getJSONForData: (NSData*)data
{
    NSError* error;
    NSDictionary* feed = [NSJSONSerialization JSONObjectWithData: data
                                                         options: kNilOptions
                                                           error: &error];

    return feed;
}

@end
