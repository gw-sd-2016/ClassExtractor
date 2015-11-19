//
//  CEAudioHandler.h
//  ClassExtractor
//
//  Created by Elliot on 11/4/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface CEAudioHandler : NSObject
{
    NSUInteger _totalNumberOfSegments;
    NSUInteger _numTimesCalled;
}

+ (id) sharedInstance;
- (AVAudioPlayer*) playAudioFile: (NSString*)audioFilePath;
- (void) deleteBigWav: (NSNotification*)notification;
- (void) convertToWav: (NSString*)pathToAudio isConvertingFiveMinuteFile: (bool)isConvertingFive;
- (bool) chopUpLargeAudioFile: (AVURLAsset*)avAsset;

@end
