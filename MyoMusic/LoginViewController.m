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
#import "UIColor+MyoMusicColors.h"

@interface LoginViewController () <SPTAuthViewDelegate>

@property (atomic, readwrite) SPTAuthViewController *authViewController;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic)UIImageView *logo;

@end

@implementation LoginViewController


-(void)loadView {
    [super loadView];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor lighterBlue];
    self.logo = [UIImageView new];
    [self.logo setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self initButton];
    
}


- (void)viewWillAppear:(BOOL)animated {
    
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
//    [self.navigationItem setBackBarButtonItem:backButton];
//    [self.navigationItem setLeftBarButtonItem:backButton];
//    [self.navigationItem setHidesBackButton:YES];
//    [self.navigationItem setTitle:@"MyoMusic"];
    self.navigationController.navigationBarHidden = YES;
    
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
    self.loginButton.backgroundColor = [UIColor darkerBlue];
    [self.loginButton setTitle:@"Login With Spotify" forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.loginButton.layer setBorderWidth:0.5f];
    [self.loginButton.layer setCornerRadius:3.0f];
    [self.loginButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.logo setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.loginButton];
    [self.view addSubview:self.logo];
    
    UIView *login = self.loginButton;
    UIView *logo = self.logo;
    NSDictionary *loginView = NSDictionaryOfVariableBindings(login, logo);
    
    NSArray *loginConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[login]-|" options:0 metrics:nil views:loginView];
    loginConstraints = [loginConstraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-100-[logo(200)]" options:0 metrics:nil views:loginView]];
    
    loginConstraints = [loginConstraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[logo(200)]" options:0 metrics:nil views:loginView]];
    
    loginConstraints = [loginConstraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[login(50)]-150-|" options:0 metrics:nil views:loginView]];
    
    loginConstraints = [loginConstraints arrayByAddingObject:[NSLayoutConstraint constraintWithItem:self.logo attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.loginButton attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self.view addConstraints:loginConstraints];
    [self.loginButton addTarget:self action:@selector(loginTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.logo setImage:[UIImage imageNamed:@"logo.png"]];
    
}

-(void)loginTapped {
    
    self.authViewController = [SPTAuthViewController authenticationViewController];
    self.authViewController.delegate = self;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.authViewController.navigationItem setBackBarButtonItem:backButton];
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
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popToRootViewControllerAnimated:YES];
    [[SpotifyUser user] handle:session];
}

- (void)authenticationViewControllerDidCancelLogin:(SPTAuthViewController *)authenticationViewController{
    NSLog(@"*** Cancelled log in.");
}

@end