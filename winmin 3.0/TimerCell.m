//
//  TimerCell.m
//  SmartSwitch
//
//  Created by sdzg on 14-8-13.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "TimerCell.h"

@interface TimerCell ()
@property(strong, nonatomic) IBOutlet UIView *viewTimeBackground;
@property(strong, nonatomic) IBOutlet UILabel *lblTimeInfo;
@property(strong, nonatomic) IBOutlet UILabel *lblAction;
@property(strong, nonatomic) IBOutlet UILabel *lblRepeate;
@property(strong, nonatomic) IBOutlet UILabel *lblExecuteCout;
@property(strong, nonatomic) IBOutlet UISwitch *_switch;

- (IBAction)switchValueChanged:(id)sender;
@end

@implementation TimerCell

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
  self.viewTimeBackground.layer.cornerRadius = 3.f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

- (void)setCellInfo:(SDZGTimerTask *)task {
  self.lblTimeInfo.text = [task actionTimeString];
  self._switch.on = [task actionEffective];
  self.lblAction.text = [task actionTypeString];
  NSString *repeateText = [task actionWeekString];
  CGRect repeateFrame = [repeateText
      boundingRectWithSize:CGSizeMake(self.lblRepeate.frame.size.width,
                                      MAXFLOAT)
                   options:NSStringDrawingUsesLineFragmentOrigin
                attributes:@{
                  NSFontAttributeName : self.lblRepeate.font
                } context:nil];
  if (repeateFrame.size.height > self.lblRepeate.frame.size.height) {
    CGRect lblRepeateFrame = self.lblRepeate.frame;
    lblRepeateFrame.size =
        CGSizeMake(lblRepeateFrame.size.width, repeateFrame.size.height);
    self.lblRepeate.frame = lblRepeateFrame;
  }
  self.lblRepeate.text = repeateText;
}

- (IBAction)switchValueChanged:(id)sender {
  //    kTimerSwitchValueChanged
  NSDictionary *userInfo = @{ @"effective" : @(self._switch.on) };
  [[NSNotificationCenter defaultCenter]
      postNotificationName:kTimerEffectiveChanged
                    object:self
                  userInfo:userInfo];
}
@end
