//
//  FaqCell.h
//  winmin 3.0
//
//  Created by sdzg on 14-10-23.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>
extern const CGFloat kContentWidth;

@interface FaqCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UIView *viewTitle;
@property (nonatomic, strong) IBOutlet UIView *viewTitleBg;
@property (nonatomic, strong) IBOutlet UILabel *lblQNum;
@property (nonatomic, strong) IBOutlet UILabel *lblQuestion;

@property (nonatomic, strong) IBOutlet UIView *viewContent;
@property (nonatomic, strong) IBOutlet UIView *viewLine;
@property (nonatomic, strong) IBOutlet UILabel *lblANum;
@property (nonatomic, strong) IBOutlet UILabel *lblAnswer;

- (void)setQuestion:(NSString *)question
     questionHeight:(CGFloat)questionHeight
             answer:(NSString *)answer
       answerHeight:(CGFloat)answerHeight
          indexPath:(NSIndexPath *)indexPath;
@end
