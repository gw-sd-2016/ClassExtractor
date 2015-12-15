//
//  CEWelcomeViewController.m
//  ClassExtractor
//
//  Created by Elliot on 10/14/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import "CEWelcomeViewController.h"
#import "CECalculator.h"
#import "CEConnector.h"
#import "Constants.h"

// ============================================================
// ViewController
// ============================================================
@implementation CEWelcomeViewController


// ------------------------------------------------------------
// viewDidLoad
// ------------------------------------------------------------
- (void) viewDidLoad
{
    [super viewDidLoad];
    
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
}


// ------------------------------------------------------------
// viewDidAppear
// ------------------------------------------------------------
- (void) viewDidAppear
{
    [super viewDidAppear];
    
    [[[self view] window] setTitle: @"Class Extractor"];
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
            
            // [TODO] Instead of just logging the error, report it to the user in some nice
            // GUI fashion
            // [TODO] If this fails, kill all connections to Watson and don't process
            // any more audio files
            NSString* result = [[CEAudioHandler sharedInstance] chopUpLargeAudioFile: selectedAudioAsset];
            if (![result isEqualToString: kChoppingSuccess])
                NSLog(@"%@", result);
        }
    }];
}

@end

