//
//  CEAudioHandler.m
//  ClassExtractor
//
//  Created by Elliot on 11/4/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import "CEAudioHandler.h"
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
    
    if (instance == nil)
    {
        instance = [[CEAudioHandler alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver: [CEAudioHandler sharedInstance]
                                                 selector: @selector(deleteBigWav:)
                                                     name: kDeleteBigWav
                                                   object: [CEAudioHandler sharedInstance]];
    }
    
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
    return [NSString stringWithFormat: @"%@/bigFile.wav", [[NSBundle mainBundle] resourcePath]];
}


// ------------------------------------------------------------
// deleteBigWav:
//
// After we've chopped up the big wav file into five minute
// segments, we don't need it anymore and it can be deleted.
// ------------------------------------------------------------
- (void) deleteBigWav: (NSNotification*)notification
{
    NSError* error;
    [[NSFileManager defaultManager] removeItemAtPath: [self getBigWavFilePath] error: &error];
}


// ------------------------------------------------------------
// singleConvertToWav:
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
// of those files back to wavs. Each of these files are then
// sent to Watson for transliteration.
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
    // there's currently no reason this function will ever be called in
    // the background, but if that ever changes, we'll be sure this
    // function runs on the main thread (see the header comment of
    // multipleConvertToWav:)
    // (we don't have to check if we're on the main thread, as the
    // block is scheduled regularly and executed when the run loop
    // of the main thread is run, which is the same as if this function
    // were called from the main thread and this GCD call weren't here)
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTask* task = [[NSTask alloc] init];
        [task setLaunchPath: @"/usr/bin/afconvert"];
        
        NSArray* arguments = @[@"-d", @"LEI16", @"-f", @"WAVE", pathToAudio, [self getBigWavFilePath]];
        [task setArguments: arguments];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(taskFinished:)
                                                     name: NSTaskDidTerminateNotification
                                                   object: task];
        
        [task launch];
    });
}


// ------------------------------------------------------------
// multipleConvertToWav:
//
// This converts an audio file to a wav file, and puts it in
// this bundle's resource directory. The purpose of this
// function is convert all of the newly chopped up files into
// wavs, since AVAssetExportSession can only export files as
// m4as.
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
// ------------------------------------------------------------
- (void) multipleConvertToWav: (NSString*)filePath
{
    dispatch_async(dispatch_get_main_queue(), ^{
        ++_numTimesCalled;
        if (_numTimesCalled == _totalNumberOfSegments)
            [[NSNotificationCenter defaultCenter] postNotificationName: kDeleteBigWav object: self];
        
        NSURL* fileURL = [NSURL URLWithString: filePath];
        NSString* lastComponent = [fileURL lastPathComponent];
        NSString* noExtension = [lastComponent substringToIndex: [lastComponent length] - 4]; // we know the extension is m4a,
                                                                                              // so it's 4 chars with the "."
        
        NSTask* task = [[NSTask alloc] init];
        [task setLaunchPath: @"/usr/bin/afconvert"];
        
        NSArray* arguments = @[@"-d", @"LEI16", @"-f", @"WAVE", filePath, [NSString stringWithFormat: @"%@/%@.wav", [[NSBundle mainBundle] resourcePath], noExtension]];
        [task setArguments: arguments];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(multipleConvertTaskFinished:)
                                                     name: NSTaskDidTerminateNotification
                                                   object: task];
        
        [task launch];
    });
}


// ------------------------------------------------------------
// multipleConvertTaskFinished:
//
// Called when the task converting an m4a file to wav has
// completed. Posts a notification that that specific file is
// ready for transliteration (by getJSONFromWatson).
//
// [TODO] There is some duplication between this function and
// taskFinished:, fix that.
// ------------------------------------------------------------
- (void) multipleConvertTaskFinished: (NSNotification*)notification
{
    // now that we're done with NSTask, we can switch back to a background thread for
    // Watson transliteration (see the header comment for multipleConvertToWav:)
    dispatch_queue_t globalConcurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalConcurrentQueue, ^{
        NSTask* finishedTask = [notification object];
        NSArray* taskArguments = [finishedTask arguments];
        NSString* convertedPath = [taskArguments lastObject];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: kGetJSON
                                                            object: convertedPath];
        
        NSString* m4aPath = [taskArguments objectAtIndex: [taskArguments count] - 2];
        NSError* error;
        [[NSFileManager defaultManager] removeItemAtPath: m4aPath error: &error];
    });
}


// ------------------------------------------------------------
// taskFinished:
//
// Called when the task running afconvert is finished.
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
    
    _totalNumberOfSegments = 0;
    _numTimesCalled = 0;
    
    // iterate through the audio file, kNumMinsPerClip minutes at a time, and put each
    // kNumMinsPerClip minute segment into the resource path
    const NSUInteger kSecondsInAMinute = 60;
    for (NSUInteger minutes = 0; minutes * kSecondsInAMinute < seconds; minutes += kNumMinsPerClip)
    {
        CMTime startTime = CMTimeMake(minutes * kSecondsInAMinute, kTimescale);
        NSValue* startValue = [NSValue valueWithBytes: &startTime objCType: @encode(CMTime)];
        [self chopUpLargeAudioFile: audioAsset
                     withStartTime: startValue
                        toFilePath: [NSString stringWithFormat: @"%@/trimmed%lu.m4a", [[NSBundle mainBundle] resourcePath], (unsigned long)minutes]];
        
        ++_totalNumberOfSegments;
    }
}


// ------------------------------------------------------------
// chopUpLargeAudioFile:withStartTime:toFilePath:
//
// avAsset must have been created using a wav file (mp3s won't
// work). Splices a large audio file into a smaller one,
// starting from the start time and going until either a) five
// minutes has elapsed in the file or b) the end of the audio
// has been reached. The truncated audio file is then dropped
// at filePath location.
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
    
    // no need to check if we've reached the end of the audio clip, as
    // the exportSession is smart enough to know to stop
    const NSUInteger kSecondsInAMinute = 60;
    CMTime stopTime = CMTimeMake(startTime.value + kSecondsInAMinute * kNumMinsPerClip, kTimescale);
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
    
    [exportSession setOutputFileType: @"com.apple.m4a-audio"];
    [exportSession setOutputURL: [NSURL fileURLWithPath: filePath]];
    [exportSession setTimeRange: exportTimeRange];
    
    [exportSession exportAsynchronouslyWithCompletionHandler: ^{
        [[CEAudioHandler sharedInstance] multipleConvertToWav: filePath];
    }];
    
    return true;
}

@end
