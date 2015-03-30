//
//  AppDelegate.m
//  MyoMusic
//
//  Created by Kate Findlay on 3/29/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import "AppDelegate.h"
#import "Config.h"
#import "LoginViewController.h"
#import "ProfileViewController.h"
#import "SpotifyUser.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    ProfileViewController *profileVC = [ProfileViewController new];
    [SpotifyUser user].profileVC = profileVC;
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:profileVC];
    [self.window setRootViewController:navVC];
    [navVC setNavigationBarHidden:NO];
    
    SPTAuth *auth = [SPTAuth defaultInstance];
    auth.clientID = @kClientId;
    auth.requestedScopes = @[SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope,
                             SPTAuthUserReadPrivateScope, SPTAuthUserLibraryReadScope];
    auth.redirectURL = [NSURL URLWithString:@kCallbackURL];
#ifdef kTokenSwapServiceURL
    auth.tokenSwapURL = [NSURL URLWithString:@kTokenSwapServiceURL];
#endif
#ifdef kTokenRefreshServiceURL
    auth.tokenRefreshURL = [NSURL URLWithString:@kTokenRefreshServiceURL];
#endif
    auth.sessionUserDefaultsKey = @kSessionUserDefaultsKey;
    
    if(auth.session == nil || ![auth.session isValid]) {
        [navVC pushViewController:[LoginViewController new] animated:YES];
    } else {
        [[SpotifyUser user] handle:auth.session];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
