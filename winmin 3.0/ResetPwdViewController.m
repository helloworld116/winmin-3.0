//
//  ResetPwdViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-10-28.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "ResetPwdViewController.h"

@interface ResetPwdViewController ()<UITextFieldDelegate>
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
  self.navigationItem.title = NSLocalizedString(@"Reset Password", nil);
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

- (IBAction)save:(id)sender {
}

- (IBAction)touchBackground:(id)sender {
}

@end
