//
//  MusicPlayerViewController.m
//  MyoMusic
//
//  Created by Alexander Athan on 4/5/15.
//  Copyright (c) 2015 EECS493. All rights reserved.
//

#import "MusicPlayerViewController.h"
#import "Config.h"
#import <MyoKit/MyoKit.h>

@interface MusicPlayerViewController () <SPTAudioStreamingDelegate>

@property (nonatomic)SPTPlaylistSnapshot *currentPlaylist;
@property (nonatomic)SPTAudioStreamingController *audioPlayer;
@property (nonatomic)NSMutableArray *trackURIs;
@property (nonatomic)SPTTrack *currentTrack;
@property (nonatomic)SPTArtist *currentArtist;
@property (nonatomic)NSInteger currentIndex;

@property (nonatomic)UILabel *trackLabel;
@property (nonatomic)UILabel *artistLabel;
@property (nonatomic)UIImageView *coverArt;
@property (nonatomic)UIImage *playImage;
@property (nonatomic)UIImage *pauseImage;

@property (nonatomic)UIButton *playButton;
@property (nonatomic)UIButton *pauseButton;
@property (nonatomic)UIButton *nextButton;
@property (nonatomic)UIButton *prevButton;

@property (nonatomic)UISlider *trackSlider;
@property (nonatomic)UISlider *volumeSlider;
@property (nonatomic)NSTimer *playbackTimer;

@property (nonatomic)TLMPose *currentPose;

@property (nonatomic)BOOL isAdjustingVolume;
@property (nonatomic)int latestNoFistRoll;
@property (nonatomic) NSTimer *volumeIncreaseTimer;
@property (nonatomic) NSTimer *volumeDecreaseTimer;

-(void)updateInfo;

@end

