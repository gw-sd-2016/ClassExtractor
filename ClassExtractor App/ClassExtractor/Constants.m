//
//  Constants.m
//  ClassExtractor
//
//  Created by Elliot on 11/17/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

NSString* const kGetJSON = @"getJSON";
NSString* const kBigFileName = @"bigFile";
NSString* const kZeroDurationError = @"The file's duration is 0.";
NSString* const kExportSessionCreationError = @"The export session could not be created.";
NSString* const kChoppingSuccess = @"choppingSuccess"; // doesn't need to be proper English as
                                                       // this is never displayed to the user
NSString* const kAllFilesTransliterated = @"allFilesTransliterated";
NSString* const kTranscriptKey = @"transcript";
NSString* const kShowWordCloud = @"showWordCloudNotification";
NSString* const kCloudWindowOpened = @"cloudWindowOpened";
const NSUInteger kNumMinsPerClip = 5lu;
const int32_t kTimescale = 1;
