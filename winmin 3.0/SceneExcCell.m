//
//  SceneExcCell.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-26.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SceneExcCell.h"
@interface SceneExcCell ()
@property(nonatomic, strong) IBOutlet UILabel *lblSeq;
@property(nonatomic, strong) IBOutlet UILabel *lblDesc;
@property(nonatomic, strong) IBOutlet UILabel *lblExcResult;
@property(nonatomic, strong) IBOutlet UIImageView *imgViewResult;
@end

@implementation SceneExcCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    // Initialization code
  }
  return self;
}

- (void)awakeFromNib {
  // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

@end
