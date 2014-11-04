//
//  TimerCell.h
//  SmartSwitch
//
//  Created by sdzg on 14-8-13.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kTimerEffectiveChanged @"TimerEffectiveChanged"

@interface TimerCell : UITableViewCell
- (void)setCellInfo:(SDZGTimerTask *)task;
- (void)switchStateBackup;
@end
