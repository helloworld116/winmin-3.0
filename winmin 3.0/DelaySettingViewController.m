//
//  DelaySettingViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-23.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "DelaySettingViewController.h"

@interface DelaySettingViewController () <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIButton *btnInput;
@property (strong, nonatomic) IBOutlet UIButton *btnMinitues5;
@property (strong, nonatomic) IBOutlet UIButton *btnMinitues10;
@property (strong, nonatomic) IBOutlet UIButton *btnMinitues30;
@property (strong, nonatomic) IBOutlet UIButton *btnMinitues60;
@property (strong, nonatomic) IBOutlet UIButton *btnMinitues90;
@property (strong, nonatomic) IBOutlet UIButton *btnMinitues120;
@property (strong, nonatomic) IBOutlet UIButton *btnOnOff;
@property (strong, nonatomic) IBOutlet UIButton *btnSave;
- (IBAction)choiceAction:(id)sender;
- (IBAction)onOffAction:(id)sender;
- (IBAction)save:(id)sender;

@property (nonatomic, assign) BOOL actionState;    //开关状态
@property (nonatomic, assign) int actionMinitues;  //延迟时间
@property (nonatomic, strong) UIButton *btnOfLast; //最后操作的按钮
@property (nonatomic, strong) UIButton *btnDone;   //键盘左下角的按钮
@end

@implementation DelaySettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)setupStyle {
  self.btnSave.layer.cornerRadius = 5.f;

  self.view.layer.borderColor =
      [UIColor colorWithHexString:@"#C3C3C3" alpha:1].CGColor;
  self.view.layer.cornerRadius = 5.f;
  //  self.view.layer.borderWidth = 1.f;
  self.view.layer.masksToBounds = YES;
}

- (void)setup {
  [self setupStyle];
  self.textField.delegate = self;
  self.actionState = YES;
  //默认选中5分钟的按钮
  self.actionMinitues = 5;
  self.btnOfLast = self.btnMinitues5;
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
                                           selector:@selector(delaySetSuccess:)
                                               name:kDelaySettingNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(noResponseNotification:)
             name:kNoResponseNotification
           object:self.model];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  [self setup];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  [self.textField resignFirstResponder];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)choiceAction:(id)sender {
  UIButton *btn = (UIButton *)sender;
  int minitues;
  UIButton *btnOfCurrentSelected;
  switch (btn.tag) {
    case 301:
      // 5分钟
      minitues = 5;
      btnOfCurrentSelected = self.btnMinitues5;
      [self.textField resignFirstResponder];
      break;
    case 302:
      // 10分钟
      minitues = 10;
      btnOfCurrentSelected = self.btnMinitues10;
      [self.textField resignFirstResponder];
      break;
    case 303:
      // 30分钟
      minitues = 30;
      btnOfCurrentSelected = self.btnMinitues30;
      [self.textField resignFirstResponder];
      break;
    case 304:
      // 60分钟
      minitues = 60;
      btnOfCurrentSelected = self.btnMinitues60;
      [self.textField resignFirstResponder];
      break;
    case 305:
      // 90分钟
      minitues = 90;
      btnOfCurrentSelected = self.btnMinitues90;
      [self.textField resignFirstResponder];
      break;
    case 306:
      // 120分钟
      minitues = 120;
      btnOfCurrentSelected = self.btnMinitues120;
      [self.textField resignFirstResponder];
      break;
    case 307:
      // 自定义分钟
      minitues = 10;
      btnOfCurrentSelected = self.btnInput;
      [self.textField becomeFirstResponder];
      break;
    default:
      break;
  }
  self.actionMinitues = minitues;
  [UIView animateWithDuration:0.3
                   animations:^{
                       self.btnOfLast.selected = NO;
                       btnOfCurrentSelected.selected = YES;
                       self.btnOfLast = btnOfCurrentSelected;
                   }];
}

- (IBAction)onOffAction:(id)sender {
  [UIView animateWithDuration:0.3
                   animations:^{
                       self.btnOnOff.selected = !self.btnOnOff.selected;
                   }];
  self.actionState = self.btnOnOff.selected;
}
- (IBAction)save:(id)sender {
  if (self.actionMinitues > 1440) {
    [self.view makeToast:NSLocalizedString(@"at most 1440 minutes", nil)];
  } else {
    [self.model setDelayWithMinitues:self.actionMinitues
                             onOrOff:self.actionState];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  }
}

#pragma mark - UITextField协议
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self.textField resignFirstResponder];
  return YES;
}

#pragma mark - 键盘通知
- (void)keyboardDidShow:(NSNotification *)notification {
  NSDictionary *info = [notification userInfo];
  CGSize kbSize =
      [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
  CGFloat width = kbSize.width / 3;
  CGFloat height = kbSize.height / 4;
  if (self.btnDone == nil) {
    self.btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnDone.frame = CGRectMake(0, SCREEN_HEIGHT - height, width, height);
    [self.btnDone setTitle:@"完成" forState:UIControlStateNormal];
    [self.btnDone setTitleColor:[UIColor blackColor]
                       forState:UIControlStateNormal];
    [self.btnDone addTarget:self
                     action:@selector(finishAction:)
           forControlEvents:UIControlEventTouchUpInside];
  }

  // locate keyboard view
  UIWindow *tempWindow =
      [[[UIApplication sharedApplication] windows] objectAtIndex:1];
  if (self.btnDone.superview == nil) {
    [tempWindow addSubview:self.btnDone]; // 注意这里直接加到window上
  }

  CGRect selfFrame = self.view.frame;
  selfFrame.origin.y -= 90;
  [UIView animateWithDuration:0.3 animations:^{ self.view.frame = selfFrame; }];
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
  CGRect selfFrame = self.view.frame;
  selfFrame.origin.y += 90;
  [UIView animateWithDuration:0.3 animations:^{ self.view.frame = selfFrame; }];
  if (self.btnDone.superview) {
    [self.btnDone removeFromSuperview];
    self.btnDone = nil;
  }
}

- (void)finishAction:(id)sender {
  [self.textField resignFirstResponder];
  self.actionMinitues = [self.textField.text intValue];
}

- (void)delaySetSuccess:(NSNotification *)notification {
  dispatch_async(MAIN_QUEUE,
                 ^{ [MBProgressHUD hideHUDForView:self.view animated:YES]; });
  if (self.delegate &&
      [self.delegate
          respondsToSelector:@selector(closePopViewController:passMinitues:)]) {
    [self.delegate closePopViewController:self
                             passMinitues:self.actionMinitues];
  }
}

- (void)noResponseNotification:(NSNotification *)notif {
  dispatch_async(MAIN_QUEUE,
                 ^{ [MBProgressHUD hideHUDForView:self.view animated:YES]; });
}
@end
