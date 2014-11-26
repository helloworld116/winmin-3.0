//
//  TestViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-30.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "TestViewController.h"
//#import "ElecRealTimeView.h"
#import <NCISimpleChartView.h>
#import <NCIZoomGraphView.h>
#import "HistoryElec.h"

typedef void (^successResponse)(void);
typedef void (^failureResponse)(void);

#pragma mark - MyOperation
/**
 Canonical, Concurrent Subclass of NSOperation
 */

#pragma mark - TestOperation
@interface TestOperation : NSOperation {
  BOOL executing;
  BOOL finished;
}
@property (nonatomic, assign) BOOL isResponseSuccess;
@property (nonatomic, assign) int outValue;
- (id)initWithSuccess:(successResponse)success
              failure:(failureResponse)failure
             outValue:(int)outValue;
@end

@implementation TestOperation

- (id)initWithSuccess:(successResponse)success
              failure:(failureResponse)failure
             outValue:(int)outValue {
  self = [super init];
  if (self) {
    executing = NO;
    finished = NO;
    self.outValue = outValue;
    [self setCompletionBlockWithSuccess:success failure:failure];
  }
  return self;
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
  executing = YES;
  [self main];
  [self didChangeValueForKey:@"isExecuting"];
}

- (void)main {
  @autoreleasepool {
    if (![self isCancelled]) {
      [self simulationUdpRequest];
      while (!self.isResponseSuccess) {
        // Do some work and set isDone to YES when finished
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate distantFuture]];
      }
      DDLogDebug(@"out while");
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
- (void)simulationUdpRequest {
  dispatch_async(GLOBAL_QUEUE, ^{
      for (int i = 0; i <= 500; i++) {
        DDLogDebug(@"i is %d j is %d", self.outValue, i);
        if (i == 500) {
          self.isResponseSuccess = YES;
          self.completionBlock();
          DDLogDebug(@"response data recived");
          [NSThread sleepForTimeInterval:1];
        }
      }
  });
  DDLogDebug(@"request send");
}

@end

//
//
//
//
//
//
#pragma mark - MyOperation
//// MyOperation.h
// typedef void (^MyOperationAction)(void);
//@interface MyOperation : NSOperation
//- (id)initWithAction:(MyOperationAction)action
//             success:(successResponse)success
//             failure:(failureResponse)failure;
//@end
//// MyOperation.m
//
// typedef NS_ENUM(NSInteger, MyOperationState) {
//  MyOperationReadyState = 1,
//  MyOperationExecutingState,
//  MyOperationFinishedState
//};
//@interface MyOperation () {
//  MyOperationAction _action;
//  MyOperationState _state;
//}
//@property (nonatomic, copy) MyOperationAction action;
//@property (nonatomic, assign) MyOperationState state;
//@property (nonatomic, readonly, getter=isCancelled) BOOL cancel;
//@end
//
//@implementation MyOperation
//
//#pragma mark - Override
//- (BOOL)isConcurrent {
//  return YES;
//}
//
//- (BOOL)isExecuting {
//  return self.state == MyOperationExecutingState;
//}
//
//- (BOOL)isFinished {
//  return self.state == MyOperationFinishedState;
//}
//
//- (BOOL)isReady {
//  return self.state == MyOperationReadyState;
//}
//
//- (void)cancel {
//  [self willChangeValueForKey:@"isCancelled"];
//  _cancel = YES;
//  [self didChangeValueForKey:@"isCancelled"];
//}
//
//+ (void)keepThreadAlive {
//  do {
//    @autoreleasepool {
//      [[NSRunLoop currentRunLoop] run];
//    }
//  } while (YES);
//}
//
//+ (NSThread *)threadForMyOperation {
//  static NSThread *_threadInstance = nil;
//  static dispatch_once_t onceToken;
//  dispatch_once(&onceToken, ^{
//      _threadInstance =
//          [[NSThread alloc] initWithTarget:self
//                                  selector:@selector(keepThreadAlive)
//                                    object:nil];
//      _threadInstance.name = @"MyOperation.Thread";
//      [_threadInstance start];
//  });
//  return _threadInstance;
//}
//
//- (void)start {
//  if ([self isReady]) {
//
//    [self willChangeValueForKey:@"isExecuting"];
//    [self willChangeValueForKey:@"isReady"];
//    _state = MyOperationExecutingState;
//    [self didChangeValueForKey:@"isReady"];
//    [self didChangeValueForKey:@"isExecuting"];
//
//    [self performSelector:@selector(operationDidStart)
//                 onThread:[[self class] threadForMyOperation]
//               withObject:nil
//            waitUntilDone:NO];
//  }
//}
//
//- (void)operationDidStart {
//  if (self.isCancelled) {
//    [self willChangeValueForKey:@"isFinished"];
//    [self willChangeValueForKey:@"isCancelled"];
//    _state = MyOperationFinishedState;
//    [self didChangeValueForKey:@"isCancelled"];
//    [self didChangeValueForKey:@"isFinished"];
//  } else {
//    NSLog(@"Operation is running %@ thread", [NSThread currentThread]);
//    self.action();
//    [self willChangeValueForKey:@"isFinished"];
//    [self willChangeValueForKey:@"isExecuting"];
//    _state = MyOperationFinishedState;
//    [self didChangeValueForKey:@"isExecuting"];
//    [self didChangeValueForKey:@"isFinished"];
//  }
//}
//@end

@interface TestViewController ()
//@property(nonatomic, strong) IBOutlet ElecRealTimeView *realTimeView;
@property (nonatomic, strong) NCISimpleChartView *chartView;
@property (nonatomic, strong) IBOutlet UIView *containerView;

@property (nonatomic, strong) NSOperationQueue *queue;
@end

@implementation TestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self startQueue];
}

- (void)startQueue {
  self.queue = [[NSOperationQueue alloc] init];
  self.queue.maxConcurrentOperationCount = 1;

  dispatch_async(GLOBAL_QUEUE, ^{
      for (int i = 0; i < 5; i++) {
        //        TestOperation *op = [[TestOperation alloc] initWithSuccess:^{
        //            DDLogDebug(@"i is %d", i);
        //            //        [self.queue.operations[0] cancel];
        //        } failure:^{
        //
        //        } outValue:i];
        //        //        DDLogDebug(@"1 start %d", i);
        //        //        [op start];
        //        //        DDLogDebug(@"2 start %d", i);
        //        //        [NSThread sleepForTimeInterval:1];
        //        MyOperation *op = [[MyOperation alloc]
        //            initWithCount:100
        //               completion:^(id result) { DDLogDebug(@"result is %@",
        //               result); }];
        //        [self.queue addOperation:op];
      }
  });

  //  [self.queue waitUntilAllOperationsAreFinished];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end