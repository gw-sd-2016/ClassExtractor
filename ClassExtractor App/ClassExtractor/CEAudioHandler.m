//
//  CEAudioHandler.m
//  ClassExtractor
//
//  Created by Elliot on 11/4/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import "CEAudioHandler.h"


// ============================================================
// CEAudioHandler
// ============================================================
@implementation CEAudioHandler


// ------------------------------------------------------------
// sharedInstance
//
// Sets up (if not already setup) and returns the singleton
// object of this class.
// ------------------------------------------------------------
+ (CEAudioHandler*) sharedInstance
{
    static CEAudioHandler* instance = nil;
    
    if (instance == nil)
        instance = [[CEAudioHandler alloc] init];
    
    return instance;
}


// ------------------------------------------------------------
// playAudioFile
//
// Plays the audio file.
// ------------------------------------------------------------
- (AVAudioPlayer*) playAudioFile: (NSString*)audioFilePath
{
    NSURL* fileURL = [NSURL fileURLWithPath: audioFilePath];
    
    AVAudioPlayer* audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL error: nil];
    
    audioPlayer.numberOfLoops = -1; // infinite number of loops
    
    [audioPlayer play];
    
    return audioPlayer;
}


// ------------------------------------------------------------
// convertToWav:withOutputPath:
//
// Takes an audio file and converts it to a wav file using
// afconvert, dropping it into the bundle's resource path. wavs
// are useful because Watson can use wav files for
// transliteration. afconvert can work with a ton of different
// audio file types, type "afconvert -hf" into Terminal to see
// them all.
//
// Note: We don't have to check if we're trying to convert a
// wav to a wav because afconvert handles that situation for us.
// ------------------------------------------------------------
- (void) convertToWav: (NSString*)pathToAudio withOutputPath: (NSString*)outputPath
{
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath: @"/usr/bin/afconvert"];

    NSArray* arguments = @[@"-d", @"LEI16", @"-f", @"WAVE", pathToAudio, outputPath];
    [task setArguments: arguments];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(taskFinished:)
                                                 name: NSTaskDidTerminateNotification
                                               object: task];
    
    [task launch];
}


// ------------------------------------------------------------
// taskFinished:
//
// Called when the task running afconvert is finished. Gets the
// parameters to chop up the file and drops it at the "toFilePath"
// parameter location.
//
// [TODO] Don't hardcode the drop location. Put it in something
// like [[NSBundle mainBundle] resourcePath]
//
// [TODO] Repeatedly call chopUpLargeAudioFile until the whole
// audio file has been chopped up.
// ------------------------------------------------------------
- (void) taskFinished: (NSNotification*)taskNotification
{
    NSTask* finishedTask = [taskNotification object];
    NSArray* taskArguments = [finishedTask arguments];
    NSString* convertedPath = [taskArguments lastObject];
    NSURL* convertedURL = [NSURL fileURLWithPath: convertedPath isDirectory: false];
    AVURLAsset* audioAsset = [[AVURLAsset alloc] initWithURL: convertedURL options: nil];
    CMTime startTime = CMTimeMake(0, 1);
    NSValue* startValue = [NSValue valueWithBytes: &startTime objCType: @encode(CMTime)];
    [self chopUpLargeAudioFile: audioAsset
                 withStartTime: startValue
                    toFilePath: @"/Users/elliot/Desktop/trimmed.wav"];
}


// ------------------------------------------------------------
// chopUpLargeAudioFile: withStartTime: toFilePath:
//
// avAsset must have been created using a wav file (mp3s won't
// work). Splices a large audio file into a smaller one,
// starting from the start time and going until either a) five
// minutes has elapsed in the file or b) the end of the audio
// has been reached. The truncated audio file is then dropped
// at filePath location.
//
// [TODO] Don't hardcode the notification object path. That
// path should be wherever the chopped up files are dropped.
//
// [TODO] Make "doneChopping" a constant in a header file.
// ------------------------------------------------------------
- (bool) chopUpLargeAudioFile: (AVAsset*)avAsset withStartTime: (NSValue*)startTimeValue toFilePath: (NSString*)filePath
{
    CMTime startTime;
    [startTimeValue getValue: &startTime];
    
    // we only care about the first audio track
    AVAssetTrack* firstTrack = [[avAsset tracksWithMediaType: AVMediaTypeAudio] firstObject];
    if (firstTrack == nil)
        return false;
    
    AVAssetExportSession* exportSession = [AVAssetExportSession exportSessionWithAsset: avAsset
                                                                            presetName: AVAssetExportPresetAppleM4A];
    if (exportSession == nil)
        return false;
    
    // stopTime ends in 300 seconds (five minutes)
    // No need to check if we've reached the end of the audio clip, as
    // the exportSession is smart enough to know to just stop.
    CMTime stopTime = CMTimeMake(startTime.value + 300, 1);
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
    
    [exportSession setOutputFileType: @"com.apple.m4a-audio"];
    [exportSession setOutputURL: [NSURL fileURLWithPath: filePath]];
    [exportSession setTimeRange: exportTimeRange];
    
    [exportSession exportAsynchronouslyWithCompletionHandler: ^{
        [[NSNotificationCenter defaultCenter] postNotificationName: @"doneChopping" object: @"/Users/elliot/Desktop/trimmed.wav"];
    }];
    
    return true;
}

@end
