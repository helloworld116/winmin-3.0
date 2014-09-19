//
//  SwitchDetailModel.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-19.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SwitchDetailModel.h"
@interface SwitchDetailModel ()<UdpRequestDelegate>
@property(strong, nonatomic) NSTimer *timer;
@property(nonatomic, strong) UdpRequest *request11Or13;
@property(nonatomic, strong) UdpRequest *request0BOr0D;

@property(nonatomic, strong) SDZGSwitch *aSwitch;
@end

@implementation SwitchDetailModel
- (void)openOrCloseSwitch:(SDZGSwitch *)aSwitch groupId:(int)groupId {
  dispatch_async(GLOBAL_QUEUE, ^{
      self.aSwitch = aSwitch;
      [self sendMsg11Or13:aSwitch groupId:groupId];
  });
}

- (void)startScanSwitchState {
  self.timer = [NSTimer timerWithTimeInterval:REFRESH_DEV_TIME
                                       target:self
                                     selector:@selector(querySwitchState:)
                                     userInfo:nil
                                      repeats:YES];
  [self.timer fire];
  [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopScanSwitchState {
  if (self.timer) {
    [self.timer invalidate];
    self.timer = nil;
  }
}

- (void)querySwitchState:(SDZGSwitch *)aSwitch {
  dispatch_async(GLOBAL_QUEUE, ^{ [self sendMsg0BOr0D:aSwitch]; });
}

- (void)sendMsg11Or13:(SDZGSwitch *)aSwitch groupId:(int)groupId {
  if (!self.request11Or13) {
    self.request11Or13 = [UdpRequest manager];
    self.request11Or13.delegate = self;
  }
  [self.request11Or13 sendMsg11Or13:aSwitch
                      socketGroupId:groupId
                           sendMode:ActiveMode];
}

- (void)sendMsg0BOr0D:(SDZGSwitch *)aSwitch {
  if (!self.request0BOr0D) {
    self.request0BOr0D = [UdpRequest manager];
    self.request0BOr0D.delegate = self;
  }
  [self.request0BOr0D sendMsg0BOr0D:aSwitch sendMode:ActiveMode];
}

#pragma mark - UdpRequestDelegate
- (void)responseMsg:(CC3xMessage *)message address:(NSData *)address {
  switch (message.msgId) {
    //开关状态查询
    case 0xc:
    case 0xe:
      [self responseMsgCOrE:message];
      break;
    //开关控制
    case 0x12:
    case 0x14:
      [self responseMsg12Or14:message];
      break;
  }
}

- (void)responseMsgCOrE:(CC3xMessage *)message {
  if (message.state == 0) {
    SDZGSwitch *aSwitch = [SDZGSwitch parseMessageCOrEToSwitch:message];
    [[SwitchDataCeneter sharedInstance] updateSwitch:aSwitch];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSwitchUpdate
                                                        object:self
                                                      userInfo:nil];
  }
}

- (void)responseMsg12Or14:(CC3xMessage *)message {
  if (message.state == 0) {
    //    NSArray *switchs = [[SwitchDataCeneter sharedInstance] switchs];
    //    SDZGSwitch *editSwitch;
    //    for (SDZGSwitch *aSwitch in switchs) {
    //      if ([message.mac isEqualToString:aSwitch.mac]) {
    //        editSwitch = aSwitch;
    //        break;
    //      }
    //    }
    //    SDZGSocket *socket =
    //        [editSwitch.sockets objectAtIndex:(message.socketGroupId - 1)];
    //    [[SwitchDataCeneter sharedInstance]
    //    updateSocketStaus:!socket.socketStatus
    //                                            socketGroupId:socket.groupId
    //                                                      mac:message.mac];
    //    [[NSNotificationCenter defaultCenter]
    //    postNotificationName:kSwitchUpdate
    //                                                        object:self
    //                                                      userInfo:nil];

    SDZGSocket *socket =
        [self.aSwitch.sockets objectAtIndex:message.socketGroupId - 1];
    socket.socketStatus = !socket.socketStatus;
  }
}

@end
