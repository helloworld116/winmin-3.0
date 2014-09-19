//
//  SwitchDetailModel.h
//  winmin 3.0
//
//  Created by sdzg on 14-9-19.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SwitchDetailModel : NSObject
- (void)openOrCloseSwitch:(SDZGSwitch *)aSwitch groupId:(int)groupId;

/**
 *  开始扫描设备
 */
- (void)startScanSwitchState;
/**
 *  结束扫描设备
 */
- (void)stopScanSwitchState;
@end
