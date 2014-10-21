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
  UIImage *image = [UIImage
      imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"book@2x"
                                                              ofType:@"jpg"]];
  self.imgWidth = image.size.width;
  //  CGRect imgViewFrame = self.imgView.frame;
  //  imgViewFrame.size = image.size;
  //  self.imgView.frame = imgViewFrame;
  self.imgView.image = image;
  //  self.scollView.contentSize = image.size;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
  debugLog(@"img width is %f", self.imgWidth);
  self.scollView.contentSize = CGSizeMake(
      self.imgWidth, SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT);
  self.imgView.frame =
      CGRectMake(0, 0, self.imgWidth,
                 SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT);
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
