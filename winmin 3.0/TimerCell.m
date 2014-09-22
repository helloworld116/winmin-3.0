//
//  TimerCell.m
//  SmartSwitch
//
//  Created by sdzg on 14-8-13.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "TimerCell.h"

@interface TimerCell ()
@property(strong, nonatomic) IBOutlet UIView *viewContent;
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
  self.viewContent.layer.borderColor = [UIColor lightGrayColor].CGColor;
  self.viewContent.layer.borderWidth = 1.f;
  self.viewContent.layer.cornerRadius = 1.5f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

- (void)setCellInfo:(SDZGTimerTask *)task {
  self.lblTimeInfo.text = [task actionTimeString];
  self._switch.on = [task actionEffective];
  self.lblAction.text = [task actionTypeString];
  self.lblRepeate.text = [task actionWeekString];
}

- (IBAction)switchValueChanged:(id)sender {
  //    kTimerSwitchValueChanged

  [[NSNotificationCenter defaultCenter]
      postNotificationName:kTimerSwitchValueChanged
                    object:self
                  userInfo:nil];
}
@end
