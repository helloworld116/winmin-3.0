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

@interface SwitchDetailViewController ()<SocketViewDelegate,
                                         SocketImgTemplateDelegate>
@property(strong, nonatomic) IBOutlet SocketView *socketView1;
@property(strong, nonatomic) IBOutlet SocketView *socketView2;
@property(strong, nonatomic) IBOutlet ElecView *elecView;
@property(strong, nonatomic) SwitchDetailModel *model;
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

  self.model = [[SwitchDetailModel alloc] init];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self setup];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(changeOnOffState:)
                                               name:kSwitchOnOffStateChange
                                             object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:kSwitchOnOffStateChange
                                                object:nil];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
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
  [self.model openOrCloseSwitch:self.aSwitch groupId:_self.groupId];
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
  UIImage *img = [SDZGSocket imgNameToImage:imgName];
  switch (socketId) {
    case 1:
      socketView.imgViewSocket1.image = img;
      break;
    case 2:
      socketView.imgViewSocket2.image = img;
      break;
    case 3:
      socketView.imgViewSocket3.image = img;
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
@end
