//
//  MoreCellTypeFirst.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-17.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "MoreCellTypeFirst.h"

@implementation MoreCellTypeFirst

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

- (void)showLoginPage:(id)sender {
}
@end
