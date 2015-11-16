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
    
    // [TODO] Make self an observer of when a file gets reconverted to a wav,
    // so that that file can be sent to Watson.
    
    // Leave this here for now, but at some point self will be notified to start
    // sending data to Watson
//    [[NSNotificationCenter defaultCenter] addObserver: self
//                                             selector: @selector(getJSONFromWatsonAsync:)
//                                                 name: @""
//                                               object: nil];
}


// ------------------------------------------------------------
// getJSONFromWatson
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
        
        NSString* audioPath = [notification object];
        
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


// ------------------------------------------------------------
// importAudioFile
//
// [TODO] Change this to be a dropdown sheet.
// ------------------------------------------------------------
- (IBAction) importAudioFile: (id)sender
{
    NSOpenPanel* openFileDialogue = [NSOpenPanel openPanel];
    
    [openFileDialogue setCanChooseFiles: true];
    [openFileDialogue setAllowsMultipleSelection: false];
    [openFileDialogue setCanChooseDirectories: false];
    
    // display the dialogue
    // only do something if the ok button was pressed
    NSInteger button = [openFileDialogue runModal];
    if (button == NSModalResponseOK)
    {
        // we only allow selection of one file, so it's ok to just get the first object
        NSString* selectedFilePath = [[[openFileDialogue URLs] firstObject] path];
        [[CEAudioHandler sharedInstance] singleConvertToWav: selectedFilePath];
    }
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
