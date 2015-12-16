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
// sharedInstance
//
// Sets up (if not already setup) and returns the singleton
// object of this class.
// ------------------------------------------------------------
+ (CEAudioHandler*) sharedInstance
{
    static CEAudioHandler* instance = nil;
    
    if (nil == instance)
        instance = [[CEAudioHandler alloc] init];
    
    return instance;
}


// ------------------------------------------------------------
// playAudioFile:
//
// Plays the audio file.
// ------------------------------------------------------------
- (AVAudioPlayer*) playAudioFile: (NSString*)audioFilePath
{
    NSURL* fileURL = [NSURL fileURLWithPath: audioFilePath];
    
    AVAudioPlayer* audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL error: nil];
    
    // 0 means it will play exactly once
    audioPlayer.numberOfLoops = 0;
    
    [audioPlayer play];
    
    return audioPlayer;
}


// ------------------------------------------------------------
// getBigWavFilePath
//
// For accessing the original converted wav file.
// ------------------------------------------------------------
- (NSString*) getBigWavFilePath
{
    return [NSString stringWithFormat: @"%@/%@.wav", [[NSBundle mainBundle] resourcePath], kBigFileName];
}


// ------------------------------------------------------------
// convertToWav:isConvertingFiveMinuteFile:
//
// This converts an audio file to a wav file, and puts it in
// this bundle's resource directory. This functions serves
// two purposes: the first is to convert the file the user
// gives us to a wav, since AVAssets only like wavs. The second
// is to convert all of the newly chopped up five minute files
// back into wavs, since AVAssetExportSession can only export files
// as m4as.
//
// The workflow is as follows: user selects file,
// convertToWav:isConvertingFiveMinuteFile: converts that file to
// a wav, chopUpLargeAudioFile splices the audio file into five
// minute segments (and in the process converting them to m4as (this
// is automatic, see the [TODO] in this comment)),
// convertToWav:isConvertingFiveMinuteFile: converts each
// of those files back to wavs. Each of these files are then
// sent to Watson for transliteration.
//
// This function uses NSTask, which is not thread safe (while it
// is true that we're not working with the same instance of NSTask
// across multiple threads and therefore it should theoretically be
// ok to have multipleConvertToWav: run in the background, at the
// end of this function an NSNotification is posted. I'm not 100% sure
// why, but if that notification is posted on a background thread, it
// is never delivered; I believe it has to do with the fact that
// NSNotifications are delivered on the thread they are posted on,
// and since NSTasks create their own runloops, it's possible that
// that notification gets posted from that runloop (which is then
// promptly destroyed), meaning it never has a chance to be
// delivered.
//
// [TODO] This convert, chop-up, reconvert methodology is obtuse
// and inefficient (especially with so many calls to afconvert).
// Make it so there is only one conversion necessary.
// ------------------------------------------------------------
- (void) convertToWav: (NSString*)pathToAudio
{
    // if isConvertingFives is true, this function will have been called
    // from the main thread, and if it's false, this function will have
    // been called from a background thread, but we don't have to check if
    // we're on the main thread as the block is scheduled regularly and
    // executed when the run loop of the main thread is run, which is the
    // same as if this function were called from the main thread and this
    // GCD call weren't here
    //
    // [TODO] Does this really need to be called from the main thread? The
    // above comment is outdated; can we do this async?
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTask* task = [[NSTask alloc] init];
        [task setLaunchPath: @"/usr/bin/afconvert"];
        NSMutableArray* arguments = [[NSMutableArray alloc] initWithObjects: @"-d", @"LEI16", @"-f", @"WAVE", pathToAudio, nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(taskFinished:)
                                                     name: NSTaskDidTerminateNotification
                                                   object: task];
        
        // we know the extension is going to be .m4a
        const NSUInteger lengthOfExt = 4;
        NSURL* fileURL = [NSURL URLWithString: pathToAudio];
        NSString* lastComponent = [fileURL lastPathComponent];
        NSString* noExtension = [lastComponent substringToIndex: [lastComponent length] - lengthOfExt];
        
        [arguments addObject: [NSString stringWithFormat: @"%@/%@.wav", [[NSBundle mainBundle] resourcePath], noExtension]];
        
        [task setArguments: arguments];
        [task launch];
    });
}


// ------------------------------------------------------------
// taskFinished:
//
// Called when the task converting an m4a file to a wav
// file has completed.
// ------------------------------------------------------------
- (void) taskFinished: (NSNotification*)notification
{
    NSTask* finishedTask = [notification object];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: NSTaskDidTerminateNotification
                                                  object: finishedTask];
    
    __block NSArray* taskArguments = [finishedTask arguments];
    __block NSString* convertedPath = [taskArguments lastObject];
    
    // now that we're done with NSTask, we can switch back to a background thread for
    // Watson transliteration (see the header comment of convertToWav:)
    dispatch_queue_t globalConcurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalConcurrentQueue, ^{
        [[NSNotificationCenter defaultCenter] postNotificationName: kGetJSON
                                                            object: convertedPath];
        
        const NSUInteger m4aPathIndex = [taskArguments count] - 2;
        NSString* m4aPath = [taskArguments objectAtIndex: m4aPathIndex];
        NSError* error;
        [[NSFileManager defaultManager] removeItemAtPath: m4aPath error: &error];
    });
}


// ------------------------------------------------------------
// chopUpLargeAudioFile:withStartTime:toFilePath:
//
// avAsset must have been created using a wav file (mp3s won't
// work). Splices a large audio file into a smaller one,
// creating an audio file of length kNumMinsPerClip. The truncated
// audio file is then dropped at the resource path.
//
// [TODO] Do a comprehensive test of which file formats work
// here. It is known that mp3 and wav do.
// ------------------------------------------------------------
- (NSString*) chopUpLargeAudioFile: (AVURLAsset*)selectedAudioAsset
{
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
            [[CEAudioHandler sharedInstance] convertToWav: filePath];
        }];
    }
    
    return kChoppingSuccess;
}

@end
