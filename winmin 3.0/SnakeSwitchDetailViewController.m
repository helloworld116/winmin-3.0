//
//  SnakeSwitchDetailViewController.m
//  winmin 3.0
//
//  Created by sdzg on 15-3-24.
//  Copyright (c) 2015年 itouchco.com. All rights reserved.
//

#import "SnakeSwitchDetailViewController.h"
#import "ElecView.h"
#import "SnakeSocketView.h"
#import "SocketImgTemplateViewController.h"
#import "SwitchDetailModel.h"
#import "SwitchInfoViewController.h"
#import "DelayViewController.h"
#import "TimerViewController.h"
#import <CRToast.h>

@interface SnakeSwitchDetailViewController () <
    SnakeSocketViewDelegate, SocketImgTemplateDelegate, ElecViewDelegate,
    MBProgressHUDDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//@property (weak, nonatomic) IBOutlet SocketView *socketView1;
//@property (weak, nonatomic) IBOutlet SocketView *socketView2;
@property (weak, nonatomic) IBOutlet SnakeSocketView *socketView;
@property (weak, nonatomic) IBOutlet ElecView *elecView;
@property (strong, nonatomic) SwitchDetailModel *model;

@property (assign, nonatomic) BOOL showingRealTimeElecView;
@property (strong, nonatomic) NSMutableArray *powers; //保存实时电量数据

@property (strong, nonatomic) UIView *errorMsgView;
@property (nonatomic, strong) MBProgressHUD *HUD;

@end

@implementation SnakeSwitchDetailViewController

- (void)setup {
  UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
  backButtonItem.title = NSLocalizedString(@"Back", nil);
  self.navigationItem.backBarButtonItem = backButtonItem;

  self.navigationItem.rightBarButtonItem =
      [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"info"]
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(shwoInfo:)];
  //  self.navigationItem.rightBarButtonItem setTarget:@selector()

  self.navigationItem.title = self.aSwitch.name;
  self.HUD = [[MBProgressHUD alloc] initWithWindow:kSharedAppliction.window];
  [self.view addSubview:self.HUD];
  self.HUD.delegate = self;

  //    if (!self.aSwitch.sockets || [self.aSwitch.sockets count] != 2) {
  //      self.aSwitch.sockets = [@[] mutableCopy];
  //      SDZGSocket *socket1 = [[SDZGSocket alloc] init];
  //      socket1.groupId = 1;
  //      socket1.socketStatus = SocketStatusOff;
  //      socket1.imageNames =
  //          @[ socket_default_image, socket_default_image,
  //          socket_default_image
  //          ];
  //      [self.aSwitch.sockets addObject:socket1];
  //
  //      SDZGSocket *socket2 = [[SDZGSocket alloc] init];
  //      socket2.groupId = 2;
  //      socket2.socketStatus = SocketStatusOff;
  //      socket2.imageNames =
  //          @[ socket_default_image, socket_default_image,
  //          socket_default_image
  //          ];
  //      [self.aSwitch.sockets addObject:socket2];
  //    }

  self.socketView.sockeViewDelegate = self;
  self.socketView.groupId = 1;
  SDZGSocket *socket = [self.aSwitch.sockets objectAtIndex:0];
  [self.socketView setSocketInfo:socket];

  self.elecView.layer.borderColor =
      [UIColor colorWithHexString:@"#C3C3C3" alpha:1].CGColor;
  self.elecView.layer.cornerRadius = 5.f;
  self.elecView.layer.borderWidth = 1.f;
  self.elecView.layer.masksToBounds = YES;
  self.elecView.delegate = self;

  self.errorMsgView =
      [[UIView alloc] initWithFrame:CGRectMake(0, -20, SCREEN_WIDTH, 20)];
  UILabel *lblMsg = [[UILabel alloc] initWithFrame:self.errorMsgView.bounds];
  lblMsg.text =
      NSLocalizedString(@"Device offline, Please check your network", nil);
  lblMsg.textColor = [UIColor redColor];
  lblMsg.font = [UIFont systemFontOfSize:13.f];
  lblMsg.textAlignment = NSTextAlignmentCenter;
  [self.errorMsgView addSubview:lblMsg];
  [self.scrollView addSubview:self.errorMsgView];

  __weak SnakeSwitchDetailViewController *weakSelf = self;
  self.model =
      [[SwitchDetailModel alloc] initWithSwitch:self.aSwitch
                         switchStateChangeBlock:^(int switchStatus) {
                           dispatch_async(MAIN_QUEUE, ^{
                             if (switchStatus == SWITCH_OFFLINE) {
                               weakSelf.scrollView.contentInset =
                                   UIEdgeInsetsMake(20, 0, 0, 0);
                               weakSelf.scrollView.contentOffset =
                                   CGPointMake(0, -20);
                               //关闭开关动画
                               [weakSelf.socketView removeRotateAnimation];
                               //关闭实时电量查询
                               [weakSelf.model stopRealTimeElec];
                               [weakSelf.elecView stopRealTimeDraw];
                             } else {
                               weakSelf.scrollView.contentInset =
                                   UIEdgeInsetsZero;
                               weakSelf.scrollView.contentOffset = CGPointZero;
                               //从详情、定时和延时页面返回时如果选中的是实时则开启刷新
                               if (weakSelf.showingRealTimeElecView) {
                                 weakSelf.showingRealTimeElecView = YES;
                               }
                             }
                           });
                         }];
  self.powers = [@[] mutableCopy];
  //必须在添加观察者之前
  self.showingRealTimeElecView = YES;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self setup];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(changeOnOffState:)
                                               name:kSwitchOnOffStateChange
                                             object:nil];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(historyElecDataRecivied:)
             name:kHistoryElecNotification
           object:nil];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(realTimeElecDataRecivied:)
             name:kRealTimeElecNotification
           object:nil];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(switchStateChanged:)
             name:kOneSwitchUpdate
           object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(noResponse:)
                                               name:kNoResponseNotification
                                             object:self.model];
  [self addObserver:self
         forKeyPath:@"showingRealTimeElecView"
            options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
            context:nil];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self viewAppearOrEnterForeground];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(applicationWillEnterForegroundNotification:)
             name:UIApplicationWillEnterForegroundNotification
           object:nil];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(applicationDidEnterBackgroundNotification:)
             name:UIApplicationDidEnterBackgroundNotification
           object:nil];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(netChangedNotification:)
             name:kNetChangedNotification
           object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  [self viewDisappearOrEnterBackground];
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:UIApplicationWillEnterForegroundNotification
              object:nil];
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:UIApplicationDidEnterBackgroundNotification
              object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:kNetChangedNotification
                                                object:nil];
}

