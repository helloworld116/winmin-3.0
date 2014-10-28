//
//  RegisterViewController.m
//  SmartSwitch
//
//  Created by sdzg on 14-8-6.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "RegisterViewController.h"
#import "UserInfo.h"
#import "TextUtil.h"

@interface RegisterViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextField *textEmail;
@property (strong, nonatomic) IBOutlet UITextField *textFieldPassword;
@property (strong, nonatomic) IBOutlet UITextField *textFieldPassword2;
@property (strong, nonatomic) IBOutlet UITextField *textFieldNickName;
@property (strong, nonatomic) IBOutlet UIView *view1;
@property (strong, nonatomic) IBOutlet UIView *view2;
@property (strong, nonatomic) IBOutlet UIView *view3;
@property (strong, nonatomic) IBOutlet UIView *view4;
@property (strong, nonatomic) IBOutlet UIButton *btnRegister;
- (IBAction)toUserProtocolPage:(id)sender;
- (IBAction)agreenProtocol:(id)sender;
- (IBAction) register:(id)sender;

- (IBAction)touchBackground:(id)sender;

@property (strong, nonatomic) UITextField *activeField;
@property (assign, nonatomic) BOOL isAgreenProtocol;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *nickName;
@property (strong, nonatomic) NSString *password;
@end

@implementation RegisterViewController

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
  self.view3.layer.borderColor =
      [UIColor colorWithHexString:@"#c3c3c3"].CGColor;
  self.view3.layer.borderWidth = .5f;
  self.view3.layer.cornerRadius = 5.f;
  self.view4.layer.borderColor =
      [UIColor colorWithHexString:@"#c3c3c3"].CGColor;
  self.view4.layer.borderWidth = .5f;
  self.view4.layer.cornerRadius = 5.f;

  self.btnRegister.layer.borderColor = [UIColor blackColor].CGColor;
  self.btnRegister.layer.borderWidth = .5f;
  self.btnRegister.layer.cornerRadius = 3.f;
}

- (void)setup {
  [self setupStyle];
  self.textEmail.delegate = self;
  self.textFieldPassword.delegate = self;
  self.textFieldPassword2.delegate = self;
  self.textFieldNickName.delegate = self;

  self.isAgreenProtocol = YES;
  UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
  backButtonItem.title = NSLocalizedString(@"Back", nil);
  self.navigationItem.backBarButtonItem = backButtonItem;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.navigationItem.title = NSLocalizedString(@"User Register", nil);
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
                                           selector:@selector(registerResponse:)
                                               name:kRegisterResponse
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
                                                  name:kRegisterResponse
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 导航栏按钮处理
- (IBAction)toUserProtocolPage:(id)sender {
  UIViewController *nextController = [self.storyboard
      instantiateViewControllerWithIdentifier:@"ProtocolViewController"];
  [self.navigationController pushViewController:nextController animated:YES];
}

- (IBAction)agreenProtocol:(id)sender {
  UIButton *btn = (UIButton *)sender;
  btn.selected = !btn.selected;
  self.isAgreenProtocol = btn.selected;
  self.btnRegister.enabled = self.isAgreenProtocol;
}

- (IBAction) register:(id)sender {
  if ([self check]) {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    UserInfo *userInfo = [[UserInfo alloc] initWithEmail:self.email
                                                password:self.password
                                                nickName:self.nickName];
    [userInfo registerRequest];
  }
}

- (BOOL)check {
  [self touchBackground:nil];
  NSCharacterSet *charSet = [NSCharacterSet whitespaceCharacterSet];
  NSString *email =
      [self.textEmail.text stringByTrimmingCharactersInSet:charSet];
  NSString *nickName =
      [self.textFieldNickName.text stringByTrimmingCharactersInSet:charSet];
  NSString *password =
      [self.textFieldPassword.text stringByTrimmingCharactersInSet:charSet];
  NSString *password2 =
      [self.textFieldPassword2.text stringByTrimmingCharactersInSet:charSet];
  if (email.length) {
    if ([TextUtil isEmailAddress:email]) {
      self.email = email;
    } else {
      [self showMessage:@"邮箱格式不正确"];
      return NO;
    }
  } else {
    [self showMessage:@"邮箱不能为空"];
    return NO;
  }
  if (!password.length) {
    [self showMessage:@"密码不能为空"];
    return NO;
  }
  if ([password isEqualToString:password2]) {
    self.password = password;
  } else {
    [self showMessage:@"两次输入的密码不一致"];
    return NO;
  }
  if (nickName.length) {
    self.nickName = nickName;
  } else {
    [self showMessage:@"昵称不能为空"];
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

- (IBAction)touchBackground:(id)sender {
  [self.textEmail resignFirstResponder];
  [self.textFieldPassword resignFirstResponder];
  [self.textFieldPassword2 resignFirstResponder];
  [self.textFieldNickName resignFirstResponder];
}

#pragma mark - UITextField协议
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField == self.textEmail) {
    [self.textFieldPassword becomeFirstResponder];
    return NO;
  } else if (textField == self.textFieldPassword) {
    [self.textFieldPassword2 becomeFirstResponder];
    return NO;
  } else if (textField == self.textFieldPassword2) {
    [self.textFieldNickName becomeFirstResponder];
    return NO;
  } else if (textField == self.textFieldNickName) {
    [self.textFieldNickName resignFirstResponder];
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

#pragma mark - 注册消息通知
- (void)registerResponse:(NSNotification *)notification {
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

        [self.navigationController popToRootViewControllerAnimated:NO];
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
