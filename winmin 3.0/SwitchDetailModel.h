//
//  SwitchDetailModel.h
//  winmin 3.0
//
//  Created by sdzg on 14-9-19.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HistoryElec.h"

@interface SwitchDetailModel : NSObject
- (id)initWithSwitch:(SDZGSwitch *)aSwitch;

- (void)openOrCloseSwitch:(SDZGSwitch *)aSwitch groupId:(int)groupId;

/**
 *  开始扫描设备
 */
- (void)startScanSwitchState;
/**
 *  结束扫描设备
 */
- (void)stopScanSwitchState;

/**
 *  开始扫描实时电量
 */
- (void)startRealTimeElec;

/**
 *  停止扫描实时电量
 */
- (void)stopRealTimeElec;

/**
 *  历史电量
 *
 *  @param param
 */
- (void)historyElec:(HistoryElecDateType)dateType;

@end
