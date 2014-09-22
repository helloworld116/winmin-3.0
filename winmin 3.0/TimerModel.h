//
//  TimerModel.h
//  winmin 3.0
//
//  Created by sdzg on 14-9-22.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kTimerListChanged @"TimerListChanged"

@interface TimerModel : NSObject
- (id)initWithSwitch:(SDZGSwitch *)aSwitch socketGroupId:(int)groupId;

- (void)queryTimers;

- (void)updateTimers:(NSMutableArray *)timers;
@end
