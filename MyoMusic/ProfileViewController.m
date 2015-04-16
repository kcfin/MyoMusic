//
//  ProfileViewController.m
//  MyoMusic
//
//  Created by Kate Findlay on 3/29/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import "ProfileViewController.h"
#import "PlaylistViewController.h"
#import "MusicPlayerViewController.h"
#import "BasicCell.h"
#import "SpotifyUser.h"

@interface ProfileViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UITableView *tableView;
@property (nonatomic) UIView *userView;
@property (nonatomic) UIImageView *profileImageView;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) SpotifyUser *user;
@property (nonatomic) MusicPlayerViewController *musicVC;
@property (nonatomic) PlaylistViewController *pvc;
@property (nonatomic) NSInteger currentPlayingIndex;


-(void)fetchPlaylistPageForSession:(SPTSession *)session error:(NSError *)error object:(id)object;

@end

@implementation ProfileViewController

-(void)loadView {
    [super loadView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.profileImageView = [UIImageView new];
    self.currentPlayingIndex = -1;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, self.view.frame.size.height/2) style:UITableViewStylePlain];
    self.tableView.contentInset = UIEdgeInsetsZero;
    
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[BasicCell class] forCellReuseIdentifier:@"Cell"];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundColor:[UIColor blackColor]];
    self.tableView.tableHeaderView = nil;
    self.tableView.rowHeight = self.tableView.frame.size.height/6;
    self.tableView.scrollEnabled = NO;
    
    self.userView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-self.tableView.frame.size.height)];
    [self.view addSubview:self.userView];
    self.userView.backgroundColor = [UIColor darkGrayColor];
    [self loadProfilePicture];

    self.user = [SpotifyUser user];
    self.playlists = [NSMutableArray new];
    self.pvc = [PlaylistViewController new];
    [self.navigationController.navigationBar.topItem setTitle:@"Home"];
}

    
-(void)reload {
    NSLog(@"RELOADING PROFILE INFO W/ USER: %@", self.user.sptUser.displayName);
    self.profileImageView.image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:self.user.sptUser.largestImage.imageURL]];
    self.nameLabel.text = self.user.sptUser.displayName;
    [SPTRequest playlistsForUserInSession:self.user.session callback:^(NSError *error, id object) {
        [self fetchPlaylistPageForSession:self.user.session error:error object:object];
    }];
    
}

-(void)fetchPlaylistPageForSession:(SPTSession *)session error:(NSError *)error object:(id)object{
    if (error != nil) {
        NSLog(@"PLAYLIST ERROR");
        abort();
    } else {
        if ([object isKindOfClass:[SPTPlaylistList class]]) {
            SPTPlaylistList *playlistList = (SPTPlaylistList *)object;
            
            for (SPTPartialPlaylist *playlist in playlistList.items) {
                NSLog(@"GOT PLAYLIST");
                [self.playlists addObject:playlist];
            }
                        
            if (playlistList.hasNextPage) {
                NSLog(@"GETTING NEXT PAGE");
                [playlistList requestNextPageWithSession:session callback:^(NSError *error, id object) {
                    [self fetchPlaylistPageForSession:session error:error object:object];
                }];
            }
            
            [self.tableView reloadData];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    // Do any additional setup after loading the view.
}

-(void)loadProfilePicture {
    NSLog(@"PROFILE PIC URL: %@", self.user.sptUser.largestImage.imageURL);
    self.profileImageView.image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:self.user.sptUser.largestImage.imageURL]];
    self.profileImageView.layer.cornerRadius = self.userView.frame.size.width/6;
    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView.frame = CGRectMake(0, 0, self.userView.frame.size.width/3, self.userView.frame.size.width/3);
    self.profileImageView.center = self.userView.center;
    self.profileImageView.backgroundColor = [UIColor lightGrayColor];
    [self.userView addSubview:self.profileImageView];
    
    self.nameLabel = [UILabel new];
    self.nameLabel.frame = CGRectMake(0, self.profileImageView.frame.origin.y + self.profileImageView.frame.size.height, self.userView.frame.size.width, 50);
    [self.nameLabel setTextAlignment:NSTextAlignmentCenter];
    [self.nameLabel setTextColor:[UIColor blackColor]];
    if(self.user.sptUser.displayName){
        NSLog(@"SETTING DISPLAY NAME");
        self.nameLabel.text = [[NSString alloc] initWithString:self.user.sptUser.displayName];
    }
    [self.userView addSubview:self.nameLabel];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BasicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSString *playlistName;
    SPTPartialPlaylist *playlistTemp = [self.playlists objectAtIndex:indexPath.row];
    playlistName = playlistTemp.name;
    [cell.textLabel setText:playlistName];
    
    if(cell.isSelected){
        [cell setBackgroundColor:[UIColor darkGrayColor]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
    }else{
        [cell setBackgroundColor:[UIColor blackColor]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.playlists.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *title = @"Playlists";
    return title;
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
