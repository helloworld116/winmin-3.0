//
//  SceneExecuteModel.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-29.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SceneExecuteModel.h"
#import "SceneDetail.h"

// static dispatch_queue_t scene_suspend_queue() {
//  static dispatch_queue_t sdzg_scene_suspend_queue;
//  static dispatch_once_t onceToken;
//  dispatch_once(&onceToken, ^{
//      sdzg_scene_suspend_queue = dispatch_queue_create(
//          "serial.scene.suspend.com.itouchco.www", DISPATCH_QUEUE_SERIAL);
//  });
//  return sdzg_scene_suspend_queue;
//}

@interface SceneExecuteModel () <UdpRequestDelegate>
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) UdpRequest *request;
@property (nonatomic, assign) BOOL receivedData;
@property (nonatomic, assign) int timerExcCount; //定时器执行次数
@property (nonatomic, assign) int taskCount; //任务个数，队列中的数据个数
@end

@implementation SceneExecuteModel
- (id)init {
  self = [super init];
  if (self) {
    self.request = [UdpRequest manager];
    self.request.delegate = self;
    self.queue = [[NSOperationQueue alloc] init];
    [self.queue setMaxConcurrentOperationCount:1];
    [self.queue setSuspended:YES];
    //    [self.queue addObserver:self
    //                 forKeyPath:@"operations"
    //                    options:0
    //                    context:nil];
  }
  return self;
}

- (void)dealloc {
  //  [self.queue removeObserver:self forKeyPath:@"operations"];
}

- (void)executeSceneDetails:(NSArray *)sceneDetails {
  self.taskCount = [sceneDetails count];
  for (SceneDetail *sceneDetail in sceneDetails) {
    SDZGSwitch *aSwitch = sceneDetail.aSwitch;
    SDZGSocket *socket = aSwitch.sockets[sceneDetail.groupId - 1];
    socket.socketStatus = !sceneDetail.onOrOff;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [self sendMsg11Or13:aSwitch groupId:sceneDetail.groupId];
    }];
    operation.completionBlock =
        ^{ debugLog(@"*****######## %@", [sceneDetail description]); };
    NSOperation *dependencyOperation = [self.queue.operations lastObject];
    if (dependencyOperation) {
      [operation addDependency:dependencyOperation];
    }

    [self.queue addOperation:operation];
    debugLog(@"######## %@", [sceneDetail description]);
  }
  [self.queue setSuspended:NO];
}

- (void)cancelExecute {
  [self.queue cancelAllOperations];
}

- (void)sendMsg11Or13:(SDZGSwitch *)aSwitch groupId:(int)groupId {
  //  debugLog(@"%s operation count is %d", __func__,
  //  self.queue.operationCount);
  //  for (NSOperation *op in [self.queue operations]) {
  //    debugLog(@"ready:%d,executing:%d,finished:%d", op.isReady, op.executing,
  //             op.finished);
  //  }
  self.receivedData = NO;
  [self.request sendMsg11Or13:aSwitch
                socketGroupId:groupId
                     sendMode:ActiveMode];
  [self.queue setSuspended:YES];

  //  for (int i = 0; i < 1000; i++) {
  //    debugLog(@"..........%d", i);
  //    if (i == 1000) {
  //      [self.queue setSuspended:NO];
  //    }
  //  }
  //  [self.queue setSuspended:YES];
  //  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 *
  //  NSEC_PER_SEC)),
  //                 dispatch_get_main_queue(), ^{});
}

#pragma mark - UdpRequestDelegate
- (void)udpRequest:(UdpRequest *)request
     didReceiveMsg:(CC3xMessage *)message
           address:(NSData *)address {
  switch (message.msgId) {
    //开关控制
    case 0x12:
    case 0x14:
      [self responseMsg12Or14:message];
      break;
  }
}

- (void)noResponseMsgtag:(long)tag socketGroupId:(int)socketGroupId {
  //  if ([self.queue isSuspended]) {
  //    debugLog(@"%s queue 被挂起", __func__);
  //  } else {
  //    debugLog(@"%s queue 未被挂起", __func__);
  //  }
  //  debugLog(@"%s operation count is %d", __func__,
  //  self.queue.operationCount);
  //  dispatch_sync(scene_suspend_queue(), ^{
  //      if (self.queue.isSuspended) {
  //        [self.queue setSuspended:NO];
  //      }
  //  });
}

- (void)responseMsg12Or14:(CC3xMessage *)message {
  //  if ([self.queue isSuspended]) {
  //    debugLog(@"%s queue 被挂起", __func__);
  //  } else {
  //    debugLog(@"%s queue 未被挂起", __func__);
  //  }
  //  debugLog(@"%s operation count is %d", __func__,
  //  self.queue.operationCount);
  for (NSOperation *op in [self.queue operations]) {
    debugLog(@"ready:%d,executing:%d,finished:%d", op.isReady, op.executing,
             op.finished);
  }

  [self.queue setSuspended:NO];
  if (message.state == kUdpResponseSuccessCode) {
    self.receivedData = YES;
  }
}

- (void)isReceivedData {
  BOOL resulstType; // NO表示未收到响应，执行失败;YES表示收到响应，执行成功
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
    debugLog(@"任务全部完成");
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kSceneExecuteFinishedNotification
                      object:self];
  }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if (object == self.queue && [keyPath isEqualToString:@"operations"]) {
    debugLog(@"######### operations changed");
    if (0 == self.queue.operations.count) {
      debugLog(@"parse finished");
      // other operation
      [self.queue setSuspended:YES];
    }
  } else {
    [super observeValueForKeyPath:keyPath
                         ofObject:object
                           change:change
                          context:context];
  }
}
@end

@interface SceneOperation : NSOperation {
  BOOL executing;
  BOOL finished;
}
- (void)completeOperation;
@end
@implementation SceneOperation
- (id)init {
  self = [super init];
  if (self) {
    executing = NO;
    finished = NO;
  }
  return self;
}
- (void)start {
  // Always check for cancellation before launching the task.
  if ([self isCancelled]) {
    // Must move the operation to the finished state if it is canceled.
    [self willChangeValueForKey:@"isFinished"];
    finished = YES;
    [self didChangeValueForKey:@"isFinished"];
    return;
  }
  // If the operation is not canceled, begin executing the task.
  [self willChangeValueForKey:@"isExecuting"];
  [self main];
  executing = YES;
  [self didChangeValueForKey:@"isExecuting"];
}

- (void)main {
  @autoreleasepool {
    BOOL isDone = NO;
    while (![self isCancelled] && !isDone) {
      // Do some work and set isDone to YES when finished
    }
    [self completeOperation];
  }
}

- (void)completeOperation {
  [self willChangeValueForKey:@"isFinished"];
  [self willChangeValueForKey:@"isExecuting"];
  executing = NO;
  finished = YES;
  [self didChangeValueForKey:@"isExecuting"];
  [self didChangeValueForKey:@"isFinished"];
}

- (void)cancel {
  [super cancel];
  //取消网络请求
}

- (BOOL)isConcurrent {
  return YES;
}

- (BOOL)isExecuting {
  return executing;
}
- (BOOL)isFinished {
  return finished;
}
@end