@implementation MusicPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMyoNotifications];
    UIBarButtonItem *myoButton = [[UIBarButtonItem alloc] initWithTitle:@"Connect" style:UIBarButtonItemStylePlain target:self action:@selector(connectMyo:)];
    self.navigationItem.rightBarButtonItem = myoButton;
    
    self.isAdjustingVolume = NO;
    
    self.title = @"Now Playing";
    self.trackURIs = [NSMutableArray new];
    self.currentIndex = 0;

    self.volumeSlider = [UISlider new];
    [self.volumeSlider addTarget:self action:@selector(volumeChanged:) forControlEvents:UIControlEventValueChanged];
    [self.volumeSlider setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.volumeSlider setContinuous:YES];
    [self.volumeSlider setMinimumValue:0.0f];
    [self.volumeSlider setValue:0.5f];
    [self.volumeSlider setMaximumValue:1.0f];
    
    UIImage *trackImage = [UIImage imageNamed:@"mySlider.png"];
    self.trackSlider = [UISlider new];
    [self.trackSlider setThumbImage:trackImage forState:UIControlStateNormal];
    [self.trackSlider addTarget:self action:@selector(sliderActive:) forControlEvents:UIControlEventTouchUpInside];
    [self.trackSlider setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.trackSlider setMinimumValue:0];
    [self.trackSlider setContinuous:YES];
    
    self.playImage = [UIImage imageNamed:@"playButton.png"];
    self.pauseImage = [UIImage imageNamed:@"pauseButton.png"];
    self.playButton = [UIButton new];
    [self.playButton setImage:self.pauseImage forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(togglePlaying:) forControlEvents:UIControlEventTouchUpInside];
    [self.playButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    UIImage *nextImage = [UIImage imageNamed:@"nextButton.png"];
    self.nextButton = [UIButton new];
    [self.nextButton setImage:nextImage forState:UIControlStateNormal];
    [self.nextButton addTarget:self action:@selector(nextButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.nextButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    UIImage *prevImage = [UIImage imageNamed:@"prevButton.png"];
    self.prevButton = [UIButton new];
    [self.prevButton setImage:prevImage forState:UIControlStateNormal];
    [self.prevButton addTarget:self action:@selector(prevButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.prevButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.trackLabel = [UILabel new];
    //[self.trackLabel setFrame:CGRectMake(50, 300, 250, 50)];
    [self.trackLabel setTextColor:[UIColor whiteColor]];
    [self.trackLabel setClipsToBounds:YES];
    [self.trackLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    self.trackLabel.backgroundColor = [UIColor blackColor];
    self.trackLabel.numberOfLines = 1;
    [self.trackLabel setTextAlignment:NSTextAlignmentCenter];
    [self.trackLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.artistLabel = [UILabel new];
    //[self.artistLabel setFrame:CGRectMake(100, 350, 200, 50)];
    [self.artistLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [self.artistLabel setClipsToBounds:YES];
    self.artistLabel.backgroundColor = [UIColor blackColor];
    [self.artistLabel setTextColor:[UIColor whiteColor]];
    [self.artistLabel setTextAlignment:NSTextAlignmentCenter];
    [self.artistLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.coverArt = [UIImageView new];
    //[self.coverArt setFrame:CGRectMake(50, 50, 200, 200)];
    [self.coverArt setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.view setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2)];
    
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.volumeSlider];
    [self.view addSubview:self.trackSlider];
    [self.view addSubview:self.trackLabel];
    [self.view addSubview:self.artistLabel];
    [self.view addSubview:self.coverArt];
    [self.view addSubview:self.playButton];
    [self.view addSubview:self.pauseButton];
    [self.view addSubview:self.nextButton];
    [self.view addSubview:self.prevButton];

    [self createConstraints];

    // Do any additional setup after loading the view.
}

-(void)setupMyoNotifications{
    // Data notifications are received through NSNotificationCenter.
    // Posted whenever a TLMMyo connects
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didConnectDevice:)
                                                 name:TLMHubDidConnectDeviceNotification
                                               object:nil];
    // Posted whenever a TLMMyo disconnects.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDisconnectDevice:)
                                                 name:TLMHubDidDisconnectDeviceNotification
                                               object:nil];
    // Posted whenever the user does a successful Sync Gesture.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSyncArm:)
                                                 name:TLMMyoDidReceiveArmSyncEventNotification
                                               object:nil];
    // Posted whenever Myo loses sync with an arm (when Myo is taken off, or moved enough on the user's arm).
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUnsyncArm:)
                                                 name:TLMMyoDidReceiveArmUnsyncEventNotification
                                               object:nil];
    // Posted whenever Myo is unlocked and the application uses TLMLockingPolicyStandard.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUnlockDevice:)
                                                 name:TLMMyoDidReceiveUnlockEventNotification
                                               object:nil];
    // Posted whenever Myo is locked and the application uses TLMLockingPolicyStandard.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLockDevice:)
                                                 name:TLMMyoDidReceiveLockEventNotification
                                               object:nil];
    // Posted when a new orientation event is available from a TLMMyo. Notifications are posted at a rate of 50 Hz.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveOrientationEvent:)
                                                 name:TLMMyoDidReceiveOrientationEventNotification
                                               object:nil];
    // Posted when a new accelerometer event is available from a TLMMyo. Notifications are posted at a rate of 50 Hz.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveAccelerometerEvent:)
                                                 name:TLMMyoDidReceiveAccelerometerEventNotification
                                               object:nil];
    // Posted when a new pose is available from a TLMMyo.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivePoseChange:)
                                                 name:TLMMyoDidReceivePoseChangedNotification
                                               object:nil];
}

-(void)didConnectDevice:(NSNotification *)notification{
    NSLog(@"Connected Device");
}

-(void)didDisconnectDevice:(NSNotification *)notification{
    NSLog(@"Disconnected Device");
}

-(void)didSyncArm:(NSNotification *)notification{
    NSLog(@"Synced Arm");
}

-(void)didUnsyncArm:(NSNotification *)notification{
    NSLog(@"Unsync Arm");
}

-(void)didUnlockDevice:(NSNotification *)notification{
    NSLog(@"Unlock Device");
}

-(void)didLockDevice:(NSNotification *)notification{
    NSLog(@"Lock Device");
}

