//
//  HAMEditCatPopoverViewController.h
//  iosapp
//
//  Created by Dai Yue on 13-12-11.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMStructureEditViewController.h"

@interface HAMEditCatPopoverViewController : UIViewController<HAMCategoryEditorViewControllerDelegate>
{}

@property HAMStructureEditViewController* mainSettingsViewController_;
@property HAMConfig* config_;
@property NSString* parentID_;
@property int childIndex_;
@property UIPopoverController* popover;
@property (weak, nonatomic) IBOutlet UIButton *editInLibButton;

- (IBAction)editInLibClicked:(UIButton *)sender;
- (IBAction)removeCatClicked:(UIButton *)sender;
- (IBAction)cancelClicked:(UIButton *)sender;

@end
