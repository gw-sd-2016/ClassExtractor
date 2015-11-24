//
//  Constants.h
//  ClassExtractor
//
//  Created by Elliot on 11/17/15.
//  Copyright © 2015 ECL. All rights reserved.
//

#ifndef Constants_h
#define Constants_h


// NSNotification name for when the small audio clips have been
// converted to wavs and are ready to be uploaded to Watson
extern NSString* const kGetJSON;


// the name of the large audio file that is generated
// from the conversion of the user selected file to
// a wav file
extern NSString* const kBigFileName;


// the number of minutes per small audio clip (the maximum
// number of minutes Watson allows is 5)
//
// [TODO] Play around with shorter times. The amount of time
// it takes to upload the clip to Watson is the length of the
// audio clip. It might make more sense to have shorter clips,
// such as a minute or even 30 seconds, as we can spawn a new
// thread for each of those clips. However, accuracy may be
// sacrificed, as instead of cutting off the clip length / 5
// times, we're now cutting it off more (which may lead to
// Watson trying to interpret half-words, etc).
extern const NSUInteger kNumMinsPerClip;


// the time scale for each CMTime (to keep everything simple,
// keep them the same (i.e. a timescale of 1 second))
extern const int32_t kTimescale;


#endif /* Constants_h */
