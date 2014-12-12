//
//  DelayModel.h
//  winmin 3.0
//
//  Created by sdzg on 14-9-23.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^QueryBlock)(int delaySeconds, SocketStatus status);
typedef void (^SettingBlock)(BOOL result);

@interface DelayModel : NSObject
- (id)initWithSwitch:(SDZGSwitch *)aSwitch socketGroupId:(int)groupId;

- (void)queryDelay:(QueryBlock)queryResult
    notReceiveData:(NotReceiveDataBlock)notReceiveData;

- (void)setDelayWithMinitues:(int)minitues
                     onOrOff:(BOOL)onOrOff
                  completion:(SettingBlock)result
              notReceiveData:(NotReceiveDataBlock)notReceiveData;
;
@end
