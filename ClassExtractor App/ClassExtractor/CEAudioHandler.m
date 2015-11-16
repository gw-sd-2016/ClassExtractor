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
    {
        instance = [[CEAudioHandler alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver: [CEAudioHandler sharedInstance]
                                                 selector: @selector(multipleConvertToWav:)
                                                     name: @"doneChopping"
                                                   object: nil];
    }
    
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
// singleConvertToWav
//
// This converts one audio file to a wav file, and puts it in
// this bundle's resource directory. AVAssets only like wavs,
// so we have to convert the file the user gives us to a wav
// before manipulating it. Send up a notification when we're
// done converting.
//
// The workflow is as follows: user selects file, singleConvertToWav
// converts that file to a wav, chopUpLargeAudioFile splices
// the audio file into five minute segments (and in the process
// converting them to m4as (this is automatic, see the second
// [TODO] in this comment)), multipleConvertToWav converts each
// of those files back to wavs. In the future, each of these
// files will then get sent to Watson for transliteration.
//
// [TODO] This function and multipleConvertToWav are somewhat
// repetitive. Combine the two and/or distill out what they
// have in common.
//
// [TODO] This convert, chop-up, reconvert methodology is obtuse
// and inefficient (especially with so many calls to afconvert).
// Make it so there is only one conversion necessary.
// ------------------------------------------------------------
- (void) singleConvertToWav: (NSString*)pathToAudio
{
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath: @"/usr/bin/afconvert"];
    
    NSArray* arguments = @[@"-d", @"LEI16", @"-f", @"WAVE", pathToAudio, [NSString stringWithFormat: @"%@/bigFile.wav", [[NSBundle mainBundle] resourcePath]]];
    [task setArguments: arguments];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(taskFinished:)
                                                 name: NSTaskDidTerminateNotification
                                               object: task];
    
    [task launch];
}


// ------------------------------------------------------------
// multipleConvertToWav
//
// This converts an audio file to a wav file, and puts it in
// this bundle's resource directory. The purpose of this
// function is convert all of the newly chopped up files into
// wavs, since AVAssetExportSession can only export files as
// m4as.
//
// [TODO] When we're done coverting the five minute m4a to wav,
// delete the m4a.
// ------------------------------------------------------------
- (void) multipleConvertToWav: (NSNotification*)notification
{
    NSString* filePath = [notification object];
    NSURL* fileURL = [NSURL URLWithString: filePath];
    NSString* lastComponent = [fileURL lastPathComponent];
    NSString* noExtension = [lastComponent substringToIndex: [lastComponent length] - 4]; // we know the extension is m4a,
                                                                                          // so it's 4 chars with the "."
    
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath: @"/usr/bin/afconvert"];
    
    NSArray* arguments = @[@"-d", @"LEI16", @"-f", @"WAVE", filePath, [NSString stringWithFormat: @"%@/%@.wav", [[NSBundle mainBundle] resourcePath], noExtension]];
    [task setArguments: arguments];
    
    [task launch];
}


// ------------------------------------------------------------
// taskFinished:
//
// Called when the task running afconvert is finished.
//
// [TODO] When we're done chopping up the large audio file,
// delete it.
// ------------------------------------------------------------
- (void) taskFinished: (NSNotification*)taskNotification
{
    NSTask* finishedTask = [taskNotification object];
    NSArray* taskArguments = [finishedTask arguments];
    NSString* convertedPath = [taskArguments lastObject];
    NSURL* convertedURL = [NSURL fileURLWithPath: convertedPath isDirectory: false];
    AVURLAsset* audioAsset = [[AVURLAsset alloc] initWithURL: convertedURL options: nil];
    
    CMTime duration = [audioAsset duration];
    double seconds = (double)duration.value / (double)duration.timescale;
    
    // iterate through the audio file, five minutes at a time, and put each
    // five minute segment into the resource path
    const NSUInteger kSecondsInAMinute = 60;
    for (NSUInteger minutes = 0; minutes * kSecondsInAMinute < seconds; minutes += 5)
    {
        CMTime startTime = CMTimeMake(minutes * kSecondsInAMinute, 1);
        NSValue* startValue = [NSValue valueWithBytes: &startTime objCType: @encode(CMTime)];
        [self chopUpLargeAudioFile: audioAsset
                     withStartTime: startValue
                        toFilePath: [NSString stringWithFormat: @"%@/trimmed%lu.m4a", [[NSBundle mainBundle] resourcePath], (unsigned long)minutes]];
    }
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
            [[NSNotificationCenter defaultCenter] postNotificationName: @"doneChopping" object: filePath];
    }];
    
    return true;
}

@end
