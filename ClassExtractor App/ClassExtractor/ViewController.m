//
//  ViewController.m
//  ClassExtractor
//
//  Created by Elliot on 10/14/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#import "ViewController.h"
#import "CECalculator.h"
#import "CEConnector.h"
#import "Constants.h"

// ============================================================
// ViewController
// ============================================================
@implementation ViewController


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
// importAudioFile:
//
// Presents a modal sheet for the user to select a lecture file
// for analysis.
// ------------------------------------------------------------
- (IBAction) importAudioFile: (id)sender
{
    NSOpenPanel* openFileDialogue = [NSOpenPanel openPanel];
    
    [openFileDialogue setCanChooseFiles: true];
    [openFileDialogue setAllowsMultipleSelection: false];
    [openFileDialogue setCanChooseDirectories: false];
    
    [openFileDialogue beginSheetModalForWindow: [[self view] window] completionHandler: ^(NSInteger response) {
        if (NSModalResponseOK == response)
        {
            // we only allow selection of one file, so it's ok to get just the first object
            NSURL* selectedFilePath = [[openFileDialogue URLs] firstObject];
            AVURLAsset* selectedAudioAsset = [[AVURLAsset alloc] initWithURL: selectedFilePath options: nil];
            
            // [TODO] Instead of just logging the error, report it to the user in some nice
            // GUI fashion
            if (![[CEAudioHandler sharedInstance] chopUpLargeAudioFile: selectedAudioAsset])
                NSLog(@"Error chopping up large audio file.");
        }
    }];
}

@end

