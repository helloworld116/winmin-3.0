//
//  SceneEditCell2.m
//  winmin 3.0
//
//  Created by sdzg on 14-12-18.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SceneEditCell2.h"

@implementation SceneEditCell2

- (void)awakeFromNib {
  // Initialization code
  //  self.btnSwitchName.backgroundColor = kThemeColor;
  //  self.btnSwitchName.layer.borderColor = [kThemeColor CGColor];
  //  self.btnSwitchName.layer.borderWidth = 1.f;
  //  self.btnSwitchName.layer.cornerRadius = 12.f;
  //  self.btnSwitchName.enabled = NO;
  //
  self.btnTimeInterval.backgroundColor = [UIColor whiteColor];
  self.btnTimeInterval.layer.borderColor = [kThemeColor CGColor];
  self.btnTimeInterval.layer.borderWidth = 1.f;
  self.btnTimeInterval.layer.cornerRadius = 12.f;
  [self.btnTimeInterval addTarget:self
                           action:@selector(touchTimeInterval:)
                 forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

- (void)setSceneDetail:(SceneDetail *)detail row:(NSInteger)row {
  int groupId = detail.groupId;
  SDZGSwitch *aSwitch = detail.aSwitch;
  NSString *switchName = aSwitch.name;
  NSString *socketState = detail.onOrOff ? @"开" : @"关";
  [self.btnTimeInterval
      setTitle:[NSString stringWithFormat:@"%.1fs", detail.interval]
      forState:UIControlStateNormal]; //默认1秒
  NSString *group;
  if ([aSwitch.deviceType isEqualToString:kDeviceType_Snake]) {
    group = @"";
  } else {
    SDZGSocket *socket = aSwitch.sockets[groupId - 1];
    if (socket.groupId == 1) {
      group = @"I";
    } else {
      group = @"II";
    }
  }
  if (detail.onOrOff) {
    self.imgVCicle.image = [UIImage imageNamed:@"scene_cicle_on"];
    self.viewLine1.backgroundColor = kThemeColor;
    self.viewLine2.backgroundColor = kThemeColor;
    self.viewLine3.backgroundColor = kThemeColor;
    if ([aSwitch.deviceType isEqualToString:kDeviceType_Snake]) {
      self.imgVSwitch.image =
          [SDZGSwitch imgNameToImageSnake:aSwitch.imageName];
    } else {
      self.imgVSwitch.image = [SDZGSwitch imgNameToImage:aSwitch.imageName];
    }
  } else {
    self.imgVCicle.image = [UIImage imageNamed:@"scene_cicle_off"];
    self.viewLine1.backgroundColor = [UIColor colorWithWhite:0.746 alpha:1.000];
    self.viewLine2.backgroundColor = [UIColor colorWithWhite:0.746 alpha:1.000];
    self.viewLine3.backgroundColor = [UIColor colorWithWhite:0.746 alpha:1.000];
    if ([aSwitch.deviceType isEqualToString:kDeviceType_Snake]) {
      self.imgVSwitch.image =
          [SDZGSwitch imgNameToImageOfflineSnake:aSwitch.imageName];
    } else {
      self.imgVSwitch.image =
          [SDZGSwitch imgNameToImageOffline:aSwitch.imageName];
    }
  }
  NSString *imgSocketGroup;
  NSString *info;
  if (row % 2 == 0) {
    info =
        [NSString stringWithFormat:@"%@ %@ %@", switchName, group, socketState];
    if (detail.onOrOff) {
      imgSocketGroup = @"scene_arrow_on_right";
    } else {
      imgSocketGroup = @"scene_arrow_off_right";
    }
  } else {
    info =
        [NSString stringWithFormat:@"%@ %@ %@", socketState, switchName, group];
    if (detail.onOrOff) {
      imgSocketGroup = @"scene_arrow_on_left";
    } else {
      imgSocketGroup = @"scene_arrow_off_left";
    }
  }
  self.lblState.text = info;
  [self.btnSocketGroup setBackgroundImage:[UIImage imageNamed:imgSocketGroup]
                                 forState:UIControlStateNormal];
  //  [self.sceneSocketView setSocketInfo:socket isOn:detail.onOrOff];
  //  [self.btnSwitchName setTitle:aSwitch.name forState:UIControlStateNormal];
}

- (void)setSwitchInfo:(SDZGSwitch *)aSwitch row:(NSInteger)row {
  //  [self.sceneSocketView1 setSelected:NO onOff:NO];
  //  [self.sceneSocketView2 setSelected:NO onOff:NO];
  //  if (row == 0) {
  //    self.topLineView.hidden = YES;
  //  } else {
  //    self.topLineView.hidden = NO;
  //  }
  //  self.textFieldSwitchName.text = aSwitch.name;
  //  NSArray *sceneDetails = [[DBUtil sharedInstance] allSceneDetailsTmp];
  //  [self.sceneSocketView1 setSocketInfo:aSwitch.sockets[0]
  //                                   mac:aSwitch.mac
  //                          sceneDetails:sceneDetails];
  //  [self.sceneSocketView2 setSocketInfo:aSwitch.sockets[1]
  //                                   mac:aSwitch.mac
  //                          sceneDetails:sceneDetails];
}

- (void)touchTimeInterval:(id)sender {
}
@end
