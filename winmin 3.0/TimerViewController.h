//
//  TimerViewController.h
//  SmartSwitch
//
//  Created by sdzg on 14-8-13.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimerViewController : UITableViewController
@property(nonatomic, strong) SDZGSwitch *aSwitch;
@property(nonatomic, assign) int socketGroupId;
@end
