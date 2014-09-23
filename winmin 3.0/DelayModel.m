//
//  DelayModel.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-23.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "DelayModel.h"
@interface DelayModel ()<UdpRequestDelegate>
@property(nonatomic, strong) SDZGSwitch *aSwitch;
@property(nonatomic, strong) UdpRequest *request;
@property(nonatomic, assign) int groupId;
@end

@implementation DelayModel
- (id)initWithSwitch:(SDZGSwitch *)aSwitch socketGroupId:(int)groupId {
  self = [super init];
  if (self) {
    self.aSwitch = aSwitch;
    self.groupId = groupId;
    self.request = [UdpRequest manager];
    self.request.delegate = self;
  }
  return self;
}

- (void)queryDelay {
  dispatch_async(GLOBAL_QUEUE, ^{ [self sendMsg53Or55]; });
}

- (void)setDelayWithMinitues:(int)minitues onOrOff:(BOOL)onOrOff {
  dispatch_async(GLOBAL_QUEUE, ^{
      [self sendMsg4DOr4FWithMinitues:minitues onOrOff:onOrOff];
  });
}

- (void)sendMsg53Or55 {
  [self.request sendMsg53Or55:self.aSwitch
                socketGroupId:self.groupId
                     sendMode:ActiveMode];
}

- (void)sendMsg4DOr4FWithMinitues:(int)minitues onOrOff:(BOOL)onOrOff {
  [self.request sendMsg4DOr4F:self.aSwitch
                socketGroupId:self.groupId
                    delayTime:minitues
                     switchOn:onOrOff
                     sendMode:ActiveMode];
}

#pragma mark - UdpRequest代理
- (void)responseMsg:(CC3xMessage *)message address:(NSData *)address {
  switch (message.msgId) {
    //设置延时
    case 0x4e:
    case 0x50:
      [self responseMsg4EOr50:message];
      break;
    //查询延时
    case 0x54:
    case 0x56:
      [self responseMsg54Or56:message];
      break;

    default:
      break;
  }
}

- (void)responseMsg4EOr50:(CC3xMessage *)message {
  if (message.state == 0) {
  }
}

- (void)responseMsg54Or56:(CC3xMessage *)message {
  if (message.delay > 0) {
    NSDictionary *userInfo = @{ @"delay" : @(message.delay) };
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kDelayQueryNotification
                      object:self
                    userInfo:userInfo];
  }
}

@end
