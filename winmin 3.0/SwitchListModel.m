//
//  SwitchListModel.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-17.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SwitchListModel.h"
#import "APServiceUtil.h"
static const int successCode = 1;
@interface SwitchListModel () <UdpRequestDelegate>
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic, strong) NSString *mac; //扫描指定设备时使用

@property (strong, nonatomic) UdpRequest *request;
@property (strong, nonatomic) UdpRequest *request2; //用于闪烁和检查单个设备状态

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
    self.request2 = [UdpRequest manager];
    self.request2.delegate = self;
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{
          [self uploadDeviceAndAppInfo];
        });
    //获取设备固件版本
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW,
                      (int64_t)((REFRESH_DEV_TIME / 3.0) * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{
          [self getSwitchsFireware];
        });
    //获取服务端设备固件版本
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 (int64_t)(REFRESH_DEV_TIME * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                     [self getFirewareInServer];
                   });
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
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
  });
}

- (void)uploadDeviceAndAppInfo {
  [self.request2 sendMsg59WithSendMode:ActiveMode];
}

- (void)getSwitchsFireware {
  [self.request2 sendMsg7BWithsendMode:ActiveMode];
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
  _isScanningState = NO;
  [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)resumeScanState {
  if (![self.timer isValid]) {
    return;
  }
  self.request.delegate = self;
  _isScanningState = YES;
  [self.timer setFireDate:[NSDate date]];
}

- (void)refreshSwitchList {
  [self pauseScanState];
  [self.request sendMsg09:ActiveMode];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
                   [self resumeScanState];
                 });
}

- (void)addSwitchWithMac:(NSString *)mac password:(NSString *)password {
  SDZGSwitch *aSwitch = [SwitchDataCeneter sharedInstance].switchsDict[mac];
  if (aSwitch) {
    aSwitch.networkStatus = SWITCH_NEW;
    aSwitch.password = password;
    aSwitch.name = NSLocalizedString(@"Smart Switch", nil);
    if ([aSwitch.deviceType isEqualToString:kDeviceType_Snake]) {
      SDZGSocket *socket1 = aSwitch.sockets[0];
      socket1.imageNames = @[
        socket_default_image,
        socket_default_image,
        socket_default_image,
        socket_default_image
      ];
    } else {
      SDZGSocket *socket1 = aSwitch.sockets[0];
      socket1.imageNames = @[
        socket_default_image,
        socket_default_image,
        socket_default_image
      ];
      SDZGSocket *socket2 = aSwitch.sockets[1];
      socket2.imageNames = @[
        socket_default_image,
        socket_default_image,
        socket_default_image
      ];
    }
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
      if ((aSwitch.networkStatus == SWITCH_REMOTE ||
           aSwitch.networkStatus == SWITCH_OFFLINE) &&
          _isScanningState) {
        DDLogDebug(@"switch mac is %@", aSwitch.mac);
        [self.request sendMsg0D:aSwitch sendMode:ActiveMode tag:0];
      }
      //实时电量
      if (aSwitch.networkStatus != SWITCH_OFFLINE) {
        [self.request sendMsg33Or35:aSwitch sendMode:ActiveMode];
      }
      //        aSwitch.power = (arc4random() % 2500);
    }
  });
}

