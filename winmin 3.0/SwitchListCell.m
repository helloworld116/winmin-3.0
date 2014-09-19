//
//  SwitchListCell.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-16.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SwitchListCell.h"

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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

- (void)setCellInfo:(SDZGSwitch *)aSwitch {
  self.lblName.text = aSwitch.name;
  self.lblMac.text = aSwitch.mac;
  NSString *imageName;
  if (aSwitch.lockStatus == LockStatusOn) {
    if (aSwitch.networkStatus == SWITCH_LOCAL) {
      imageName = @"zx_lock";
    } else if (aSwitch.networkStatus == SWITCH_REMOTE) {
      imageName = @"yc_lock";
    } else if (aSwitch.networkStatus == SWITCH_OFFLINE) {
      imageName = @"lx_lock";
    } else if (aSwitch.networkStatus == SWITCH_NEW) {
      imageName = @"new_lock";
    }
  } else {
    if (aSwitch.networkStatus == SWITCH_LOCAL) {
      imageName = @"zx";
    } else if (aSwitch.networkStatus == SWITCH_REMOTE) {
      imageName = @"yc";
    } else if (aSwitch.networkStatus == SWITCH_OFFLINE) {
      imageName = @"lx";
    } else if (aSwitch.networkStatus == SWITCH_NEW) {
      imageName = @"new";
    }
  }
  self.imgViewOfState.image = [UIImage imageNamed:imageName];
  self.imgViewOfSwitch.image = [UIImage imageNamed:@"switch_default_online"];
}

@end
