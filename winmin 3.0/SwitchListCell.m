//
//  SwitchListCell.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-16.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SwitchListCell.h"
@interface SwitchListCell ()
@property (nonatomic, strong) UIImage *img_zx_lock;
@property (nonatomic, strong) UIImage *img_yc_lock;
@property (nonatomic, strong) UIImage *img_lx_lock;
@property (nonatomic, strong) UIImage *img_new_lock;
@property (nonatomic, strong) UIImage *img_zx;
@property (nonatomic, strong) UIImage *img_yc;
@property (nonatomic, strong) UIImage *img_lx;
@property (nonatomic, strong) UIImage *img_new;
@end

@implementation SwitchListCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    // Initialization code
  }
  return self;
}

- (void)awakeFromNib {
  // Initialization code
  self.img_zx_lock = [UIImage imageNamed:NSLocalizedString(@"zx_lock", nil)];
  self.img_yc_lock = [UIImage imageNamed:NSLocalizedString(@"yc_lock", nil)];
  self.img_lx_lock = [UIImage imageNamed:NSLocalizedString(@"lx_lock", nil)];
  self.img_new_lock = [UIImage imageNamed:NSLocalizedString(@"new_lock", nil)];
  self.img_zx = [UIImage imageNamed:NSLocalizedString(@"zx", nil)];
  self.img_yc = [UIImage imageNamed:NSLocalizedString(@"yc", nil)];
  self.img_lx = [UIImage imageNamed:NSLocalizedString(@"lx", nil)];
  self.img_new = [UIImage imageNamed:NSLocalizedString(@"new", nil)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

- (void)setCellInfo:(SDZGSwitch *)aSwitch {
  self.lblName.text = aSwitch.name;
  BOOL sMac =
      [[[NSUserDefaults standardUserDefaults] objectForKey:showMac] boolValue];
  if (sMac) {
    self.lblMac.text = aSwitch.mac;
  } else {
    self.lblMac.text = @"";
  }
  //  NSString *imageName;
  UIImage *imgState;
  if (aSwitch.lockStatus == LockStatusOn) {
    if (aSwitch.networkStatus == SWITCH_LOCAL) {
      //      imageName = NSLocalizedString(@"zx_lock", nil);
      imgState = self.img_zx_lock;
    } else if (aSwitch.networkStatus == SWITCH_REMOTE) {
      //      imageName = NSLocalizedString(@"yc_lock", nil);
      imgState = self.img_yc_lock;
    } else if (aSwitch.networkStatus == SWITCH_OFFLINE) {
      //      imageName = NSLocalizedString(@"lx_lock", nil);
      imgState = self.img_lx_lock;
    } else if (aSwitch.networkStatus == SWITCH_NEW) {
      //      imageName = NSLocalizedString(@"new_lock", nil);
      imgState = self.img_new_lock;
    }
  } else {
    if (aSwitch.networkStatus == SWITCH_LOCAL) {
      //      imageName = NSLocalizedString(@"zx", nil);
      imgState = self.img_zx;
    } else if (aSwitch.networkStatus == SWITCH_REMOTE) {
      //      imageName = NSLocalizedString(@"yc", nil);
      imgState = self.img_yc;
    } else if (aSwitch.networkStatus == SWITCH_OFFLINE) {
      //      imageName = NSLocalizedString(@"lx", nil);
      imgState = self.img_lx;
    } else if (aSwitch.networkStatus == SWITCH_NEW) {
      //      imageName = NSLocalizedString(@"new", nil);
      imgState = self.img_new;
    }
  }
  //  self.imgViewOfState.image = [UIImage imageNamed:imageName];
  self.imgViewOfState.image = imgState;
  SDZGSocket *socket1 = aSwitch.sockets[0];
  SDZGSocket *socket2 = aSwitch.sockets[1];
  //插孔均关闭或离线情况下
  if (aSwitch.networkStatus == SWITCH_OFFLINE ||
      (socket1.socketStatus == SocketStatusOff &&
       socket2.socketStatus == SocketStatusOff)) {
    self.imgViewOfSwitch.image =
        [SDZGSwitch imgNameToImageOffline:aSwitch.imageName];
  } else {
    self.imgViewOfSwitch.image = [SDZGSwitch imgNameToImage:aSwitch.imageName];
  }
}

@end
