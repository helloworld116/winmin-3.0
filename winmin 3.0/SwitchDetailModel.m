//
//  SwitchDetailModel.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-19.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SwitchDetailModel.h"
#import "HistoryElec.h"

@interface SwitchDetailModel () <UdpRequestDelegate>
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSTimer *timerElec;
@property (strong, nonatomic) NSTimer *timerCheckOnline; //检查设备是否在线

@property (nonatomic, strong) UdpRequest *request1; //查询状态
@property (nonatomic, strong) UdpRequest *request2; //控制插孔I
@property (nonatomic, strong) UdpRequest *request3; //控制插孔II
@property (nonatomic, strong) UdpRequest *request4; //实时电量和历史电量查询
@property (nonatomic, strong) UdpRequest *request5; //插孔I定时
@property (nonatomic, strong) UdpRequest *request6; //插孔I延时
@property (nonatomic, strong) UdpRequest *request7; //插孔II定时
@property (nonatomic, strong) UdpRequest *request8; //插孔II延时

@property (nonatomic, strong) SDZGSwitch *aSwitch;
@property (nonatomic, strong) HistoryElec *historyElec;
@property (nonatomic, strong) HistoryElecParam *param;
@property (nonatomic, assign) HistoryElecDateType dateType;

@property (nonatomic, strong) SwitchStateChangeBlock stateChangeBlock;
@property (nonatomic, strong) SocketTimerBlock socket1TimerBlock;
@property (nonatomic, strong) SocketTimerBlock socket2TimerBlock;
@property (nonatomic, strong) SocketDelayBlock socket1DelayBlock;
@property (nonatomic, strong) SocketDelayBlock socket2DelayBlock;
@property (nonatomic, strong) HistoryElecBlock historyElecBlock;

//防止网络延迟多个请求同时或延迟响应时改变开关状态，值为1表示第一次接收，正常处理，其他情况下抛弃响应
@property (atomic, assign) int responseData12Or14GroupId1Count;
@property (atomic, assign) int responseData12Or14GroupId2Count;
@end

@implementation SwitchDetailModel

- (id)initWithSwitch:(SDZGSwitch *)aSwitch
    switchStateChangeBlock:(SwitchStateChangeBlock)block {
  if (self = [super init]) {
    self.aSwitch = aSwitch;
    self.request1 = [UdpRequest manager];
    self.request1.delegate = self;
    self.request4 = [UdpRequest manager];
    self.request4.delegate = self;
    self.request5 = [UdpRequest manager];
    self.request5.delegate = self;
    self.request6 = [UdpRequest manager];
    self.request6.delegate = self;
    self.request7 = [UdpRequest manager];
    self.request7.delegate = self;
    self.request8 = [UdpRequest manager];
    self.request8.delegate = self;
    self.stateChangeBlock = block;
    [self.aSwitch
        addObserver:self
         forKeyPath:@"networkStatus"
            options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
            context:nil];
  }
  return self;
}

- (void)dealloc {
  self.request1.delegate = nil;
  self.request2.delegate = nil;
  self.request3.delegate = nil;
  self.request4.delegate = nil;
  self.request5.delegate = nil;
  self.request6.delegate = nil;
  self.request7.delegate = nil;
  self.request8.delegate = nil;
  if (self.aSwitch) {
    [self.aSwitch removeObserver:self forKeyPath:@"networkStatus"];
  }
}

- (void)socket1Timer:(SocketTimerBlock)block {
  dispatch_async(GLOBAL_QUEUE, ^{
      self.socket1TimerBlock = block;
      [self sendMsg17Or19Socket1];
  });
}

- (void)socket2Timer:(SocketTimerBlock)block {
  dispatch_async(GLOBAL_QUEUE, ^{
      self.socket2TimerBlock = block;
      [self sendMsg17Or19Socket2];
  });
}

- (void)socket1Delay:(SocketDelayBlock)block {
  dispatch_async(GLOBAL_QUEUE, ^{
      self.socket1DelayBlock = block;
      [self sendMsg53Or55Socket1];
  });
}

- (void)socket2Delay:(SocketDelayBlock)block {
  dispatch_async(GLOBAL_QUEUE, ^{
      self.socket2DelayBlock = block;
      [self sendMsg53Or55Socket2];
  });
}

- (void)openOrCloseWithGroupId:(int)groupId {
  dispatch_async(GLOBAL_QUEUE,
                 ^{ [self sendMsg11Or13:self.aSwitch groupId:groupId]; });
}

