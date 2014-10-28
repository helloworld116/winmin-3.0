//
//  ForgetPwdViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-10-28.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "ForgetPwdViewController.h"

@interface ForgetPwdViewController ()
@property (nonatomic, strong) IBOutlet UITextField *textEmail;
@property (nonatomic, strong) IBOutlet UIButton *btn;
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
  self.navigationItem.title = NSLocalizedString(@"Find Password", nil);
  UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
  backButtonItem.title = NSLocalizedString(@"Back", nil);
  self.navigationItem.backBarButtonItem = backButtonItem;
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

- (IBAction)sendEmail:(id)sender {
  UIViewController *nextController = [self.storyboard
      instantiateViewControllerWithIdentifier:@"ResetPwdViewController"];
  [self.navigationController pushViewController:nextController animated:YES];
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

@end
