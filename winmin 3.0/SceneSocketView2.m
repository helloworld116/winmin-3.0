//
//  SceneSocketView2.m
//  winmin 3.0
//
//  Created by sdzg on 14-12-18.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SceneSocketView2.h"
#define kSelectColor kThemeColor
#define kUnselectColor [UIColor colorWithHexString:@"#F0EFEF"]

@implementation SceneSocketView2
- (void)awakeFromNib {
  self.lblStatus.layer.cornerRadius = 15.f;
  [self setSelected:NO onOff:NO];
}

- (void)setSelected:(BOOL)selected onOff:(BOOL)onOff {
  if (selected) {
    self.bgView.backgroundColor = kSelectColor;
  } else {
    self.bgView.backgroundColor = kUnselectColor;
  }
  if (onOff) {
    self.lblStatus.backgroundColor = kSelectColor;
    self.lblStatus.textColor = [UIColor whiteColor];
    self.lblStatus.text = NSLocalizedString(@"ON_Scene", nil);
  } else {
    //默认关闭
    self.lblStatus.backgroundColor = kUnselectColor;
    self.lblStatus.textColor = [UIColor colorWithHexString:@"#CCCCCC"];
    self.lblStatus.text = NSLocalizedString(@"OFF_Scene", nil);
  }
}

- (void)setSocketInfo:(SDZGSocket *)socket isOn:(BOOL)isOn {
  NSString *socket1ImageName = socket.imageNames[0];
  socket1ImageName = socket1ImageName.length < 10
                         ? [NSString stringWithFormat:@"%@_", socket1ImageName]
                         : socket1ImageName;
  NSString *socket2ImageName = socket.imageNames[1];
  socket2ImageName = socket2ImageName.length < 10
                         ? [NSString stringWithFormat:@"%@_", socket2ImageName]
                         : socket2ImageName;
  NSString *socket3ImageName = socket.imageNames[2];
  socket3ImageName = socket3ImageName.length < 10
                         ? [NSString stringWithFormat:@"%@_", socket3ImageName]
                         : socket3ImageName;
  self.imgGroup.image =
      [UIImage imageNamed:[NSString stringWithFormat:@"%d", socket.groupId]];
  self.imgViewSocket1.image =
      [SDZGSocket imgNameToImage:socket1ImageName status:socket.socketStatus];
  self.imgViewSocket2.image =
      [SDZGSocket imgNameToImage:socket2ImageName status:socket.socketStatus];
  self.imgViewSocket3.image =
      [SDZGSocket imgNameToImage:socket3ImageName status:socket.socketStatus];
  if (isOn) {
    [self setSelected:YES onOff:YES];
  } else {
    [self setSelected:NO onOff:NO];
  }
}

@end
