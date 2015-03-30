//
//  ProfileViewController.m
//  MyoMusic
//
//  Created by Kate Findlay on 3/29/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import "ProfileViewController.h"
#import "PlaylistViewController.h"
#import "BasicCell.h"
#import "SpotifyUser.h"

@interface ProfileViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UITableView *tableView;
@property (nonatomic) UIView *userView;
@property (nonatomic) UIImageView *profileImageView;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic, weak) SpotifyUser *user;

@end

@implementation ProfileViewController

-(void)loadView {
    [super loadView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectInset(self.view.frame, 0, self.view.frame.size.height/4) style:UITableViewStylePlain];
    [self.tableView setCenter:CGPointMake(self.view.center.x, self.view.center.y+self.view.frame.size.height/4)];
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[BasicCell class] forCellReuseIdentifier:@"Cell"];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    self.userView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-self.tableView.frame.size.height)];
    [self.view addSubview:self.userView];
    self.userView.backgroundColor = [UIColor greenColor];
    
    self.user = [SpotifyUser user];
    [self loadProfilePicture];
}

-(void)reload {
    self.profileImageView.image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:self.user.sptUser.largestImage.imageURL]];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)loadProfilePicture {
    self.profileImageView = [UIImageView new];
    self.profileImageView.image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:self.user.sptUser.largestImage.imageURL]];
    self.profileImageView.layer.cornerRadius = self.userView.frame.size.width/6;
    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView.frame = CGRectMake(0, 0, self.userView.frame.size.width/3, self.userView.frame.size.width/3);
    self.profileImageView.center = self.userView.center;
    self.profileImageView.backgroundColor = [UIColor blueColor];
    [self.userView addSubview:self.profileImageView];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BasicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor redColor]];
    [cell.textLabel setText:@"Fuck!"];
    [cell.detailTextLabel setText:@"you!"];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PlaylistViewController *playlistVC = [PlaylistViewController new];
    [self.navigationController pushViewController:playlistVC animated:YES];
}

@end
