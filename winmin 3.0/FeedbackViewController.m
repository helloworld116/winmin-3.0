//
//  FeedbackViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-12-7.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "FeedbackViewController.h"
#import "FeedbackModel.h"
#import "TextUtil.h"
@interface FeedbackTextField : UITextField
@end

@implementation FeedbackTextField
- (void)awakeFromNib {
}

//控制文本所在的的位置，左右缩 10
- (CGRect)textRectForBounds:(CGRect)bounds {
  return CGRectInset(bounds, 10, 0);
}

//控制编辑文本时所在的位置，左右缩 10
- (CGRect)editingRectForBounds:(CGRect)bounds {
  return CGRectInset(bounds, 10, 0);
}

@end

@interface FeedbackViewController () <UITextFieldDelegate,
                                      MBProgressHUDDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *textSuggestion;
@property (weak, nonatomic) IBOutlet UITextField *textEmail;
@property (weak, nonatomic) IBOutlet UIButton *btnQuestion;
@property (weak, nonatomic) IBOutlet UIButton *btnSuggestion;
@property (weak, nonatomic) IBOutlet UIButton *btnUsage;
@property (weak, nonatomic) IBOutlet UIButton *btnOther;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;

@property (nonatomic, strong) UITextField *activeField;
@property (nonatomic, strong) UIButton *btnCurrent;
@property (nonatomic, assign) FeedbackType feedbackType;
@property (nonatomic, strong) NSString *detail; //建议内容
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) FeedbackModel *model;
@property (nonatomic, strong) MBProgressHUD *HUD;
@end

@implementation FeedbackViewController

- (void)setup {
  self.navigationItem.title = NSLocalizedString(@"Feedback", nil);
  self.textSuggestion.delegate = self;
  self.textEmail.delegate = self;
  self.textEmail.layer.cornerRadius = 3.f;
  self.textSuggestion.layer.cornerRadius = 3.f;

  [self.btnQuestion setTitleColor:kThemeColor forState:UIControlStateNormal];
  [self.btnQuestion setTitleColor:[UIColor whiteColor]
                         forState:UIControlStateSelected];
  [self.btnQuestion setBackgroundImage:nil forState:UIControlStateNormal];
  [self.btnQuestion setBackgroundImage:[UIImage imageNamed:@"feedback_btn"]
                              forState:UIControlStateSelected];
  [self.btnQuestion addTarget:self
                       action:@selector(question)
             forControlEvents:UIControlEventTouchUpInside];

  [self.btnSuggestion setTitleColor:kThemeColor forState:UIControlStateNormal];
  [self.btnSuggestion setTitleColor:[UIColor whiteColor]
                           forState:UIControlStateSelected];
  [self.btnSuggestion setBackgroundImage:nil forState:UIControlStateNormal];
  [self.btnSuggestion setBackgroundImage:[UIImage imageNamed:@"feedback_btn"]
                                forState:UIControlStateSelected];
  [self.btnSuggestion addTarget:self
                         action:@selector(suggestion)
               forControlEvents:UIControlEventTouchUpInside];

  [self.btnUsage setTitleColor:kThemeColor forState:UIControlStateNormal];
  [self.btnUsage setTitleColor:[UIColor whiteColor]
                      forState:UIControlStateSelected];
  [self.btnUsage setBackgroundImage:nil forState:UIControlStateNormal];
  [self.btnUsage setBackgroundImage:[UIImage imageNamed:@"feedback_btn"]
                           forState:UIControlStateSelected];
  [self.btnUsage addTarget:self
                    action:@selector(usage)
          forControlEvents:UIControlEventTouchUpInside];

  [self.btnOther setTitleColor:kThemeColor forState:UIControlStateNormal];
  [self.btnOther setTitleColor:[UIColor whiteColor]
                      forState:UIControlStateSelected];
  [self.btnOther setBackgroundImage:nil forState:UIControlStateNormal];
  [self.btnOther setBackgroundImage:[UIImage imageNamed:@"feedback_btn"]
                           forState:UIControlStateSelected];
  [self.btnOther addTarget:self
                    action:@selector(other)
          forControlEvents:UIControlEventTouchUpInside];

  self.btnSubmit.layer.cornerRadius = 3.f;
  [self.btnSubmit addTarget:self
                     action:@selector(submit)
           forControlEvents:UIControlEventTouchUpInside];

  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  if ([[userDefaults objectForKey:@"loginType"] isEqualToString:@"email"]) {
    self.textEmail.text = [userDefaults objectForKey:@"email"];
  }

  self.model = [[FeedbackModel alloc] init];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setup];
  self.btnQuestion.selected = YES;
  self.btnCurrent = self.btnQuestion;
  self.feedbackType = FeedbackQuestion;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)touchBackground:(id)sender {
  [self.textEmail resignFirstResponder];
  [self.textSuggestion resignFirstResponder];
}

- (void)question {
  [self touchType:FeedbackQuestion];
  self.btnQuestion.selected = YES;
  self.btnCurrent = self.btnQuestion;
}

- (void)suggestion {
  [self touchType:FeedbackSuggestion];
  self.btnSuggestion.selected = YES;
  self.btnCurrent = self.btnSuggestion;
}

- (void)usage {
  [self touchType:FeedbackUsage];
  self.btnUsage.selected = YES;
  self.btnCurrent = self.btnUsage;
}

- (void)other {
  [self touchType:FeedbackOther];
  self.btnOther.selected = YES;
  self.btnCurrent = self.btnOther;
}

- (void)touchType:(int)type {
  self.btnCurrent.selected = NO;
}

- (void)submit {
  if ([self check]) {
    self.HUD = [[MBProgressHUD alloc] initWithWindow:kSharedAppliction.window];
    [self.view.window addSubview:self.HUD];
    self.HUD.delegate = self;
    [self.HUD show:YES];
    [self.model
        requestWithFeedbackType:self.feedbackType
                         detail:self.detail
                          email:self.email
                     completion:^(BOOL result) {
                         dispatch_async(MAIN_QUEUE, ^{
                             [self.HUD hide:YES];
                             if (result) {
                               self.textSuggestion.text = @"";
                               [self showMessage:NSLocalizedString(
                                                     @"feedback success", nil)];
                             } else {
                               [self showMessage:NSLocalizedString(
                                                     @"feedback error", nil)];
                             }
                         });
                     }];
  }
}

- (BOOL)check {
  [self touchBackground:nil];
  NSCharacterSet *charSet = [NSCharacterSet whitespaceCharacterSet];
  NSString *email =
      [self.textEmail.text stringByTrimmingCharactersInSet:charSet];
  NSString *detail =
      [self.textSuggestion.text stringByTrimmingCharactersInSet:charSet];
  if (!detail.length) {
    [self showMessage:NSLocalizedString(@"feedback cannot empty", nil)];
    return NO;
  }
  if (email.length) {
    if ([TextUtil isEmailAddress:email]) {
      self.email = email;
    } else {
      [self showMessage:NSLocalizedString(@"email format is incorrect", nil)];
      return NO;
    }
  } else {
    [self showMessage:NSLocalizedString(@"email can not be empty", nil)];
    return NO;
  }
  self.email = email;
  self.detail = detail;
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

#pragma mark - UITextField协议
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField == self.textSuggestion) {
    [self.textEmail becomeFirstResponder];
    return NO;
  }
  [self.textEmail resignFirstResponder];
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

#pragma mark - MBProgressHud
- (void)hudWasHidden {
  // Remove HUD from screen
  [self.HUD removeFromSuperview];

  // add here the code you may need
}
@end
