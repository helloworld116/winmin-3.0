//
//  SwitchDetailModel.h
//  winmin 3.0
//
//  Created by sdzg on 14-9-19.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HistoryElec.h"

typedef void (^SwitchStateChangeBlock)(int);
@interface SwitchDetailModel : NSObject
@property (nonatomic, assign, readonly) BOOL isScanning;
- (id)initWithSwitch:(SDZGSwitch *)aSwitch
    switchStateChangeBlock:(SwitchStateChangeBlock)block;

- (void)openOrCloseWithGroupId:(int)groupId;

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
