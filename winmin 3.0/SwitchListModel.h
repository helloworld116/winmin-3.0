//
//  SwitchListModel.h
//  winmin 3.0
//
//  Created by sdzg on 14-9-17.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>
//-1表示设备离线，其他表示设备状态
typedef void (^ScaneOneSwitchCompleteBlock)(int);

@interface SwitchListModel : NSObject
/**
 *  指示当前是否正在扫描设备状态
 */
@property (nonatomic, assign, readonly) BOOL isScanningState;
/**
 *  开始扫描设备状态
 */
- (void)startScanState;
/**
 *  结束扫描设备状态
 */
- (void)stopScanState;
/**
 *  暂停状态扫描
 */
- (void)pauseScanState;
/**
 *  恢复状态扫描
 */
- (void)resumeScanState;

/**
 *  添加设备，扫描局域网内
 */
- (void)refreshSwitchList;

/**
 *  设备闪烁
 *
 *  @param aSwitch
 */
- (void)blinkSwitch:(SDZGSwitch *)aSwitch;

/**
 *  删除switch
 *
 *  @param aSwitch
 */
- (void)deleteSwitch:(SDZGSwitch *)aSwitch;

/**
 *  配置时根据mac地址添加指定设备
 *
 *  @param mac
 */
- (void)addSwitchWithMac:(NSString *)mac;

/**
 *  扫描一个设备当前状态信息
 *
 *  @param aSwitch
 */
- (void)scanSwitchState:(SDZGSwitch *)aSwitch
               complete:(ScaneOneSwitchCompleteBlock)complete;
@end
