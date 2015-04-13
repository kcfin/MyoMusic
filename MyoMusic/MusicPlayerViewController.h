//
//  MusicPlayerViewController.h
//  MyoMusic
//
//  Created by Alexander Athan on 4/5/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Spotify/Spotify.h>

@interface MusicPlayerViewController : UIViewController <SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate>

@property(nonatomic)SPTSession *session;

-(void)setPlaylistWithPartialPlaylist:(SPTPartialPlaylist *)partialPlaylist;


@end
