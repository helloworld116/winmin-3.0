//
//  ShakeWindow.m
//  winmin 3.0
//
//  Created by sdzg on 15-1-4.
//  Copyright (c) 2015年 itouchco.com. All rights reserved.
//

#import "ShakeWindow.h"
#import "Scene.h"
#import "SceneDetail.h"
#import <CoreMotion/CoreMotion.h>
#import "BackgroundAudioPlay.h"

typedef void (^shakeResponseMsg)(NSMutableArray *);
typedef void (^shakeNoResponseMsg)(NSMutableArray *);
@interface ShakeWindow () <UdpRequestDelegate>
@property (nonatomic, strong) CMMotionManager *manager;
@property (nonatomic, strong) NSOperationQueue *motionQueue;
//用于全局摇一摇
@property (nonatomic, strong) UdpRequest *request;

//控制指定插孔
@property (nonatomic, strong) SDZGSwitch *aSwitch;
@property (nonatomic, assign) int groupId;

//控制场景
@property (nonatomic, strong) Scene *scene;
@property (nonatomic, assign) int taskCount; //任务个数，队列中的数据个数
@property (nonatomic, assign) BOOL executeSuccess;
@property (nonatomic, assign)
    int sendMsgCount; //发送消息次数,每个开关任务对应一条执行次数

@property (nonatomic, strong) NSString *mac; //当前执行的设备mac
@property (nonatomic, assign) int socketGroupId; //当前执行设备所要执行的组
@property (nonatomic, strong) shakeResponseMsg response;
@property (nonatomic, strong) shakeNoResponseMsg noResponse;
@property (nonatomic, strong) NSArray *sceneDetails; //原始的任务
@property (nonatomic, strong)
    NSMutableArray *remainingSceneDetails; //剩下待执行的任务
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSTimer *timerExe;
@property (nonatomic, assign) double leftSeconds; //当前执行任务的剩余时间
@property (nonatomic, strong) SceneDetail *sceneDetail; //当前执行任务
@property (nonatomic, assign) BOOL isFirstExc;

@end

@implementation ShakeWindow

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.request = [UdpRequest manager];
    self.request.delegate = self;
    //    CMMotionManager *manager = [[CMMotionManager alloc] init];
    //    if (!manager.accelerometerAvailable) {
    //      NSLog(@"Accelerometer not available");
    //    } else {
    //      self.motionQueue = [[NSOperationQueue alloc] init];
    //      manager.deviceMotionUpdateInterval = .5f;
    //    }
    //    self.manager = manager;
    //    [[NSNotificationCenter defaultCenter]
    //        addObserver:self
    //           selector:@selector(applicationWillEnterForegroundNotification:)
    //               name:UIApplicationWillEnterForegroundNotification
    //             object:nil];
    //    [[NSNotificationCenter defaultCenter]
    //        addObserver:self
    //           selector:@selector(applicationDidEnterBackgroundNotification:)
    //               name:UIApplicationDidEnterBackgroundNotification
    //             object:nil];
    //    [self registerforDeviceLockNotif];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  CFNotificationCenterRemoveEveryObserver(
      CFNotificationCenterGetDarwinNotifyCenter(), NULL);
}

//#pragma mark - UdpRequestDelegate
//- (void)udpRequest:(UdpRequest *)request
//     didReceiveMsg:(CC3xMessage *)message
//           address:(NSData *)address {
//  switch (message.msgId) { //开关控制
//    case 0x12:
//    case 0x14:
//      [self responseMsg12Or14:message request:request];
//      break;
//  }
//}
//
//- (void)responseMsg12Or14:(CC3xMessage *)message request:(UdpRequest *)request
//{
//  DDLogDebug(@"%s socketGroupId is %d", __func__, message.socketGroupId);
//  if (message.state == kUdpResponseSuccessCode) {
//    SDZGSocket *socket =
//        [self.aSwitch.sockets objectAtIndex:message.socketGroupId - 1];
//    socket.socketStatus = !socket.socketStatus;
//    [self.aSwitch.sockets replaceObjectAtIndex:message.socketGroupId - 1
//                                    withObject:socket];
//  }
//}
#define accelerationThreshold 2.0
- (void)motionMethod:(CMDeviceMotion *)deviceMotion {
  CMAcceleration userAcceleration = deviceMotion.userAcceleration;
  if (fabs(userAcceleration.x) > accelerationThreshold ||
      fabs(userAcceleration.y) > accelerationThreshold ||
      fabs(userAcceleration.z) > accelerationThreshold) {
    DDLogDebug(@"motion shake");
    if (self.scene && kSharedAppliction.networkStatus == ReachableViaWiFi) {
      NSArray *sceneDetails = self.scene.detailList;
      [self executeSceneDetails:sceneDetails];
    }
  }
}

static dispatch_queue_t shake_scene_recive_serial_queue() {
  static dispatch_queue_t sdzg_scene_shake_recive_send_serial_queue;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
      sdzg_scene_shake_recive_send_serial_queue = dispatch_queue_create(
          "serial.shake.scenerecive.com.itouchco.www", DISPATCH_QUEUE_SERIAL);
  });
  return sdzg_scene_shake_recive_send_serial_queue;
}

- (void)setSwitch:(SDZGSwitch *)aSwitch groupId:(int)groupId {
  self.aSwitch = aSwitch;
  self.groupId = groupId;
}

- (void)setShakeScene:(id)scene {
  self.scene = (Scene *)scene;
}

