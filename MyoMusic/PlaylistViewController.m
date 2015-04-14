//
//  PlaylistViewController.m
//  MyoMusic
//
//  Created by Kate Findlay on 3/29/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import "PlaylistViewController.h"
#import "MusicPlayerViewController.h"
#import "SpotifyUser.h"
#import "BasicCell.h"

@interface PlaylistViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UITableView *tableView;
@property (nonatomic, weak) SpotifyUser *user;
@property (nonatomic) MusicPlayerViewController *musicVC;
@property (nonatomic) NSInteger currentPlayingIndex;
@property (nonatomic) UIView *playlistView;

-(void)fetchPlaylistPageForSession:(SPTSession *)session error:(NSError *)error object:(id)object;

@end

@implementation PlaylistViewController

-(void)loadView {
    [super loadView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.currentPlayingIndex = -1;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, self.view.frame.size.height/2) style:UITableViewStylePlain];
    self.tableView.contentInset = UIEdgeInsetsZero;
    [self.tableView registerClass:[BasicCell class] forCellReuseIdentifier:@"Cell"];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundColor:[UIColor blackColor]];
    self.tableView.tableHeaderView = nil;
    [self.view addSubview:self.tableView];
    
    self.playlistView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-self.tableView.frame.size.height)];
    self.playlistView.backgroundColor = [UIColor darkGrayColor];
    UILabel *label = [UILabel new];
    label.frame = CGRectMake(0, 0, self.playlistView.frame.size.width/2, 50);
    label.center = self.playlistView.center;
    label.text = @"Playlists";
    label.textColor = [UIColor whiteColor];
    [label setTextAlignment:NSTextAlignmentCenter];
    label.font = [UIFont fontWithName:@"Avenir-Heavy" size:[UIFont systemFontSize] * 2];
    [self.playlistView addSubview:label];
    [self.view addSubview:self.playlistView];
    
    self.user = [SpotifyUser user];
    self.musicVC = [MusicPlayerViewController new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BasicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    NSString *playlistName;
    SPTPartialPlaylist *playlistTemp = [self.playlists objectAtIndex:indexPath.row];
    playlistName = playlistTemp.name;
    [cell.textLabel setText:playlistName];

    if(cell.isSelected){
        [cell setBackgroundColor:[UIColor darkGrayColor]];
    }else{
        [cell setBackgroundColor:[UIColor blackColor]];
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.playlists.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.currentPlayingIndex != indexPath.row){
        self.currentPlayingIndex = indexPath.row;
        self.musicVC.session = self.user.session;
        [self.musicVC setPlaylistWithPartialPlaylist:(SPTPartialPlaylist *)[self.playlists objectAtIndex:indexPath.row]];
    }

    [self.navigationController pushViewController:self.musicVC animated:YES];
}

@end