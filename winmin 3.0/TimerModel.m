//
//  TimerModel.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-22.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "TimerModel.h"

@interface TimerModel () <UdpRequestDelegate>
@property (nonatomic, strong) NSMutableArray *timers;
@property (nonatomic, strong) SDZGSwitch *aSwitch;
@property (nonatomic, assign) int groupId;
@property (nonatomic, assign) int type;
@property (atomic, assign) int responseData1EOr20Count;
@property (nonatomic, strong) UdpRequest *request;
@end

@implementation TimerModel
- (id)initWithSwitch:(SDZGSwitch *)aSwitch socketGroupId:(int)groupId {
  self = [super init];
  if (self) {
    self.aSwitch = aSwitch;
    self.groupId = groupId;
    self.timers = [@[] mutableCopy];
    self.request = [UdpRequest manager];
    self.request.delegate = self;
  }
  return self;
}

- (void)queryTimers {
  dispatch_async(GLOBAL_QUEUE, ^{ [self sendMsg17Or19]; });
}

- (void)updateTimers:(NSMutableArray *)timers type:(int)type {
  self.timers = timers;
  self.type = type;
  dispatch_async(GLOBAL_QUEUE, ^{ [self sendMsg1DOr1F]; });
}

#pragma mark - 定时列表查询请求
- (void)sendMsg17Or19 {
  [self.request sendMsg17Or19:self.aSwitch
                socketGroupId:self.groupId
                     sendMode:ActiveMode];
}

- (void)sendMsg1DOr1F {
  self.responseData1EOr20Count = 0;
  [self.request sendMsg1DOr1F:self.aSwitch
                socketGroupId:self.groupId
                     timeList:self.timers
                     sendMode:ActiveMode];
}

#pragma mark - UdpRequest代理
- (void)udpRequest:(UdpRequest *)request
     didReceiveMsg:(CC3xMessage *)message
           address:(NSData *)address {
  switch (message.msgId) {
    //查询定时
    case 0x18:
    case 0x1a:
      [self responseMsg18Or1A:message];
      break;
    //设置定时
    case 0x1e:
    case 0x20:
      [self responseMsg1EOr20:message];
      break;
    default:
      break;
  }
}

- (void)noResponseMsgtag:(long)tag socketGroupId:(int)socketGroupId {
  debugLog(@"tag is %ld and socketGroupId is %d", tag, socketGroupId);
  NSDictionary *userInfo = @{
    @"tag" : @(tag),
    @"socketGroupId" : @(socketGroupId)
  };
  [[NSNotificationCenter defaultCenter]
      postNotificationName:kNoResponseNotification
                    object:self
                  userInfo:userInfo];
}

- (void)responseMsg18Or1A:(CC3xMessage *)message {
  if (message.timerTaskList) {
    [self.timers removeAllObjects];
    [self.timers addObjectsFromArray:message.timerTaskList];
    NSDictionary *userInfo = @{ @"timers" : self.timers };
    [[NSNotificationCenter defaultCenter] postNotificationName:kTimerListChanged
                                                        object:self
                                                      userInfo:userInfo];
  }
}

- (void)responseMsg1EOr20:(CC3xMessage *)message {
  if (message.state == kUdpResponseSuccessCode) {
    self.responseData1EOr20Count++;
    if (self.responseData1EOr20Count == 1) {
      switch (self.type) {
        case 1:
          [[NSNotificationCenter defaultCenter]
              postNotificationName:kTimerAddNotification
                            object:nil
                          userInfo:nil];
          break;
        case 2:
          [[NSNotificationCenter defaultCenter]
              postNotificationName:kTimerUpdateNotification
                            object:nil
                          userInfo:nil];
          break;
        case 3:
          [[NSNotificationCenter defaultCenter]
              postNotificationName:kTimerDeleteNotification
                            object:nil
                          userInfo:nil];
          break;
        case 4:
          [[NSNotificationCenter defaultCenter]
              postNotificationName:kTimerEffectiveChangedNotifcation
                            object:nil
                          userInfo:nil];
          break;
        default:
          break;
      }
    }
  }
}

@end
