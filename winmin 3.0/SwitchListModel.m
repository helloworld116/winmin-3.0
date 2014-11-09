//
//  SwitchListModel.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-17.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SwitchListModel.h"
@interface SwitchListModel () <UdpRequestDelegate>
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic, strong) NSString *mac; //扫描指定设备时使用

@property (strong, nonatomic) UdpRequest *request;
@end

@implementation SwitchListModel

- (id)init {
  self = [super init];
  if (self) {
    self.request = [UdpRequest manager];
    self.request.delegate = self;
  }
  return self;
}

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
  [self.request sendMsg09:ActiveMode];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{ [self sendMsg0BOr0D]; });
}

- (void)addSwitchWithMac:(NSString *)mac {
  self.mac = mac;
  [self refreshSwitchList];
}

//扫描设备
- (void)sendMsg0BOr0D {
  //先局域网内扫描，0.5秒后请求外网，更新设备状态
  dispatch_async(GLOBAL_QUEUE, ^{
      [self.request sendMsg0B:ActiveMode];
      //设置0.5秒，保证内网的响应优先级
      [NSThread sleepForTimeInterval:0.5];
      NSArray *switchs = [[SwitchDataCeneter sharedInstance] switchs];
      for (SDZGSwitch *aSwitch in switchs) {
        debugLog(@"switch mac is %@", aSwitch.mac);
        [self.request sendMsg0D:aSwitch.mac sendMode:ActiveMode tag:0];
      }
  });
}

- (void)blinkSwitch:(SDZGSwitch *)aSwitch {
  [self.request sendMsg39Or3B:aSwitch on:YES sendMode:ActiveMode];
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
- (void)udpRequest:(UdpRequest *)request
     didReceiveMsg:(CC3xMessage *)message
           address:(NSData *)address {
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
  //添加指定mac地址的设备，配置时使用
  if (self.mac) {
    if (![self.mac isEqualToString:message.mac]) {
      return;
    }
  }
  if (message.version == kHardwareVersion &&
      message.state == kUdpResponseSuccessCode) {
    SDZGSwitch *aSwitch = [[[SwitchDataCeneter sharedInstance] switchsDict]
        objectForKey:message.mac];
    if (!aSwitch && message.lockStatus == LockStatusOff) {
      //设备未加锁，并且不在本地列表中，发送请求，查询设备状态
      aSwitch = [[SDZGSwitch alloc] init];
      aSwitch.mac = message.mac;
      aSwitch.ip = message.ip;
      aSwitch.port = message.port;
      aSwitch.networkStatus = SWITCH_NEW;
      [[SwitchDataCeneter sharedInstance] addSwitchToTmp:aSwitch];
      [self.request sendMsg0B:aSwitch sendMode:ActiveMode];
    }
  }
  //删除指定mac，避免下拉刷新时使用该mac
  if (self.mac) {
    self.mac = nil;
  }
}

- (void)responseMsgCOrE:(CC3xMessage *)message {
  SDZGSwitch *aSwitchInTmp =
      [[SwitchDataCeneter sharedInstance] getSwitchFromTmpByMac:message.mac];

  SDZGSwitch *aSwitch = [[[SwitchDataCeneter sharedInstance] switchsDict]
      objectForKey:message.mac];
  if ((aSwitchInTmp || aSwitch) && message.version == kHardwareVersion &&
      message.state == kUdpResponseSuccessCode) {
    [SDZGSwitch parseMessageCOrEToSwitch:message];
    if (aSwitchInTmp) {
      [[SwitchDataCeneter sharedInstance] removeSwitchFromTmp:aSwitchInTmp];
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
