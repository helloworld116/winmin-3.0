//
//  AppDelegate.h
//  winmin 3.0
//
//  Created by sdzg on 14-9-15.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder<UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIWindow *userWindow;
@property (nonatomic, assign) NetworkStatus networkStatus;
@property (nonatomic, strong) SwitchDataCeneter *switchDataCeneter;
@property (nonatomic, strong) NSString *currnetLanguage;
//服务器最新固件版本信息{@"T1501":@".....",@"T1502",@"...."}
@property (nonatomic, strong) NSMutableDictionary *dictOfFireware;
@end
