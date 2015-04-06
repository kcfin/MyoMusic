//
//  MusicPlayerViewController.m
//  MyoMusic
//
//  Created by Alexander Athan on 4/5/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import "MusicPlayerViewController.h"
#import "Config.h"

@interface MusicPlayerViewController () <SPTAudioStreamingDelegate>

@property (nonatomic)SPTPlaylistSnapshot *currentPlaylist;
@property (nonatomic)SPTAudioStreamingController *audioPlayer;
@property (nonatomic)NSMutableArray *trackURIs;
@property (nonatomic)SPTTrack *currentTrack;
@property (nonatomic)SPTArtist *currentArtist;

@property (nonatomic)UILabel *trackLabel;
@property (nonatomic)UILabel *artistLabel;
@property (nonatomic)UIImageView *coverArt;

-(void)updateInfo;

@end

@implementation MusicPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.title = @"Now Playing";
    self.trackURIs = [NSMutableArray new];
    
    self.trackLabel = [UILabel new];
    [self.trackLabel setFrame:CGRectMake(50, 300, 250, 50)];
    [self.trackLabel setTextColor:[UIColor redColor]];
    [self.trackLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    self.trackLabel.backgroundColor = [UIColor whiteColor];
    self.trackLabel.numberOfLines = 2;
    [self.trackLabel setTextAlignment:NSTextAlignmentCenter];
    
    self.artistLabel = [UILabel new];
    [self.artistLabel setFrame:CGRectMake(100, 350, 200, 50)];
    self.artistLabel.backgroundColor = [UIColor whiteColor];
    [self.artistLabel setTextColor:[UIColor redColor]];
    
    self.coverArt = [UIImageView new];
    [self.coverArt setFrame:CGRectMake(50, 50, 200, 200)];
    [self.view addSubview:self.trackLabel];
    [self.view addSubview:self.artistLabel];
    [self.view addSubview:self.coverArt];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setPlaylistWithPartialPlaylist:(SPTPartialPlaylist *)partialPlaylist{
    if(partialPlaylist){
        [SPTRequest requestItemAtURI:partialPlaylist.uri withSession:self.session callback:^(NSError *error, id object) {
            if([object isKindOfClass:[SPTPlaylistSnapshot class]]){
                self.currentPlaylist = (SPTPlaylistSnapshot *)object;
                NSLog(@"PLAYLIST SIZE: %lu", (unsigned long)self.currentPlaylist.trackCount);
                if(self.currentPlaylist.trackCount > 0){
                    for(SPTTrack *track in self.currentPlaylist.tracksForPlayback){
                        NSLog(@"GOT SONG: %@", track.name);
                        [self.trackURIs addObject:track.uri];
                    }
                    [self handleNewSession];
                }
            }
        }];
    }
}

-(void)updateInfo{
    NSLog(@"SHOULD UPDATE TRACK INFO");
}

-(void)handleNewSession {
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    if (self.audioPlayer == nil) {
        self.audioPlayer = [[SPTAudioStreamingController alloc] initWithClientId:auth.clientID];
        self.audioPlayer.playbackDelegate = self;
        self.audioPlayer.diskCache = [[SPTDiskCache alloc] initWithCapacity:1024 * 1024 * 64];
    }
    
    [self.audioPlayer loginWithSession:auth.session callback:^(NSError *error) {
        
        if (error != nil) {
            NSLog(@"*** Enabling playback got error: %@", error);
            return;
        }
        
        //[self updateUI];
        [self.audioPlayer playURIs:self.trackURIs fromIndex:0 callback:^(NSError *error) {
            if(error != nil){
                NSLog(@"ERROR");
                return;
            }
            self.currentTrack = [self.currentPlaylist.tracksForPlayback objectAtIndex:0];
            self.trackLabel.text = self.currentTrack.name;
            SPTPartialArtist *artist = (SPTPartialArtist *)[self.currentTrack.artists objectAtIndex:0];
            self.artistLabel.text = artist.name;
            
            NSURL *coverArtURL = self.currentTrack.album.largestCover.imageURL;
            if(coverArtURL){
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError *error = nil;
                    UIImage *image = nil;
                    NSData *imageData = [NSData dataWithContentsOfURL:coverArtURL options:0 error:&error];
                    
                    if (imageData != nil) {
                        image = [UIImage imageWithData:imageData];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //[self.spinner stopAnimating];
                        self.coverArt.image = image;
                        if (image == nil) {
                            NSLog(@"Couldn't load cover image with error: %@", error);
                            return;
                        }
                    });
                    
                    // Also generate a blurry version for the background
                    //UIImage *blurred = [self applyBlurOnImage:image withRadius:10.0f];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        self.coverView2.image = blurred;
//                    });
                });
            }
            
        }];
    }];
}

#pragma mark - Track Player Delegates

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didReceiveMessage:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message from Spotify"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didFailToPlayTrack:(NSURL *)trackUri {
    NSLog(@"failed to play track: %@", trackUri);
}

- (void) audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeToTrack:(NSDictionary *)trackMetadata {
    NSLog(@"track changed = %@", [trackMetadata valueForKey:SPTAudioStreamingMetadataTrackURI]);
    [self updateInfo];
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePlaybackStatus:(BOOL)isPlaying {
    NSLog(@"is playing = %d", isPlaying);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
