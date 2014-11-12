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
@property (nonatomic, assign) int sendMsgCount; //发送消息次数

@property (nonatomic, strong) NSString *mac; //当前执行的设备mac
@property (nonatomic, assign) int socketGroupId; //当前执行设备所要执行的组

@property (nonatomic, strong) responseMsg response;
@property (nonatomic, strong) noResponseMsg noResponse;
@property (nonatomic, strong)
    NSMutableArray *remainingSceneDetails; //剩下待执行的任务
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
}

- (void)executeSceneDetails:(NSArray *)sceneDetails {
  self.taskCount = [sceneDetails count];
  if (self.taskCount) {
    __weak typeof(self) weakSelf = self;
    self.response = ^(NSMutableArray *details) {
        if (details.count) {
          [weakSelf executeFirstOperationInSceneDetails:details];
        }
    };
    self.noResponse = ^(NSMutableArray *details) {
        if (details.count) {
          [weakSelf executeFirstOperationInSceneDetails:details];
        }
    };

    self.remainingSceneDetails = [sceneDetails mutableCopy];
    debugLog(@"details is %@", self.remainingSceneDetails);
    [self executeFirstOperationInSceneDetails:self.remainingSceneDetails];
  }
}

- (void)executeFirstOperationInSceneDetails:(NSMutableArray *)sceneDetails {
  //  __block NSMutableArray *block_sceneDetails = sceneDetails;
  dispatch_async(scene_recive_serial_queue(), ^{
      SceneDetail *sceneDetail = [sceneDetails firstObject];
      if (sceneDetail) {
        SDZGSwitch *aSwitch = sceneDetail.aSwitch;
        SDZGSocket *socket = aSwitch.sockets[sceneDetail.groupId - 1];
        socket.socketStatus = !sceneDetail.onOrOff;

        NSOperation *op = [NSBlockOperation blockOperationWithBlock:^{
            SENDMODE mode;
            self.executeSuccess = NO;
            if (!(self.socketGroupId == sceneDetail.groupId &&
                  self.mac == aSwitch.mac)) {
              self.socketGroupId = sceneDetail.groupId;
              self.mac = aSwitch.mac;
              self.sendMsgCount++;
              NSDictionary *userInfo = @{ @"row" : @(self.sendMsgCount - 1) };
              [[NSNotificationCenter defaultCenter]
                  postNotificationName:kSceneExecuteBeginNotification
                                object:self
                              userInfo:userInfo];
              [NSThread sleepForTimeInterval:0.5f];
              mode = ActiveMode;
            } else {
              mode = PassiveMode;
            }
            debugLog(@"sendMsgCount is %d", self.sendMsgCount);
            [self.request sendMsg11Or13:aSwitch
                          socketGroupId:sceneDetail.groupId
                               sendMode:mode];
        }];
        [op start];
      }
  });
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

- (void)noResponseMsgtag:(long)tag socketGroupId:(int)socketGroupId {
  if (!self.executeSuccess) {
    if (self.remainingSceneDetails.count > 0) {
      [self.remainingSceneDetails removeObjectAtIndex:0];
    }
    debugLog(@"details is %@", self.remainingSceneDetails);
    self.noResponse(self.remainingSceneDetails);
    [self sendNotification];
  }
}

- (void)responseMsg12Or14:(CC3xMessage *)message {
  debugLog(@"message info mac is %@ and socketGroupId is %d", message.mac,
           message.socketGroupId);
  if (!self.executeSuccess && [self.mac isEqualToString:message.mac] &&
      self.socketGroupId == message.socketGroupId) {
    if (self.remainingSceneDetails.count > 0) {
      [self.remainingSceneDetails removeObjectAtIndex:0];
    }
    debugLog(@"details is %@", self.remainingSceneDetails);
    if (message.state == kUdpResponseSuccessCode) {
      self.executeSuccess = YES;
      [self sendNotification];
      self.response(self.remainingSceneDetails);
    } else {
      [self sendNotification];
      self.noResponse(self.remainingSceneDetails);
    }
  } else {
    // TODO:udp包超时后回应，导致前一条请求的响应当做了后一条请求的响应
    //    [self sendNotification];
    self.noResponse(self.remainingSceneDetails);
  }
}

- (void)cancelExecute {
  //  [self.queue cancelAllOperations];
  [self.remainingSceneDetails removeAllObjects];
  self.request.delegate = nil;
  self.request = nil;
}

- (void)sendNotification {
  //  BOOL resulstType; //
  //  NO表示未收到响应，执行失败;YES表示收到响应，执行成功
  //  self.timerExcCount++;
  //  if (self.receivedData) {
  //    debugLog(@"收到数据");
  //    resulstType = YES;
  //  } else {
  //    debugLog(@"未收到数据");
  //    resulstType = NO;
  //  }
  NSDictionary *userInfo = @{
    @"row" : @(self.sendMsgCount - 1),
    @"resultType" : @(self.executeSuccess)
  };
  [[NSNotificationCenter defaultCenter]
      postNotificationName:kSceneExecuteResultNotification
                    object:self
                  userInfo:userInfo];
  if (self.remainingSceneDetails.count == 0) {
    debugLog(@"任务全部完成");
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kSceneExecuteFinishedNotification
                      object:self];
  }
}
@end