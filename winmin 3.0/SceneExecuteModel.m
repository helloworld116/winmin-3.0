//
//  SceneExecuteModel.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-29.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SceneExecuteModel.h"
#import "SceneDetail.h"

typedef void (^responseMsg)(NSMutableArray *);
typedef void (^noResponseMsg)(NSMutableArray *);

static dispatch_queue_t scene_recive_serial_queue() {
  static dispatch_queue_t sdzg_scene_recive_send_serial_queue;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
      sdzg_scene_recive_send_serial_queue = dispatch_queue_create(
          "serial.scenerecive.com.itouchco.www", DISPATCH_QUEUE_SERIAL);
  });
  return sdzg_scene_recive_send_serial_queue;
}

@interface SceneExecuteModel () <UdpRequestDelegate>
@property (nonatomic, strong) UdpRequest *request;
@property (nonatomic, assign) int taskCount; //任务个数，队列中的数据个数
@property (nonatomic, assign) BOOL executeSuccess;
@property (nonatomic, assign)
    int sendMsgCount; //发送消息次数,每个开关任务对应一条执行次数

@property (nonatomic, strong) NSString *mac; //当前执行的设备mac
@property (nonatomic, assign) int socketGroupId; //当前执行设备所要执行的组

@property (nonatomic, strong) responseMsg response;
@property (nonatomic, strong) noResponseMsg noResponse;
@property (nonatomic, strong) NSArray *sceneDetails; //原始的任务
@property (nonatomic, strong)
    NSMutableArray *remainingSceneDetails; //剩下待执行的任务
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSTimer *timerExe;
@property (nonatomic, assign) double leftSeconds; //当前执行任务的剩余时间
@end

@implementation SceneExecuteModel
- (id)init {
  self = [super init];
  if (self) {
    self.request = [UdpRequest manager];
    self.request.delegate = self;
  }
  return self;
}

- (void)dealloc {
  //  [self.queue removeObserver:self forKeyPath:@"operations"];
  DDLogDebug(@"%s", __FUNCTION__);
  self.request.delegate = nil;
}

- (void)executeSceneDetails:(NSArray *)sceneDetails {
  self.taskCount = [sceneDetails count];
  if (self.taskCount) {
    self.sceneDetails = sceneDetails;
    __weak typeof(self) weakSelf = self;
    self.response = ^(NSMutableArray *details) {
        if (details.count) {
          [weakSelf executeFirstOperationInSceneDetails:details isFirstExc:NO];
        }
    };
    self.noResponse = ^(NSMutableArray *details) {
        if (details.count) {
          [weakSelf executeFirstOperationInSceneDetails:details isFirstExc:NO];
        }
    };

    self.remainingSceneDetails = [sceneDetails mutableCopy];
    DDLogDebug(@"details is %@", self.remainingSceneDetails);
    [self executeFirstOperationInSceneDetails:self.remainingSceneDetails
                                   isFirstExc:YES];
  }
}

- (void)executeFirstOperationInSceneDetails:(NSMutableArray *)sceneDetails
                                 isFirstExc:(BOOL)isFirstExc {
  SceneDetail *sceneDetail = [sceneDetails firstObject];
  double interval = sceneDetail.interval;
  self.leftSeconds = interval;
  self.timer = [NSTimer timerWithTimeInterval:1
                                       target:self
                                     selector:@selector(timerAction:)
                                     userInfo:@(self.sendMsgCount)
                                      repeats:YES];
  [self.timer fire];
  [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];

  self.timerExe = [NSTimer timerWithTimeInterval:NSIntegerMax
                                          target:self
                                        selector:@selector(sendRequest:)
                                        userInfo:@{
                                          @"sceneDetail" : sceneDetail,
                                          @"isFirstExc" : @(isFirstExc)
                                        }
                                         repeats:NO];

  [self.timerExe setFireDate:[NSDate dateWithTimeIntervalSinceNow:interval]];
  [[NSRunLoop mainRunLoop] addTimer:self.timerExe forMode:NSRunLoopCommonModes];
}

- (void)sendRequest:(NSTimer *)timer {
  NSDictionary *userInfo = timer.userInfo;
  BOOL isFirstExc = [userInfo[@"isFirstExc"] boolValue];
  SceneDetail *sceneDetail = userInfo[@"sceneDetail"];
  dispatch_async(scene_recive_serial_queue(), ^{
      if (sceneDetail) {
        SDZGSwitch *aSwitch = sceneDetail.aSwitch;
        if (aSwitch.networkStatus == SWITCH_OFFLINE) {
          aSwitch.networkStatus = SWITCH_REMOTE;
        }
        SDZGSocket *socket = aSwitch.sockets[sceneDetail.groupId - 1];
        socket.socketStatus = !sceneDetail.onOrOff;
        NSOperation *op = [NSBlockOperation blockOperationWithBlock:^{
            SENDMODE mode = ActiveMode;
            self.executeSuccess = NO;
            if (self.sendMsgCount < self.sceneDetails.count) {
              if (isFirstExc ||
                  ([sceneDetail
                      isEqual:self.sceneDetails[self.sendMsgCount]])) {
                self.socketGroupId = sceneDetail.groupId;
                self.mac = aSwitch.mac;
                self.sendMsgCount++;
                NSDictionary *userInfo = @{ @"row" : @(self.sendMsgCount - 1) };
                [[NSNotificationCenter defaultCenter]
                    postNotificationName:kSceneExecuteBeginNotification
                                  object:self
                                userInfo:userInfo];
                mode = ActiveMode;
              } else {
                mode = PassiveMode;
              }
            }
            DDLogDebug(@"sendMsgCount is %d", self.sendMsgCount);
            [self.request sendMsg11Or13:aSwitch
                          socketGroupId:sceneDetail.groupId
                               sendMode:mode];
        }];
        [op start];
      }
  });
}

