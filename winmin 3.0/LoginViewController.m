//
//  LoginViewController.m
//  SmartSwitch
//
//  Created by sdzg on 14-8-6.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "LoginViewController.h"
#import "UserInfo.h"

static int const kCancelAuthoriztionCode = -103;

@interface LoginViewController () <UITextFieldDelegate, ISSViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UITextField *textFieldUsername;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnWeibo;
@property (weak, nonatomic) IBOutlet UIButton *btnQQ;

- (IBAction)toRegisterPage:(id)sender;
- (IBAction)weiboLogin:(id)sender;
- (IBAction)qqLogin:(id)sender;
- (IBAction)login:(id)sender;
- (IBAction)touchBackground:(id)sender;
- (IBAction)forgetPassword:(id)sender;

@property (strong, nonatomic) UITextField *activeField;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) ResponseBlock successResonse;
@property (strong, nonatomic) ResponseBlock failureResponse;
@property (strong, nonatomic) id passwordLoginObserver;
@end
@implementation LoginViewController
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)setupStyle {
  self.view1.layer.borderColor =
      [UIColor colorWithHexString:@"#c3c3c3"].CGColor;
  self.view1.layer.borderWidth = .5f;
  self.view1.layer.cornerRadius = 5.f;
  self.view2.layer.borderColor =
      [UIColor colorWithHexString:@"#c3c3c3"].CGColor;
  self.view2.layer.borderWidth = .5f;
  self.view2.layer.cornerRadius = 5.f;
  self.btnLogin.layer.borderColor = [UIColor blackColor].CGColor;
  self.btnLogin.layer.borderWidth = .5f;
  self.btnLogin.layer.cornerRadius = 3.f;
  self.btnQQ.layer.cornerRadius = 3.f;
  [self.btnQQ.layer setMasksToBounds:YES];
  [self.btnQQ
      setBackgroundImage:
          [UIImage imageWithColor:[UIColor colorWithHexString:@"#3399ff"]
                             size:self.btnQQ.frame.size]
                forState:UIControlStateNormal];
  [self.btnQQ
      setBackgroundImage:
          [UIImage imageWithColor:[UIColor colorWithHexString:@"#3399f0"]
                             size:self.btnQQ.frame.size]
                forState:UIControlStateHighlighted];

  self.btnWeibo.layer.cornerRadius = 3.f;
  UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
  backButtonItem.title = NSLocalizedString(@"Back", nil);
  self.navigationItem.backBarButtonItem = backButtonItem;
}

- (void)setup {
  //  self.scrollView.contentSize = CGSizeMake(
  //      self.scrollView.frame.size.width, self.scrollView.frame.size.height +
  //      1);
  [self setupStyle];
  self.textFieldUsername.delegate = self;
  self.textFieldPassword.delegate = self;
  //  [[NSNotificationCenter defaultCenter] addObserver:self
  //                                           selector:@selector(loginResponse:)
  //                                               name:kLoginResponse
  //                                             object:nil];
  __weak __typeof__(self) weakSelf = self;
  self.passwordLoginObserver = [[NSNotificationCenter defaultCenter]
      addObserverForName:kNewPasswordLogin
                  object:nil
                   queue:nil
              usingBlock:^(NSNotification *note) {
                __strong __typeof__(self) strongSelf = weakSelf;
                [strongSelf
                    showMessage:NSLocalizedString(@"new  password login", nil)];
              }];
  self.successResonse = ^(int status, id responseData) {
    __strong __typeof__(self) strongSelf = weakSelf;
    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    if (status == 1) {
      ServerResponse *reponse = (ServerResponse *)responseData;
      switch (reponse.status) {
        case 1: {
          //登陆成功
          [[NSNotificationCenter defaultCenter]
              postNotificationName:kLoginSuccess
                            object:weakSelf
                          userInfo:nil];
          [strongSelf.navigationController popViewControllerAnimated:NO];
          break;
        }
        default:
          [strongSelf.view
              makeToast:reponse.errorMsg
               duration:1.f
               position:[NSValue
                            valueWithCGPoint:
                                CGPointMake(
                                    strongSelf.view.frame.size.width / 2,
                                    strongSelf.view.frame.size.height - 40)]];
          break;
      }
    }
  };
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.navigationItem.title = NSLocalizedString(@"User Login", nil);

  [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
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
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:UIKeyboardDidShowNotification
              object:nil];
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:UIKeyboardWillHideNotification
              object:nil];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [[NSNotificationCenter defaultCenter]
      removeObserver:self.passwordLoginObserver];
}

#pragma mark - UIStatusBarStyle
- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

#pragma mark - 导航栏按钮处理

- (IBAction)toRegisterPage:(id)sender {
  UIViewController *nextVC = [self.storyboard
      instantiateViewControllerWithIdentifier:@"RegisterViewController"];
  [self.navigationController pushViewController:nextVC animated:YES];
}

