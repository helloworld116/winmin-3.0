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

typedef void (^successResponse)(void);
typedef void (^failureResponse)(void);

@interface SceneOperation : NSOperation<UdpRequestDelegate> {
  BOOL _executing;
  BOOL _finished;
}
@property (nonatomic, strong) UdpRequest *request;
@property (nonatomic, strong) SDZGSwitch *aSwitch;
@property (nonatomic, assign) int socketGroupId;
@property (nonatomic, assign) BOOL isResponseSuccess;

+ (instancetype)request:(UdpRequest *)request
                aSwitch:(SDZGSwitch *)aSwitch
          socketGroupId:(int)socketGroupId
                success:(successResponse)success
                failure:(failureResponse)failure;

- (void)setCompletionBlockWithSuccess:(successResponse)success
                              failure:(failureResponse)failure;
@end
@implementation SceneOperation

+ (instancetype)request:(UdpRequest *)request
                aSwitch:(SDZGSwitch *)aSwitch
          socketGroupId:(int)socketGroupId
                success:(successResponse)success
                failure:(failureResponse)failure {
  SceneOperation *operation = [[SceneOperation alloc] initWithRequest:request];
  operation.aSwitch = aSwitch;
  operation.socketGroupId = socketGroupId;
  [operation setCompletionBlockWithSuccess:success failure:failure];
  return operation;
}

- (void)setCompletionBlockWithSuccess:(successResponse)success
                              failure:(failureResponse)failure {
  __weak typeof(self) weakSelf = self;
  self.completionBlock = ^{
      if (weakSelf.isResponseSuccess) {
        if (success) {
          success();
        }
      } else {
        if (failure) {
          failure();
        }
      }
  };
}

- (id)initWithRequest:(UdpRequest *)request {
  self = [super init];
  if (self) {
    _executing = NO;
    _finished = NO;
    self.request = request;
    self.request.delegate = self;
  }
  return self;
}

//- (void)start {
//  // Always check for cancellation before launching the task.
//  if ([self isCancelled]) {
//    // Must move the operation to the finished state if it is canceled.
//    [self willChangeValueForKey:@"isFinished"];
//    _finished = YES;
//    [self didChangeValueForKey:@"isFinished"];
//    return;
//  }
//  // If the operation is not canceled, begin executing the task.
//  [self willChangeValueForKey:@"isExecuting"];
//  _executing = YES;
//  [self main];
//  [self didChangeValueForKey:@"isExecuting"];
//}

- (void)main {
  //  [self.request scheduleInRunLoop:[NSRunLoop currentRunLoop]
  //                          forMode:NSRunLoopCommonModes];

  @autoreleasepool {
    if (![self isCancelled]) {
      [self.request sendMsg11Or13:self.aSwitch
                    socketGroupId:self.socketGroupId
                         sendMode:ActiveMode];
      while (!self.isResponseSuccess) {
        // Do some work and set isDone to YES when finished
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate distantFuture]];
        debugLog(@"in runloop");
      }
      debugLog(@"out loop");
    }
    //    [self completeOperation];
  }
}

//- (void)completeOperation {
//  [self willChangeValueForKey:@"isFinished"];
//  [self willChangeValueForKey:@"isExecuting"];
//  _executing = NO;
//  _finished = YES;
//  [self didChangeValueForKey:@"isExecuting"];
//  [self didChangeValueForKey:@"isFinished"];
//}

- (void)cancel {
  [super cancel];
  //取消网络请求
}

//- (BOOL)isConcurrent {
//  return YES;
//}
//
//- (BOOL)isExecuting {
//  return executing;
//}
//- (BOOL)isFinished {
//  return finished;
//}

#pragma mark -  UdpRequestDelegate
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
  self.isResponseSuccess = NO;
  self.completionBlock();
  //  [self completeOperation];
}

- (void)responseMsg12Or14:(CC3xMessage *)message {
  if (message.state == kUdpResponseSuccessCode) {
    self.isResponseSuccess = YES;
  } else {
    self.isResponseSuccess = NO;
  }
  self.completionBlock();
  //  [self completeOperation];
}

@end

/**










test sub operation





 */
typedef void (^completion_block_t)(id result);

@interface MyOperation : NSOperation

// Designated Initializer
// For the sake of testing, parameter count equals the duration in 1/10 seconds
// until the task is fininshed.
- (id)initWithCount:(int)count completion:(completion_block_t)completioHandler;
- (id)initWithRequest:(UdpRequest *)request
              aSwitch:(SDZGSwitch *)aSwitch
        socketGroupId:(int)socketGroupId
              success:(successResponse)success
              failure:(failureResponse)failure;

@property (nonatomic, readonly) id result;
@property (nonatomic, copy) completion_block_t completionHandler;
@property (nonatomic, copy) successResponse success;
@property (nonatomic, copy) failureResponse failure;
@property (nonatomic, strong) UdpRequest *request;
@property (nonatomic, strong) SDZGSwitch *aSwitch;
@property (nonatomic, assign) int socketGroupId;
@end

