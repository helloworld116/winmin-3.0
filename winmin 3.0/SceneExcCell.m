//
//  SceneExcCell.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-26.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SceneExcCell.h"
#import "SceneDetail.h"
@interface SceneExcCell ()
@property (nonatomic, strong) IBOutlet UILabel *lblSeq;
@property (nonatomic, strong) IBOutlet UILabel *lblDesc;
@property (nonatomic, strong) IBOutlet UILabel *lblExcResult;
@property (nonatomic, strong) IBOutlet UIImageView *imgViewResult;
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

- (void)setSceneDetail:(SceneDetail *)sceneDetail row:(int)row {
  self.lblSeq.text = [NSString stringWithFormat:@"%d", row];
  self.lblDesc.text = [sceneDetail description];
}

- (void)showLeftSeconds:(double)leftSeconds {
  NSString *preState = NSLocalizedString(@"scene waiting", nil);
  NSString *suffState = [NSString stringWithFormat:@"%.1fs", leftSeconds];
  self.lblExcResult.text =
      [NSString stringWithFormat:@"%@ %@", preState, suffState];
}

- (void)updatePage:(BOOL)success {
  NSString *result;
  NSString *imgName;
  if (success) {
    result = NSLocalizedString(@"execute success", nil);
    imgName = @"exc_ok";
  } else {
    result = NSLocalizedString(@"execute failure", nil);
    imgName = @"exc_failure";
  }
  self.lblExcResult.text = result;
  self.imgViewResult.image = [UIImage imageNamed:imgName];
  self.imgViewResult.hidden = NO;
}

- (void)beginExecute {
  self.lblExcResult.text = NSLocalizedString(@"executing", nil);
  ;
}
@end
