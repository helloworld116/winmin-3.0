//
//  MessageCell.m
//  winmin 3.0
//
//  Created by sdzg on 14-12-9.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "MessageCell.h"
@interface MessageCell ()
@property (nonatomic, weak) IBOutlet UIView *viewContainer;
@property (nonatomic, weak) IBOutlet UIView *viewLine;
@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblContent;
@property (nonatomic, weak) IBOutlet UILabel *lblTime;
@end

@implementation MessageCell

- (void)awakeFromNib {
  // Initialization code
  self.viewContainer.layer.cornerRadius = 5.f;
  self.viewContainer.layer.borderColor =
      [UIColor colorWithHexString:@"#F0EFEF"].CGColor;
  self.viewContainer.layer.borderWidth = .5f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

- (void)setInfo:(HistoryMessage *)message {
  self.lblTime.text = message.insertDate;
  self.lblContent.text = message.content;
  self.lblTitle.text = message.title;
}

@end
