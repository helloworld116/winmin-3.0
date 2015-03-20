//
//  AboutUsViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-10-13.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "AboutUsViewController.h"

static NSString *const kAPPURL = @"http://itunes.apple.com/lookup?id=935562573";

@interface AboutUsViewController ()
@property (nonatomic, strong) IBOutlet UILabel *lblVersion;
@property (nonatomic, strong) IBOutlet UIButton *btn;

@property (nonatomic, strong) NSString *trackViewURL;
@property (nonatomic, strong) NSString *appVersion;
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
  self.appVersion = [[NSBundle mainBundle]
      objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
  self.lblVersion.text = [@"V" stringByAppendingString:self.appVersion];
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
  //  [self.view makeToast:@"已是最新版本"];
  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  dispatch_async(GLOBAL_QUEUE, ^{
    [self onCheckVersion:self.appVersion];
  });
}

- (IBAction)moreInfo:(id)sender {
  //  [[UIApplication sharedApplication]
  //      openURL:[NSURL URLWithString:AboutUsURLString]];
}

- (void)onCheckVersion:(NSString *)currentVersion {
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
  [request setURL:[NSURL URLWithString:kAPPURL]];
  [request setHTTPMethod:@"POST"];
  NSHTTPURLResponse *urlResponse = nil;
  NSError *error = nil;
  NSData *recervedData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:&urlResponse
                                                           error:&error];
  NSString *results = [[NSString alloc] initWithBytes:[recervedData bytes]
                                               length:[recervedData length]
                                             encoding:NSUTF8StringEncoding];
  NSDictionary *dic = __JSON(results);
  NSArray *infoArray = [dic objectForKey:@"results"];
  if ([infoArray count]) {
    NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
    NSString *lastVersion = [releaseInfo objectForKey:@"version"];
    if (![lastVersion isEqualToString:currentVersion]) {
      self.trackViewURL = [releaseInfo objectForKey:@"trackViewUrl"];
      dispatch_async(MAIN_QUEUE, ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIAlertView *alert = [[UIAlertView alloc]
                initWithTitle:nil
                      message:NSLocalizedString(@"Answer Update", nil)
                     delegate:self
            cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
            otherButtonTitles:NSLocalizedString(@"Go Update", nil), nil];
        [alert show];
      });
    } else {
      dispatch_async(MAIN_QUEUE, ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.view makeToast:@"已是最新版本"];
      });
    }
  }
}

#pragma mark UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  switch (buttonIndex) {
    case 0:
      break;
    case 1:
      [[UIApplication sharedApplication]
          openURL:[NSURL URLWithString:self.trackViewURL]];
      break;
    default:
      break;
  }
}
@end