- (void)timerAction:(NSTimer *)timer {
  int row = [timer.userInfo intValue];
  DDLogDebug(@"row is %d", row);
  NSDictionary *userInfo = @{
    @"row" : @(row),
    @"leftSeconds" : @(self.leftSeconds)
  };
  [[NSNotificationCenter defaultCenter]
      postNotificationName:kSceneExecuteLeftTimeNotification
                    object:self
                  userInfo:userInfo];
  self.leftSeconds -= 1.f;
  if (self.leftSeconds < 0) {
    [self.timer invalidate];
    self.timer = nil;
  }
}

#pragma mark - UdpRequestDelegate
- (void)udpRequest:(UdpRequest *)request
     didReceiveMsg:(CC3xMessage *)message
           address:(NSData *)address {
  switch (message.msgId) {
    //开关控制
    case 0x12:
    case 0x14:
      dispatch_sync(scene_recive_serial_queue(),
                    ^{ [self responseMsg12Or14:message]; });

      break;
  }
}

- (void)udpRequest:(UdpRequest *)request
    didNotReceiveMsgTag:(long)tag
          socketGroupId:(int)socketGroupId {
  dispatch_sync(scene_recive_serial_queue(), ^{
      if (!self.executeSuccess) {
        if (self.remainingSceneDetails.count > 0) {
          [self.remainingSceneDetails removeObjectAtIndex:0];
        }
        DDLogDebug(@"details is %@", self.remainingSceneDetails);
        self.noResponse(self.remainingSceneDetails);
        [self sendNotification];
      }
  });
}

- (void)responseMsg12Or14:(CC3xMessage *)message {
  DDLogDebug(@"message info mac is %@ and socketGroupId is %d", message.mac,
             message.socketGroupId);
  if (message.state == kUdpResponseSuccessCode) {
    if (!self.executeSuccess) {
      if (self.remainingSceneDetails.count > 0) {
        [self.remainingSceneDetails removeObjectAtIndex:0];
      }
      DDLogDebug(@"details is %@", self.remainingSceneDetails);
      self.executeSuccess = YES;
      [self sendNotification];
      self.response(self.remainingSceneDetails);
    }
  } else {
    //收到不在线设备控制的回应
    if (self.remainingSceneDetails.count > 0) {
      [self.remainingSceneDetails removeObjectAtIndex:0];
    }
    DDLogDebug(@"details is %@", self.remainingSceneDetails);
    self.executeSuccess = NO;
    [self sendNotification];
    self.response(self.remainingSceneDetails);
  }

  //  if (!self.executeSuccess && [self.mac isEqualToString:message.mac] &&
  //      self.socketGroupId == message.socketGroupId) {
  //    if (self.remainingSceneDetails.count > 0) {
  //      [self.remainingSceneDetails removeObjectAtIndex:0];
  //    }
  //    DDLogDebug(@"details is %@", self.remainingSceneDetails);
  //    if (message.state == kUdpResponseSuccessCode) {
  //      self.executeSuccess = YES;
  //      [self sendNotification];
  //      self.response(self.remainingSceneDetails);
  //    } else {
  //      [self sendNotification];
  //      self.noResponse(self.remainingSceneDetails);
  //    }
  //  } else {
  //    // TODO:udp包超时后回应，导致前一条请求的响应当做了后一条请求的响应
  //    //    [self sendNotification];
  //    self.noResponse(self.remainingSceneDetails);
  //  }
}

- (void)cancelExecute {
  //  [self.queue cancelAllOperations];
  [self.timer invalidate];
  self.timer = nil;
  [self.timerExe invalidate];
  self.timerExe = nil;
  [self.remainingSceneDetails removeAllObjects];
  self.request.delegate = nil;
  self.request = nil;
}

- (void)sendNotification {
  NSDictionary *userInfo = @{
    @"row" : @(self.sendMsgCount - 1),
    @"resultType" : @(self.executeSuccess)
  };
  [[NSNotificationCenter defaultCenter]
      postNotificationName:kSceneExecuteResultNotification
                    object:self
                  userInfo:userInfo];
  if (self.remainingSceneDetails.count == 0) {
    DDLogDebug(@"任务全部完成");
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kSceneExecuteFinishedNotification
                      object:self];
  }
}
@end