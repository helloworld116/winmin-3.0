//
//  ChoiceViewController.m
//  winmin 3.0
//
//  Created by sdzg on 15-3-25.
//  Copyright (c) 2015年 itouchco.com. All rights reserved.
//

#import "ChoiceViewController.h"
#import "ProductIntroViewController.h"

@interface ChoiceViewController ()

@end

@implementation ChoiceViewController

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

- (IBAction)t1501Action:(id)sender {
  ProductIntroViewController *nextController = [self.storyboard
      instantiateViewControllerWithIdentifier:@"ProductIntroViewController"];
  nextController.type = DeviceType_T1501;
  [self presentViewController:nextController
                     animated:YES
                   completion:^{

                   }];
}

- (IBAction)t1601Action:(id)sender {
  ProductIntroViewController *nextController = [self.storyboard
      instantiateViewControllerWithIdentifier:@"ProductIntroViewController"];
  nextController.type = DeviceType_T1601;
  [self presentViewController:nextController
                     animated:YES
                   completion:^{

                   }];
}
@end
