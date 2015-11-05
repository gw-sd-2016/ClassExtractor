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

+ (AVAudioPlayer*) chopUpLargeAudioFile: (NSString*)audioFilePath;
+ (void) convertToWav: (NSString*)pathToAudio;

@end
