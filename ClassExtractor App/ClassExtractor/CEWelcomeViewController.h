//
//  CEWelcomeViewController.h
//  ClassExtractor
//
//  Created by Elliot on 10/14/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CEAudioHandler.h"
#import "CECloudViewScrollView.h"
#import "CETimeline.h"

@interface CEWelcomeViewController : NSViewController
{
    // this is necessary because thanks to ARC, once we leave the function that created
    // the audioPlayer, audioPlayer is released and the file never gets played
    AVAudioPlayer* audioPlayer;
}
@property (strong) IBOutlet NSProgressIndicator* progressIndicator;
@property (strong) IBOutlet NSButton* selectAudioButton;
@property (strong) IBOutlet NSView* studyView;
@property (strong) IBOutlet NSSegmentedControl *interfaceChooser;
@property (strong) IBOutlet CECloudViewScrollView* cloudView;
@property (strong) IBOutlet CETimelineBarView* timelineView;
@property (strong) IBOutlet NSTextField *loadingLabel;
- (IBAction)changeSegment:(id)sender;

- (IBAction) importAudioFile: (id)sender;

@end


@interface CEWelcomeView : NSView

@end
