//
//  SwitchInfoModel.h
//  winmin 3.0
//
//  Created by sdzg on 14-9-22.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SwitchInfoModel : NSObject
- (id)initWithSwitch:(SDZGSwitch *)aSwitch;

- (void)changeSwitchLockStatus;

- (void)setSwitchName:(NSString *)name;
@end