//默认是NO，所以得重写此方法，设成YES
- (BOOL)canBecomeFirstResponder {
  return NO;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
  //  NSLog(@"shake");
  //  if (self.aSwitch && self.groupId) {
  //    [self.request sendMsg11Or13:self.aSwitch
  //                  socketGroupId:self.groupId
  //                       sendMode:ActiveMode];
  //  }
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  BOOL motionEnable = [[userDefaults objectForKey:acceleration] boolValue];
  if (motionEnable && self.scene &&
      kSharedAppliction.networkStatus == ReachableViaWiFi) {
    [[BackgroundAudioPlay sharedInstance] playSound];
    NSArray *sceneDetails = self.scene.detailList;
    [self executeSceneDetails:sceneDetails];
  }
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
}

- (void)executeSceneDetails:(NSArray *)sceneDetails {
  self.sendMsgCount = 0;
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
  self.sceneDetail = sceneDetail;
  self.isFirstExc = isFirstExc;
  double interval = sceneDetail.interval;
  self.leftSeconds = interval;
  if (self.timer) {
    [self.timer invalidate];
    self.timer = nil;
  }
  if (self.timerExe) {
    [self.timerExe invalidate];
    self.timerExe = nil;
  }
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
  dispatch_async(shake_scene_recive_serial_queue(), ^{
      if (sceneDetail) {
        SDZGSwitch *aSwitch = sceneDetail.aSwitch;
        //        if (aSwitch.networkStatus == SWITCH_OFFLINE) {
        //          aSwitch.networkStatus = SWITCH_REMOTE;
        //        }
        aSwitch.networkStatus = SWITCH_LOCAL;
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
      dispatch_sync(shake_scene_recive_serial_queue(),
                    ^{ [self responseMsg12Or14:message]; });

      break;
  }
}

- (void)udpRequest:(UdpRequest *)request
    didNotReceiveMsgTag:(long)tag
          socketGroupId:(int)socketGroupId {
  dispatch_sync(shake_scene_recive_serial_queue(), ^{
      if (!self.executeSuccess) {
        if (self.remainingSceneDetails.count > 0) {
          [self.remainingSceneDetails removeObjectAtIndex:0];
        }
        DDLogDebug(@"details is %@", self.remainingSceneDetails);
        self.noResponse(self.remainingSceneDetails);
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
      self.response(self.remainingSceneDetails);
    }
  } else {
    //收到不在线设备控制的回应
    if (self.remainingSceneDetails.count > 0) {
      [self.remainingSceneDetails removeObjectAtIndex:0];
    }
    DDLogDebug(@"details is %@", self.remainingSceneDetails);
    self.executeSuccess = NO;
    self.response(self.remainingSceneDetails);
  }
}

#pragma mark - 通知
- (void)applicationWillEnterForegroundNotification:(NSNotification *)notif {
  if (self.manager) {
    [self.manager stopDeviceMotionUpdates];
  }
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notif {
  [self.manager startDeviceMotionUpdatesToQueue:self.motionQueue
                                    withHandler:^(CMDeviceMotion *motion,
                                                  NSError *error) {
                                        [self motionMethod:motion];
                                    }];
}

#pragma mark - Screen Lock Event
// call back
static void displayStatusChanged(CFNotificationCenterRef center, void *observer,
                                 CFStringRef name, const void *object,
                                 CFDictionaryRef userInfo) {
  // the "com.apple.springboard.lockcomplete" notification will always come
  // after the "com.apple.springboard.lockstate" notification

  NSString *lockState = (NSString *)CFBridgingRelease(name);
  NSLog(@"Darwin notification NAME = %@", name);

  if ([lockState isEqualToString:@"com.apple.springboard.lockcomplete"]) {
    NSLog(@"DEVICE LOCKED");
  } else if ([lockState isEqualToString:@"com.apple.iokit.hid.displayStatus"]) {
    if (userInfo != nil) {
      CFShow(userInfo);
    }
  } else if ([lockState
                 isEqualToString:@"com.apple.springboard.hasBlankedScreen"]) {
    if (userInfo != nil) {
      CFShow(userInfo);
    }
  } else {
    NSLog(@"LOCK STATUS CHANGED");
  }
}

- (void)registerforDeviceLockNotif {
  // Screen lock notifications
  CFNotificationCenterAddObserver(
      CFNotificationCenterGetDarwinNotifyCenter(), // center
      NULL,                                        // observer
      displayStatusChanged,                        // callback
      CFSTR("com.apple.springboard.lockcomplete"), // event name
      NULL,                                        // object
      CFNotificationSuspensionBehaviorDeliverImmediately);

  CFNotificationCenterAddObserver(
      CFNotificationCenterGetDarwinNotifyCenter(), // center
      NULL,                                        // observer
      displayStatusChanged,                        // callback
      CFSTR("com.apple.springboard.lockstate"),    // event name
      NULL,                                        // object
      CFNotificationSuspensionBehaviorDeliverImmediately);
  CFNotificationCenterAddObserver(
      CFNotificationCenterGetDarwinNotifyCenter(), // center
      NULL,                                        // observer
      displayStatusChanged,                        // callback
      CFSTR("com.apple.iokit.hid.displayStatus"),  // event name
      NULL,                                        // object
      CFNotificationSuspensionBehaviorDeliverImmediately);
  //  CFNotificationCenterAddObserver(
  //      CFNotificationCenterGetDarwinNotifyCenter(),     // center
  //      NULL,                                            // observer
  //      displayStatusChanged,                            // callback
  //      CFSTR("com.apple.springboard.hasBlankedScreen"), // event name
  //      NULL,                                            // object
  //      CFNotificationSuspensionBehaviorDeliverImmediately);
}

@end
