//
//  SpotifyUser.h
//  MyoMusic
//
//  Created by Kate Findlay on 3/29/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Spotify/Spotify.h>
#import "ProfileViewController.h"

@interface SpotifyUser : NSObject

+(SpotifyUser *)user;
-(void)handle:(SPTSession *)session;

@property (nonatomic) SPTUser *sptUser;
@property (nonatomic, weak) ProfileViewController *profileVC;

@end