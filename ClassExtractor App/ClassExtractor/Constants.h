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


// NSNotification name for when the big wav file has been
// chopped up into smaller audio clips and is no longer
// needed
extern NSString* const kDeleteBigWav;


// the number of minutes per small audio clip (the maximum
// number of minutes Watson allows is 5)
extern const NSUInteger kNumMinsPerClip;


// the time scale for each CMTime (to keep everything simple,
// keep them the same (i.e. a timescale of 1 second))
extern const int32_t kTimescale;


#endif /* Constants_h */
