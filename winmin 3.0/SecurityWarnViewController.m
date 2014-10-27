//
//  SecurityWarnViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-10-13.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SecurityWarnViewController.h"

@interface SecurityWarnViewController ()
@property (nonatomic, strong) IBOutlet UIView *bgA;
@property (nonatomic, strong) IBOutlet UIView *bgW;
@end

@implementation SecurityWarnViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)setupStyle {
  self.bgA.layer.cornerRadius = 6.f;
  self.bgW.layer.cornerRadius = 6.f;
}

- (void)setup {
  [self setupStyle];
  self.navigationItem.title = NSLocalizedString(@"Safety Warning", nil);
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

@end
