//
//  SwitchRestartViewController.m
//  winmin 3.0
//
//  Created by sdzg on 15-2-3.
//  Copyright (c) 2015年 itouchco.com. All rights reserved.
//

#import "SwitchRestartViewController.h"
#import "SwitchRestartModel.h"
#import "SwitchDetailViewController.h"
#import "SnakeSwitchDetailViewController.h"

@interface SwitchRestartViewController () <MBProgressHUDDelegate>
@property (nonatomic, weak) IBOutlet UILabel *lblMsg;
@property (nonatomic, weak) IBOutlet UIButton *btnType1;
@property (nonatomic, weak) IBOutlet UIButton *btnType2;

@property (nonatomic, strong) MBProgressHUD *hud;
- (IBAction)btnAction:(id)sender;

@property (nonatomic, strong) SwitchRestartModel *model;
@end

@implementation SwitchRestartViewController
- (void)setup {
  UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
  backButtonItem.title = NSLocalizedString(@"Back", nil);
  self.navigationItem.backBarButtonItem = backButtonItem;
  self.navigationItem.title = NSLocalizedString(@"Move Confirm", nil);
  self.btnType1.layer.cornerRadius = 5.f;
  self.btnType2.layer.cornerRadius = 5.f;
  self.model = [[SwitchRestartModel alloc] init];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self setup];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
}

#pragma mark -
- (IBAction)btnAction:(id)sender {
  int flag;
  if (sender == self.btnType1) {
    flag = 1;
  } else if (sender == self.btnType2) {
    flag = 0;
  }
  self.hud = [[MBProgressHUD alloc] initWithView:self.view];
  self.hud.labelText = NSLocalizedString(@"Confirming", nil);
  [self.view addSubview:self.hud];
  self.hud.delegate = self;
  [self.hud show:YES];
  [self.model
      resetDeviceMove:self.aSwitch.mac
                 flag:flag
           completion:^(SDZGHttpResponse *response) {
               [self.hud hide:YES];
               if (response.isSuccess) {
                   if([self.aSwitch.deviceType isEqualToString:kDeviceType_Snake]){
                       SnakeSwitchDetailViewController *detailViewController =
                            [self.storyboard instantiateViewControllerWithIdentifier:
                                                @"SnakeSwitchDetailViewController"];
                       self.aSwitch.isRestart = NO;
                       detailViewController.aSwitch = self.aSwitch;
                       [self.navigationController
                        pushViewController:detailViewController
                        animated:YES];
                   }else{
                     SwitchDetailViewController *detailViewController =
                         [self.storyboard instantiateViewControllerWithIdentifier:
                                              @"SwitchDetailViewController"];
                     self.aSwitch.isRestart = NO;
                     detailViewController.aSwitch = self.aSwitch;
                     [self.navigationController
                         pushViewController:detailViewController
                      animated:YES];
                }
                 NSMutableArray *stackControllers = [NSMutableArray
                     arrayWithArray:self.navigationController.viewControllers];
                 for (UIViewController *viewController in stackControllers) {
                   if ([viewController
                           isKindOfClass:[SwitchRestartViewController class]]) {
                     [stackControllers removeObject:viewController];
                     break;
                   }
                 }
                 self.navigationController.viewControllers = stackControllers;

               } else {
               }
           }];
}
@end
