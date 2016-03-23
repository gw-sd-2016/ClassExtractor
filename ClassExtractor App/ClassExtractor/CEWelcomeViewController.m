//
//  CEWelcomeViewController.m
//  ClassExtractor
//
//  Created by Elliot on 10/14/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import "CEWelcomeViewController.h"
#import "CEWordCloudViewController.h"
#import "CECalculator.h"
#import "CEConnector.h"
#import "CETimeline.h"
#import "Constants.h"

// ============================================================
// ViewController
// ============================================================
@implementation CEWelcomeViewController
@synthesize progressIndicator;
@synthesize selectAudioButton;
@synthesize studyView;
@synthesize interfaceChooser;
@synthesize timelineView;
@synthesize cloudView;
@synthesize loadingLabel;


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
    
    const NSPoint windowOrigin = [[[self view] window] frame].origin;
    const CGSize windowSize = [[[self view] window] frame].size;
    CGFloat valueToSetWidthTo, valueToSetHeightTo;
    if (windowSize.width < 600)
        valueToSetWidthTo = 600;
    else
        valueToSetWidthTo = windowSize.width;
    
    if (windowSize.height < 600)
        valueToSetHeightTo = 600;
    else
        valueToSetHeightTo = windowSize.height;
    
    [[[self view] window] setFrame: CGRectMake(windowOrigin.x, windowOrigin.y, valueToSetWidthTo, valueToSetHeightTo) display: true animate: true];

    
    // [TODO] Need some way of notifying cloud view to create its clouds.
#endif
}


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
    
    const NSPoint windowOrigin = [[[self view] window] frame].origin;
    const CGSize windowSize = [[[self view] window] frame].size;
    CGFloat valueToSetWidthTo, valueToSetHeightTo;
    if (windowSize.width < 600)
        valueToSetWidthTo = 600;
    else
        valueToSetWidthTo = windowSize.width;
    
    if (windowSize.height < 600)
        valueToSetHeightTo = 600;
    else
        valueToSetHeightTo = windowSize.height;
    
    [[[self view] window] setFrame: CGRectMake(windowOrigin.x, windowOrigin.y, valueToSetWidthTo, valueToSetHeightTo) display: true animate: true];
    
    // this array is for testing only
    NSArray* array = @[@{@"Marginal Benefit"                    : [NSNumber numberWithInteger: 10]},
                       @{@"Comparative Advantage"               : [NSNumber numberWithInteger: 7]},
                       @{@"Opportunity Cost"                    : [NSNumber numberWithInteger: 7]},
                       @{@"Absolute Advantage"                  : [NSNumber numberWithInteger: 7]},
                       @{@"Labor"                               : [NSNumber numberWithInteger: 5]},
                       @{@"Sticky Wages"                        : [NSNumber numberWithInteger: 5]},
                       @{@"Production Possibilities Frontier"   : [NSNumber numberWithInteger: 5]},
                       @{@"Crowding Out"                        : [NSNumber numberWithInteger: 4]},
                       @{@"Ricardo-Barro Effect"                : [NSNumber numberWithInteger: 3]},
                       @{@"Chili"                               : [NSNumber numberWithInteger: 3]},
                       @{@"Computers"                           : [NSNumber numberWithInteger: 3]},
                       @{@"Gross Domestic Product"              : [NSNumber numberWithInteger: 3]},
                       @{@"Inflation"                           : [NSNumber numberWithInteger: 2]},
                       @{@"Industry"                            : [NSNumber numberWithInteger: 2]},
                       @{@"Government"                          : [NSNumber numberWithInteger: 1]},
                       @{@"Central Bank"                        : [NSNumber numberWithInteger: 1]},
                       @{@"The Fed"                             : [NSNumber numberWithInteger: 1]},
                       @{@"World Economy"                       : [NSNumber numberWithInteger: 1]},
                       @{@"Trade"                               : [NSNumber numberWithInteger: 1]}];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kCloudWindowOpened object: array];
}


- (IBAction) changeSegment: (id)sender
{
    const NSInteger selectedSegment = [interfaceChooser selectedSegment];
    [self switchVisibleInterfaceWithNewSelectedSegment: selectedSegment];
}


- (void) switchVisibleInterfaceWithNewSelectedSegment: (NSInteger)selectedSegment
{
    // 0 corresponds to Word Cloud, 1 to Timeline
    if (selectedSegment == 0)
    {
        [cloudView setHidden: false];
        [timelineView setHidden: true];
    }
    else if (selectedSegment == 1)
    {
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

