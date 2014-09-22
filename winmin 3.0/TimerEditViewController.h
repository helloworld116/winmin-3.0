//
//  TimerEditViewController.h
//  SmartSwitch
//
//  Created by sdzg on 14-8-14.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimerModel.h"

#define kAddOrEditTimerNotification @"AddOrEditTimerNotification"
@interface TimerEditViewController : UIViewController

/**
 *  初始化参数设置
 *
 *  @param timers 定时列表集合
 *  @param timer  正在编辑的定时列表,nil表示执行添加操作
 *  @param index  正在编辑的定时列表在集合的索引，-1则表示执行添加操作
 */
//- (void)setParamSwitch:(SDZGSwitch *)aSwtich
//         socketGroupId:(int)socketGroupId
//            timerModel:(TimerModel *)model
//                timers:(NSMutableArray *)timers
//                 timer:(SDZGTimerTask *)timer
//                 index:(int)index;

- (void)setTimers:(NSMutableArray *)timers
            timer:(SDZGTimerTask *)timer
       timerModel:(TimerModel *)model
            index:(int)index;
@end
