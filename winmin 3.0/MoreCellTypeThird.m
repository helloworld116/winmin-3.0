//
//  MoreCellTypeThird.m
//  winmin 3.0
//
//  Created by sdzg on 14-10-15.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "MoreCellTypeThird.h"

@interface MoreCellTypeThird () <UIAlertViewDelegate>

@end

@implementation MoreCellTypeThird

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    // Initialization code
  }
  return self;
}

- (void)setupStyle {
  //  UIImage *imgNormal =
  //      [UIImage imageWithColor:kThemeColor size:self.btn.frame.size];
  //  UIImage *imgHighlighted =
  //      [UIImage imageWithColor:[UIColor colorWithHexString:@"#31AD44"]
  //                         size:self.btn.frame.size];
  //  [self.btn setBackgroundImage:imgNormal forState:UIControlStateNormal];
  //  [self.btn setBackgroundImage:imgHighlighted
  //                      forState:UIControlStateHighlighted];
  [self.btn setBackgroundColor:kThemeColor];

  self.btn.layer.borderColor = [UIColor colorWithHexString:@"#0F7523"].CGColor;
  self.btn.layer.borderWidth = .5f;
  self.btn.layer.cornerRadius = 4.f;
}

- (void)awakeFromNib {
  // Initialization code
  [self setupStyle];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

- (IBAction)loginOut:(id)sender {
  UIAlertView *alertView = [[UIAlertView alloc]
          initWithTitle:nil
                message:NSLocalizedString(@"Log out message", nil)
               delegate:self
      cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
      otherButtonTitles:NSLocalizedString(@"Sure", nil), nil];
  [alertView show];
}

- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 1) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginOut
                                                        object:self];
  }
}
@end
