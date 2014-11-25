//
//  ElecView.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-30.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "ElecView.h"
#import "ElecRealTimeView.h"
#import <NCISimpleChartView.h>
#import <NCIZoomGraphView.h>
@interface ElecView ()
@property (nonatomic, strong) IBOutlet UIButton *btnRealTime;
@property (nonatomic, strong) IBOutlet UIButton *btnOneDay;
@property (nonatomic, strong) IBOutlet UIButton *btnOneWeek;
@property (nonatomic, strong) IBOutlet UIButton *btnOneMonth;
@property (nonatomic, strong) IBOutlet UIButton *btnThreeMonth;
@property (nonatomic, strong) IBOutlet UIButton *btnSixMonth;
@property (nonatomic, strong) IBOutlet UIButton *btnOneYear;
@property (nonatomic, strong) IBOutlet UIView *containerView;

@property (nonatomic, strong) IBOutlet ElecRealTimeView *realTimeView;
@property (nonatomic, strong) UIView *viewOneDay;
@property (nonatomic, strong) UIView *viewOneWeek;
@property (nonatomic, strong) UIView *viewOneMonth;
@property (nonatomic, strong) UIView *viewThreeMonth;
@property (nonatomic, strong) UIView *viewSixMonth;
@property (nonatomic, strong) UIView *viewOneYear;

@property (nonatomic, strong) UIButton *btnLastSelected;
@property (nonatomic, strong) UIView *viewShowing; //当前展示的view
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
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

  HistoryElecDateType dateType = OneDay;
  BOOL shouldGetData = NO;
  //隐藏之前的view
  self.viewShowing.hidden = YES;
  if (btn == self.btnRealTime) {
    dateType = RealTime;
    self.viewShowing = self.realTimeView;
  } else if (btn == self.btnOneDay) {
    dateType = OneDay;
    if (!self.viewOneDay) {
      shouldGetData = YES;
      self.viewOneDay =
          [[UIView alloc] initWithFrame:self.containerView.bounds];
      [self.containerView addSubview:self.viewOneDay];
    }
    self.viewShowing = self.viewOneDay;
  } else if (btn == self.btnOneWeek) {
    dateType = OneWeek;
    if (!self.viewOneWeek) {
      shouldGetData = YES;
      self.viewOneWeek =
          [[UIView alloc] initWithFrame:self.containerView.bounds];
      [self.containerView addSubview:self.viewOneWeek];
    }
    self.viewShowing = self.viewOneWeek;
  } else if (btn == self.btnOneMonth) {
    dateType = OneMonth;
    if (!self.viewOneMonth) {
      shouldGetData = YES;
      self.viewOneMonth =
          [[UIView alloc] initWithFrame:self.containerView.bounds];
      [self.containerView addSubview:self.viewOneMonth];
    }
    self.viewShowing = self.viewOneMonth;
  } else if (btn == self.btnThreeMonth) {
    dateType = ThreeMonth;
    if (!self.viewThreeMonth) {
      shouldGetData = YES;
      self.viewThreeMonth =
          [[UIView alloc] initWithFrame:self.containerView.bounds];
      [self.containerView addSubview:self.viewThreeMonth];
    }
    self.viewShowing = self.viewThreeMonth;
  } else if (btn == self.btnSixMonth) {
    dateType = SixMonth;
    if (!self.viewSixMonth) {
      shouldGetData = YES;
      self.viewSixMonth =
          [[UIView alloc] initWithFrame:self.containerView.bounds];
      [self.containerView addSubview:self.viewSixMonth];
    }
    self.viewShowing = self.viewSixMonth;
  } else if (btn == self.btnOneYear) {
    dateType = OneYear;
    if (!self.viewOneYear) {
      shouldGetData = YES;
      self.viewOneYear =
          [[UIView alloc] initWithFrame:self.containerView.bounds];
      [self.containerView addSubview:self.viewOneYear];
    }
    self.viewShowing = self.viewOneYear;
  }
  self.viewShowing.hidden = NO;
  if (self.delegate &&
      [self.delegate
          respondsToSelector:@selector(selectedDatetype:needGetData:)]) {
    [self.delegate selectedDatetype:dateType needGetData:shouldGetData];
  }
  //绘制
  if (btn == self.btnRealTime) {
    [self.realTimeView start];
  } else {
    [self.realTimeView stop];
  }
  if (!self.dateFormatter) {
    self.dateFormatter = [[NSDateFormatter alloc] init];
  }
  if (dateType == OneDay) {
    [self.dateFormatter setDateFormat:@"HH:mm"];
  } else {
    [self.dateFormatter setDateFormat:@"MM-dd"];
  }
}

