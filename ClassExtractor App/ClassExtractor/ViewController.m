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
            // we only allow selection of one file, so it's ok to just get the first object
            NSString* selectedFilePath = [[[openFileDialogue URLs] firstObject] path];
            [[CEAudioHandler sharedInstance] convertToWav: selectedFilePath isConvertingFiveMinuteFile: false];
        }
    }];
}

@end


// ============================================================
// CEJSONManipulator
// ============================================================
@implementation CEJSONManipulator


// ------------------------------------------------------------
// getJSONForData:
//
// Given an NSData object, serialize the data into an
// NSDictionary and return that object.
// ------------------------------------------------------------
+ (NSDictionary*) getJSONForData: (NSData*)data
{
    NSError* error;
    NSDictionary* feed = [NSJSONSerialization JSONObjectWithData: data
                                                         options: kNilOptions
                                                           error: &error];

    return feed;
}

@end
