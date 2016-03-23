//
//  CEWelcomeViewController.m
//  ClassExtractor
//
//  Created by Elliot on 10/14/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import "CECalculator.h"
#import "CEConnector.h"
#import "CEModel.h"
#import "CETimeline.h"
#import "CEWelcomeViewController.h"
#import "Constants.h"

// ============================================================
// ViewController
// ============================================================
@implementation CEWelcomeViewController
@synthesize cloudView;
@synthesize interfaceChooser;
@synthesize loadingLabel;
@synthesize progressIndicator;
@synthesize selectAudioButton;
@synthesize studyView;
@synthesize timelineView;


// ------------------------------------------------------------
// viewDidLoad
// ------------------------------------------------------------
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    NSView* selfView = [self view];
    [selfView setWantsLayer: true];
    [[selfView layer] setBackgroundColor: [[NSColor blackColor] CGColor]];
    
    [progressIndicator setAlphaValue: 0.0f];
    [interfaceChooser setAlphaValue: 0.0f];
    [loadingLabel setAlphaValue: 0.0f];
    
    [studyView setWantsLayer: true];
    [studyView setAlphaValue: 0.0f];
    CALayer* studyLayer = [studyView layer];
    [studyLayer setBackgroundColor: [[NSColor whiteColor] CGColor]];
    [studyLayer setCornerRadius: 8.0f];
    
    // [TODO] Remove this observer, and instead have CEAudioHandler call
    // the method directly.
//    [[NSNotificationCenter defaultCenter] addObserver: [CEConnector sharedInstance]
//                                             selector: @selector(getJSONFromWatsonAsync:)
//                                                 name: kGetJSON
//                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(showStudyInterface:)
                                                 name: kShowStudyInterface
                                               object: nil];
}


// ------------------------------------------------------------
// viewDidAppear
//
// Configure the window appearance.
// ------------------------------------------------------------
- (void) viewDidAppear
{
    [super viewDidAppear];

    NSWindow* selfWindow = [[self view] window];
    
    [selfWindow setStyleMask: NSTitledWindowMask |
                                NSFullSizeContentViewWindowMask |
                                NSClosableWindowMask |
                                NSMiniaturizableWindowMask |
                                NSResizableWindowMask];
    
    [selfWindow setTitlebarAppearsTransparent: true];
    
    // even though the titlebar is transparent, we still want to set the title
    // because the titlebar appears when the user is in split screen
    [selfWindow setTitle: @"Class Extractor"];
}


// ------------------------------------------------------------
// showStudyInterface:
// ------------------------------------------------------------
- (void) showStudyInterface: (NSNotification*)notification
{
#if DEMO
    [self performSelector: @selector(createDelayedStudyInterface) withObject: nil afterDelay: 4];
#else
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration: 1.0f];
    [[studyView animator] setAlphaValue: 1.0f];
    [[interfaceChooser animator] setAlphaValue: 1.0f];
    [[progressIndicator animator] setAlphaValue: 0.0f];
    [[loadingLabel animator] setAlphaValue: 0.0f];
    [NSAnimationContext endGrouping];
    
    NSWindow* selfWindow = [[self view] window];
    const CGRect windowFrame = [selfWindow frame];
    const NSPoint windowOrigin = windowFrame.origin;
    const CGSize windowSize = windowFrame.size;
    CGFloat valueToSetWidthTo, valueToSetHeightTo;
    if (windowSize.width < 600)
        valueToSetWidthTo = 600;
    else
        valueToSetWidthTo = windowSize.width;
    
    if (windowSize.height < 600)
        valueToSetHeightTo = 600;
    else
        valueToSetHeightTo = windowSize.height;
    
    [selfWindow setMinSize: CGSizeMake(600, 600)];
    
    [selfWindow setFrame: CGRectMake(windowOrigin.x, windowOrigin.y, valueToSetWidthTo, valueToSetHeightTo) display: true animate: true];

    
    // [TODO] Need some way of notifying cloud view to create its clouds.
#endif
}

