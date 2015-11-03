//
//  ViewController.m
//  AudioDemo
//
//  Created by 1 on 15/5/14.
//  Copyright (c) 2015年 Lee. All rights reserved.
//

#import "ViewController.h"
#import "PlayCenter.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    PlayCenter *center = [PlayCenter shareCenter];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"3" ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    NSDictionary *dict = [center play:url];

    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, 180.0f, 280.0f, 280.0f)];
    MPMediaItemArtwork *work = dict[MPMediaItemPropertyArtwork];
    _imageView.image = [work imageWithSize:_imageView.frame.size];
    
    [self.view addSubview:_imageView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0f, 120.0f, 80.0f, 40.0f);
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"Next" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 20.0f, 320.0f, 88.0f)];
    _label.textColor = [UIColor blackColor];
    _label.numberOfLines = 0;
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = [NSString stringWithFormat:@"%@ \n%@ - %@",dict[MPMediaItemPropertyTitle],dict[MPMediaItemPropertyAlbumTitle],dict[MPMediaItemPropertyArtist]];
    [self.view addSubview:_label];

    [center addObserver:self forKeyPath:@"info" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)buttonTouch:(UIButton *)sender{
    [[PlayCenter shareCenter] nextItem];


}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSDictionary *dict = [PlayCenter shareCenter].info;

    MPMediaItemArtwork *work = dict[MPMediaItemPropertyArtwork];
    _imageView.image = [work imageWithSize:_imageView.frame.size];
    _label.text = [NSString stringWithFormat:@"%@ \n%@ - %@",dict[MPMediaItemPropertyTitle],dict[MPMediaItemPropertyAlbumTitle],dict[MPMediaItemPropertyArtist]];

}
- (void)dealloc{

    
    [[PlayCenter shareCenter] removeObserver:self forKeyPath:@"info"];
}
@end
