//
//  FaqCell.m
//  winmin 3.0
//
//  Created by sdzg on 14-10-23.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "FaqCell.h"
const CGFloat kContentWidth = 265.f;
@implementation FaqCell

- (void)awakeFromNib {
  // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

- (void)setQuestion:(NSString *)question
     questionHeight:(CGFloat)questionHeight
             answer:(NSString *)answer
       answerHeight:(CGFloat)answerHeight
          indexPath:(NSIndexPath *)indexPath {
  //头部
  CGRect rect = self.viewTitle.frame;
  rect.size.height = questionHeight;
  self.viewTitle.frame = rect;
  //底部
  rect = self.viewContent.frame;
  rect.size.height = answerHeight;
  self.viewContent.frame = rect;
  //图标
  rect = self.viewTitleBg.frame;
  rect.origin.y = questionHeight - rect.size.height;
  self.viewTitleBg.frame = rect;
  //问题
  self.lblQuestion.frame = CGRectMake(50, 5, kContentWidth, questionHeight);
  //线条
  rect = self.viewLine.frame;
  rect.size.height = answerHeight;
  self.viewLine.frame = rect;
  //答案
  self.lblAnswer.frame = CGRectMake(50, 5, kContentWidth, answerHeight - 10);

  self.lblQNum.text = [@"Q" stringByAppendingFormat:@"%d", indexPath.row + 1];
  self.lblANum.text = [@"A" stringByAppendingFormat:@"%d", indexPath.row + 1];
  self.lblQuestion.text = question;
  self.lblAnswer.text = answer;
  debugLog(@"****************cell height is %f", questionHeight + answerHeight);
}
@end
