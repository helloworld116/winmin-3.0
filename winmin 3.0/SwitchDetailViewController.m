//
//  SwitchDetailViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-17.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SwitchDetailViewController.h"
#import "SocketImgTemplateViewController.h"
#import "SocketView.h"
#import "SwitchDetailModel.h"
#import "TimerViewController.h"
#import "SwitchInfoViewController.h"
#import "DelayViewController.h"
#import "ElecView.h"
#import "HistoryElec.h"

@interface SwitchDetailViewController ()<
    SocketViewDelegate, SocketImgTemplateDelegate, ElecViewDelegate>
@property (strong, nonatomic) IBOutlet SocketView *socketView1;
@property (strong, nonatomic) IBOutlet SocketView *socketView2;
@property (strong, nonatomic) IBOutlet ElecView *elecView;
@property (strong, nonatomic) SwitchDetailModel *model;

@property (assign, nonatomic) BOOL showingRealTimeElecView;
@property (strong, nonatomic) NSMutableArray *powers; //保存实时电量数据
@end

@implementation SwitchDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)setup {
  UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
  backButtonItem.title = @"返回";
  self.navigationItem.backBarButtonItem = backButtonItem;
  self.navigationItem.title = self.aSwitch.name;
  self.socketView1.sockeViewDelegate = self;
  self.socketView1.groupId = 1;
  SDZGSocket *socket1 = [self.aSwitch.sockets objectAtIndex:0];
  [self.socketView1 setSocketInfo:socket1];

  self.socketView2.sockeViewDelegate = self;
  self.socketView2.groupId = 2;
  SDZGSocket *socket2 = [self.aSwitch.sockets objectAtIndex:1];
  [self.socketView2 setSocketInfo:socket2];

  self.elecView.layer.borderColor =
      [UIColor colorWithHexString:@"#C3C3C3" alpha:1].CGColor;
  self.elecView.layer.cornerRadius = 5.f;
  self.elecView.layer.borderWidth = 1.f;
  self.elecView.layer.masksToBounds = YES;
  self.elecView.delegate = self;

  self.model = [[SwitchDetailModel alloc] initWithSwitch:self.aSwitch];
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
  [self addObserver:self
         forKeyPath:@"showingRealTimeElecView"
            options:NSKeyValueObservingOptionNew
            context:nil];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self.model startScanSwitchState];
  //从详情、定时和延时页面返回时如果选中的是实时则开启刷新
  if (self.showingRealTimeElecView) {
    self.showingRealTimeElecView = YES;
  }
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  [self.model stopRealTimeElec];
  [self.model stopScanSwitchState];
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
  SwitchInfoViewController *destViewController =
      [segue destinationViewController];
  destViewController.aSwitch = self.aSwitch;
}

#pragma mark -
- (void)touchSocket:(int)socketId withSelf:(SocketView *)_self {
  [[UIApplication sharedApplication] setStatusBarHidden:YES];
  SocketImgTemplateViewController *templateViewController =
      [self.storyboard instantiateViewControllerWithIdentifier:
                           @"SocketImgTemplateViewController"];
  templateViewController.socketId = socketId;
  templateViewController.socketView = _self;
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
                   completion:^{}];
}

- (void)touchOnOrOffWithSelf:(SocketView *)_self {
  [self.model openOrCloseWithGroupId:_self.groupId];
}

- (void)touchTimerWithSelf:(SocketView *)_self {
  TimerViewController *nextViewController = [self.storyboard
      instantiateViewControllerWithIdentifier:@"TimerViewController"];
  nextViewController.aSwitch = self.aSwitch;
  nextViewController.socketGroupId = _self.groupId;
  [self.navigationController pushViewController:nextViewController
                                       animated:YES];
}
- (void)touchDelayWithSelf:(SocketView *)_self {
  DelayViewController *nextViewController = [self.storyboard
      instantiateViewControllerWithIdentifier:@"DelayViewController"];
  nextViewController.aSwitch = self.aSwitch;
  nextViewController.socketGroupId = _self.groupId;
  [self.navigationController pushViewController:nextViewController
                                       animated:YES];
}

- (void)socketView:(SocketView *)socketView
          socketId:(int)socketId
           imgName:(NSString *)imgName {
  UIImage *img = [SDZGSocket imgNameToImage:imgName status:SocketStatusOn];
  switch (socketId) {
    case 1:
      //      socketView.imgViewSocket1.image = img;
      [socketView.btnSocket1 setImage:img forState:UIControlStateNormal];
      break;
    case 2:
      //      socketView.imgViewSocket2.image = img;
      [socketView.btnSocket2 setImage:img forState:UIControlStateNormal];
      break;
    case 3:
      //      socketView.imgViewSocket3.image = img;
      [socketView.btnSocket3 setImage:img forState:UIControlStateNormal];
      break;
    default:
      break;
  }
}

#pragma mark - 电量代理
- (void)selectedDatetype:(HistoryElecDateType)dateType
             needGetData:(BOOL)needGetData {
  switch (dateType) {
    case RealTime:
      //      [self.model startRealTimeElec];
      self.showingRealTimeElecView = YES;
      break;
    case OneDay:
    case OneWeek:
    case OneMonth:
    case ThreeMonth:
    case SixMonth:
    case OneYear:
      //      [self.model stopRealTimeElec];
      self.showingRealTimeElecView = NO;
      if (needGetData) {
        [self.model historyElec:dateType];
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
        [self.socketView1 changeSocketState:socket];
      } else if (socketGroupId == 2) {
        [self.socketView2 changeSocketState:socket];
      }
  });
}

- (void)historyElecDataRecivied:(NSNotification *)notif {
  NSDictionary *userInfo = notif.userInfo;
  HistoryElecData *data = userInfo[@"data"];
  HistoryElecDateType dateType = [userInfo[@"dateType"] intValue];
  dispatch_async(MAIN_QUEUE,
                 ^{ [self.elecView showChart:data dateType:dateType]; });
}

- (void)realTimeElecDataRecivied:(NSNotification *)notif {
  NSDictionary *userInfo = notif.userInfo;
  float power = [userInfo[@"power"] floatValue];
  [self.powers addObject:@(power)];

  [self.elecView showRealTimeData:self.powers];
}

- (void)switchStateChanged:(NSNotification *)notif {
  NSDictionary *userInfo = notif.userInfo;
  self.aSwitch = userInfo[@"switch"];
  NSArray *sockets = self.aSwitch.sockets;
  SDZGSocket *socket1 = sockets[0];
  SDZGSocket *socket2 = sockets[1];
  dispatch_async(MAIN_QUEUE, ^{
      [self.socketView1 changeSocketState:socket1];
      [self.socketView2 changeSocketState:socket2];
  });
  debugLog(@"############## 修改界面");
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
    } else {
      [self.model stopRealTimeElec];
    }
  }
}

@end
