//
//  ForgetPwdViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-10-28.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "ForgetPwdViewController.h"
#import "ResetPwdViewController.h"
#import "FindPassword.h"
#import "TextUtil.h"

@interface ForgetPwdViewController () <UITextFieldDelegate>
@property (nonatomic, strong) IBOutlet UITextField *textEmail;
@property (nonatomic, strong) IBOutlet UIButton *btn;
@property (nonatomic, strong) FindPassword *findPassword;
@property (nonatomic, strong) NSString *email;
- (IBAction)sendEmail:(id)sender;
- (IBAction)touchBackground:(id)sender;
@end

@implementation ForgetPwdViewController

- (void)setupStyle {
  self.textEmail.layer.cornerRadius = 5.f;
  self.btn.layer.cornerRadius = 5.f;
}

- (void)setup {
  [self setupStyle];
  self.textEmail.delegate = self;
  self.navigationItem.title = NSLocalizedString(@"Find Password", nil);
  UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
  backButtonItem.title = NSLocalizedString(@"Back", nil);
  self.navigationItem.backBarButtonItem = backButtonItem;

  [[NSNotificationCenter defaultCenter]
      addObserverForName:kSendEmailResponse
                  object:nil
                   queue:nil
              usingBlock:^(NSNotification *note) {
                  NSDictionary *userInfo = [note userInfo];
                  int status = [userInfo[@"status"] intValue];
                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                  if (status == 1) {
                    ResetPwdViewController *nextController = [self.storyboard
                        instantiateViewControllerWithIdentifier:
                            @"ResetPwdViewController"];
                    nextController.email = self.email;
                    [self.navigationController pushViewController:nextController
                                                         animated:YES];
                  } else {
                    [self showMessage:userInfo[@"msg"]];
                  }
              }];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self setup];
  //数据
  self.findPassword = [[FindPassword alloc] init];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)sendEmail:(id)sender {
  if ([self check]) {
    [self sendRequest];
  }
  //  ResetPwdViewController *nextController = [self.storyboard
  //      instantiateViewControllerWithIdentifier:@"ResetPwdViewController"];
  //  nextController.email = @"646767424@qq.com";
  //  [self.navigationController pushViewController:nextController
  //  animated:YES];
}

- (IBAction)touchBackground:(id)sender {
  [self.textEmail resignFirstResponder];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - UITextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  [self sendEmail:nil];
  return YES;
}

- (BOOL)check {
  NSCharacterSet *charSet = [NSCharacterSet whitespaceCharacterSet];
  NSString *email =
      [self.textEmail.text stringByTrimmingCharactersInSet:charSet];
  if (email.length) {
    if ([TextUtil isEmailAddress:email]) {
      self.email = email;
      return YES;
    } else {
      [self showMessage:NSLocalizedString(@"email format is incorrect", nil)];
      return NO;
    }
  } else {
    [self showMessage:NSLocalizedString(@"email can not be empty", nil)];
    return NO;
  }
}

- (void)showMessage:(NSString *)message {
  [self.view
      makeToast:message
       duration:1.f
       position:[NSValue
                    valueWithCGPoint:CGPointMake(self.view.frame.size.width / 2,
                                                 self.view.frame.size.height -
                                                     40)]];
}

- (void)sendRequest {
  dispatch_async(GLOBAL_QUEUE, ^{
      dispatch_async(MAIN_QUEUE, ^{
          [MBProgressHUD showHUDAddedTo:self.view animated:YES];
      });
      [self.findPassword sendEmail:self.email];

  });
}
@end
