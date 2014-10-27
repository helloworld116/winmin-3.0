//
//  AboutUsViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-10-13.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "AboutUsViewController.h"

@interface AboutUsViewController ()
@property (nonatomic, strong) IBOutlet UILabel *lblVersion;
@property (nonatomic, strong) IBOutlet UIButton *btn;
- (IBAction)checkVersion:(id)sender;
- (IBAction)moreInfo:(id)sender;
@end

@implementation AboutUsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)setupStyle {
  self.btn.layer.cornerRadius = 6.f;
}

- (void)setup {
  [self setupStyle];
  self.navigationItem.title = NSLocalizedString(@"About Us", nil);
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self setup];
  NSString *appVersion = [[NSBundle mainBundle]
      objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
  self.lblVersion.text = [@"V" stringByAppendingString:appVersion];
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
- (IBAction)checkVersion:(id)sender {
  [self.view makeToast:@"已是最新版本"];
}

- (IBAction)moreInfo:(id)sender {
}
@end