@implementation MyOperation {
  BOOL _isExecuting;
  BOOL _isFinished;
  BOOL _isResponseSuccess;

  dispatch_queue_t _syncQueue;
  int _count;
  id _result;
  completion_block_t _completionHandler;
  successResponse _success;
  failureResponse _failure;
  id _self; // immortality
}

- (id)initWithCount:(int)count
         completion:(completion_block_t)completionHandler {
  self = [super init];
  if (self) {
    _count = count;
    _syncQueue = dispatch_queue_create("op.sync_queue", NULL);
    _completionHandler = [completionHandler copy];
  }
  return self;
}

- (id)initWithRequest:(UdpRequest *)request
              aSwitch:(SDZGSwitch *)aSwitch
        socketGroupId:(int)socketGroupId
              success:(successResponse)success
              failure:(failureResponse)failure {
  self = [super init];
  if (self) {
    self.request = request;
    self.aSwitch = aSwitch;
    self.socketGroupId = socketGroupId;
    _syncQueue = dispatch_queue_create("op.sync_queue", NULL);
    _success = [success copy];
    _failure = [failure copy];
  }
  return self;
}

- (id)result {
  __block id result;
  dispatch_sync(_syncQueue, ^{ result = _result; });
  return result;
}

- (void)start {
  dispatch_async(_syncQueue, ^{
      if (!self.isCancelled && !_isFinished && !_isExecuting) {
        self.isExecuting = YES;
        _self = self; // make self immortal for the duration of the task
        dispatch_async(dispatch_get_global_queue(0, 0), ^{

            // Simulated work load:
            //            int count = _count;
            //            while (count > 0) {
            //              if (self.isCancelled) {
            //                break;
            //              }
            //              printf(".");
            //              usleep(100 * 1000);
            //              --count;
            //            }
            [self.request sendMsg11Or13:self.aSwitch
                          socketGroupId:self.socketGroupId
                               sendMode:ActiveMode];

            // Set result and terminate
            //            dispatch_async(_syncQueue, ^{
            //                if (_result == nil && count == 0) {
            //                  _result = @"OK";
            //                }
            //                [self terminate];
            //            });
        });
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
      [self responseMsg12Or14:message];
      break;
  }
}

- (void)noResponseMsgtag:(long)tag socketGroupId:(int)socketGroupId {
  _isResponseSuccess = NO;
  [self terminate];
}

- (void)responseMsg12Or14:(CC3xMessage *)message {
  if (message.state == kUdpResponseSuccessCode) {
    _isResponseSuccess = YES;
  } else {
    _isResponseSuccess = NO;
  }
  [self terminate];
}

- (void)terminate {
  self.isExecuting = NO;
  self.isFinished = YES;
  //  completion_block_t completionHandler = _completionHandler;
  //  _completionHandler = nil;
  //  id result = _result;
  _self = nil;
  //  if (completionHandler) {
  //    dispatch_async(dispatch_get_global_queue(0, 0),
  //                   ^{ completionHandler(result); });
  //  }
  successResponse success = _success;
  _success = nil;
  _failure = nil;
  failureResponse failure = _failure;
  if (_isResponseSuccess) {
    if (success) {
      dispatch_async(dispatch_get_global_queue(0, 0), ^{ success(); });
    }
  } else {
    if (failure) {
      dispatch_async(dispatch_get_global_queue(0, 0), ^{ failure(); });
    }
  }
}

- (BOOL)isConcurrent {
  return YES;
}

- (BOOL)isExecuting {
  return _isExecuting;
}
- (void)setIsExecuting:(BOOL)isExecuting {
  if (_isExecuting != isExecuting) {
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = isExecuting;
    [self didChangeValueForKey:@"isExecuting"];
  }
}

- (BOOL)isFinished {
  return _isFinished;
}
- (void)setIsFinished:(BOOL)isFinished {
  if (_isFinished != isFinished) {
    [self willChangeValueForKey:@"isFinished"];
    _isFinished = isFinished;
    [self didChangeValueForKey:@"isFinished"];
  }
}

- (void)cancel {
  dispatch_async(_syncQueue, ^{
      if (_result == nil) {
        NSLog(@"Operation cancelled");
        [super cancel];
        _result =
            [[NSError alloc] initWithDomain:@"MyOperation"
                                       code:-1000
                                   userInfo:@{
                                     NSLocalizedDescriptionKey : @"cancelled"
                                   }];
      }
  });
}

@end

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
  }
  return self;
}

- (void)dealloc {
  //  [self.queue removeObserver:self forKeyPath:@"operations"];
}

