//
//  DelayViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-23.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "DelayViewController.h"
#import "DelayTimeCountDownView.h"
#import "DelayModel.h"
#import "DelaySettingViewController.h"

@interface DelayViewController () <DelaySettingControllerDelegate,
                                   UIAlertViewDelegate>
@property (nonatomic, weak) IBOutlet DelayTimeCountDownView *countDownView;
@property (nonatomic, weak) IBOutlet UIButton *settingBtn;
@property (nonatomic, weak) IBOutlet UIView *viewTop;
@property (nonatomic, weak) IBOutlet UILabel *lblOperationInfo;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSTimer *timer;
- (IBAction)showSetting:(id)sender;

@property (nonatomic, strong) DelayModel *model;
@end

@implementation DelayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)setupStyle {
  self.settingBtn.layer.borderWidth = .5f;
  self.settingBtn.layer.borderColor =
      [UIColor colorWithHexString:@"#39ac42"].CGColor;
  self.settingBtn.layer.cornerRadius = 8.f;
}

- (void)setup {
  [self setupStyle];
  self.navigationItem.title = NSLocalizedString(@"Delay Task", nil);
  self.model = [[DelayModel alloc] initWithSwitch:self.aSwitch
                                    socketGroupId:self.socketGroupId];
  self.dateFormatter = [[NSDateFormatter alloc] init];
  [self.dateFormatter setDateFormat:@"HH:mm"];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.model queryDelay:^(int delaySeconds, SocketStatus status) {
      [self showDelayInfo:delaySeconds action:status];
  } notReceiveData:^(long tag, int socktGroupId) {
      [self.view makeToast:NSLocalizedString(@"No UDP Response Msg", nil)];
  }];
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
- (IBAction)showSetting:(id)sender {
  DelaySettingViewController *viewController =
      [[DelaySettingViewController alloc]
          initWithNibName:@"DelaySettingViewController"
                   bundle:nil];
  viewController.model = self.model;
  SDZGSocket *socket = self.aSwitch.sockets[self.socketGroupId - 1];
  viewController.socketStatus = socket.socketStatus;
  viewController.delegate = self;
  [self presentPopupViewController:viewController
                     animationType:MJPopupViewAnimationFade
               backgroundClickable:YES];
}

- (void)closePopViewController:(UIViewController *)controller
                  passMinitues:(int)minitues
                    actionType:(int)actionType {
  dispatch_async(MAIN_QUEUE, ^{
      [self
          dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
      [self showDelayInfo:minitues * 60 action:actionType];
  });
}

#pragma mark -
- (void)showDelayInfo:(int)delaySeconds action:(SocketStatus)actionType {
  NSDate *executeDate = [[NSDate date] dateByAddingTimeInterval:delaySeconds];
  NSString *info = [self.dateFormatter stringFromDate:executeDate];
  NSString *action;
  if (actionType) {
    action = NSLocalizedString(@"ON", nil);
  } else {
    action = NSLocalizedString(@"OFF", nil);
  }
  dispatch_async(MAIN_QUEUE, ^{
      [self.countDownView countDown:delaySeconds];
      self.viewTop.hidden = NO;
      self.lblOperationInfo.text =
          [NSString stringWithFormat:@"延时至%@%@", info, action];
      self.timer =
          [NSTimer scheduledTimerWithTimeInterval:delaySeconds
                                           target:self
                                         selector:@selector(timerAction)
                                         userInfo:nil
                                          repeats:NO];
      [self.settingBtn setTitle:NSLocalizedString(@"CancelWithBlank", nil)
                       forState:UIControlStateNormal];
      [self.settingBtn removeTarget:self
                             action:@selector(showSetting:)
                   forControlEvents:UIControlEventTouchUpInside];
      [self.settingBtn addTarget:self
                          action:@selector(cancelDelay:)
                forControlEvents:UIControlEventTouchUpInside];
  });
}

#pragma mark -
- (void)cancelDelay:(id)sender {
  UIAlertView *alertView =
      [[UIAlertView alloc] initWithTitle:nil
                                 message:@"确定取消延时吗？"
                                delegate:self
                       cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                       otherButtonTitles:NSLocalizedString(@"Sure", nil), nil];
  [alertView show];
}

- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  switch (buttonIndex) {
    case 0:
      break;
    case 1:
      [self cancel];
      break;
    default:
      break;
  }
}

- (void)cancel {
  [self.countDownView countDown:0];
  self.viewTop.hidden = YES;
  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  __weak DelayViewController *weakSelf = self;
  [self.model setDelayWithMinitues:0
      onOrOff:NO
      completion:^(BOOL result) {
          __strong DelayViewController *strongSelf = weakSelf;
          dispatch_async(MAIN_QUEUE, ^{
              if (result) {
                [strongSelf cancelTimer];
                [strongSelf.settingBtn
                    setTitle:NSLocalizedString(@"SettingWithBlank", nil)
                    forState:UIControlStateNormal];
                [strongSelf.settingBtn
                        removeTarget:strongSelf
                              action:@selector(cancelDelay:)
                    forControlEvents:UIControlEventTouchUpInside];
                [strongSelf.settingBtn addTarget:strongSelf
                                          action:@selector(showSetting:)
                                forControlEvents:UIControlEventTouchUpInside];
                [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
              }
          });
      }
      notReceiveData:^(long tag, int socktGroupId) {
          __strong DelayViewController *strongSelf = weakSelf;
          dispatch_async(MAIN_QUEUE, ^{
              [strongSelf.view
                  makeToast:NSLocalizedString(@"No UDP Response Msg", nil)];
          });
      }];
}

#pragma mark - timer
- (void)timerAction {
  self.viewTop.hidden = YES;
  [self.settingBtn setTitle:NSLocalizedString(@"SettingWithBlank", nil)
                   forState:UIControlStateNormal];
  [self.settingBtn removeTarget:self
                         action:@selector(cancelDelay:)
               forControlEvents:UIControlEventTouchUpInside];
  [self.settingBtn addTarget:self
                      action:@selector(showSetting:)
            forControlEvents:UIControlEventTouchUpInside];
}

- (void)cancelTimer {
  if (self.timer) {
    [self.timer invalidate];
    self.timer = nil;
  }
}
@end
