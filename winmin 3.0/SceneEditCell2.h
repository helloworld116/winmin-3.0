//
//  SceneEditCell2.h
//  winmin 3.0
//
//  Created by sdzg on 14-12-18.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SceneSocketView2.h"
#import "SceneDetail.h"

@interface SceneEditCell2 : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *btnTimeInterval;
@property (weak, nonatomic) IBOutlet UIButton *btnSocketGroup;
@property (weak, nonatomic) IBOutlet UILabel *lblState;
@property (weak, nonatomic) IBOutlet UIImageView *imgVSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *imgVCicle;
@property (weak, nonatomic) IBOutlet UIView *viewLine1;
@property (weak, nonatomic) IBOutlet UIView *viewLine2;
@property (weak, nonatomic) IBOutlet UIView *viewLine3;
//@property (weak, nonatomic) IBOutlet UITextField *textFieldSwitchName;
//- (void)setSwitch:(SDZGSwitch *)aSwtich groupId:(int)groupId isOn:(BOOL)isOn;
- (void)setSceneDetail:(SceneDetail *)detail row:(NSInteger)row;
@end
