//
//  SceneExecuteModel.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-29.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SceneExecuteModel.h"
#import "SceneDetail.h"

@interface SceneExecuteModel ()<UdpRequestDelegate>
@property(nonatomic, strong) NSOperationQueue *queue;
@property(nonatomic, strong) UdpRequest *request;
@property(nonatomic, assign) BOOL receivedData;
@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, assign) int timerExcCount;  //定时器执行次数
@property(nonatomic, assign) int taskCount;  //任务个数，队列中的数据个数
@end

@implementation SceneExecuteModel
- (id)init {
  self = [super init];
  if (self) {
    self.request = [UdpRequest manager];
    self.request.delegate = self;
    self.queue = [[NSOperationQueue alloc] init];
    [self.queue setMaxConcurrentOperationCount:1];
  }
  return self;
}

- (void)startTimer {
  self.timer = [NSTimer timerWithTimeInterval:1
                                       target:self
                                     selector:@selector(isReceivedData)
                                     userInfo:nil
                                      repeats:YES];
  [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
  [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
  self.timerExcCount = 0;
}

- (void)executeSceneDetails:(NSArray *)sceneDetails {
  self.taskCount = [sceneDetails count];
  dispatch_async(GLOBAL_QUEUE, ^{
      for (SceneDetail *sceneDetail in sceneDetails) {
        SDZGSwitch *aSwitch = sceneDetail.aSwitch;
        SDZGSocket *socket = aSwitch.sockets[sceneDetail.groupId - 1];
        socket.socketStatus = !sceneDetail.onOrOff;
        NSBlockOperation *operation =
            [NSBlockOperation blockOperationWithBlock:^{
                [self sendMsg11Or13:aSwitch groupId:sceneDetail.groupId];
                [NSThread sleepForTimeInterval:1];
            }];
        [self.queue addOperation:operation];
        debugLog(@"######## %@", [sceneDetail description]);
      }
  });
  [self startTimer];
}

- (void)cancelExecute {
  [self.queue cancelAllOperations];
  [self.timer invalidate];
}

- (void)sendMsg11Or13:(SDZGSwitch *)aSwitch groupId:(int)groupId {
  self.receivedData = NO;
  if (!self.request) {
    self.request = [UdpRequest manager];
    self.request.delegate = self;
  }
  [self.request sendMsg11Or13:aSwitch
                socketGroupId:groupId
                     sendMode:ActiveMode];
}

#pragma mark - UdpRequestDelegate
- (void)responseMsg:(CC3xMessage *)message address:(NSData *)address {
  switch (message.msgId) {
    //开关控制
    case 0x12:
    case 0x14:
      [self responseMsg12Or14:message];
      break;
  }
}

- (void)responseMsg12Or14:(CC3xMessage *)message {
  if (message.state == 0) {
    self.receivedData = YES;
  }
}

- (void)isReceivedData {
  BOOL resulstType;  // NO表示未收到响应，执行失败;YES表示收到响应，执行成功
  self.timerExcCount++;
  if (self.receivedData) {
    debugLog(@"收到数据");
    resulstType = YES;
  } else {
    debugLog(@"未收到数据");
    resulstType = NO;
  }
  NSDictionary *userInfo = @{
    @"row" : @(self.timerExcCount - 1),
    @"resultType" : @(resulstType)
  };
  [[NSNotificationCenter defaultCenter]
      postNotificationName:kSceneExecuteResultNotification
                    object:self
                  userInfo:userInfo];
  if (self.timerExcCount == self.taskCount) {
    [self.timer invalidate];
    debugLog(@"任务全部完成");
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kSceneExecuteFinishedNotification
                      object:self];
  }
}
@end