#if DEMO
// ------------------------------------------------------------
// createDelayedStudyInterface
//
// This function delays the creation of the study interface. In
// a real world scenario, the delay will happen naturally from
// Watson processing the audio, but for the sake of the demo,
// the demo is synthetic to illustrate what would happen. Pre-
// loaded data from Watson will be at the ready for the demo.
// ------------------------------------------------------------
- (void) createDelayedStudyInterface
{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration: 0.8f];
    [[interfaceChooser animator] setAlphaValue: 1.0f];
    [[studyView animator] setAlphaValue: 1.0f];
    [[progressIndicator animator] setAlphaValue: 0.0f];
    [[loadingLabel animator] setAlphaValue: 0.0f];
    [NSAnimationContext endGrouping];
    
    NSWindow* selfWindow = [[self view] window];
    const CGRect windowFrame = [selfWindow frame];
    const NSPoint windowOrigin = windowFrame.origin;
    const CGSize windowSize = windowFrame.size;
    CGFloat valueToSetWidthTo, valueToSetHeightTo;
    if (windowSize.width < 600)
        valueToSetWidthTo = 600;
    else
        valueToSetWidthTo = windowSize.width;
    
    if (windowSize.height < 600)
        valueToSetHeightTo = 600;
    else
        valueToSetHeightTo = windowSize.height;
    
    [selfWindow setMinSize: CGSizeMake(600, 600)];
    
    [selfWindow setFrame: CGRectMake(windowOrigin.x, windowOrigin.y, valueToSetWidthTo, valueToSetHeightTo) display: true animate: true];

    [self createDemoModel];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kCloudWindowOpened object: [[CEModel sharedInstance] topics]];
}

- (void) createDemoModel
{
    CEModel* model = [CEModel sharedInstance];
    
    CETopic* topic1 = [[CETopic alloc] init];
    [topic1 setTopicName: @"Marginal Benefit"];
    [topic1 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(327, 1), CMTimeMake(2000, 1))];
    [topic1 setImportanceWeighting: 10];
    [model addTopic: topic1];
    
    CETopic* topic2 = [[CETopic alloc] init];
    [topic2 setTopicName: @"Comparative Advantage"];
    [topic2 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(762, 1), CMTimeMake(2134, 1))];
    [topic2 setImportanceWeighting: 7];
    [model addTopic: topic2];
    
    CETopic* topic3 = [[CETopic alloc] init];
    [topic3 setTopicName: @"Opportunity Cost"];
    [topic3 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(1800, 1), CMTimeMake(2982, 1))];
    [topic3 setImportanceWeighting: 7];
    [model addTopic: topic3];
    
    CETopic* topic4 = [[CETopic alloc] init];
    [topic4 setTopicName: @"Absolute Advantage"];
    [topic4 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(1478, 1), CMTimeMake(2789, 1))];
    [topic4 setImportanceWeighting: 7];
    [model addTopic: topic4];
    
    CETopic* topic5 = [[CETopic alloc] init];
    [topic5 setTopicName: @"Labor"];
    [topic5 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(100, 1), CMTimeMake(871, 1))];
    [topic5 setImportanceWeighting: 5];
    [model addTopic: topic5];
    
    CETopic* topic6 = [[CETopic alloc] init];
    [topic6 setTopicName: @"Sticky Wages"];
    [topic6 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(100, 1), CMTimeMake(417, 1))];
    [topic6 setImportanceWeighting: 5];
    [model addTopic: topic6];
    
    CETopic* topic7 = [[CETopic alloc] init];
    [topic7 setTopicName: @"Production Possibilities Frontier"];
    [topic7 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(100, 1), CMTimeMake(417, 1))];
    [topic7 setImportanceWeighting: 5];
    [model addTopic: topic7];
    
    CETopic* topic8 = [[CETopic alloc] init];
    [topic8 setTopicName: @"Crowding Out"];
    [topic8 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(100, 1), CMTimeMake(417, 1))];
    [topic8 setImportanceWeighting: 4];
    [model addTopic: topic8];
    
    CETopic* topic9 = [[CETopic alloc] init];
    [topic9 setTopicName: @"Ricardo-Barro Effect"];
    [topic9 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(100, 1), CMTimeMake(417, 1))];
    [topic9 setImportanceWeighting: 3];
    [model addTopic: topic9];
    
    CETopic* topic10 = [[CETopic alloc] init];
    [topic10 setTopicName: @"Chili"];
    [topic10 setTopicRange: CMTimeRangeFromTimeToTime(CMTimeMake(100, 1), CMTimeMake(417, 1))];
    [topic10 setImportanceWeighting: 3];
    [model addTopic: topic10];
}
#endif