- (void)scanSwitchState:(SDZGSwitch *)aSwitch
               complete:(ScaneOneSwitchCompleteBlock)complete {
  [self pauseScanState];
  self.request.delegate = nil;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
                   self.request.delegate = self;
                 });
  if (!self.request2) {
    self.request2 = [UdpRequest manager];
    self.request2.delegate = self;
  }
  self.timerCheckOneSwitch =
      [NSTimer scheduledTimerWithTimeInterval:5.f
                                       target:self
                                     selector:@selector(checkSwitchStatus)
                                     userInfo:nil
                                      repeats:NO];
  self.currentSwitch = aSwitch;
  self.completeBlock = complete;
  self.isScanOneSwitch = YES;
  self.isRemote = NO;
  DDLogDebug(@"switch status is %d", aSwitch.networkStatus);
  if (aSwitch.networkStatus == SWITCH_REMOTE ||
      aSwitch.networkStatus == SWITCH_OFFLINE) {
    [self.request2 sendMsg0D:aSwitch sendMode:ActiveMode tag:0];
  } else {
    [self.request2 sendMsg0B:aSwitch sendMode:ActiveMode];
    [NSThread sleepForTimeInterval:0.1f];
    [self.request2 sendMsg0D:aSwitch sendMode:ActiveMode tag:0];
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
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  BOOL reciveRemoteNotification =
      [[defaults objectForKey:remoteNotification] boolValue];
  if (reciveRemoteNotification) {
    [APServiceUtil removeSwitchRemoteNotification:aSwitch
                                      finishBlock:^(BOOL result){
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
      [self responseMsgCOrE:message request:request];
      break;
    //实时电量
    case 0x34:
    case 0x36:
      [self responseMsg34Or36:message];
      break;
    //闪烁
    case 0x3a:
    case 0x3c:
      [self responseMsg3AOr3C:message];
      break;
    case 0x5a:
      DDLogDebug(@"设备信息已上传");
      break;
    case 0x7c:
      [self responseMsg7C:message];
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
  if (message.version >= kHardwareVersion) {
    SDZGSwitch *aSwitch = [[[SwitchDataCeneter sharedInstance] switchsDict]
        objectForKey:message.mac];
    if (!aSwitch && message.lockStatus == LockStatusOff) {
      //设备未加锁，并且不在本地列表中，发送请求，查询设备状态
      aSwitch = [[SDZGSwitch alloc] init];
      aSwitch.mac = message.mac;
      aSwitch.ip = message.ip;
      aSwitch.port = message.port;
      aSwitch.networkStatus = SWITCH_NEW;
      [[SwitchDataCeneter sharedInstance]
          addSwitchToTmp:aSwitch
              completion:^{
                [self.request sendMsg0B:aSwitch sendMode:ActiveMode];
              }];
    }
  }
  //删除指定mac，避免下拉刷新时使用该mac
  if (self.mac) {
    self.mac = nil;
  }
}

- (void)responseMsgCOrE:(CC3xMessage *)message request:(UdpRequest *)request {
  //  DDLogDebug(@"%s", __func__);
  if (self.isScanOneSwitch && request == self.request2) {
    if (message.state == kUdpResponseSuccessCode) {
      if (message.msgId == 0xc) {
        DDLogDebug(@"%@ msgId=0xc", [NSThread currentThread]);
        //设备内网
        //解决多个设备使用同一ip导致各种奇怪问题
        if ([message.mac isEqualToString:self.currentSwitch.mac]) {
          self.completeBlock(SWITCH_LOCAL);
        } else {
          self.completeBlock(-1);
        }
        [self stopScanOneSwitch];
      } else if (message.msgId == 0xe) {
        DDLogDebug(@"%@ msgId=0xe", [NSThread currentThread]);
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
  } else if (request == self.request) {
    SDZGSwitch *aSwitchInTmp =
        [[SwitchDataCeneter sharedInstance] getSwitchFromTmpByMac:message.mac];
    SDZGSwitch *aSwitch = [[[SwitchDataCeneter sharedInstance] switchsDict]
        objectForKey:message.mac];
    if ((aSwitchInTmp || aSwitch) && message.version >= kHardwareVersion &&
        message.state == kUdpResponseSuccessCode) {
      [SDZGSwitch parseMessageCOrE:message
                          toSwitch:^(SDZGSwitch *aSwitch) {
                            if (aSwitchInTmp) {
                              [[SwitchDataCeneter sharedInstance]
                                  removeSwitchFromTmp:aSwitchInTmp];
                              [[NSNotificationCenter defaultCenter]
                                  postNotificationName:kSwitchUpdate
                                                object:self
                                              userInfo:nil];
                            }
                          }];
    }
  }
}

- (void)responseMsg34Or36:(CC3xMessage *)message {
  //  DDLogDebug(@"power is %f mac is %@", message.power, message.mac);
  //  float diff = floorf(message.power - kElecDiff);
  //  float power = diff > 0 ? diff : 0.f;
  //  DDLogDebug(@"show power is %f", power);
  SDZGSwitch *aSwitch =
      [[SwitchDataCeneter sharedInstance] getSwitchByMac:message.mac];
  aSwitch.power = (int)message.power;
  if (message.sensorInfo.hasSensorTemperature ||
      message.sensorInfo.hasSensorHumidity ||
      message.sensorInfo.hasSensorSmog || message.sensorInfo.hasSensorCo ||
      message.sensorInfo.hasSensorLight ||
      message.sensorInfo.hasSensorInfaredFlag) {
    //有传感器数据
    aSwitch.hasSensorData = YES;
    aSwitch.sensorInfo = message.sensorInfo;
  } else {
    aSwitch.hasSensorData = NO;
  }
  DDLogDebug(@"power is %i mac is %@", aSwitch.power, aSwitch.mac);
}

- (void)responseMsg3AOr3C:(CC3xMessage *)message {
  if (message.state == kUdpResponseSuccessCode) {
    //成功
  }
}

- (void)responseMsg7C:(CC3xMessage *)message {
  SDZGSwitch *aSwitch =
      [[SwitchDataCeneter sharedInstance] getSwitchByMac:message.mac];
  aSwitch.firewareVersion = message.firmwareVersion;
  aSwitch.deviceType = message.deviceType;
  if (message.firmwareVersion && message.deviceType) {
    [kSharedAppliction.dictOfFireware setObject:message.firmwareVersion
                                         forKey:message.deviceType];
  }
}

#pragma mark - HTTP

- (void)getFirewareInServer {
  NSArray *deviceTypes = [kSharedAppliction.dictOfFireware allKeys];
  if ([deviceTypes count]) {
    for (NSString *deviceType in deviceTypes) {
      [self checkFirewareWithDeviceType:deviceType];
    }
  }
}

- (void)checkFirewareWithDeviceType:(NSString *)deviceType {
  if (deviceType) {
    NSString *requestUrl =
        [NSString stringWithFormat:@"%@deviceVersion/getLastVersion",
                                   BaseURLStringWithNoEncrypt];
    AFHTTPRequestOperationManager *manager =
        [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableDictionary *parameters = [@{} mutableCopy];
    [parameters setObject:deviceType forKey:@"deviceType"];
    [manager POST:requestUrl
        parameters:parameters
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSString *string =
              [[NSString alloc] initWithData:responseObject
                                    encoding:NSUTF8StringEncoding];
          //          DDLogDebug(@"response msg is %@",string);
          NSDictionary *responseData = __JSON(string);
          int status = [responseData[@"status"] intValue];
          if (status == successCode) {
            NSDictionary *data = responseData[@"data"];
            NSDictionary *lastVersion = data[@"lastVersion"];
            NSString *serverFirewareVersion = lastVersion[@"softWareVersion"];
            if (serverFirewareVersion) {
              [kSharedAppliction.dictOfFireware setObject:serverFirewareVersion
                                                   forKey:deviceType];
            }
          } else {
            DDLogDebug(@"服务器错误，请稍后再试");
          }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          DDLogDebug(@"网络错误，请稍后再试");
        }];
  } else {
    DDLogDebug(@"未知设备");
  }
}

- (void)getSwitchRestartInfo {
  NSArray *switchs = [[SwitchDataCeneter sharedInstance] switchs];
  NSMutableString *macStr = [NSMutableString string];
  for (int i = 0; i < [switchs count]; i++) {
    SDZGSwitch *aSwitch = switchs[i];
    [macStr appendString:aSwitch.mac];
    [macStr appendString:@","];
  }
  NSString *macs = [macStr substringToIndex:macStr.length];
  NSString *requestUrl = [NSString
      stringWithFormat:@"%@deviceMove/getUnDeals", BaseURLStringWithNoEncrypt];
  AFHTTPRequestOperationManager *manager =
      [AFHTTPRequestOperationManager manager];
  manager.responseSerializer = [AFHTTPResponseSerializer serializer];
  NSMutableDictionary *parameters = [@{} mutableCopy];
  [parameters setObject:macs forKey:@"mac"];
  [manager POST:requestUrl
      parameters:parameters
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *string = [[NSString alloc] initWithData:responseObject
                                                 encoding:NSUTF8StringEncoding];
        //          DDLogDebug(@"response msg is %@",string);
        NSDictionary *responseData = __JSON(string);
        int status = [responseData[@"status"] intValue];
        if (status == successCode) {
          NSArray *data = responseData[@"data"];
          DDLogDebug(@"data is %@", data);
          for (NSDictionary *info in data) {
            NSString *alertDate = info[@"alertDate"];
            NSString *mac = info[@"mac"];
            SDZGSwitch *aSwitch =
                [[SwitchDataCeneter sharedInstance] getSwitchByMac:mac];
            if (aSwitch) {
              aSwitch.isRestart = YES;
              aSwitch.restartMsgDateStr = alertDate;
            }
          }
        } else {
          DDLogDebug(@"服务器错误，请稍后再试");
        }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogDebug(@"网络错误，请稍后再试");
      }];
}

- (void)getDealFlag:(SDZGSwitch *)aSwitch
         completion:(HttpCompletionBlock)completion {
  NSString *requestUrl = [NSString
      stringWithFormat:@"%@deviceMove/getDealFlag", BaseURLStringWithNoEncrypt];
  AFHTTPRequestOperationManager *manager =
      [AFHTTPRequestOperationManager manager];
  manager.responseSerializer = [AFHTTPResponseSerializer serializer];
  NSMutableDictionary *parameters = [@{} mutableCopy];
  [parameters setObject:aSwitch.mac forKey:@"mac"];
  [parameters setObject:aSwitch.restartMsgDateStr forKey:@"alertDate"];
  [manager POST:requestUrl
      parameters:parameters
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *string = [[NSString alloc] initWithData:responseObject
                                                 encoding:NSUTF8StringEncoding];
        //          DDLogDebug(@"response msg is %@",string);
        NSDictionary *responseData = __JSON(string);
        int status = [responseData[@"status"] intValue];
        if (status == successCode) {
          SDZGHttpResponse *response = [[SDZGHttpResponse alloc]
              initWithResponseCode:status
                              data:responseData[@"data"]];
          completion(response);
        } else {
          DDLogDebug(@"服务器错误，请稍后再试");
          SDZGHttpResponse *response = [[SDZGHttpResponse alloc]
              initWithResponseCode:status
                           message:@"服务器错误，请稍后再试"
                             error:nil];
          completion(response);
        }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogDebug(@"网络错误，请稍后再试");
        SDZGHttpResponse *response = [[SDZGHttpResponse alloc]
            initWithResponseCode:-1
                         message:@"网络错误，请稍后再试"
                           error:error];
        completion(response);

      }];
}
@end
