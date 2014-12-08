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
@property (nonatomic, strong) SDZGSwitch *aSwitch;
@property (nonatomic, strong) HistoryElec *historyElec;
@property (nonatomic, strong) HistoryElecParam *param;
@property (nonatomic, assign) HistoryElecDateType dateType;

@property (nonatomic, copy) SwitchStateChangeBlock stateChangeBlock;

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
  if (self.aSwitch) {
    [self.aSwitch removeObserver:self forKeyPath:@"networkStatus"];
  }
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
                                forMode:NSDefaultRunLoopMode];

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

- (void)historyElec:(HistoryElecDateType)dateType {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (!self.historyElec) {
        self.historyElec = [[HistoryElec alloc] init];
      }
      self.dateType = dateType;
      self.param =
          [self.historyElec getParam:[[NSDate date] timeIntervalSince1970]
                            dateType:dateType];
      [self senMsg63:self.param];
  });
}

- (void)checkSwitchState {
  [[SwitchDataCeneter sharedInstance] checkSwitchOnlineState:self.aSwitch];
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
    //实时电量
    case 0x34:
    case 0x36:
      [self responseMsg34Or36:message];
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
