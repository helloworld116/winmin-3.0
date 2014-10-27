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

@interface DelayViewController ()<DelaySettingControllerDelegate>
@property (nonatomic, strong) IBOutlet DelayTimeCountDownView *countDownView;
@property (nonatomic, strong) IBOutlet UIButton *settingBtn;
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
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(delayNotif:)
                                               name:kDelayQueryNotification
                                             object:nil];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.model queryDelay];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
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
  viewController.delegate = self;
  [self presentPopupViewController:viewController
                     animationType:MJPopupViewAnimationFade
               backgroundClickable:YES];
}

- (void)closePopViewController:(UIViewController *)controller
                  passMinitues:(int)minitues {
  dispatch_async(MAIN_QUEUE, ^{
      [self
          dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
      [self.countDownView countDown:minitues * 60];
  });
}

#pragma mark - 通知
- (void)delayNotif:(NSNotification *)notification {
  if (notification.object == self.model) {
    int delay = [[notification.userInfo objectForKey:@"delay"] intValue];
    dispatch_async(MAIN_QUEUE, ^{ [self.countDownView countDown:delay]; });
  }
}
@end
