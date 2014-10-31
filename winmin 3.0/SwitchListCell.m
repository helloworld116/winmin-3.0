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
      imageName = NSLocalizedString(@"zx_lock", nil);
    } else if (aSwitch.networkStatus == SWITCH_REMOTE) {
      imageName = NSLocalizedString(@"yc_lock", nil);
    } else if (aSwitch.networkStatus == SWITCH_OFFLINE) {
      imageName = NSLocalizedString(@"lx_lock", nil);
    } else if (aSwitch.networkStatus == SWITCH_NEW) {
      imageName = NSLocalizedString(@"new_lock", nil);
    }
  } else {
    if (aSwitch.networkStatus == SWITCH_LOCAL) {
      imageName = NSLocalizedString(@"zx", nil);
    } else if (aSwitch.networkStatus == SWITCH_REMOTE) {
      imageName = NSLocalizedString(@"yc", nil);
    } else if (aSwitch.networkStatus == SWITCH_OFFLINE) {
      imageName = NSLocalizedString(@"lx", nil);
    } else if (aSwitch.networkStatus == SWITCH_NEW) {
      imageName = NSLocalizedString(@"new", nil);
    }
  }
  self.imgViewOfState.image = [UIImage imageNamed:imageName];
  if (aSwitch.networkStatus == SWITCH_OFFLINE) {
    self.imgViewOfSwitch.image =
        [SDZGSwitch imgNameToImageOffline:aSwitch.imageName];
  } else {
    self.imgViewOfSwitch.image = [SDZGSwitch imgNameToImage:aSwitch.imageName];
  }
}

@end
