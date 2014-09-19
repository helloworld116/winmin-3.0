//
//  MoreCellTypeSecond.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-17.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "MoreCellTypeSecond.h"

@implementation MoreCellTypeSecond

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    // Initialization code
  }
  return self;
}

- (void)setupStyle {
  self.lblTitle.textColor = kThemeColor;
}

- (void)awakeFromNib {
  // Initialization code
  [self setupStyle];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

- (void)setTitle:(NSString *)title icon:(NSString *)icon {
  self.lblTitle.text = title;
  self.imgIcon.image = [UIImage imageNamed:icon];
}
@end
