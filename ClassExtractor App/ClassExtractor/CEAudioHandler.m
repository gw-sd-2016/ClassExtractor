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
// playAudioFile
//
// Plays the audio file.
// ------------------------------------------------------------
+ (AVAudioPlayer*) playAudioFile: (NSString*)audioFilePath
{
    NSURL* fileURL = [NSURL fileURLWithPath: audioFilePath];
    
    AVAudioPlayer* audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL error: nil];
    
    audioPlayer.numberOfLoops = -1; // infinite number of loops
    
    [audioPlayer play];
    
    return audioPlayer;
}


// ------------------------------------------------------------
// convertToWav
//
// Takes an audio file and converts it to a wav file using
// afconvert, dropping it into the bundle's resource path. wavs
// are useful because Watson can use wav files for
// transliteration. afconvert can work with a ton of different
// audio file types, type "afconvert -hf" into Terminal to see
// them all.
//
// [TODO] Test what happens if you try converting a wav to
// a wav.
// ------------------------------------------------------------
+ (void) convertToWav: (NSString*)pathToAudio
{
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath: @"/usr/bin/afconvert"];

    NSArray* arguments = @[@"-d", @"LEI16", @"-f", @"WAVE", pathToAudio, [[NSBundle mainBundle] resourcePath]];
    [task setArguments: arguments];

    [task launch];
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
// ------------------------------------------------------------
+ (bool) chopUpLargeAudioFile: (AVAsset*)avAsset withStartTime: (CMTime)startTime toFilePath: (NSString*)filePath
{
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
    
    [exportSession setOutputURL: [NSURL fileURLWithPath: filePath]];
    [exportSession setTimeRange: exportTimeRange];
    
    [exportSession exportAsynchronouslyWithCompletionHandler: ^{}];
    
    return true;
}

@end
