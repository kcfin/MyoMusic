//
//  SpotifyUser.m
//  MyoMusic
//
//  Created by Kate Findlay on 3/29/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import "SpotifyUser.h"


@implementation SpotifyUser

static SpotifyUser *userInst = nil;
+(SpotifyUser *)user {
    if (!userInst) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            userInst = [self new];
        });
    }
    return userInst;
}

-(void)handle:(SPTSession *)session {
    if(session){
        _session = session;
    }
    [SPTRequest userInformationForUserInSession:session callback:^(NSError *error, id object) {
        if (!error) {
            self.sptUser = object;
            [self.profileVC reload];
        } else {
            NSLog(@"error: %@", error.localizedDescription);
        }
    }];
    
}

@end
