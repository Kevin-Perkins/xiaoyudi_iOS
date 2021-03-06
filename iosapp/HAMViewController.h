//
//  HAMViewController.h
//  iosapp
//
//  Created by daiyue on 13-7-9.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "HAMGridViewTool.h"
#import "HAMConfig.h"
#import "HAMUserManager.h"
#import "HAMAnimation.h"

@interface HAMViewController : UIViewController <AVAudioPlayerDelegate,HAMGifAnimationDelegate>
{
    NSString* activeUsername;
    
    AVAudioPlayer *audioPlayer;
    
    HAMGridViewTool* gridViewTool;
    HAMGridViewTool* inCatGridViewTool;
    HAMConfig* config;
    HAMUserManager* userManager;
    
    NSString* currentUUID;
}

@property (weak, nonatomic) IBOutlet UIImageView *pressHintImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *pressHintImageView2;
@property (weak, nonatomic) IBOutlet UIImageView *pressHintImageView3;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView_;

@property (weak, nonatomic) IBOutlet UIView *inCatView;
@property (weak, nonatomic) IBOutlet UIImageView *blurBgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *inCatBgImageView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIScrollView *inCatScrollView;

- (IBAction)backButtonClicked:(UIButton *)sender;

- (IBAction)touchDownEnterEditButton:(UIButton *)sender;
- (IBAction)touchUpEnterEditButton:(UIButton *)sender;

@end
