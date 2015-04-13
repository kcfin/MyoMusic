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
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self initButton];
    
}


- (void)viewWillAppear:(BOOL)animated {
    
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
//    [self.navigationItem setBackBarButtonItem:backButton];
//    [self.navigationItem setLeftBarButtonItem:backButton];
//    [self.navigationItem setHidesBackButton:YES];
//    [self.navigationItem setTitle:@"MyoMusic"];
    self.navigationController.navigationBarHidden = NO;
    
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
    self.loginButton.backgroundColor = [UIColor whiteColor];
    [self.loginButton setTitle:@"Log In With Spotify" forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.loginButton.layer setBorderWidth:0.5f];
    [self.loginButton.layer setCornerRadius:3.0f];
    [self.loginButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.loginButton];

    UIView *login = self.loginButton;
    NSDictionary *loginView = NSDictionaryOfVariableBindings(login);
    
    NSArray *loginConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[login]-|" options:0 metrics:nil views:loginView];
    loginConstraints = [loginConstraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[login(50)]-150-|" options:0 metrics:nil views:loginView]];
    
    [self.view addConstraints:loginConstraints];
    [self.loginButton addTarget:self action:@selector(loginTapped) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)loginTapped {
    
    self.authViewController = [SPTAuthViewController authenticationViewController];
    self.authViewController.delegate = self;
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
//    [self.authViewController.navigationItem setBackBarButtonItem:backButton];
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