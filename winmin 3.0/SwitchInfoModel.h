//
//  SwitchInfoModel.h
//  winmin 3.0
//
//  Created by sdzg on 14-9-22.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString *const kGetElecPowerInfoSuccess;
extern NSString *const kSetElecPowerInfoSuccess;
typedef void (^CompetionBlock)(void);

@interface SwitchInfoModel : NSObject
- (id)initWithSwitch:(SDZGSwitch *)aSwitch;

- (void)changeSwitchLockStatus;

- (void)setSwitchName:(NSString *)name;

- (void)getElecPowerInfo;

- (void)setElecInfoWithAlertUnder:(short)alertUnder
                     isAlertUnder:(BOOL)isAlertUnder
                     alertGreater:(short)alertGreater
                   isAlertGreater:(BOOL)isAlertGreater
                     turnOffUnder:(short)turnOffUnder
                   isTurnOffUnder:(BOOL)isTurnOffUnder
                   turnOffGreater:(short)turnOffGreater
                 isTurnOffGreater:(BOOL)isTurnOffGreater;

- (void)getSwitchsFireware:(CompetionBlock)block;
@end
