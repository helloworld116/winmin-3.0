//
//  DelaySettingViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-23.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "DelaySettingViewController.h"

@interface DelaySettingViewController ()<UITextFieldDelegate>
@property(strong, nonatomic) IBOutlet UITextField *textField;
@property(strong, nonatomic) IBOutlet UIButton *btnInput;
@property(strong, nonatomic) IBOutlet UIButton *btnMinitues5;
@property(strong, nonatomic) IBOutlet UIButton *btnMinitues10;
@property(strong, nonatomic) IBOutlet UIButton *btnMinitues30;
@property(strong, nonatomic) IBOutlet UIButton *btnMinitues60;
@property(strong, nonatomic) IBOutlet UIButton *btnMinitues90;
@property(strong, nonatomic) IBOutlet UIButton *btnMinitues120;
- (IBAction)choiceAction:(id)sender;

@property(nonatomic, assign) BOOL actionState;     //开关状态
@property(nonatomic, assign) int actionMinitues;   //延迟时间
@property(nonatomic, strong) UIButton *btnOfLast;  //最后操作的按钮
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

- (void)setup {
  self.textField.delegate = self;
  self.actionState = YES;
  //默认选中5分钟的按钮
  self.actionMinitues = 5;
  self.btnOfLast = self.btnMinitues5;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
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
      minitues = 0;
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
@end
