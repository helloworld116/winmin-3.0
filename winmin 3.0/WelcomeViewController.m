//
//  WelcomeViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-10-18.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "WelcomeViewController.h"
#import <EAIntroView.h>

@interface WelcomeViewController () <EAIntroDelegate>
@property (strong, nonatomic) IBOutlet EAIntroView *introView;
@end

@implementation WelcomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.

  self.introView.delegate = self;
  NSString *page1Name, *page2Name, *page3Name, *page4Name;
  if (is4Inch) {
    page1Name = @"welcome1-5@2x";
    page2Name = @"welcome2-5@2x";
    page3Name = @"welcome3-5@2x";
    page4Name = @"welcome4-5@2x";
  } else {
    page1Name = @"welcome1@2x";
    page2Name = @"welcome2@2x";
    page3Name = @"welcome3@2x";
    page4Name = @"welcome4@2x";
  }

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
  page4.titleIconPositionY = [[UIScreen mainScreen] bounds].size.height - 90;
  page4.titleIconView = enterBtn;

  NSArray *pages = @[ page1, page2, page3, page4 ];
  self.introView.pageControl.pageIndicatorTintColor = [UIColor whiteColor];
  self.introView.pageControl.currentPageIndicatorTintColor =
      [UIColor colorWithRed:0.210 green:0.948 blue:0.501 alpha:1.000];
  [self.introView setPages:pages];
  [self.introView setSwipeToExit:NO];
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
