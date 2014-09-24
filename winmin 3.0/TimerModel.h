//
//  TimerModel.h
//  winmin 3.0
//
//  Created by sdzg on 14-9-22.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimerModel : NSObject
- (id)initWithSwitch:(SDZGSwitch *)aSwitch socketGroupId:(int)groupId;

- (void)queryTimers;

/**
 *  <#Description#>
 *
 *  @param timers <#timers description#>
 *  @param type   1表示添加，2表示修改，3表示删除,4表示生效修改
 */
- (void)updateTimers:(NSMutableArray *)timers type:(int)type;
@end
