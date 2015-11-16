//
//  ViewController.h
//  ClassExtractor
//
//  Created by Elliot on 10/14/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CEAudioHandler.h"

@interface ViewController : NSViewController
{
    // this is necessary because thanks to ARC, once we leave the function that created
    // the audioPlayer, audioPlayer is released and the file never gets played
    AVAudioPlayer* audioPlayer;
}

- (void) getJSONFromWatsonAsync: (NSNotification*)notification;
- (IBAction) importAudioFile: (id)sender;

@end


@interface CEJSONManipulator : NSObject

+ (NSDictionary*) getJSONForData: (NSData*)data;

@end
