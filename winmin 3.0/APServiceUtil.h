//
//  APServiceUtil.h
//  winmin 3.0
//
//  Created by sdzg on 14-11-21.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^finishCallbackBlock)(BOOL);
@interface APServiceUtil : NSObject
+ (void)closeRemoteNotification:(finishCallbackBlock)block;
+ (void)openRemoteNotification:(finishCallbackBlock)block;
+ (void)removeSwitchRemoteNotification:(SDZGSwitch *)aSwitch
                           finishBlock:(finishCallbackBlock)block;
@end