- (void)showChart:(HistoryElecData *)data
         dateType:(HistoryElecDateType)dateType {
  CGRect frame = self.containerView.bounds;
  frame.size.width -= 20;
    NCISimpleChartView *chart = [[NCISimpleChartView alloc] initWithFrame:frame
    andOptions:@{
          nciGraphRenderer : [NCIZoomGraphView class],
          nciIsSmooth : @[ @NO ],
          nciIsFill : @[ @YES ],
          nciLineColors : @[ kThemeColor ],
          nciLineWidths : @[ @1 ],
          nciHasSelection : @NO,
          nciShowPoints : @NO,
          nciGridVertical : @{
                  nciLineColor : kThemeColor,
                  nciLineDashes : @[],
                  nciLineWidth : @0.3
                  },
          nciGridHorizontal : @{
                  nciLineColor : [UIColor clearColor],
                  nciLineDashes : @[ ],
                  nciLineWidth : @1
                  },
          nciGridColor : [UIColor colorWithHexString:@"#ccefd1"],
          nciGridLeftMargin : @0,
          nciGridRightMargin : @20,
          nciGridTopMargin : @0,
          nciGridBottomMargin : @20,
          nciYAxis : @{
                  nciLineColor : kThemeColor,
                  nciLineDashes : @[],
                  nciAxisShift : @259,
                  nciInvertedLabes:@YES,
                  nciLineWidth : @2,
                  nciLabelsColor : [UIColor blackColor],
                  nciLabelsDistance : @((int)(frame.size.height/6)),
                  nciLabelRenderer : ^(double value) {
    return [[NSAttributedString alloc]
    initWithString:[NSString stringWithFormat:@"%.1fW", value]];
}
}
, nciXAxis :
    @{
      nciLineColor : [UIColor colorWithHexString:@"#C3C3C3"],
      nciLineWidth : @1,
      nciAxisShift : @(frame.size.height - 20),
      nciLineDashes : @[],
      nciInvertedLabes : @NO,
      nciLabelsDistance : @40,
      //               nciUseDateFormatter : @YES
      nciLabelRenderer : ^(double value){ NSTimeInterval interval = value;
NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
return [self.dateFormatter stringFromDate:date];
}
}
}];

NSArray *values = data.values;
NSArray *times = data.times;
for (int i = 0; i < values.count; i++) {
  double time = [times[i] doubleValue];
  double value = [values[i] doubleValue];
  [chart addPoint:time val:@[ @(value) ]];
}
UIView *view;
switch (dateType) {
  case OneDay:
    view = self.viewOneDay;
    break;
  case OneWeek:
    view = self.viewOneWeek;
    break;
  case OneMonth:
    view = self.viewOneMonth;
    break;
  case ThreeMonth:
    view = self.viewThreeMonth;
    break;
  case SixMonth:
    view = self.viewSixMonth;
    break;
  case OneYear:
    view = self.viewOneYear;
    break;
  default:
    break;
}
[view addSubview:chart];
}

- (void)showRealTimeData:(NSMutableArray *)powers {
  self.realTimeView.powers = powers;
}

- (void)startRealTimeDraw {
  [self.realTimeView start];
}

- (void)stopRealTimeDraw {
  [self.realTimeView stop];
}
@end