-(void)didReceiveOrientationEvent:(NSNotification *)notification{
    
    TLMOrientationEvent *orientationEvent = notification.userInfo[kTLMKeyOrientationEvent];
    TLMEulerAngles *angles = [TLMEulerAngles anglesWithQuaternion:orientationEvent.quaternion];
    int rotation = angles.roll.degrees;

    if(self.isAdjustingVolume == YES) {
        NSLog(@"Received Orientation: %d", rotation);
        
        //not sure about these roll numbers, need to test
        [self adjustVolumeWithMyo:rotation - self.latestNoFistRoll];
    } else {
        self.latestNoFistRoll = rotation;
    }
}

-(void)adjustVolumeWithMyo:(int)rotation {
    BOOL shouldIncrease = rotation > 30;
    BOOL shouldDecrease = rotation < -30;
    
    if (shouldIncrease) {
        [self.volumeDecreaseTimer invalidate];
        self.volumeIncreaseTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(increaseVolume) userInfo:nil repeats:NO];
        [self.volumeIncreaseTimer fire];
    } else if (shouldDecrease) {
        [self.volumeIncreaseTimer invalidate];
        self.volumeDecreaseTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(decreaseVolume) userInfo:nil repeats:NO];
        [self.volumeDecreaseTimer fire];
    }
}

-(void)increaseVolume {
    SPTVolume volume = self.volumeSlider.value;
    volume += 0.01;
    if (volume < 0) {
        volume = 0;
    } else if (volume >= 1) {
        volume = 1.0f;
    }
    self.volumeSlider.value = volume;
    [self.audioPlayer setVolume:volume callback:^(NSError *error) {
        
    }];
}

-(void)decreaseVolume {
    SPTVolume volume = self.volumeSlider.value;
    volume -= 0.01;
    if (volume <= 0) {
        volume = 0;
    } else if (volume > 1) {
        volume = 1.0f;
    }
    self.volumeSlider.value = volume;
    [self.audioPlayer setVolume:volume callback:^(NSError *error) {
        
    }];
}

-(void)didReceiveAccelerometerEvent:(NSNotification *)notification{
    //NSLog(@"Received Acceleration");
}

-(void)didReceivePoseChange:(NSNotification *)notification{
    //NSLog(@"Received Pose");
    TLMPose *pose = notification.userInfo[kTLMKeyPose];
    self.currentPose = pose;
    self.isAdjustingVolume = NO;
    
    // Handle the cases of the TLMPoseType enumeration, and change the color of helloLabel based on the pose we receive.
    switch (pose.type) {
        case TLMPoseTypeUnknown:
        case TLMPoseTypeRest:
        case TLMPoseTypeDoubleTap:
            //NSLog(@"DOUBLE TAP");
            break;
        case TLMPoseTypeFist:
            // Triggers adjusting music with fist rotation
            self.isAdjustingVolume = YES;
            break;
        case TLMPoseTypeWaveIn:
            // Plays previous song with a wave in pose
            [self prevButtonPressed:nil];
            break;
        case TLMPoseTypeWaveOut:
            // Plays next song with a wave out pose
            [self nextButtonPressed:nil];
            break;
        case TLMPoseTypeFingersSpread:
            // Plays or pauses the music with a fingers spread pose
            [self togglePlaying:nil];
            break;
    }
    
    // Unlock the Myo whenever we receive a pose
    if (pose.type == TLMPoseTypeUnknown || pose.type == TLMPoseTypeRest) {
        // Causes the Myo to lock after a short period.
        [pose.myo unlockWithType:TLMUnlockTypeTimed];
    } else {
        // Keeps the Myo unlocked until specified.
        // This is required to keep Myo unlocked while holding a pose, but if a pose is not being held, use
        // TLMUnlockTypeTimed to restart the timer.
        [pose.myo unlockWithType:TLMUnlockTypeHold];
        // Indicates that a user action has been performed.
        [pose.myo indicateUserAction];
    }

}

