//
//  CEAudioHandler.m
//  ClassExtractor
//
//  Created by Elliot on 11/4/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import "CEAudioHandler.h"
#import "CEConnector.h"
#import "Constants.h"


// ============================================================
// CEAudioHandler
// ============================================================
@implementation CEAudioHandler


// ------------------------------------------------------------
// playAudioFile:
//
// Plays the audio file.
// ------------------------------------------------------------
+ (AVAudioPlayer*) playAudioFile: (NSString*)audioFilePath
{
    NSURL* fileURL = [NSURL fileURLWithPath: audioFilePath];
    
    AVAudioPlayer* audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL error: nil];
    
    // 0 means it will play exactly once
    audioPlayer.numberOfLoops = 0;
    
    [audioPlayer play];
    
    return audioPlayer;
}


// ------------------------------------------------------------
// convertToWav:
//
// This converts an audio file to a wav file, and puts it in
// this bundle's resource directory. AVAssetExportSession can only
// export files as m4as, so this function converts all of those newly
// chopped up five minute files into wavs.
//
// The workflow is as follows: user selects file, chopUpLargeAudioFile:
// splices the audio file into five minute segments, convertToWav:
// converts each of those files back to wavs. Each of these files
// are then sent to Watson for transliteration.
// ------------------------------------------------------------
+ (void) convertToWav: (NSString*)pathToAudio
{
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath: @"/usr/bin/afconvert"];
    
    NSString* convertedFilePath = [pathToAudio stringByReplacingOccurrencesOfString: @".m4a" withString: @".wav"];
        
    [task setArguments: @[@"-d", @"LEI16", @"-f", @"WAVE", pathToAudio, convertedFilePath]];

    NSPipe* pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];

    NSFileHandle* file = [pipe fileHandleForReading];

    [task launch];
    
    NSData* taskData = [file readDataToEndOfFile];
    if (nil != taskData && 0 == [taskData length])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: kGetJSON object: convertedFilePath];
        
        NSError* error;
        [[NSFileManager defaultManager] removeItemAtPath: pathToAudio error: &error];
        if (error)
            NSLog(@"%@: %s", error, __PRETTY_FUNCTION__);
    }
    else
        NSLog(@"Task data is nil or task data is not empty: %s", __PRETTY_FUNCTION__);
}

#if DEMO
// ------------------------------------------------------------
// shortCircuit
//
// This function is meant only for demoing without using Watson
// directly. This function skips over splicing up the selected
// audio file, sending it to Watson, and parsing the response.
// ------------------------------------------------------------
+ (void) shortCircuit
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kShowStudyInterface
                                                        object: nil];
}
#endif


// ------------------------------------------------------------
// chopUpLargeAudioFile:
//
// Splices a large audio file into a smaller one,
// creating an audio file of length kNumMinsPerClip. The truncated
// audio file is then dropped at the resource path.
// ------------------------------------------------------------
+ (NSString*) chopUpLargeAudioFile: (AVURLAsset*)selectedAudioAsset
{
#if DEMO
    [CEAudioHandler shortCircuit];
    return kChoppingSuccess;
#endif
    
    const CMTime kDuration = [selectedAudioAsset duration];
    if (0 == kDuration.value)
        return kZeroDurationError;
    
    const double seconds = (double)kDuration.value / (double)kDuration.timescale;
    const NSUInteger kSecondsInAMinute = 60;
    NSString* const kBundlePath = [[NSBundle mainBundle] resourcePath];

    const NSUInteger numSegments = ceil((double)seconds / (double)(kNumMinsPerClip * kSecondsInAMinute));
    [[CEConnector sharedInstance] setTotalFiles: numSegments];

    // iterate through the audio file, kNumMinsPerClip minutes at a time, and put each
    // kNumMinsPerClip minute segment into the resource path
    for (NSUInteger minutes = 0; minutes * kSecondsInAMinute < seconds; minutes += kNumMinsPerClip)
    {
        // -exportSessionWithAsset:presetName: checks if the asset is nil, so no need
        // to check it again before attempting to create the asset
        AVAssetExportSession* exportSession = [AVAssetExportSession exportSessionWithAsset: selectedAudioAsset
                                                                                presetName: AVAssetExportPresetAppleM4A];
        if (nil == exportSession)
            return kExportSessionCreationError;
        
        // no need to check if we've reached the end of the audio clip, as
        // the exportSession is smart enough to know to stop
        const CMTime kStartTime = CMTimeMake(minutes * kSecondsInAMinute, kTimescale);
        const CMTime kStopTime = CMTimeMake(kStartTime.value + kSecondsInAMinute * kNumMinsPerClip, kTimescale);
        const CMTimeRange kExportTimeRange = CMTimeRangeFromTimeToTime(kStartTime, kStopTime);
        
        NSString* filePath = [NSString stringWithFormat: @"%@/trimmed%lu.m4a", kBundlePath, (unsigned long)minutes];
        [exportSession setOutputFileType: @"com.apple.m4a-audio"];
        [exportSession setOutputURL: [NSURL fileURLWithPath: filePath]];
        [exportSession setTimeRange: kExportTimeRange];
        
        [exportSession exportAsynchronouslyWithCompletionHandler: ^{
            [CEAudioHandler convertToWav: filePath];
        }];
    }
    
    return kChoppingSuccess;
}

@end
