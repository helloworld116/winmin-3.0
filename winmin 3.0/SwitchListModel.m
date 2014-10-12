//
//  SwitchListModel.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-17.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SwitchListModel.h"
@interface SwitchListModel ()<UdpRequestDelegate>
@property(strong, nonatomic) NSTimer *timer;
@property(nonatomic, strong) UdpRequest *request;
@property(nonatomic, strong) UdpRequest *request39Or3B;
@end

@implementation SwitchListModel

- (void)startScan {
  _isScanning = YES;
  self.timer = [NSTimer timerWithTimeInterval:REFRESH_DEV_TIME
                                       target:self
                                     selector:@selector(sendMsg0BOr0D)
                                     userInfo:nil
                                      repeats:YES];
  [self.timer fire];
  [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopScan {
  _isScanning = NO;
  if (self.timer) {
    [self.timer invalidate];
    self.timer = nil;
  }
}

//扫描设备
- (void)sendMsg0BOr0D {
//  //先局域网内扫描，1秒后内网没有响应的请求外网，更新设备状态
//  dispatch_async(GLOBAL_QUEUE, ^{
//      if (!self.request) {
//        self.request = [UdpRequest manager];
//        self.request.delegate = self;
//      }
//      [self.request sendMsg0B:ActiveMode];
//  });
//
//  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC),
//                 GLOBAL_QUEUE, ^{
//      NSArray *switchs = [[SwitchDataCeneter sharedInstance] switchs];
//      for (SDZGSwitch *aSwitch in switchs) {
//        //        aSwitch.networkStatus = SWITCH_OFFLINE;
//        [self.request sendMsg0D:aSwitch.mac sendMode:ActiveMode tag:0];
//        [NSThread sleepForTimeInterval:0.1f];
//      }
//  });

  //先局域网内扫描，1秒后内网没有响应的请求外网，更新设备状态
  dispatch_async(GLOBAL_QUEUE, ^{
      if (!self.request) {
        self.request = [UdpRequest manager];
        self.request.delegate = self;
      }
      [self.request sendMsg0B:ActiveMode];

      NSArray *switchs = [[SwitchDataCeneter sharedInstance] switchsWithChangeStatus];
      for (SDZGSwitch *aSwitch in switchs) {
        //        aSwitch.networkStatus = SWITCH_OFFLINE;
        [self.request sendMsg0D:aSwitch.mac sendMode:ActiveMode tag:0];
        [NSThread sleepForTimeInterval:0.2f];
      }
  });
}

- (void)blinkSwitch:(SDZGSwitch *)aSwitch {
  if (!self.request39Or3B) {
    self.request39Or3B = [UdpRequest manager];
    self.request39Or3B.delegate = self;
  }
  [self.request39Or3B sendMsg39Or3B:aSwitch on:YES sendMode:ActiveMode];
}

#pragma mark - UdpRequestDelegate
- (void)responseMsg:(CC3xMessage *)message address:(NSData *)address {
  switch (message.msgId) {
    //开关状态查询
    case 0xc:
    case 0xe:
      [self responseMsgCOrE:message];
      break;
    //闪烁
    case 0x3a:
    case 0x3c:
      [self responseMsg3AOr3C:message];
      break;
    default:
      break;
  }
}

- (void)responseMsgCOrE:(CC3xMessage *)message {
  if (message.version == 2 && message.state == 0) {
    SDZGSwitch *aSwitch = [SDZGSwitch parseMessageCOrEToSwitch:message];
    if (aSwitch) {
      [[SwitchDataCeneter sharedInstance] updateSwitch:aSwitch];
      [[NSNotificationCenter defaultCenter] postNotificationName:kSwitchUpdate
                                                          object:self
                                                        userInfo:nil];
    }
  }
}

- (void)responseMsg3AOr3C:(CC3xMessage *)message {
  if (message.state == 0) {
    //成功
  }
}

@end