- (void)startScanSwitchState {
  [self stopScanSwitchState];
  dispatch_async(MAIN_QUEUE, ^{
      _isScanning = YES;
      self.timer = [NSTimer timerWithTimeInterval:REFRESH_DEV_TIME
                                           target:self
                                         selector:@selector(sendMsg0BOr0D)
                                         userInfo:nil
                                          repeats:YES];
      [self.timer fire];
      [[NSRunLoop mainRunLoop] addTimer:self.timer
                                forMode:NSRunLoopCommonModes];

      self.timerCheckOnline =
          [NSTimer timerWithTimeInterval:kElecRefreshInterval
                                  target:self
                                selector:@selector(checkSwitchState)
                                userInfo:nil
                                 repeats:YES];
      [self.timerCheckOnline
          setFireDate:[NSDate dateWithTimeIntervalSinceNow:2.f]];
      [[NSRunLoop mainRunLoop] addTimer:self.timerCheckOnline
                                forMode:NSDefaultRunLoopMode];
  });
}

- (void)stopScanSwitchState {
  dispatch_async(MAIN_QUEUE, ^{
      _isScanning = NO;
      if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
      }
      if (self.timerCheckOnline) {
        [self.timerCheckOnline invalidate];
        self.timerCheckOnline = nil;
      }
  });
}

- (void)startRealTimeElec {
  [self stopRealTimeElec];
  dispatch_async(MAIN_QUEUE, ^{
      self.timerElec = [NSTimer timerWithTimeInterval:kElecRefreshInterval
                                               target:self
                                             selector:@selector(sendMsg33Or35)
                                             userInfo:nil
                                              repeats:YES];
      [self.timerElec fire];
      [[NSRunLoop mainRunLoop] addTimer:self.timerElec
                                forMode:NSDefaultRunLoopMode];
  });
}

- (void)stopRealTimeElec {
  dispatch_async(MAIN_QUEUE, ^{
      if (self.timerElec) {
        [self.timerElec invalidate];
        self.timerElec = nil;
      }
  });
}

- (void)historyElec:(HistoryElecDateType)dateType
         completion:(HistoryElecBlock)compeltion {
  //  dispatch_async(GLOBAL_QUEUE, ^{
  //      if (!self.historyElec) {
  //        self.historyElec = [[HistoryElec alloc] init];
  //      }
  //      self.dateType = dateType;
  //      self.param =
  //          [self.historyElec getParam:[[NSDate date] timeIntervalSince1970]
  //                            dateType:dateType];
  //      [self senMsg63:self.param];
  //  });

  self.historyElecBlock = compeltion;
  NSString *messageUrl =
      [NSString stringWithFormat:@"%@degrees/list", MessageURLString];
  AFHTTPRequestOperationManager *manager =
      [AFHTTPRequestOperationManager manager];
  manager.responseSerializer = [AFHTTPResponseSerializer serializer];
  if (!self.historyElec) {
    self.historyElec = [[HistoryElec alloc] init];
  }
  self.param = [self.historyElec getParam:0 dateType:dateType];

  NSMutableDictionary *parameters = [@{} mutableCopy];
  [parameters setObject:self.aSwitch.mac forKey:@"mac"];
  //    0 半小时, 1 天  ，2 月.
  [parameters setObject:@(self.param.type) forKey:@"type"];
  [parameters setObject:@(self.param.beginTime) forKey:@"beginTimes"];
  [parameters setObject:@(self.param.endTime) forKey:@"endTimes"];
  [manager POST:messageUrl
      parameters:parameters
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSString *string =
              [[NSString alloc] initWithData:responseObject
                                    encoding:NSUTF8StringEncoding];
          DDLogDebug(@"response msg is %@", string);
          NSDictionary *responseData = __JSON(string);
          int status = [responseData[@"status"] intValue];
          if (status == 1) {
            NSDictionary *data = responseData[@"data"];
            NSArray *degrees = data[@"degrees"];
            HistoryElecData *historyElecData =
                [self.historyElec parseResponse:degrees param:self.param];
            self.historyElecBlock(YES, self.dateType, historyElecData);
          } else {
            self.historyElecBlock(NO, self.dateType, nil);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          self.historyElecBlock(NO, self.dateType, nil);
      }];
}

- (void)checkSwitchState {
  [[SwitchDataCeneter sharedInstance] checkSwitchOnlineState:self.aSwitch];
}

//插孔I定时
- (void)sendMsg17Or19Socket1 {
  [self.request5 sendMsg17Or19:self.aSwitch
                 socketGroupId:1
                      sendMode:ActiveMode];
}

