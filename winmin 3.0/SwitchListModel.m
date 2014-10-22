//
//  SwitchListModel.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-17.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SwitchListModel.h"
@interface SwitchListModel ()<UdpRequestDelegate>
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic, strong) UdpRequest *request;
@property (nonatomic, strong) UdpRequest *request9;
@property (nonatomic, strong) UdpRequest *request39Or3B;
@end

@implementation SwitchListModel

- (void)startScanState {
  _isScanningState = YES;
  self.timer = [NSTimer timerWithTimeInterval:REFRESH_DEV_TIME
                                       target:self
                                     selector:@selector(sendMsg0BOr0D)
                                     userInfo:nil
                                      repeats:YES];
  [self.timer fire];
  [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopScanState {
  _isScanningState = NO;
  if (self.timer) {
    [self.timer invalidate];
    self.timer = nil;
  }
}

- (void)refreshSwitchList {
  if (!self.request9) {
    self.request9 = [UdpRequest manager];
    self.request9.delegate = self;
  }
  [self.request9 sendMsg09:ActiveMode];

  //  [self stopScanState];
  //  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 *
  //  NSEC_PER_SEC)),
  //                 dispatch_get_main_queue(), ^{ [self startScanState]; });
}

//扫描设备
- (void)sendMsg0BOr0D {
  //先局域网内扫描，0.5秒后请求外网，更新设备状态
  dispatch_async(GLOBAL_QUEUE, ^{
      if (!self.request) {
        self.request = [UdpRequest manager];
        self.request.delegate = self;
      }
      [self.request sendMsg0B:ActiveMode];
      //设置0.5秒，保证内网的响应优先级
      [NSThread sleepForTimeInterval:0.5];
      NSArray *switchs =
          [[SwitchDataCeneter sharedInstance] switchsWithChangeStatus];
      for (SDZGSwitch *aSwitch in switchs) {
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

- (void)deleteSwitch:(SDZGSwitch *)aSwitch {
  [[SwitchDataCeneter sharedInstance] removeSwitch:aSwitch];
  [[DBUtil sharedInstance] removeSceneBySwitch:aSwitch];
  [[NSNotificationCenter defaultCenter] postNotificationName:kSwitchUpdate
                                                      object:self];
  [[NSNotificationCenter defaultCenter]
      postNotificationName:kSwitchDeleteSceneNotification
                    object:nil];
}

#pragma mark - UdpRequestDelegate
- (void)responseMsg:(CC3xMessage *)message address:(NSData *)address {
  switch (message.msgId) {
    //添加设备
    case 0xa:
      [self responseMsgA:message];
      break;
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

- (void)responseMsgA:(CC3xMessage *)message {
  dispatch_sync(SWITCHPARSETOADD_SERIAL_QUEUE, ^{
      if (message.version == kHardwareVersion &&
          message.state == kUdpResponseSuccessCode) {
        debugLog(@"switchs is %@",
                 [[SwitchDataCeneter sharedInstance] switchs]);
        SDZGSwitch *aSwitch = [[[SwitchDataCeneter sharedInstance] switchsDict]
            objectForKey:message.mac];
        debugLog(@"switch is %@", aSwitch);
        if (!aSwitch && message.lockStatus == LockStatusOff) {
          //设备未加锁，并且不在本地列表中，发送请求，查询设备状态
          debugLog(@"########## add to dict and send ");
          aSwitch = [[SDZGSwitch alloc] init];
          aSwitch.mac = message.mac;
          aSwitch.ip = message.ip;
          aSwitch.port = message.port;
          aSwitch.networkStatus = SWITCH_NEW;
          [[SwitchDataCeneter sharedInstance] addSwitch:aSwitch];
          [self.request9 sendMsg0B:aSwitch sendMode:ActiveMode];
          [[NSNotificationCenter defaultCenter] postNotificationName:kNewSwitch
                                                              object:self];
          [NSThread sleepForTimeInterval:10];
        }
      }
  });
}

- (void)responseMsgCOrE:(CC3xMessage *)message {
  SDZGSwitch *aSwitch = [[[SwitchDataCeneter sharedInstance] switchsDict]
      objectForKey:message.mac];
  if (aSwitch && message.version == kHardwareVersion &&
      message.state == kUdpResponseSuccessCode) {
    aSwitch = [SDZGSwitch parseMessageCOrEToSwitch:message];
    if (aSwitch.networkStatus == SWITCH_NEW) {
      [[NSNotificationCenter defaultCenter] postNotificationName:kSwitchUpdate
                                                          object:self
                                                        userInfo:nil];
    }
  }
}

- (void)responseMsg3AOr3C:(CC3xMessage *)message {
  if (message.state == kUdpResponseSuccessCode) {
    //成功
  }
}

@end
