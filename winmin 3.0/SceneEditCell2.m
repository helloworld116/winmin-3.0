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
  self.btnSwitchName.backgroundColor = kThemeColor;
  self.btnSwitchName.layer.borderColor = [kThemeColor CGColor];
  self.btnSwitchName.layer.borderWidth = 1.f;
  self.btnSwitchName.layer.cornerRadius = 12.f;
  self.btnSwitchName.enabled = NO;

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

- (void)setSceneDetail:(SceneDetail *)detail {
  int groupId = detail.groupId;
  SDZGSwitch *aSwitch = detail.aSwitch;
  SDZGSocket *socket = aSwitch.sockets[groupId - 1];
  [self.btnTimeInterval
      setTitle:[NSString stringWithFormat:@"%.1fs", detail.interval]
      forState:UIControlStateNormal]; //默认1秒
  [self.sceneSocketView setSocketInfo:socket isOn:detail.onOrOff];
  [self.btnSwitchName setTitle:aSwitch.name forState:UIControlStateNormal];
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
