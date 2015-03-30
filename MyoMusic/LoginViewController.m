//
//  LoginViewController.m
//  MyoMusic
//
//  Created by Kate Findlay on 3/29/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import "LoginViewController.h"
#import <Spotify/Spotify.h>
#import "Config.h"
#import "SpotifyUser.h"

@interface LoginViewController () <SPTAuthViewDelegate>

@property (atomic, readwrite) SPTAuthViewController *authViewController;
@property (nonatomic, strong) UIButton *loginButton;

@end

@implementation LoginViewController


-(void)loadView {
    [super loadView];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    [self initButton];
    
}


- (void)viewWillAppear:(BOOL)animated {
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    if (auth.hasTokenRefreshService) {
        [self renewToken];
        return;
    }
    
}

- (void)renewToken {
    
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    [auth renewSession:auth.session callback:^(NSError *error, SPTSession *session) {
        auth.session = session;
        
        if (error) {
            NSLog(@"*** Error renewing session: %@", error);
            return;
        }
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

-(void)initButton {
    self.loginButton = [UIButton new];
    self.loginButton.backgroundColor = [UIColor greenColor];
    [self.loginButton setFrame:CGRectMake(50, 200, 250, 50)];
    [self.loginButton setTitle:@"Log In To Spotify" forState:UIControlStateNormal];
    
    [self.view addSubview:self.loginButton];
    [self.loginButton addTarget:self action:@selector(loginTapped) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)loginTapped {
    
    self.authViewController = [SPTAuthViewController authenticationViewController];
    self.authViewController.delegate = self;
    self.authViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.authViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.definesPresentationContext = YES;
    
    [self presentViewController:self.authViewController animated:NO completion:nil];
}

- (void)authenticationViewController:(SPTAuthViewController *)viewcontroller didFailToLogin:(NSError *)error {
    NSLog(@"*** Failed to log in: %@", error);
}

- (void)authenticationViewController:(SPTAuthViewController *)viewcontroller didLoginWithSession:(SPTSession *)session {
    [self.navigationController popToRootViewControllerAnimated:YES];
    [[SpotifyUser user] handle:session];
}

@end