- (void)viewDisappearOrEnterBackground {
  [self.model stopRealTimeElec];
  [self.elecView stopRealTimeDraw];
  [self.model stopScanSwitchState];
  //清空实时电量数据
  [self.powers removeAllObjects];
}

- (void)viewAppearOrEnterForeground {
  NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
  self.aSwitch.lastUpdateInterval = current;
  [self.model startScanSwitchState];
  //从详情、定时和延时页面返回时如果选中的是实时则开启刷新
  if (self.showingRealTimeElecView) {
    self.showingRealTimeElecView = YES;
  }
  __weak SnakeSwitchDetailViewController *weakSelf = self;
  dispatch_after(
      dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.10 * NSEC_PER_SEC)),
      dispatch_get_main_queue(), ^{
        [self.model socket1Timer:^(BOOL isSuccess, NSArray *timers) {
          dispatch_async(MAIN_QUEUE, ^{
            __strong SnakeSwitchDetailViewController *strongSelf = weakSelf;
            if (isSuccess) {
              SDZGSocket *socket = strongSelf.aSwitch.sockets[0];
              [socket.timerList removeAllObjects];
              [socket.timerList addObjectsFromArray:timers];
              int seconds = [SDZGTimerTask getShowSeconds:timers];
              if (seconds) {
                [strongSelf.socketView timerState:YES];
              } else {
                [strongSelf.socketView timerState:NO];
              }
            } else {
              [strongSelf.socketView timerState:NO];
            }
          });
        }];
      });
  dispatch_after(
      dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.20 * NSEC_PER_SEC)),
      dispatch_get_main_queue(), ^{
        [self.model socket1Delay:^(BOOL isSuccess, int delaySeconds) {
          dispatch_async(MAIN_QUEUE, ^{
            __strong SnakeSwitchDetailViewController *strongSelf = weakSelf;
            if (isSuccess) {
              if (delaySeconds) {
                [strongSelf.socketView delayState:YES];
              } else {
                [strongSelf.socketView delayState:NO];
              }
            } else {
              [strongSelf.socketView delayState:NO];
            }
          });
        }];
      });
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self removeObserver:self forKeyPath:@"showingRealTimeElecView"];
}

