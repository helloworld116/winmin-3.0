//
//  ProtocolViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-10-24.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "ProtocolViewController.h"

@interface ProtocolViewController ()
@property (nonatomic, strong) IBOutlet UIWebView *webView;
@end

@implementation ProtocolViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.navigationItem.title = @"晟大用户协议";
  NSURL *url =
      [[NSBundle mainBundle] URLForResource:@"protocol" withExtension:@"htm"];
  [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
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

@end
