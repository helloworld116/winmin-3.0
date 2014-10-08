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
@property(nonatomic, strong) IBOutlet UIView *containerView;

@property(nonatomic, strong) IBOutlet ElecRealTimeView *realTimeView;
@property(nonatomic, strong) UIView *viewOneDay;
@property(nonatomic, strong) UIView *viewOneWeek;
@property(nonatomic, strong) UIView *viewOneMonth;
@property(nonatomic, strong) UIView *viewThreeMonth;
@property(nonatomic, strong) UIView *viewSixMonth;
@property(nonatomic, strong) UIView *viewOneYear;

@property(nonatomic, strong) UIButton *btnLastSelected;
@property(nonatomic, strong) UIView *viewShowing;  //当前展示的view
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
  self.viewShowing = self.realTimeView;
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

  //隐藏之前的view
  self.viewShowing.hidden = YES;
  if (btn == self.btnRealTime) {
    self.viewShowing = self.realTimeView;
  } else if (btn == self.btnOneDay) {
    if (!self.viewOneDay) {
      self.viewOneDay =
          [[UIView alloc] initWithFrame:self.containerView.bounds];
      [self.containerView addSubview:self.viewOneDay];

      UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
      //      label.center = self.viewOneDay.center;
      label.text = @"1天";
      [self.viewOneDay addSubview:label];
      [self.containerView bringSubviewToFront:self.viewOneDay];
    }
    self.viewShowing = self.viewOneDay;
  } else if (btn == self.btnOneWeek) {
    if (!self.viewOneWeek) {
      self.viewOneWeek =
          [[UIView alloc] initWithFrame:self.containerView.bounds];
      [self.containerView addSubview:self.viewOneWeek];
    }
    self.viewShowing = self.viewOneWeek;
  } else if (btn == self.btnOneMonth) {
    if (!self.viewOneMonth) {
      self.viewOneMonth =
          [[UIView alloc] initWithFrame:self.containerView.bounds];
      [self.containerView addSubview:self.viewOneMonth];
    }
    self.viewShowing = self.viewOneMonth;
  } else if (btn == self.btnThreeMonth) {
    if (!self.viewThreeMonth) {
      self.viewThreeMonth =
          [[UIView alloc] initWithFrame:self.containerView.bounds];
      [self.containerView addSubview:self.viewThreeMonth];
    }
    self.viewShowing = self.viewThreeMonth;
  } else if (btn == self.btnSixMonth) {
    if (!self.viewSixMonth) {
      self.viewSixMonth =
          [[UIView alloc] initWithFrame:self.containerView.bounds];
      [self.containerView addSubview:self.viewSixMonth];
    }
    self.viewShowing = self.viewSixMonth;
  } else if (btn == self.btnOneYear) {
    if (!self.viewOneYear) {
      self.viewOneYear =
          [[UIView alloc] initWithFrame:self.containerView.bounds];
      [self.containerView addSubview:self.viewOneYear];
    }
    self.viewShowing = self.viewOneYear;
  }
  self.viewShowing.hidden = NO;
}

@end
