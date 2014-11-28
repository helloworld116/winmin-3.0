//
//  ScenePreExcDailogViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-11-28.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "ScenePreExcDailogViewController.h"

@interface ScenePreExcDailogViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblMsg;
- (IBAction)touchCancel:(id)sender;
- (IBAction)touchExecute:(id)sender;
@end

@implementation ScenePreExcDailogViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.lblMsg.text = @"场"
                     @"景是预定义的一组开关操作。\n执行场景可能会立即打开或关"
                     @"闭你的用电设备。\n确定执行吗？";
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

- (IBAction)touchCancel:(id)sender {
  if ([self.delegate respondsToSelector:@selector(closePopViewController:
                                                          passExecutable:)]) {
    [self.delegate closePopViewController:self passExecutable:NO];
  }
}

- (IBAction)touchExecute:(id)sender {
  if ([self.delegate respondsToSelector:@selector(closePopViewController:
                                                          passExecutable:)]) {
    [self.delegate closePopViewController:self passExecutable:YES];
  }
}
@end