- (void)executeSceneDetails:(NSArray *)sceneDetails {
  dispatch_async(GLOBAL_QUEUE, ^{
      self.taskCount = [sceneDetails count];
      if (self.taskCount) {
        NSMutableArray *tmpSceneDetails = [sceneDetails mutableCopy];
        [self executeFirstOperationInSceneDetails:tmpSceneDetails];
      }
      //      for (SceneDetail *sceneDetail in sceneDetails) {
      //        SDZGSwitch *aSwitch = sceneDetail.aSwitch;
      //        SDZGSocket *socket = aSwitch.sockets[sceneDetail.groupId - 1];
      //        socket.socketStatus = !sceneDetail.onOrOff;
      //        MyOperation *op = [[MyOperation alloc]
      //        initWithRequest:self.request
      //            aSwitch:aSwitch
      //            socketGroupId:sceneDetail.groupId
      //            success:^{
      //                debugLog(@"#success %d", [self.queue operationCount]);
      //                for (NSOperation *op2 in self.queue.operations) {
      //                  debugLog(@"redy:%d, execute:%d,finished:%d",
      //                  op2.isReady,
      //                           op2.isExecuting, op2.isFinished);
      //                }
      //
      //            }
      //            failure:^{ debugLog(@"#failure"); }];
      //        //        //        [op start];
      //        //        NSOperation *op = [NSBlockOperation
      //        blockOperationWithBlock:^{
      //        //
      //        //            dispatch_sync(GLOBAL_QUEUE, ^{
      //        //                for (int i = 0; i <= 100; i++) {
      //        //                  if (i == 100) {
      //        //                    debugLog(@"i is 100");
      //        //                    for (NSOperation *op2 in
      //        self.queue.operations) {
      //        //                      debugLog(@"redy:%d,execute: %d,
      //        finished: %d ",
      //        //                               op2.isReady, op2.isExecuting,
      //        //                               op2.isFinished);
      //        //                    }
      //        //                  }
      //        //                }
      //        //                int sleepInterval = arc4random() % 10 + 1;
      //        //                debugLog(@"arc is %d", sleepInterval);
      //        //                dispatch_async(GLOBAL_QUEUE, ^{
      //        //                    [NSThread
      //        sleepForTimeInterval:sleepInterval];
      //        //                    for (NSOperation *op2 in
      //        self.queue.operations) {
      //        //                      debugLog(@"redy:%d,
      //        execute:%d,finished:%d",
      //        //                      op2.isReady,
      //        //                               op2.isExecuting,
      //        op2.isFinished);
      //        //                    }
      //        //                });
      //        //            });
      //        //        }];
      //
      //        //        NSOperation *op = [NSBlockOperation
      //        blockOperationWithBlock:^{
      //        //            dispatch_sync(GLOBAL_QUEUE, ^{
      //        //                [self.request sendMsg11Or13:aSwitch
      //        // socketGroupId:sceneDetail.groupId
      //        //                                   sendMode:ActiveMode];
      //        //                //                [NSThread
      //        sleepForTimeInterval:3];
      //        //            });
      //        //
      //        //        }];
      //        op.completionBlock = ^{ debugLog(@"completion"); };
      //        [self.queue addOperation:op];
      //      }
  });
}

- (void)executeFirstOperationInSceneDetails:(NSMutableArray *)sceneDetails {
  __block NSMutableArray *block_sceneDetails = sceneDetails;
  SceneDetail *sceneDetail = [sceneDetails firstObject];
  if (sceneDetail) {
    SDZGSwitch *aSwitch = sceneDetail.aSwitch;
    SDZGSocket *socket = aSwitch.sockets[sceneDetail.groupId - 1];
    socket.socketStatus = !sceneDetail.onOrOff;

    MyOperation *op = [[MyOperation alloc] initWithRequest:self.request
        aSwitch:aSwitch
        socketGroupId:sceneDetail.groupId
        success:^{
            debugLog(@"#success");
            [block_sceneDetails removeObjectAtIndex:0];
            [self executeFirstOperationInSceneDetails:block_sceneDetails];
        }
        failure:^{
            debugLog(@"#failure");
            [block_sceneDetails removeObjectAtIndex:0];
            [self executeFirstOperationInSceneDetails:block_sceneDetails];
        }];
    [op start];
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
      [self responseMsg12Or14:message];
      break;
  }
}

- (void)noResponseMsgtag:(long)tag socketGroupId:(int)socketGroupId {
}

- (void)responseMsg12Or14:(CC3xMessage *)message {
}

- (void)cancelExecute {
  [self.queue cancelAllOperations];
}

//- (void)isReceivedData {
//  BOOL resulstType; // NO表示未收到响应，执行失败;YES表示收到响应，执行成功
//  self.timerExcCount++;
//  if (self.receivedData) {
//    debugLog(@"收到数据");
//    resulstType = YES;
//  } else {
//    debugLog(@"未收到数据");
//    resulstType = NO;
//  }
//  NSDictionary *userInfo = @{
//    @"row" : @(self.timerExcCount - 1),
//    @"resultType" : @(resulstType)
//  };
//  [[NSNotificationCenter defaultCenter]
//      postNotificationName:kSceneExecuteResultNotification
//                    object:self
//                  userInfo:userInfo];
//  if (self.timerExcCount == self.taskCount) {
//    debugLog(@"任务全部完成");
//    [[NSNotificationCenter defaultCenter]
//        postNotificationName:kSceneExecuteFinishedNotification
//                      object:self];
//  }
//}
@end