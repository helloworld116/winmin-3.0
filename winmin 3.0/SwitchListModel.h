//
//  SwitchListModel.h
//  winmin 3.0
//
//  Created by sdzg on 14-9-17.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SwitchListModel : NSObject
/**
 *  开始扫描设备
 */
- (void)startScan;
/**
 *  结束扫描设备
 */
- (void)stopScan;

/**
 *  设备闪烁
 *
 *  @param aSwitch <#aSwitch description#>
 */
- (void)blinkSwitch:(SDZGSwitch *)aSwitch;
@end
