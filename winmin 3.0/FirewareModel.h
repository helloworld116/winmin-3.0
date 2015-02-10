//
//  FirewareModel.h
//  winmin 3.0
//
//  Created by sdzg on 15-1-27.
//  Copyright (c) 2015年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^GetSwitchFirewareInfoBlock)(NSString *firewareVersion,
                                           NSString *deviceType);
typedef void (^UpdateFirewareProgressBlock)(BOOL needContinue, BOOL success,
                                            NSString *msg);

@interface FirewareModel : NSObject
- (id)initWithSwitch:(SDZGSwitch *)aSwitch;
- (void)getSwitchFirewareInfo:(GetSwitchFirewareInfoBlock)block;
- (void)getFirewareInfoWithType:(NSString *)deviceType
                     completion:(GetSwitchFirewareInfoBlock)block;
- (void)checkFirewareWithDeviceType:(NSString *)deviceType
                         completion:(UpdateFirewareProgressBlock)block;
@end
