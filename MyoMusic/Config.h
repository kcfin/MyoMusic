//
//  Config.h
//  MyoMusic
//
//  Created by Kate Findlay on 3/29/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#ifndef MyoMusic_Config_h
#define MyoMusic_Config_h

// Your client ID
#define kClientId "41e8e28fe48e430d839821dbea5b5817"

// Your applications callback URL
#define kCallbackURL "myomusic://callback"


// The URL to your token swap endpoint
// If you don't provide a token swap service url the login will use implicit grant tokens, which means that your user will need to sign in again every time the token expires.

//#define kTokenSwapServiceURL "http://localhost:1234/swap"

// The URL to your token refresh endpoint
// If you don't provide a token refresh service url, the user will need to sign in again every time their token expires.

//#define kTokenRefreshServiceURL "http://localhost:1234/refresh"


#define kSessionUserDefaultsKey "SpotifySession"

#endif