-(void)createConstraints{
    UIView *trackView = self.trackLabel;
    UIView *artistView = self.artistLabel;
    UIView *coverView = self.coverArt;
    UIView *playView = self.playButton;
    UIView *nextView = self.nextButton;
    UIView *prevView = self.prevButton;
    UIView *playbackView = self.trackSlider;
    UIView *volumeView = self.volumeSlider;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(trackView, artistView, coverView, playView, nextView, prevView, playbackView, volumeView, self.view);
    
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[coverView(<=200)]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views];
    
    constraints = [constraints arrayByAddingObject:[NSLayoutConstraint constraintWithItem:self.coverArt attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    constraints = [constraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-104-[coverView]-20-[trackView(20)]-10-[artistView(20)]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    
    constraints = [constraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[playbackView(20)]-20-[playView(50)]-15-[volumeView(20)]-40-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    
    constraints = [constraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[trackView]-50-|" options:0 metrics:nil views:views]];
    
    constraints = [constraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[artistView]-50-|" options:0 metrics:nil views:views]];
    
    constraints = [constraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[playbackView]-50-|" options:0 metrics:nil views:views]];
    
    constraints = [constraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[volumeView]-50-|" options:0 metrics:nil views:views]];
    
    constraints = [constraints arrayByAddingObject:[NSLayoutConstraint constraintWithItem:self.playButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.playButton attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    
    constraints = [constraints arrayByAddingObject:[NSLayoutConstraint constraintWithItem:self.coverArt attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.coverArt attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    
    constraints = [constraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[prevView(50)]-40-[playView]-40-[nextView(50)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
    
    constraints = [constraints arrayByAddingObject:[NSLayoutConstraint constraintWithItem:self.nextButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.playButton attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    
    constraints = [constraints arrayByAddingObject:[NSLayoutConstraint constraintWithItem:self.prevButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.playButton attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    
    [self.view addConstraints:constraints];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)connectMyo:(id)sender{
    UINavigationController *controller = [TLMSettingsViewController settingsInNavigationController];
    [self presentViewController:controller animated:YES completion:^{
        
    }];
}

-(void)setPlaylistWithPartialPlaylist:(SPTPartialPlaylist *)partialPlaylist{
    if(partialPlaylist){
        [SPTRequest requestItemAtURI:partialPlaylist.uri withSession:self.session callback:^(NSError *error, id object) {
            if([object isKindOfClass:[SPTPlaylistSnapshot class]]){
                self.currentPlaylist = (SPTPlaylistSnapshot *)object;
                NSLog(@"PLAYLIST SIZE: %lu", (unsigned long)self.currentPlaylist.trackCount);
                unsigned int i = 0;
                if(self.currentPlaylist.trackCount > 0){
                    for(SPTTrack *track in self.currentPlaylist.tracksForPlayback){
                        NSLog(@"GOT SONG:%u %@ ", i, track.name);
                        i++;
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
        SPTVolume volume = 0.5;
        [self.audioPlayer setVolume:volume callback:^(NSError *error) {
            
        }];
        //self.audioPlayer.diskCache = [[SPTDiskCache alloc] initWithCapacity:1024 * 1024 * 64];
    }
    
    [self.audioPlayer loginWithSession:auth.session callback:^(NSError *error) {
        
        if (error != nil) {
            NSLog(@"*** Enabling playback got error: %@", error);
            return;
        }
        
        //[self updateUI];
        [self.audioPlayer playURIs:self.trackURIs fromIndex:self.currentIndex callback:^(NSError *error) {
            if(error != nil){
                NSLog(@"ERROR");
                return;
            }
            self.currentTrack = [self.currentPlaylist.tracksForPlayback objectAtIndex:self.currentIndex];
            self.trackLabel.text = self.currentTrack.name;
            self.trackLabel.font = [UIFont fontWithName:@"AppleGothic" size:[UIFont systemFontSize]];
            SPTPartialArtist *artist = (SPTPartialArtist *)[self.currentTrack.artists objectAtIndex:self.currentIndex];
            self.artistLabel.text = artist.name;
            self.artistLabel.font = [UIFont fontWithName:@"AppleGothic" size:[UIFont systemFontSize]];
            
            [self.trackSlider setMaximumValue:self.audioPlayer.currentTrackDuration];
            [self.trackSlider setValue:self.audioPlayer.currentPlaybackPosition animated:YES];
            self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateSlider:) userInfo:nil repeats:YES];
            NSLog(@"TRACK DURATION: %f", self.audioPlayer.currentTrackDuration);
            
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
                });
            }
        }];
    }];
}

-(void)volumeChanged:(id)sender{
    SPTVolume volume = self.volumeSlider.value;
    [self.audioPlayer setVolume:volume callback:^(NSError *error) {
        
    }];
}

-(void)sliderActive:(id)sender{
    [self.audioPlayer seekToOffset:self.trackSlider.value callback:^(NSError *error) {
        NSLog(@"Changed to offset");
    }];
}

-(void)updateSlider:(id)sender{
    if(!self.trackSlider.isTracking){
        [self.trackSlider setValue:self.audioPlayer.currentPlaybackPosition animated:YES];
        [self.trackSlider setMaximumValue:self.audioPlayer.currentTrackDuration];
        //NSLog(@"updating slider value w/ value: %f and max: %f", self.audioPlayer.currentPlaybackPosition, self.audioPlayer.currentTrackDuration);
    }
}

-(void)togglePlaying:(id)sender{
    NSLog(@"Current playback: %f", self.audioPlayer.currentPlaybackPosition);
    if(self.audioPlayer.isPlaying){
        [self.audioPlayer setIsPlaying:NO callback:^(NSError *error) {
        }];
        [_playButton setImage:self.playImage forState:UIControlStateNormal];

    }else{
        [self.audioPlayer setIsPlaying:YES callback:^(NSError *error) {
        }];
        [_playButton setImage:self.pauseImage forState:UIControlStateNormal];
    }
}

-(void)nextButtonPressed:(id)sender{
    
    self.currentIndex++;
    self.currentIndex = self.currentIndex % self.trackURIs.count;
    
    SPTPlayOptions *playOptions = [SPTPlayOptions new];
    playOptions.startTime = 0;
    playOptions.trackIndex = self.currentIndex;
    [self.audioPlayer playURIs:self.trackURIs withOptions:playOptions callback:^(NSError *error) {
        if(error != nil){
            NSLog(@"ERROR: %@", error);
            abort();
        }
        [self.playButton setImage:self.pauseImage forState:UIControlStateNormal];
        self.currentTrack = [self.currentPlaylist.tracksForPlayback objectAtIndex:self.currentIndex];
        self.trackLabel.text = self.currentTrack.name;
        SPTPartialArtist *artist = (SPTPartialArtist *)[self.currentTrack.artists objectAtIndex:0];
        self.artistLabel.text = artist.name;
    }];
    
    NSLog(@"Skipped to next song");
}

-(void)prevButtonPressed:(id)sender{
    if(self.currentIndex == 0){
        self.currentIndex = self.trackURIs.count-1;
    }else{
        self.currentIndex--;
    }
    
    SPTPlayOptions *playOptions = [SPTPlayOptions new];
    playOptions.startTime = 0;
    playOptions.trackIndex = self.currentIndex;
    
    [self.audioPlayer playURIs:self.trackURIs withOptions:playOptions callback:^(NSError *error) {
        if(error != nil){
            NSLog(@"ERROR: %@", error);
            abort();
        }
        [self.playButton setImage:self.pauseImage forState:UIControlStateNormal];
        self.currentTrack = [self.currentPlaylist.tracksForPlayback objectAtIndex:self.currentIndex];
        self.trackLabel.text = self.currentTrack.name;
        SPTPartialArtist *artist = (SPTPartialArtist *)[self.currentTrack.artists objectAtIndex:0];
        self.artistLabel.text = artist.name;
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
    //SPTAuth *auth = [SPTAuth defaultInstance];
    
    NSLog(@"track changed = %@", [trackMetadata valueForKey:SPTAudioStreamingMetadataTrackURI]);
//    [SPTRequest requestItemAtURI:[trackMetadata valueForKey:SPTAudioStreamingMetadataTrackURI] withSession:auth.session callback:^(NSError *error, id object) {
//        SPTTrack
//    }];
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
