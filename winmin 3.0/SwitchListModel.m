//
//  SwitchListModel.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-17.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SwitchListModel.h"
#import "APServiceUtil.h"
@interface SwitchListModel () <UdpRequestDelegate>
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic, strong) NSString *mac; //扫描指定设备时使用

@property (strong, nonatomic) UdpRequest *request;
@property (strong, nonatomic) UdpRequest *request2; //用于闪烁

//检查某个设备网络状态时使用
@property (strong, nonatomic) ScaneOneSwitchCompleteBlock completeBlock;
@property (strong, nonatomic) NSTimer *timerCheckOneSwitch;
@property (assign, nonatomic) BOOL isScanOneSwitch;
@property (assign, nonatomic) BOOL isRemote;
@property (strong, nonatomic) SDZGSwitch *currentSwitch;
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

- (void)dealloc {
  self.request.delegate = nil;
  self.request2.delegate = nil;
}

- (void)startScanState {
  [self stopScanState];
  DDLogDebug(@"%s", __FUNCTION__);
  dispatch_async(MAIN_QUEUE, ^{
      _isScanningState = YES;
      self.timer = [NSTimer timerWithTimeInterval:REFRESH_DEV_TIME
                                           target:self
                                         selector:@selector(sendMsg0BOr0D)
                                         userInfo:nil
                                          repeats:YES];
      [self.timer fire];
      [[NSRunLoop mainRunLoop] addTimer:self.timer
                                forMode:NSRunLoopCommonModes];
  });
}

- (void)stopScanState {
  DDLogDebug(@"%s", __FUNCTION__);
  dispatch_async(MAIN_QUEUE, ^{
      _isScanningState = NO;
      if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
      }
  });
}

- (void)pauseScanState {
  if (![self.timer isValid]) {
    return;
  }
  [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)resumeScanState {
  if (![self.timer isValid]) {
    return;
  }
  [self.timer setFireDate:[NSDate date]];
}

- (void)refreshSwitchList {
  [self pauseScanState];
  [self.request sendMsg09:ActiveMode];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{ [self resumeScanState]; });
}

- (void)addSwitchWithMac:(NSString *)mac {
  SDZGSwitch *aSwitch = [SwitchDataCeneter sharedInstance].switchsDict[mac];
  if (aSwitch) {
    aSwitch.networkStatus = SWITCH_NEW;
    aSwitch.name = NSLocalizedString(@"Smart Switch", nil);
    SDZGSocket *socket1 = aSwitch.sockets[0];
    socket1.imageNames =
        @[ socket_default_image, socket_default_image, socket_default_image ];
    SDZGSocket *socket2 = aSwitch.sockets[1];
    socket2.imageNames =
        @[ socket_default_image, socket_default_image, socket_default_image ];
    NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
    NSArray *switchs = [[SwitchDataCeneter sharedInstance] switchs];
    for (SDZGSwitch *aSwitch in switchs) {
      aSwitch.lastUpdateInterval = current;
    }
  } else {
    self.mac = mac;
    [self refreshSwitchList];
  }
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
        if (aSwitch.networkStatus == SWITCH_REMOTE ||
            aSwitch.networkStatus == SWITCH_OFFLINE) {
          DDLogDebug(@"switch mac is %@", aSwitch.mac);
          [self.request sendMsg0D:aSwitch sendMode:ActiveMode tag:0];
        }
      }
  });
}

- (void)scanSwitchState:(SDZGSwitch *)aSwitch
               complete:(ScaneOneSwitchCompleteBlock)complete {
  [self pauseScanState];
  self.timerCheckOneSwitch =
      [NSTimer scheduledTimerWithTimeInterval:3.f
                                       target:self
                                     selector:@selector(checkSwitchStatus)
                                     userInfo:nil
                                      repeats:NO];
  self.currentSwitch = aSwitch;
  self.completeBlock = complete;
  self.isScanOneSwitch = YES;
  self.isRemote = NO;
  if (aSwitch.networkStatus == SWITCH_REMOTE ||
      aSwitch.networkStatus == SWITCH_OFFLINE) {
    [self.request sendMsg0D:aSwitch sendMode:ActiveMode tag:0];
  } else {
    [self.request sendMsg0B:aSwitch sendMode:ActiveMode];
    [NSThread sleepForTimeInterval:0.1f];
    [self.request sendMsg0D:aSwitch sendMode:ActiveMode tag:0];
  }
}

- (void)stopScanOneSwitch {
  if (self.timerCheckOneSwitch) {
    [self.timerCheckOneSwitch invalidate];
    self.timerCheckOneSwitch = nil;
  }
}

- (void)blinkSwitch:(SDZGSwitch *)aSwitch {
  if (!self.request2) {
    self.request2 = [UdpRequest manager];
    self.request2.delegate = self;
  }
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
  if (kSharedAppliction.reciveRemoteNotification) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *jPushTagArray =
        [[defaults objectForKey:jPushTagArrayKey] mutableCopy];
    NSString *macWithout =
        [aSwitch.mac stringByReplacingOccurrencesOfString:@":" withString:@""];
    [jPushTagArray removeObject:macWithout];
    NSSet *set = [NSSet setWithArray:jPushTagArray];
    [APServiceUtil openRemoteNotification:set
                              finishBlock:^(BOOL result) {
                                  if (result) {
                                    [defaults setObject:jPushTagArray
                                                 forKey:jPushTagArrayKey];
                                  }
                              }];
  }
}

#pragma mark -
- (void)checkSwitchStatus {
  if (self.isRemote) {
    self.completeBlock(SWITCH_REMOTE);
  } else {
    self.isScanOneSwitch = NO;
    self.completeBlock(-1);
    [self resumeScanState];
  }
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
  if (message.version == kHardwareVersion) {
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
  if (self.isScanOneSwitch) {
    if (message.state == kUdpResponseSuccessCode) {
      if (message.msgId == 0xc) {
        //设备内网
        self.completeBlock(SWITCH_LOCAL);
        [self stopScanOneSwitch];
      } else if (message.msgId == 0xe) {
        self.isRemote = YES;
        if (self.currentSwitch.networkStatus == SWITCH_REMOTE ||
            self.currentSwitch.networkStatus == SWITCH_OFFLINE) {
          self.completeBlock(SWITCH_REMOTE);
          [self stopScanOneSwitch];
        }
      }
    } else {
      //设备不在线
      if (message.state == kUdpResponsePasswordErrorCode) {
        //密码错误，设备被重新配置
        self.completeBlock(kUdpResponsePasswordErrorCode);
      } else {
        //设备离线
        self.completeBlock(-1);
      }
      [self stopScanOneSwitch];
      [self resumeScanState];
    }
    self.isScanOneSwitch = NO;
  } else {
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
}

- (void)responseMsg3AOr3C:(CC3xMessage *)message {
  if (message.state == kUdpResponseSuccessCode) {
    //成功
  }
}

@end
