//
//  ShakeWindow.h
//  winmin 3.0
//
//  Created by sdzg on 15-1-4.
//  Copyright (c) 2015年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShakeWindow : UIWindow
//用于全局摇一摇
@property (nonatomic, strong) UdpRequest *request;
@property (nonatomic, strong) SDZGSwitch *aSwitch;
@property (nonatomic, assign) int groupId;
@end
