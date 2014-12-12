//
//  ConfigurationViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-16.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "ConfigurationViewController.h"
#import "ConfigLoadingViewController.h"

@interface ConfigurationTextField : UITextField
@property (nonatomic, assign) CGFloat inset;
@end

@implementation ConfigurationTextField
//- (void)awakeFromNib {
//  if ([kSharedAppliction.currnetLanguage isEqualToString:@"en"]) {
//    self.inset = 80.f;
//  } else {
//    self.inset = 50.f;
//  }
//}
//
////控制文本所在的的位置，左右缩 10
//- (CGRect)textRectForBounds:(CGRect)bounds {
//  return CGRectInset(bounds, 80, 0);
//}
//
////控制编辑文本时所在的位置，左右缩 10
//- (CGRect)editingRectForBounds:(CGRect)bounds {
//  return CGRectInset(bounds, 80, 0);
//}

@end

@interface ConfigurationViewController () <UITextFieldDelegate,
                                           MJConfigLoadingDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *viewWIFI;
@property (strong, nonatomic) IBOutlet UIView *viewPassword;
@property (strong, nonatomic) IBOutlet UITextField *textWIFI;
@property (strong, nonatomic) IBOutlet UITextField *textPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnConfig;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewShowPassword;

@property (strong, nonatomic) UITextField *activeField;
@property (strong, nonatomic) NSString *ssid;
- (IBAction)showOrHiddenPassword:(id)sender;
- (IBAction)doConfig:(id)sender;
- (IBAction)touchBackground:(id)sender;
@end

@implementation ConfigurationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)setupStyle {
  self.viewWIFI.layer.borderColor =
      [UIColor colorWithHexString:@"#c3c3c3"].CGColor;
  self.viewWIFI.layer.borderWidth = .5f;
  self.viewWIFI.layer.cornerRadius = 10.f;

  self.viewPassword.layer.borderColor =
      [UIColor colorWithHexString:@"#c3c3c3"].CGColor;
  self.viewPassword.layer.borderWidth = .5f;
  self.viewPassword.layer.cornerRadius = 10.f;

  self.btnConfig.layer.borderColor =
      [UIColor colorWithHexString:@"#136419"].CGColor;
  self.btnConfig.layer.borderWidth = .5f;
  self.btnConfig.layer.cornerRadius = 5.f;

  self.navigationItem.backBarButtonItem = nil;
}

- (void)setup {
  [self setupStyle];
  self.textWIFI.userInteractionEnabled = NO;
  self.textWIFI.delegate = self;
  self.textPassword.delegate = self;
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(netChangedNotification:)
             name:kNetChangedNotification
           object:nil];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
#if defined(TARGET_IPHONE_SIMULATOR) && TARGET_IPHONE_SIMULATOR
#else
  self.ssid = [FirstTimeConfig getSSID];
  self.textWIFI.text = self.ssid;
#endif
  //设置之前配置成功用的密码
  if (self.ssid) {
    NSString *password =
        [[NSUserDefaults standardUserDefaults] objectForKey:self.ssid];
    if (password) {
      self.textPassword.text = password;
    } else {
      self.textPassword.text = @"";
    }
  }
  self.textPassword.secureTextEntry = YES;
  self.imgViewShowPassword.image = [UIImage imageNamed:@"password_normal"];
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
}

- (IBAction)showOrHiddenPassword:(id)sender {
  self.textPassword.secureTextEntry = !self.textPassword.isSecureTextEntry;
  if (self.textPassword.isSecureTextEntry) {
    self.imgViewShowPassword.image = [UIImage imageNamed:@"password_normal"];
  } else {
    self.imgViewShowPassword.image = [UIImage imageNamed:@"password_selected"];
  }
}

- (IBAction)doConfig:(id)sender {
  [self touchBackground:nil];
  ConfigLoadingViewController *viewController =
      [[ConfigLoadingViewController alloc]
          initWithNibName:@"ConfigLoadingViewController"
                   bundle:nil];
  viewController.delegate = self;
  viewController.ssid = self.ssid;
  viewController.password = self.textPassword.text;
  [self presentPopupViewController:viewController
                     animationType:MJPopupViewAnimationFade];
}

- (IBAction)touchBackground:(id)sender {
  [self.textWIFI resignFirstResponder];
  [self.textPassword resignFirstResponder];
}

#pragma mark - UITextField协议
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField == self.textWIFI) {
    [self.textPassword becomeFirstResponder];
    return NO;
  } else if (textField == self.textPassword) {
    [self.textPassword resignFirstResponder];
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

#pragma mark - 网络改变通知
- (void)netChangedNotification:(NSNotification *)notification {
  NetworkStatus status = kSharedAppliction.networkStatus;
  if (status == NotReachable) {
    //网络不可用时修改所有设备状态为离线并停止扫描
  } else {
  }
}

#pragma mark - MJConfigLoadingDelegate
- (void)cancelButtonClicked:
            (ConfigLoadingViewController *)configLoadingViewController
                    success:(BOOL)success {
  [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
  if (success) {
    self.tabBarController.selectedIndex = 0;
  }
}
@end
