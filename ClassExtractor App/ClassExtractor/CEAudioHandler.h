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

+ (id) sharedInstance;
- (AVAudioPlayer*) playAudioFile: (NSString*)audioFilePath;
- (void) convertToWav: (NSString*)pathToAudio withOutputPath: (NSString*)outputPath;
- (bool) chopUpLargeAudioFile: (AVAsset*)avAsset withStartTime: (NSValue*)startTimeValue toFilePath: (NSString*)filePath;

@end
