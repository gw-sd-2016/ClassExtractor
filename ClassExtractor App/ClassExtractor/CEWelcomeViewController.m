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
    
    // test code
    [self performSegueWithIdentifier: @"showWordCloud" sender: self];
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
// prepareForSegue:sender:
// ------------------------------------------------------------
- (void) prepareForSegue: (NSStoryboardSegue*)segue sender: (id)sender
{
    if ([[segue identifier] isEqualToString: @"showWordCloud"])
    {
        CEWordCloudViewController* wordCloudViewController = [segue destinationController];
        
        NSArray* array = @[@{@"Chile"                               : [NSNumber numberWithInteger: 1]},
                           @{@"Comparative Advantage"               : [NSNumber numberWithInteger: 1]},
                           @{@"Opportunity Cost"                    : [NSNumber numberWithInteger: 1]},
                           @{@"Absolute Advantage"                  : [NSNumber numberWithInteger: 1]},
                           @{@"Bob Dole"                            : [NSNumber numberWithInteger: 1]},
                           @{@"Argentina"                           : [NSNumber numberWithInteger: 1]},
                           @{@"Production Possibilities Frontier"   : [NSNumber numberWithInteger: 1]},
                           @{@"Onenote"                             : [NSNumber numberWithInteger: 1]},
                           @{@"Beer"                                : [NSNumber numberWithInteger: 1]},
                           @{@"Chili"                               : [NSNumber numberWithInteger: 1]},
                           @{@"Computers"                           : [NSNumber numberWithInteger: 1]},
                           @{@"Microeconomics"                      : [NSNumber numberWithInteger: 1]},
                           @{@"Macroeconomics"                      : [NSNumber numberWithInteger: 1]},
                           @{@"Industry"                            : [NSNumber numberWithInteger: 1]},
                           @{@"Government"                          : [NSNumber numberWithInteger: 1]},
                           @{@"Central Bank"                        : [NSNumber numberWithInteger: 1]},
                           @{@"The Fed"                             : [NSNumber numberWithInteger: 1]},
                           @{@"World Economy"                       : [NSNumber numberWithInteger: 1]},
                           @{@"Trade"                               : [NSNumber numberWithInteger: 1]}];
        
        [wordCloudViewController setTopics: array];
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