// ------------------------------------------------------------
// changeSegment:
//
// Handles swapping which interface is shown based on the
// selected segment.
// ------------------------------------------------------------
- (IBAction) changeSegment: (id)sender
{
    const NSInteger selectedSegment = [interfaceChooser selectedSegment];
    [self switchVisibleInterfaceWithNewSelectedSegment: selectedSegment];
}


// ------------------------------------------------------------
// switchVisibleInterfaceWithNewSelectedSegment:
//
// Actually does the swapping for which interface is shown
// based on the selected segment.
// ------------------------------------------------------------
- (void) switchVisibleInterfaceWithNewSelectedSegment: (NSInteger)selectedSegment
{
    // 0 corresponds to Word Cloud, 1 to Timeline
    if (selectedSegment == 0)
    {
        [cloudView setHidden: false];
        [timelineView setHidden: true];
    }
    else
    {
        static bool isFirstSwitch = true;
        
        if (isFirstSwitch)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName: kDrawTimelineBars object: nil];
            isFirstSwitch = false;
        }
        
        [cloudView setHidden: true];
        [timelineView setHidden: false];
    }
}


// ------------------------------------------------------------
// importAudioFile:
//
// Presents a modal sheet for the user to select a lecture file
// for analysis.
// ------------------------------------------------------------
- (IBAction) importAudioFile: (id)sender
{
    NSOpenPanel* openFileDialogue = [NSOpenPanel openPanel];
    
    // only allow the user to select audio file types
    [openFileDialogue setAllowedFileTypes: [AVURLAsset audiovisualTypes]];
    
    [openFileDialogue beginSheetModalForWindow: [[self view] window] completionHandler: ^(NSInteger response) {
        if (NSModalResponseOK == response)
        {
            // we only allow selection of one file, so it's ok to get just the first object
            NSURL* selectedFilePath = [[openFileDialogue URLs] firstObject];
            AVURLAsset* selectedAudioAsset = [[AVURLAsset alloc] initWithURL: selectedFilePath options: nil];
            
            [progressIndicator startAnimation: self];
            
            [NSAnimationContext beginGrouping];
            [[NSAnimationContext currentContext] setDuration: 2.0f];
            [[progressIndicator animator] setAlphaValue: 1.0f];
            [[loadingLabel animator] setAlphaValue: 1.0f];
            [[selectAudioButton animator] setAlphaValue: 0.0f];
            [NSAnimationContext endGrouping];

            // [TODO] Instead of just logging the error, report it to the user in some nice
            // GUI fashion
            // [TODO] If this fails, kill all connections to Watson and don't process
            // any more audio files
            NSString* result = [CEAudioHandler chopUpLargeAudioFile: selectedAudioAsset];
            if (![result isEqualToString: kChoppingSuccess])
                NSLog(@"%@: %s", result, __PRETTY_FUNCTION__);
        }
    }];
}

@end


// ============================================================
// CEWelcomeView
// ============================================================
@implementation CEWelcomeView


// ------------------------------------------------------------
// mouseDragged:
//
// Allow the user to drag the window around from its background.
//
// [TODO] Don't do this when dragging from the title bar.
// ------------------------------------------------------------
- (void) mouseDragged: (NSEvent*)theEvent
{
    NSWindow* selfWindow = [self window];
    const CGPoint kWindowOrigin = [selfWindow frame].origin;
    [selfWindow setFrameOrigin: CGPointMake(kWindowOrigin.x + [theEvent deltaX], kWindowOrigin.y - [theEvent deltaY])];
}

@end