//插孔I延时
- (void)sendMsg53Or55Socket1 {
  [self.request6 sendMsg53Or55:self.aSwitch
                 socketGroupId:1
                      sendMode:ActiveMode];
}

//插孔II定时
- (void)sendMsg17Or19Socket2 {
  [self.request7 sendMsg17Or19:self.aSwitch
                 socketGroupId:2
                      sendMode:ActiveMode];
}

//插孔II延时
- (void)sendMsg53Or55Socket2 {
  [self.request8 sendMsg53Or55:self.aSwitch
                 socketGroupId:2
                      sendMode:ActiveMode];
}

//状态
- (void)sendMsg0BOr0D {
  [self.request1 sendMsg0BOr0D:self.aSwitch sendMode:ActiveMode];
}

//控制开关
- (void)sendMsg11Or13:(SDZGSwitch *)aSwitch groupId:(int)groupId {
  UdpRequest *request;
  if (groupId == 1) {
    self.responseData12Or14GroupId1Count = 0;
    if (!self.request2) {
      self.request2 = [UdpRequest manager];
      self.request2.delegate = self;
    }
    request = self.request2;
  } else {
    self.responseData12Or14GroupId2Count = 0;
    if (!self.request3) {
      self.request3 = [UdpRequest manager];
      self.request3.delegate = self;
    }
    request = self.request3;
  }
  DDLogDebug(@"send requeset is %@ groupId is %d", request, groupId);
  [request sendMsg11Or13:aSwitch socketGroupId:groupId sendMode:ActiveMode];
}

//实时电量
- (void)sendMsg33Or35 {
  DDLogDebug(@"****************************%s*********************************",
             __FUNCTION__);
  [self.request4 sendMsg33Or35:self.aSwitch sendMode:ActiveMode];
}

//历史电量
- (void)senMsg63:(HistoryElecParam *)param {
  [self.request4 sendMsg63:self.aSwitch
                 beginTime:param.beginTime
                   endTime:param.endTime
                  interval:param.interval
                  sendMode:ActiveMode];
}

#pragma mark - UdpRequestDelegate
- (void)udpRequest:(UdpRequest *)request
     didReceiveMsg:(CC3xMessage *)message
           address:(NSData *)address {
  DDLogDebug(@"response request is %@", request);
  switch (message.msgId) {
    //开关状态查询
    case 0xc:
    case 0xe:
      [self responseMsgCOrE:message request:request];
      break;
    //开关控制
    case 0x12:
    case 0x14:
      [self responseMsg12Or14:message request:request];
      break;
    //定时查询
    case 0x18:
    case 0x1a:
      [self responseMsg18Or1A:message];
      break;
    //实时电量
    case 0x34:
    case 0x36:
      [self responseMsg34Or36:message];
      break;
    //查询延时
    case 0x54:
    case 0x56:
      [self responseMsg54Or56:message];
      break;
    //历史电量
    case 0x64:
      [self responseMsg64:message];
      break;
  }
}

- (void)udpRequest:(UdpRequest *)request
    didNotReceiveMsgTag:(long)tag
          socketGroupId:(int)socketGroupId {
  DDLogDebug(@"tag is %ld and socketGroupId is %d", tag, socketGroupId);
  switch (tag) {
    case P2D_CONTROL_REQ_11:
    case P2S_CONTROL_REQ_13: {
      if (self.request2 == request || self.request3 == request) {
        NSDictionary *userInfo = @{
          @"tag" : @(tag),
          @"socketGroupId" : @(socketGroupId)
        };
        [[NSNotificationCenter defaultCenter]
            postNotificationName:kNoResponseNotification
                          object:self
                        userInfo:userInfo];
      }
    } break;
  }
}

- (void)responseMsgCOrE:(CC3xMessage *)message request:(UdpRequest *)request {
  if (message.state == kUdpResponseSuccessCode && request == self.request1) {
    [SDZGSwitch
        parseMessageCOrE:message
                toSwitch:^(SDZGSwitch *aSwitch) {
                    if (aSwitch) {
                      DDLogDebug(@"############## recivied msg info");
                      self.aSwitch = aSwitch;
                      [[SwitchDataCeneter sharedInstance] updateSwitch:aSwitch];
                      [[NSNotificationCenter defaultCenter]
                          postNotificationName:kOneSwitchUpdate
                                        object:self
                                      userInfo:@{
                                        @"switch" : aSwitch
                                      }];
                    }
                }];
  }
}

