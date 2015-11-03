//
//  PlayCenter.m
//  AudioDemo
//
//  Created by 1 on 15/5/14.
//  Copyright (c) 2015年 Lee. All rights reserved.
//

#import "PlayCenter.h"

@implementation PlayCenter
static PlayCenter *center = nil;
+ (PlayCenter *)shareCenter
{
    if (!center) {
        center = [PlayCenter new];
    }
    return center;
    
}
- (id)init{
    if (self = [super init]) {
        //后台播放音频设置
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        [session setActive:YES error:nil];
        
        //让app支持接受远程控制事件
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        
    }
    return self;
}


- (NSDictionary *)play:(NSURL *)url{
    if (self.player) {
        [self.player stop];
        self.player = nil;
    }
    UIBackgroundTaskIdentifier bgTask = 0;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    if([UIApplication sharedApplication].applicationState== UIApplicationStateBackground) {
        
        NSLog(@"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx后台播放");
        
        [_player play];
        
        UIApplication *app = [UIApplication sharedApplication];
        UIBackgroundTaskIdentifier newTask = [app beginBackgroundTaskWithExpirationHandler:nil];
        
        if(bgTask!= UIBackgroundTaskInvalid) {
            
            [app endBackgroundTask: bgTask];
            
        }
        bgTask = newTask;
        
    }else{
        
        NSLog(@"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx前台播放");
        
        [_player prepareToPlay];
        [_player setVolume:1];
        _player.numberOfLoops = 1; //设置音乐播放次数  -1为一直循环
        [_player play]; //播放
        
    }
    
    
    NSDictionary *dict = [self getPlayInfo:url];
    if (dict) {
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
    }
    self.info = dict;
    return dict;
    
}
- (NSDictionary *)getPlayInfo:(NSURL *)fileURL
{

    //    AudioFileTypeID fileTypeHint = kAudioFileMP3Type;
    NSString *fileExtension = [[fileURL path] pathExtension];
    if (![fileExtension isEqual:@"mp3"] && ![fileExtension isEqual:@"m4a"])
    {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict setObject:@"未知标题" forKey:MPMediaItemPropertyAlbumTitle];
        [dict setObject:@"未知歌手" forKey:MPMediaItemPropertyArtist];
        
        return dict;
    }

    AudioFileID fileID  = nil;
    OSStatus err        = noErr;
    
    err = AudioFileOpenURL( (__bridge CFURLRef) fileURL, kAudioFileReadPermission, 0, &fileID );
    if( err != noErr ) {
        NSLog( @"AudioFileOpenURL failed" );
    }
    UInt32 id3DataSize  = 0;
    err = AudioFileGetPropertyInfo( fileID,   kAudioFilePropertyID3Tag, &id3DataSize, NULL );
    
    if( err != noErr ) {
        NSLog( @"AudioFileGetPropertyInfo failed for ID3 tag" );
    }
    NSDictionary *piDict = nil;
    UInt32 piDataSize   = sizeof( piDict );
    err = AudioFileGetProperty( fileID, kAudioFilePropertyInfoDictionary, &piDataSize, &piDict );
    if( err != noErr ) {
        NSLog( @"AudioFileGetProperty failed for property info dictionary" );
    }
    CFDataRef AlbumPic= nil;
    UInt32 picDataSize = sizeof(picDataSize);
    err =AudioFileGetProperty( fileID,   kAudioFilePropertyAlbumArtwork, &picDataSize, &AlbumPic);
    if( err != noErr ) {
        NSLog( @"Get picture failed" );
    }
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    NSString * Album = [(NSDictionary*)piDict objectForKey:
                        [NSString stringWithUTF8String: kAFInfoDictionary_Album]];
    NSString * Artist = [(NSDictionary*)piDict objectForKey:
                         [NSString stringWithUTF8String: kAFInfoDictionary_Artist]];
    NSString * Title = [(NSDictionary*)piDict objectForKey:
                        [NSString stringWithUTF8String: kAFInfoDictionary_Title]];
    [dict setObject:Title forKey:MPMediaItemPropertyAlbumTitle];
    [dict setObject:Artist forKey:MPMediaItemPropertyArtist];
    [dict setObject:Album forKey:MPMediaItemPropertyTitle];

    AVURLAsset *avURLAsset = [AVURLAsset URLAssetWithURL:fileURL
                                                 options:nil];
    for (NSString *format in [avURLAsset availableMetadataFormats]) {
        for (AVMetadataItem *metadataItem in [avURLAsset metadataForFormat:format]) {
            if ([metadataItem.commonKey isEqualToString:@"artwork"]) {
                //取出封面artwork，从data转成image显示
                NSObject *value = metadataItem.value;
                NSData *data = nil;
                if ([value isKindOfClass:[NSData class]]) {
                    data = (NSData *)value;
                }else{
                    data = [((NSDictionary *)value) objectForKey:@"data"];
                
                }
                MPMediaItemArtwork *mArt = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageWithData:data]];
                [dict setObject:mArt
                         forKey:MPMediaItemPropertyArtwork];
                break;
            }
        }
    }

    return dict;

}

- (void)forwardItem
{
    NSString *lastPath = [[self.player.url path] lastPathComponent];
    int index = [lastPath.stringByDeletingPathExtension integerValue];
    index--;
    if (index < 1) {
        index = 3;
    }
    NSString *path = [NSString stringWithFormat:@"%d",index];
    
    path = [[NSBundle mainBundle] pathForResource:path ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:path];
    [self play:url];
    
}
- (void)nextItem
{

    NSString *lastPath = [[self.player.url path] lastPathComponent];
    int index = [lastPath.stringByDeletingPathExtension integerValue];
    index++;
    if (index > 3) {
        index = 1;
    }
    NSString *path = [NSString stringWithFormat:@"%d",index];
    
    path = [[NSBundle mainBundle] pathForResource:path ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:path];
    [self play:url];
}
- (void)play
{
    [self.player play];
}
- (void)pause
{
    [self.player pause];
}

@end