- (IBAction)weiboLogin:(id)sender {
  //自动授权
  id<ISSAuthOptions> authOptions =
      [ShareSDK authOptionsWithAutoAuth:NO
                          allowCallback:YES
                          authViewStyle:SSAuthViewStyleModal
                           viewDelegate:self
                authManagerViewDelegate:self];
  [ShareSDK
      getUserInfoWithType:ShareTypeSinaWeibo
              authOptions:authOptions
                   result:^(BOOL result, id<ISSPlatformUser> userInfo,
                            id<ICMErrorInfo> error) {
                     if (result) {
                       DDLogDebug(@".......nickname is %@ and uid is %@",
                                  [userInfo nickname], [userInfo uid]);
                       UserInfo *uInfo = [[UserInfo alloc]
                           initWithSinaUid:[userInfo uid]
                                  nickname:[userInfo nickname]];
                       [uInfo
                           loginRequestWithResponse:^(int status, id response) {
                             self.successResonse(status, response);
                           }];
                       [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                     }
                     DDLogDebug(@"errorCode is %d and errorDescription is %@",
                                [error errorCode], error.errorDescription);
                     if (kCancelAuthoriztionCode == [error errorCode]) {
                       [self.view makeToast:NSLocalizedString(@"The user cancels the authorization, use the account login or retry",nil)
                                   duration:1
                                   position:nil];
                     }
                   }];
}

- (IBAction)qqLogin:(id)sender {
  id<ISSAuthOptions> authOptions =
      [ShareSDK authOptionsWithAutoAuth:YES
                          allowCallback:YES
                          authViewStyle:SSAuthViewStyleModal
                           viewDelegate:self
                authManagerViewDelegate:self];
  [ShareSDK
      getUserInfoWithType:ShareTypeQQSpace
              authOptions:authOptions
                   result:^(BOOL result, id<ISSPlatformUser> userInfo,
                            id<ICMErrorInfo> error) {
                     if (result) {
                       UserInfo *uInfo =
                           [[UserInfo alloc] initWithQQUid:[userInfo uid]
                                                  nickname:[userInfo nickname]];
                       [uInfo
                           loginRequestWithResponse:^(int status, id response) {
                             self.successResonse(status, response);
                           }];
                       [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                     }
                     DDLogDebug(@"errorCode is %d and errorDescription is %@",
                                [error errorCode], error.errorDescription);
                     if (kCancelAuthoriztionCode == [error errorCode]) {
                         [self.view makeToast:NSLocalizedString(@"The user cancels the authorization, use the account login or retry",nil)
                                     duration:1
                                     position:nil];
                     }
                   }];
}

- (void)viewOnWillDisplay:(UIViewController *)viewController
                shareType:(ShareType)shareType {
  viewController.navigationItem.rightBarButtonItem = nil;
}

- (IBAction)login:(id)sender {
  if ([self check]) {
    UserInfo *userInfo =
        [[UserInfo alloc] initWithEmail:self.username password:self.password];
    [userInfo loginRequestWithResponse:^(int status, id response) {
      self.successResonse(status, response);
    }];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  }
}

- (IBAction)forgetPassword:(id)sender {
  UIViewController *nextController = [self.storyboard
      instantiateViewControllerWithIdentifier:@"ForgetPwdViewController"];
  [self.navigationController pushViewController:nextController animated:YES];
}

- (BOOL)check {
  [self touchBackground:nil];
  NSCharacterSet *charSet = [NSCharacterSet whitespaceCharacterSet];
  NSString *username =
      [self.textFieldUsername.text stringByTrimmingCharactersInSet:charSet];
  NSString *password =
      [self.textFieldPassword.text stringByTrimmingCharactersInSet:charSet];
  if (username.length && password.length) {
    self.username = username;
    self.password = password;
    return YES;
  } else {
    [self showMessage:NSLocalizedString(
                          @"Username or password can not be empty", nil)];
    return NO;
  }
}

- (void)showMessage:(NSString *)msg {
  [self.view
      makeToast:msg
       duration:1.f
       position:[NSValue
                    valueWithCGPoint:CGPointMake(self.view.frame.size.width / 2,
                                                 self.view.frame.size.height -
                                                     40)]];
}

- (IBAction)touchBackground:(id)sender {
  [self.textFieldUsername resignFirstResponder];
  [self.textFieldPassword resignFirstResponder];
}

#pragma mark - UITextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField == self.textFieldUsername) {
    [self.textFieldPassword becomeFirstResponder];
    return NO;
  } else if (textField == self.textFieldPassword) {
    [self.textFieldPassword resignFirstResponder];
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

#pragma mark - 登陆消息通知
//- (void)loginResponse:(NSNotification *)notification {
//  [MBProgressHUD hideHUDForView:self.view animated:YES];
//  NSDictionary *info = [notification userInfo];
//  int status = [[info objectForKey:@"status"] intValue];
//  if (status == 1) {
//    ServerResponse *reponse = [info objectForKey:@"data"];
//    switch (reponse.status) {
//      case 1: {
//        //登陆成功
//        [[NSNotificationCenter defaultCenter]
//        postNotificationName:kLoginSuccess
//                                                            object:self
//                                                          userInfo:nil];
//        [self.navigationController popViewControllerAnimated:NO];
//        break;
//      }
//      default:
//        [self.view
//            makeToast:reponse.errorMsg
//             duration:1.f
//             position:[NSValue
//                          valueWithCGPoint:
//                              CGPointMake(self.view.frame.size.width / 2,
//                                          self.view.frame.size.height - 40)]];
//        break;
//    }
//  } else if (status == 0) {
//    NSError *error = (NSError *)[info objectForKey:@"data"];
//  }
//}
@end