- (void)responseMsg12Or14:(CC3xMessage *)message request:(UdpRequest *)request {
  DDLogDebug(@"%s socketGroupId is %d", __func__, message.socketGroupId);
  if (message.state == kUdpResponseSuccessCode) {
    if (message.socketGroupId == 1 && self.request2 == request) {
      self.responseData12Or14GroupId1Count++;
      if (self.responseData12Or14GroupId1Count == 1) {
        SDZGSocket *socket =
            [self.aSwitch.sockets objectAtIndex:message.socketGroupId - 1];
        socket.socketStatus = !socket.socketStatus;
        [self.aSwitch.sockets replaceObjectAtIndex:message.socketGroupId - 1
                                        withObject:socket];
        NSDictionary *userInfo = @{
          @"switch" : self.aSwitch,
          @"socketGroupId" : @(message.socketGroupId)
        };
        [[NSNotificationCenter defaultCenter]
            postNotificationName:kSwitchOnOffStateChange
                          object:self
                        userInfo:userInfo];
      }
    } else if (message.socketGroupId == 2 && self.request3 == request) {
      self.responseData12Or14GroupId2Count++;
      if (self.responseData12Or14GroupId2Count == 1) {
        SDZGSocket *socket =
            [self.aSwitch.sockets objectAtIndex:message.socketGroupId - 1];
        socket.socketStatus = !socket.socketStatus;
        [self.aSwitch.sockets replaceObjectAtIndex:message.socketGroupId - 1
                                        withObject:socket];
        NSDictionary *userInfo = @{
          @"switch" : self.aSwitch,
          @"socketGroupId" : @(message.socketGroupId)
        };
        [[NSNotificationCenter defaultCenter]
            postNotificationName:kSwitchOnOffStateChange
                          object:self
                        userInfo:userInfo];
      }
    }
  }
}

- (void)responseMsg18Or1A:(CC3xMessage *)message {
  switch (message.socketGroupId) {
    case 1:
      if (message.timerTaskList) {
        self.socket1TimerBlock(YES, message.timerTaskList);
      } else {
        self.socket1TimerBlock(NO, nil);
      }
      break;
    case 2:
      if (message.timerTaskList) {
        self.socket2TimerBlock(YES, message.timerTaskList);
      } else {
        self.socket2TimerBlock(NO, nil);
      }
      break;
    default:
      break;
  }
}

- (void)responseMsg34Or36:(CC3xMessage *)message {
  DDLogDebug(@"power is %f", message.power);
  float diff = floorf(message.power - kElecDiff);
  float power = diff > 0 ? diff : 0.f;
  DDLogDebug(@"draw is %f", power);
  NSDictionary *userInfo = @{ @"power" : @(power) };
  [[NSNotificationCenter defaultCenter]
      postNotificationName:kRealTimeElecNotification
                    object:self
                  userInfo:userInfo];
}

- (void)responseMsg54Or56:(CC3xMessage *)message {
  switch (message.socketGroupId) {
    case 1:
      if (message.delay > 0) {
        self.socket1DelayBlock(YES, message.delay);
      } else {
        self.socket1DelayBlock(NO, 0);
      }
      break;
    case 2:
      if (message.delay > 0) {
        self.socket2DelayBlock(YES, message.delay);
      } else {
        self.socket2DelayBlock(NO, 0);
      }
      break;
    default:
      break;
  }
}

- (void)responseMsg64:(CC3xMessage *)message {
  if (message.state == kUdpResponseSuccessCode) {
    HistoryElecData *data =
        [self.historyElec parseResponse:message.historyElecs param:self.param];
    //    DDLogDebug(@"times is %@", data.times);
    //    DDLogDebug(@"values is %@", data.values);
    NSDictionary *userInfo = @{
      @"data" : data,
      @"dateType" : @(self.dateType)
    };
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kHistoryElecNotification
                      object:self
                    userInfo:userInfo];
  }
}

#pragma mark - Observer
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  SwitchStatus oldStatus =
      [[change objectForKey:NSKeyValueChangeOldKey] intValue];
  SwitchStatus newStatus =
      [[change objectForKey:NSKeyValueChangeNewKey] intValue];
  if ([keyPath isEqualToString:@"networkStatus"])
    if (oldStatus != newStatus) {
      if (newStatus == SWITCH_OFFLINE) {
        DDLogDebug(@"设备已离线");
      } else {
        DDLogDebug(@"设备已在线");
      }
      if (self.stateChangeBlock) {
        self.stateChangeBlock(newStatus);
      }
    }
}
@end
