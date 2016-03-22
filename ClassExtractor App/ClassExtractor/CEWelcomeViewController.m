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
@synthesize selectAudioButtonVerticalCenterConstraint;


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
    
    // [TODO] Remove this observer, and instead have CEAudioHandler call
    // the method directly.
    [[NSNotificationCenter defaultCenter] addObserver: [CEConnector sharedInstance]
                                             selector: @selector(getJSONFromWatsonAsync:)
                                                 name: kGetJSON
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(showWordCloud:)
                                                 name: kShowWordCloud
                                               object: nil];
    
    // test code
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
    
    [self performSegueWithIdentifier: @"showWordCloud" sender: self];
    [[NSNotificationCenter defaultCenter] postNotificationName: kCloudWindowOpened object: array];
    
    [self performSegueWithIdentifier: @"showTimeline" sender: self];
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
// showWordCloud:
// ------------------------------------------------------------
- (void) showWordCloud: (NSNotification*)notification
{
    [self performSegueWithIdentifier: @"showWordCloud" sender: self];
    [[NSNotificationCenter defaultCenter] postNotificationName: kCloudWindowOpened object: [notification object]];
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
            [[selectAudioButton animator] setAlphaValue: 0.0f];
            [[selectAudioButtonVerticalCenterConstraint animator] setConstant: 20];
            [NSAnimationContext endGrouping];
            
            [NSAnimationContext runAnimationGroup: ^(NSAnimationContext* context) {
                [context setDuration: 2.0f];
                [[selectAudioButtonVerticalCenterConstraint animator] setConstant: 20];
                [selectAudioButton display];
            } completionHandler: nil];

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

