//
//  BookViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-10-21.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "BookViewController.h"

@interface BookViewController ()
@property (nonatomic, strong) IBOutlet UIScrollView *scollView;
@property (nonatomic, strong) IBOutlet UIImageView *imgView;
@property (nonatomic, assign) CGFloat imgWidth;
@end

@implementation BookViewController

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
  self.navigationItem.title = NSLocalizedString(@"User Manual", nil);
  dispatch_async(GLOBAL_QUEUE, ^{
      //      NSData *data =
      //          [NSData dataWithContentsOfFile:[[NSBundle mainBundle]
      //                                             pathForResource:@"book@2x"
      //                                                      ofType:@"jpg"]];
      NSData *data =
          [NSData dataWithContentsOfFile:[[NSBundle mainBundle]
                                             pathForResource:@"bookinfo@2x"
                                                      ofType:@"png"]];

      UIImage *image = [UIImage imageWithData:data];

      self.imgWidth = image.size.width;
      dispatch_async(MAIN_QUEUE, ^{
          self.imgView.image = image;
          self.scollView.frame =
              CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - STATUSBAR_HEIGHT -
                                                 NAVIGATIONBAR_HEIGHT);
          self.scollView.contentSize =
              CGSizeMake(self.imgWidth / 2, SCREEN_HEIGHT - STATUSBAR_HEIGHT -
                                                NAVIGATIONBAR_HEIGHT);
          self.imgView.frame = CGRectMake(0, 0, self.imgWidth / 2,
                                          SCREEN_HEIGHT - STATUSBAR_HEIGHT -
                                              NAVIGATIONBAR_HEIGHT);
      });
  });
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  self.scollView.contentSize =
      CGSizeMake(3757, SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT);
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
