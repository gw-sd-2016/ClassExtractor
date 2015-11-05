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
// chopUpLargeAudioFile
//
// Slices a large audio file into smaller files, as Watson
// can only accept audio files that are smaller than 5 minutes.
//
// [TODO] This functionality is not here yet. This simply plays
// the audio file. Add slicing functionality.
// ------------------------------------------------------------
+ (AVAudioPlayer*) chopUpLargeAudioFile: (NSString*)audioFilePath
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

    [[NSBundle mainBundle] resourcePath];
    NSArray* arguments = @[@"-d", @"LEI16", @"-f", @"WAVE", pathToAudio, [[NSBundle mainBundle] resourcePath]];
    [task setArguments: arguments];

    [task launch];
}

@end

