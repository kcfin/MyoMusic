//
//  ProfileViewController.h
//  MyoMusic
//
//  Created by Kate Findlay on 3/29/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Spotify/Spotify.h>

@interface ProfileViewController : UIViewController

@property(nonatomic) NSMutableArray* playlists;

-(void)reload;

@end