/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little
 preparation before navigation
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  // Get the new view controller using [segue destinationViewController].
  // Pass the selected object to the new view controller.
  if (self.aSwitch.networkStatus == SWITCH_OFFLINE) {
    [self showOfflineMsg];
  } else {
    SwitchInfoViewController *destViewController =
        [segue destinationViewController];
    destViewController.aSwitch = self.aSwitch;
  }
}

- (void)shwoInfo:(id)sender {
  if (self.aSwitch.networkStatus == SWITCH_OFFLINE) {
    [self showOfflineMsg];
  } else {
    SwitchInfoViewController *destViewController = [self.storyboard
        instantiateViewControllerWithIdentifier:@"SwitchInfoViewController"];
    destViewController.aSwitch = self.aSwitch;
    [self.navigationController pushViewController:destViewController
                                         animated:YES];
  }
}

#pragma mark -
- (void)touchSocket:(int)socketId withSelf:(SnakeSocketView *)_self {
  [[UIApplication sharedApplication] setStatusBarHidden:YES];
  SocketImgTemplateViewController *templateViewController =
      [self.storyboard instantiateViewControllerWithIdentifier:
                           @"SocketImgTemplateViewController"];
  templateViewController.socketId = socketId;
  templateViewController.snakeSocketView = _self;
  templateViewController.delegate = self;
  templateViewController.aSwitch = self.aSwitch;

  CATransition *animation = [CATransition animation];
  [animation setDuration:0.5];
  [animation setType:kCATransitionFade];
  [animation setSubtype:kCATransitionFromBottom];
  [animation setTimingFunction:
                 [CAMediaTimingFunction
                     functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
  [[templateViewController.view layer] addAnimation:animation
                                             forKey:@"SwitchToView"];

  [self presentViewController:templateViewController
                     animated:NO
                   completion:^{
                   }];
}

- (void)touchOnOrOffWithSelf:(SnakeSocketView *)_self {
  if (self.aSwitch.networkStatus == SWITCH_OFFLINE) {
    [_self removeRotateAnimation];
    [self showOfflineMsg];
  } else {
    [self.model openOrCloseWithGroupId:_self.groupId];
  }
}

- (void)touchTimerWithSelf:(SnakeSocketView *)_self {
  if (self.aSwitch.networkStatus == SWITCH_OFFLINE) {
    [self showOfflineMsg];
  } else {
    TimerViewController *nextViewController = [self.storyboard
        instantiateViewControllerWithIdentifier:@"TimerViewController"];
    nextViewController.aSwitch = self.aSwitch;
    nextViewController.socketGroupId = _self.groupId;
    [self.navigationController pushViewController:nextViewController
                                         animated:YES];
  }
}
- (void)touchDelayWithSelf:(SnakeSocketView *)_self {
  if (self.aSwitch.networkStatus == SWITCH_OFFLINE) {
    [self showOfflineMsg];
  } else {
    DelayViewController *nextViewController = [self.storyboard
        instantiateViewControllerWithIdentifier:@"DelayViewController"];
    nextViewController.aSwitch = self.aSwitch;
    nextViewController.socketGroupId = _self.groupId;
    [self.navigationController pushViewController:nextViewController
                                         animated:YES];
  }
}

- (void)socketView:(UIView *)view
          socketId:(int)socketId
           imgName:(NSString *)imgName {
  SnakeSocketView *socketView = (SnakeSocketView *)view;
  UIImage *img = [SDZGSocket imgNameToImage:imgName status:SocketStatusOn];
  UIImage *defaultSelectBgImage = [UIImage imageNamed:@"socket_bg_selected"];
  UIImage *customSelectBgImage = [UIImage imageNamed:@"socket_bg_custom"];
  switch (socketId) {
    case 1:
      [socketView.btnSocket1 setImage:img forState:UIControlStateNormal];
      if ([imgName isEqualToString:socket_default_image]) {
        [socketView.btnSocket1 setBackgroundImage:defaultSelectBgImage
                                         forState:UIControlStateSelected];
      } else {
        [socketView.btnSocket1 setBackgroundImage:customSelectBgImage
                                         forState:UIControlStateSelected];
      }
      break;
    case 2:
      [socketView.btnSocket2 setImage:img forState:UIControlStateNormal];
      if ([imgName isEqualToString:socket_default_image]) {
        [socketView.btnSocket2 setBackgroundImage:defaultSelectBgImage
                                         forState:UIControlStateSelected];
      } else {
        [socketView.btnSocket2 setBackgroundImage:customSelectBgImage
                                         forState:UIControlStateSelected];
      }

      break;
    case 3:
      [socketView.btnSocket3 setImage:img forState:UIControlStateNormal];
      if ([imgName isEqualToString:socket_default_image]) {
        [socketView.btnSocket3 setBackgroundImage:defaultSelectBgImage
                                         forState:UIControlStateSelected];
      } else {
        [socketView.btnSocket3 setBackgroundImage:customSelectBgImage
                                         forState:UIControlStateSelected];
      }
      break;
    case 4:
      [socketView.btnSocket4 setImage:img forState:UIControlStateNormal];
      if ([imgName isEqualToString:socket_default_image]) {
        [socketView.btnSocket4 setBackgroundImage:defaultSelectBgImage
                                         forState:UIControlStateSelected];
      } else {
        [socketView.btnSocket4 setBackgroundImage:customSelectBgImage
                                         forState:UIControlStateSelected];
      }
      break;
    default:
      break;
  }
}

#pragma mark - 电量代理
- (void)selectedDatetype:(HistoryElecDateType)dateType
             needGetData:(BOOL)needGetData {
  __weak SnakeSwitchDetailViewController *weakSelf = self;
  switch (dateType) {
    case RealTime:
      if (!self.showingRealTimeElecView) {
        self.showingRealTimeElecView = YES;
      }
      break;
    case OneDay:
    case OneWeek:
    case OneMonth:
    case ThreeMonth:
    case SixMonth:
    case OneYear:
      if (self.showingRealTimeElecView) {
        self.showingRealTimeElecView = NO;
      }
      if (needGetData) {
        [self.HUD show:YES];
        [self.model
            historyElec:dateType
             completion:^(BOOL isSuccess, HistoryElecDateType dateType,
                          HistoryElecData *elecData) {
               __strong SnakeSwitchDetailViewController *strongSelf = weakSelf;
               dispatch_async(MAIN_QUEUE, ^{
                 if (isSuccess) {
                   [strongSelf.elecView showChart:elecData dateType:dateType];
                 } else {
                   [strongSelf.elecView showChart:nil dateType:dateType];
                 }
                 [strongSelf.HUD hide:YES];
               });
             }];
      }
      break;
    default:
      break;
  }
}

#pragma mark - 通知
- (void)changeOnOffState:(NSNotification *)notif {
  NSDictionary *userInfo = notif.userInfo;
  self.aSwitch = [userInfo objectForKey:@"switch"];
  int socketGroupId = [[userInfo objectForKey:@"socketGroupId"] intValue];
  SDZGSocket *socket = [self.aSwitch.sockets objectAtIndex:socketGroupId - 1];
  dispatch_async(MAIN_QUEUE, ^{
    if (socketGroupId == 1) {
      [self.socketView changeSocketState:socket];
      [self.socketView removeRotateAnimation];
    }
  });
}

- (void)historyElecDataRecivied:(NSNotification *)notif {
  NSDictionary *userInfo = notif.userInfo;
  HistoryElecData *data = userInfo[@"data"];
  HistoryElecDateType dateType = [userInfo[@"dateType"] intValue];
  dispatch_async(MAIN_QUEUE, ^{
    [self.elecView showChart:data dateType:dateType];
  });
}

- (void)realTimeElecDataRecivied:(NSNotification *)notif {
  NSDictionary *userInfo = notif.userInfo;
  float power = [userInfo[@"power"] floatValue];
  [self.powers addObject:@(power)];
  if (self.powers.count > 8 + 1) {
    [self.powers removeObjectAtIndex:0];
    NSSet *isAllEqual = [NSSet setWithArray:self.powers];
    DDLogDebug(@"all equal count is %d", [isAllEqual count]);
    if ([isAllEqual count] == 1) {
      [self.powers removeAllObjects];
      [self.powers addObjectsFromArray:[isAllEqual allObjects]];
    }
  }
  [self.elecView showRealTimeData:self.powers];
}

- (void)switchStateChanged:(NSNotification *)notif {
  NSDictionary *userInfo = notif.userInfo;
  self.aSwitch = userInfo[@"switch"];
  NSArray *sockets = self.aSwitch.sockets;
  SDZGSocket *socket1 = sockets[0];
  dispatch_async(MAIN_QUEUE, ^{
    [self.socketView changeSocketState:socket1];
    [self.socketView removeRotateAnimation];
  });
  DDLogDebug(@"############## 修改界面");
}

- (void)noResponse:(NSNotification *)notif {
  DDLogDebug(@"%s", __func__);
  dispatch_async(MAIN_QUEUE, ^{
    NSDictionary *userInfo = notif.userInfo;
    long tag = [userInfo[@"tag"] longValue];
    int socketGroupId = [userInfo[@"socketGroupId"] intValue];
    switch (tag) {
      case P2D_CONTROL_REQ_11:
      case P2S_CONTROL_REQ_13:
        [CRToastManager
            showNotificationWithMessage:NSLocalizedString(
                                            @"No UDP Response Msg", nil)
                        completionBlock:^{
                        }];
        if (socketGroupId == 1) {
          [self.socketView removeRotateAnimation];
        }
        break;

      default:
        break;
    }
  });
}

- (void)netChangedNotification:(NSNotification *)notification {
  NetworkStatus status = kSharedAppliction.networkStatus;
  if (status == NotReachable) {
    //网络不可用时
    [UIView animateWithDuration:0.3
                     animations:^{
                     }];

  } else {
    [UIView animateWithDuration:0.3
                     animations:^{
                     }];
    if (status == ReachableViaWWAN) {
      BOOL warn = [[[NSUserDefaults standardUserDefaults]
          objectForKey:wwanWarn] boolValue];
      if (warn) {
        [self.view
            makeToast:NSLocalizedString(@"WWAN Message", nil)
             duration:5.f
             position:[NSValue
                          valueWithCGPoint:
                              CGPointMake(self.view.frame.size.width / 2,
                                          self.view.frame.size.height - 40)]];
      }
    }
  }
}

- (void)applicationWillEnterForegroundNotification:(NSNotification *)notif {
  [self viewAppearOrEnterForeground];
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notif {
  [self viewDisappearOrEnterBackground];
}

#pragma mark - 观察显示view变化
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if ([keyPath isEqual:@"showingRealTimeElecView"]) {
    BOOL showingRealTimeElecView =
        [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
    if (showingRealTimeElecView) {
      [self.model startRealTimeElec];
      [self.elecView startRealTimeDraw];
    } else {
      [self.model stopRealTimeElec];
      [self.elecView stopRealTimeDraw];
    }
  }
}

#pragma mark - 显示消息
- (void)showOfflineMsg {
  //  [self.view hideToast:self.view];
  [self.view
      makeToast:NSLocalizedString(@"Device offline, Please check your network",
                                  nil)
       duration:1.f
       position:[NSValue
                    valueWithCGPoint:CGPointMake(self.view.frame.size.width / 2,
                                                 self.view.frame.size.height -
                                                     40)]];
}

#pragma mark - MBProgressHud
- (void)hudWasHidden {
  // Remove HUD from screen
  [self.HUD removeFromSuperview];

  // add here the code you may need
}

//#pragma mark -
//
//- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
//}
//
//- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
//  if (motion == UIEventSubtypeMotionShake) {
//    //    [self.model openOrCloseWithGroupId:1];
//  }
//}
//
//- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
//}

@end
