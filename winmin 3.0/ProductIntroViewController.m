//
//  ProductIntroViewController.m
//  winmin 3.0
//
//  Created by sdzg on 15-3-26.
//  Copyright (c) 2015年 itouchco.com. All rights reserved.
//

#import "ProductIntroViewController.h"
#import <EAIntroView.h>

@interface ProductIntroViewController () <EAIntroDelegate>
@property (strong, nonatomic) IBOutlet EAIntroView *introView;
@end

@implementation ProductIntroViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.

  self.introView.delegate = self;
  NSString *page1Name, *page2Name, *page3Name, *page4Name, *page5Name;
  //  if (is4Inch) {
  //    page1Name = @"welcome1-5@2x";
  //    page2Name = @"welcome2-5@2x";
  //    page3Name = @"welcome3-5@2x";
  //    page4Name = @"welcome4-5@2x";
  //  } else {
  //    page1Name = @"welcome1@2x";
  //    page2Name = @"welcome2@2x";
  //    page3Name = @"welcome3@2x";
  //    page4Name = @"welcome4@2x";
  //  }
  if (self.type == DeviceType_T1501) {
    page1Name = @"t1501_welcome_1@2x";
  } else {
    page1Name = @"t1601_welcome_1@2x";
  }
  page2Name = @"device_welcome_2@2x";
  page3Name = @"device_welcome_3@2x";
  page4Name = @"device_welcome_4@2x";
  page5Name = @"device_welcome_5@2x";

  EAIntroPage *page1 = [EAIntroPage page];
  [page1
      setBgImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                                      pathForResource:page1Name
                                                               ofType:@"png"]]];

  EAIntroPage *page2 = [EAIntroPage page];
  [page2
      setBgImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                                      pathForResource:page2Name
                                                               ofType:@"png"]]];
  EAIntroPage *page3 = [EAIntroPage page];
  [page3
      setBgImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                                      pathForResource:page3Name
                                                               ofType:@"png"]]];
  EAIntroPage *page4 = [EAIntroPage page];
  [page4
      setBgImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                                      pathForResource:page4Name
                                                               ofType:@"png"]]];
  EAIntroPage *page5 = [EAIntroPage page];
  [page5
      setBgImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                                      pathForResource:page5Name
                                                               ofType:@"png"]]];

  UIButton *enterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
  [enterBtn setBackgroundImage:[UIImage imageNamed:@"enter"]
                      forState:UIControlStateNormal];
  CGFloat btnWidth;
  if ([kSharedAppliction.currnetLanguage isEqualToString:@"en"]) {
    btnWidth = 180.f;
  } else {
    btnWidth = 105.f;
  }
  [enterBtn setFrame:CGRectMake(0, 0, btnWidth, 37)];
  [enterBtn setTitle:NSLocalizedString(@"Start to experience", nil)
            forState:UIControlStateNormal];
  [enterBtn addTarget:self
                action:@selector(enterMainViewController:)
      forControlEvents:UIControlEventTouchUpInside];
  page5.titleIconPositionY = [[UIScreen mainScreen] bounds].size.height - 80;
  page5.titleIconView = enterBtn;

  NSArray *pages = @[ page1, page2, page3, page4, page5 ];
  self.introView.pageControl.pageIndicatorTintColor = [UIColor whiteColor];
  self.introView.pageControl.currentPageIndicatorTintColor =
      [UIColor colorWithRed:0.210 green:0.948 blue:0.501 alpha:1.000];
  [self.introView setPages:pages];
  [self.introView setSwipeToExit:NO];
  self.introView.backgroundColor = [UIColor colorWithWhite:0.849 alpha:1.000];
  self.introView.bgViewContentMode = UIViewContentModeScaleAspectFit;
  self.introView.skipButton.hidden = YES;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - UIStatusBarStyle
- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

- (void)enterMainViewController:(id)sender {
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

#pragma mark - EAIntroDelegate
- (void)introDidFinish:(EAIntroView *)introView {
}

@end
