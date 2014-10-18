//
//  WelcomeViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-10-18.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController ()
- (IBAction)enter:(id)sender;
@end

@implementation WelcomeViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
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
- (IBAction)enter:(id)sender {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults setObject:@YES forKey:kWelcomePageShowed];
  NSString *appVersion =
      [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
  [userDefaults setObject:appVersion forKey:kCurrentVersion];
  UIViewController *mainViewController = [self.storyboard
      instantiateViewControllerWithIdentifier:@"MainController"];
  [mainViewController
      setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
  [self presentViewController:mainViewController
                     animated:YES
                   completion:^{
                       kSharedAppliction.window.rootViewController =
                           mainViewController;
                   }];
}
@end
