//
//  ConfHelpViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-11-28.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "ConfHelpViewController.h"

@interface ConfHelpViewController () <UIScrollViewDelegate>
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *backBtn;
@end

@implementation ConfHelpViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the
  self.scrollView.delegate = self;
  self.navigationController.navigationBarHidden = YES;
  UIImageView *imgView;
  //  UIButton *backBtn;
  //  for (int i = 0; i < 3; i++) {
  //    NSString *imageName = [NSString stringWithFormat:@"conf_help_%d", (i +
  //    1)];
  //    imgView =
  //        [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
  //    imgView.frame =
  //        CGRectMake(i * SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
  //    backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
  //    backBtn.frame = CGRectMake(i * SCREEN_WIDTH, 0, 80, 80);
  //    [backBtn setImage:[UIImage imageNamed:@"back_ch"]
  //             forState:UIControlStateNormal];
  //    [backBtn addTarget:self
  //                  action:@selector(back:)
  //        forControlEvents:UIControlEventTouchUpInside];
  //    [self.scrollView addSubview:imgView];
  //    [self.scrollView addSubview:backBtn];
  //  }

  NSString *nameFormater;
  if (is4Inch) {
    nameFormater = @"conf_help_%d_5";
  } else {
    nameFormater = @"conf_help_%d";
  }
  for (int i = 0; i < 3; i++) {
    NSString *imageName = [NSString stringWithFormat:nameFormater, (i + 1)];
    imgView =
        [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    imgView.frame =
        CGRectMake(i * SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.scrollView addSubview:imgView];
  }
  self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
  self.backBtn.frame = CGRectMake(0, 0, 80, 80);
  [self.backBtn setImage:[UIImage imageNamed:@"back_ch"]
                forState:UIControlStateNormal];
  [self.backBtn addTarget:self
                   action:@selector(back:)
         forControlEvents:UIControlEventTouchUpInside];
  [self.scrollView addSubview:self.backBtn];
}

//- (void)viewDidAppear:(BOOL)animated {
//  [super viewDidAppear:animated];
//  self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 3, SCREEN_HEIGHT);
//}

- (void)back:(id)sender {
  self.navigationController.navigationBarHidden = NO;
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 3, SCREEN_HEIGHT);
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
#pragma mark - UIScollViewDelegate
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
  [UIView animateWithDuration:0.3f animations:^{ self.backBtn.hidden = YES; }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  CGRect btnFrame = self.backBtn.frame;
  self.backBtn.frame = CGRectMake(scrollView.contentOffset.x, btnFrame.origin.y,
                                  btnFrame.size.width, btnFrame.size.height);
  [UIView animateWithDuration:0.3f animations:^{ self.backBtn.hidden = NO; }];
}
@end
