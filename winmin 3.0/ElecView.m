//
//  ElecView.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-30.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "ElecView.h"
#import "ElecRealTimeView.h"
@interface ElecView ()
@property(nonatomic, strong) IBOutlet UIButton *btnRealTime;
@property(nonatomic, strong) IBOutlet UIButton *btnOneDay;
@property(nonatomic, strong) IBOutlet UIButton *btnOneWeek;
@property(nonatomic, strong) IBOutlet UIButton *btnOneMonth;
@property(nonatomic, strong) IBOutlet UIButton *btnThreeMonth;
@property(nonatomic, strong) IBOutlet UIButton *btnSixMonth;
@property(nonatomic, strong) IBOutlet UIButton *btnOneYear;
@property(nonatomic, strong) IBOutlet ElecRealTimeView *realTimeView;

@property(nonatomic, strong) UIButton *btnLastSelected;
- (IBAction)showSelectedDate:(id)sender;
@end

@implementation ElecView

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
  }
  return self;
}

- (void)awakeFromNib {
  self.btnRealTime.selected = YES;
  self.btnLastSelected = self.btnRealTime;
  CGSize size = self.btnRealTime.frame.size;
  UIImage *img = [UIImage imageWithColor:kThemeColor size:size];

  [self.btnRealTime setBackgroundImage:img forState:UIControlStateSelected];
  [self.btnOneDay setBackgroundImage:img forState:UIControlStateSelected];
  [self.btnOneWeek setBackgroundImage:img forState:UIControlStateSelected];
  [self.btnOneMonth setBackgroundImage:img forState:UIControlStateSelected];
  [self.btnThreeMonth setBackgroundImage:img forState:UIControlStateSelected];
  [self.btnSixMonth setBackgroundImage:img forState:UIControlStateSelected];
  [self.btnOneYear setBackgroundImage:img forState:UIControlStateSelected];
}

- (IBAction)showSelectedDate:(id)sender {
  self.btnLastSelected.selected = NO;
  UIButton *btn = (UIButton *)sender;
  btn.selected = YES;
  self.btnLastSelected = btn;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
