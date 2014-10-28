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
static int const kQQNotInstalled = -6004;

@interface LoginViewController ()<UITextFieldDelegate, ISSViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *view1;
@property (strong, nonatomic) IBOutlet UIView *view2;
@property (strong, nonatomic) IBOutlet UITextField *textFieldUsername;
@property (strong, nonatomic) IBOutlet UITextField *textFieldPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnLogin;
@property (strong, nonatomic) IBOutlet UIButton *btnWeibo;
@property (strong, nonatomic) IBOutlet UIButton *btnQQ;

- (IBAction)toRegisterPage:(id)sender;
- (IBAction)weiboLogin:(id)sender;
- (IBAction)qqLogin:(id)sender;
- (IBAction)login:(id)sender;
- (IBAction)touchBackground:(id)sender;
- (IBAction)forgetPassword:(id)sender;

@property (strong, nonatomic) UITextField *activeField;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
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

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(loginResponse:)
                                               name:kLoginResponse
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
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:kLoginResponse
                                                object:nil];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
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
                         debugLog(@".......nickname is %@ and uid is %@",
                                  [userInfo nickname], [userInfo uid]);
                         UserInfo *uInfo = [[UserInfo alloc]
                             initWithSinaUid:[userInfo uid]
                                    nickname:[userInfo nickname]];
                         [uInfo loginRequest];
                         [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                       }
                       debugLog(@"errorCode is %d and errorDescription is %@",
                                [error errorCode], error.errorDescription);
                       if (kCancelAuthoriztionCode == [error errorCode]) {
                         [self.view
                             makeToast:@"用"
                             @"户取消授权，请使用账号登陆或重试"
                              duration:1
                              position:nil];
                       }
                   }];
}

- (IBAction)qqLogin:(id)sender {
  [ShareSDK
      getUserInfoWithType:ShareTypeQQSpace
              authOptions:nil
                   result:^(BOOL result, id<ISSPlatformUser> userInfo,
                            id<ICMErrorInfo> error) {

                       if (result) {
                         UserInfo *uInfo = [[UserInfo alloc]
                             initWithQQUid:[userInfo uid]
                                  nickname:[userInfo nickname]];
                         [uInfo loginRequest];
                         [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                       }
                       debugLog(@"errorCode is %d and errorDescription is %@",
                                [error errorCode], error.errorDescription);
                       if ([error errorCode] == kQQNotInstalled) {
                         UIAlertView *alertView = [[UIAlertView alloc]
                                 initWithTitle:@"温馨提示"
                                       message:@"您" @"当"
                                       @"前未安装QQ或QQ空间，请"
                                       @"先安" @"装"
                                      delegate:nil
                             cancelButtonTitle:@"取消"
                             otherButtonTitles:nil];
                         [alertView show];
                       } else if (kCancelAuthoriztionCode ==
                                  [error errorCode]) {
                         [self.view
                             makeToast:@"用"
                             @"户取消授权，请使用账号登陆或重试"
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
    [userInfo loginRequest];
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
    [self.view
        makeToast:@"用户名或密码不能为空"
         duration:1.f
         position:[NSValue
                      valueWithCGPoint:CGPointMake(
                                           self.view.frame.size.width / 2,
                                           self.view.frame.size.height - 40)]];
    return NO;
  }
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
- (void)loginResponse:(NSNotification *)notification {
  [MBProgressHUD hideHUDForView:self.view animated:YES];
  NSDictionary *info = [notification userInfo];
  int status = [[info objectForKey:@"status"] intValue];
  if (status == 1) {
    ServerResponse *reponse = [info objectForKey:@"data"];
    switch (reponse.status) {
      case 1: {
        //登陆成功
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccess
                                                            object:self
                                                          userInfo:nil];
        [self.navigationController popViewControllerAnimated:NO];
        break;
      }
      default:
        [self.view
            makeToast:reponse.errorMsg
             duration:1.f
             position:[NSValue
                          valueWithCGPoint:
                              CGPointMake(self.view.frame.size.width / 2,
                                          self.view.frame.size.height - 40)]];
        break;
    }
  } else if (status == 0) {
    NSError *error = (NSError *)[info objectForKey:@"data"];
  }
}
@end
