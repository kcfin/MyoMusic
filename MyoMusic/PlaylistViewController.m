//
//  PlaylistViewController.m
//  MyoMusic
//
//  Created by Kate Findlay on 3/29/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import "PlaylistViewController.h"

@interface PlaylistViewController ()

@end

@implementation PlaylistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UILabel *testView = [UILabel new];
    [testView setFrame:CGRectMake(60, 200, 200, 50)];
    [testView setText:@"TEST"];
    [testView setTextColor:[UIColor whiteColor]];
    [self.view addSubview:testView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end