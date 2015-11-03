//
//  PlayCenter.h
//  AudioDemo
//
//  Created by 1 on 15/5/14.
//  Copyright (c) 2015年 Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioToolbox.h>

@interface PlayCenter : NSObject
@property (nonatomic,strong) AVAudioPlayer *player;
@property (nonatomic,strong) NSDictionary *info;

+ (PlayCenter *)shareCenter;
- (NSDictionary *)play:(NSURL *)url;
- (void)play;
- (void)pause;
- (void)forwardItem;
- (void)nextItem;
@end
