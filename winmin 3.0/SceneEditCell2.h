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
@property (weak, nonatomic) IBOutlet SceneSocketView2 *sceneSocketView;
@property (weak, nonatomic) IBOutlet UIButton *btnTimeInterval;
@property (weak, nonatomic) IBOutlet UIButton *btnSwitchName;
@property (weak, nonatomic) IBOutlet UIButton *btnSocketGroup;
//@property (weak, nonatomic) IBOutlet UITextField *textFieldSwitchName;
//- (void)setSwitch:(SDZGSwitch *)aSwtich groupId:(int)groupId isOn:(BOOL)isOn;
- (void)setSceneDetail:(SceneDetail *)detail;
@end
