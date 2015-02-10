//
//  SwitchListCell.h
//  winmin 3.0
//
//  Created by sdzg on 14-9-16.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RealTimePowerView.h"

@interface SwitchListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgViewOfSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewOfState;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblMac;
@property (weak, nonatomic) IBOutlet RealTimePowerView *realTimeView;
@property (weak, nonatomic) IBOutlet UIImageView *imgVNewFireware;
@property (weak, nonatomic) IBOutlet UIImageView *imgVRestartWarn;
- (void)setCellInfo:(SDZGSwitch *)aSwitch;
@end
