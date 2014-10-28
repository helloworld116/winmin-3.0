//
//  ResetPwdViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-10-28.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "ResetPwdViewController.h"
#import "FindPassword.h"

@interface ResetPwdViewController () <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextField *textEmail;
@property (strong, nonatomic) IBOutlet UITextField *textPassword;
@property (strong, nonatomic) IBOutlet UITextField *textPassword2;
@property (strong, nonatomic) IBOutlet UITextField *textCode;
@property (strong, nonatomic) IBOutlet UIView *view1;
@property (strong, nonatomic) IBOutlet UIView *view2;
@property (strong, nonatomic) IBOutlet UIView *view3;
@property (strong, nonatomic) IBOutlet UIView *view4;
@property (strong, nonatomic) IBOutlet UIButton *btnSave;

@property (strong, nonatomic) UITextField *activeField;
@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) FindPassword *findPassword;

- (IBAction)save:(id)sender;
- (IBAction)touchBackground:(id)sender;
@end

@implementation ResetPwdViewController

- (void)setupStyle {
  self.view1.layer.borderColor =
      [UIColor colorWithHexString:@"#c3c3c3"].CGColor;
  self.view1.layer.borderWidth = .5f;
  self.view1.layer.cornerRadius = 5.f;
  self.view2.layer.borderColor =
      [UIColor colorWithHexString:@"#c3c3c3"].CGColor;
  self.view2.layer.borderWidth = .5f;
  self.view2.layer.cornerRadius = 5.f;
  self.view3.layer.borderColor =
      [UIColor colorWithHexString:@"#c3c3c3"].CGColor;
  self.view3.layer.borderWidth = .5f;
  self.view3.layer.cornerRadius = 5.f;
  self.view4.layer.borderColor =
      [UIColor colorWithHexString:@"#c3c3c3"].CGColor;
  self.view4.layer.borderWidth = .5f;
  self.view4.layer.cornerRadius = 5.f;

  self.btnSave.layer.borderColor = [UIColor blackColor].CGColor;
  self.btnSave.layer.borderWidth = .5f;
  self.btnSave.layer.cornerRadius = 3.f;
}

- (void)setup {
  [self setupStyle];
  self.textEmail.delegate = self;
  self.textCode.delegate = self;
  self.textPassword.delegate = self;
  self.textPassword2.delegate = self;
  self.textEmail.text = self.email;
  self.navigationItem.title = NSLocalizedString(@"Reset Password", nil);
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(keyboardDidShow:)
             name:UIKeyboardDidShowNotification
           object:nil];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(keyboardWillBeHidden:)
             name:UIKeyboardWillHideNotification
           object:nil];
  [[NSNotificationCenter defaultCenter]
      addObserverForName:kResetPasswordResponse
                  object:nil
                   queue:nil
              usingBlock:^(NSNotification *note) {
                  NSDictionary *userInfo = note.userInfo;
                  int status = [userInfo[@"status"] intValue];
                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                  if (status == 1) {
                    //修改成功
                    //返回登录页面
                    int count =
                        [[self.navigationController viewControllers] count];
                    UIViewController *loginViewController =
                        [self.navigationController viewControllers][count -
                                                                    3]; //上上层
                    [self.navigationController
                        popToViewController:loginViewController
                                   animated:YES];
                    [[NSNotificationCenter defaultCenter]
                        postNotificationName:kNewPasswordLogin
                                      object:nil];
                  } else {
                    [self showMessage:userInfo[@"msg"]];
                  }
              }];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self setup];
  self.findPassword = [[FindPassword alloc] init];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITextField协议
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField == self.textCode) {
    [self.textPassword becomeFirstResponder];
    return NO;
  } else if (textField == self.textPassword) {
    [self.textPassword2 becomeFirstResponder];
    return NO;
  } else if (textField == self.textPassword2) {
    [self.textPassword2 resignFirstResponder];
    return YES;
  }
  return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  self.activeField = nil;
}

#pragma mark - 键盘通知
- (void)keyboardDidShow:(NSNotification *)notification {
  NSDictionary *info = [notification userInfo];
  CGRect kbRect =
      [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
  kbRect = [self.view convertRect:kbRect fromView:nil];

  UIEdgeInsets contentInsets =
      UIEdgeInsetsMake(0.0, 0.0, kbRect.size.height, 0.0);
  self.scrollView.contentInset = contentInsets;
  self.scrollView.scrollIndicatorInsets = contentInsets;

  CGRect aRect = self.view.frame;
  aRect.size.height -= kbRect.size.height;
  if (!CGRectContainsPoint(aRect, self.activeField.frame.origin)) {
    [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
  }
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
  UIEdgeInsets contentInsets = UIEdgeInsetsZero;
  self.scrollView.contentInset = contentInsets;
  self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (IBAction)save:(id)sender {
  if ([self check]) {
    [self sendRequest];
  }
}

- (IBAction)touchBackground:(id)sender {
  [self.textCode resignFirstResponder];
  [self.textPassword resignFirstResponder];
  [self.textPassword2 resignFirstResponder];
}

- (BOOL)check {
  [self touchBackground:nil];
  NSCharacterSet *charSet = [NSCharacterSet whitespaceCharacterSet];
  NSString *code = [self.textCode.text stringByTrimmingCharactersInSet:charSet];
  NSString *password =
      [self.textPassword.text stringByTrimmingCharactersInSet:charSet];
  NSString *password2 =
      [self.textPassword2.text stringByTrimmingCharactersInSet:charSet];
  if (!code.length) {
    [self showMessage:NSLocalizedString(@"verfication code can not be empty",
                                        nil)];
    return NO;
  } else {
    self.code = code;
  }
  if (!password.length) {
    [self showMessage:NSLocalizedString(@"password can not be empty", nil)];
    return NO;
  }
  if ([password isEqualToString:password2]) {
    self.password = password;
  } else {
    [self showMessage:NSLocalizedString(@"two passwords do not match", nil)];
    return NO;
  }
  return YES;
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
      [self.findPassword resetPassword:self.password
                             withEmail:self.email
                              withCode:self.code];

  });
}
@end
