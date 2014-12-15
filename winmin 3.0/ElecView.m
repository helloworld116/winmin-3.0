//
//  ElecView.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-30.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "ElecView.h"
#import "ElecRealTimeView.h"
//#import <NCISimpleChartView.h>
//#import <NCIZoomGraphView.h>
#import <BEMSimpleLineGraphView.h>
static const int kWidth = 50.f;
@interface ElecView () <BEMSimpleLineGraphDataSource,
                        BEMSimpleLineGraphDelegate>
@property (nonatomic, strong) IBOutlet UIButton *btnRealTime;
@property (nonatomic, strong) IBOutlet UIButton *btnOneDay;
@property (nonatomic, strong) IBOutlet UIButton *btnOneWeek;
@property (nonatomic, strong) IBOutlet UIButton *btnOneMonth;
@property (nonatomic, strong) IBOutlet UIButton *btnThreeMonth;
@property (nonatomic, strong) IBOutlet UIButton *btnSixMonth;
@property (nonatomic, strong) IBOutlet UIButton *btnOneYear;
@property (nonatomic, strong) IBOutlet UIView *containerView;

@property (nonatomic, strong) IBOutlet ElecRealTimeView *realTimeView;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) BEMSimpleLineGraphView *myGraph;

@property (nonatomic, assign) BOOL oneDayDataRecived;
@property (nonatomic, assign) BOOL oneWeekDataRecived;
@property (nonatomic, assign) BOOL oneMonthDataRecived;
@property (nonatomic, assign) BOOL threeMonthDataRecived;
@property (nonatomic, assign) BOOL sixMonthDataRecived;
@property (nonatomic, assign) BOOL oneYearDataRecived;

@property (nonatomic, strong) HistoryElecData *oneDayData;
@property (nonatomic, strong) HistoryElecData *oneWeekData;
@property (nonatomic, strong) HistoryElecData *oneMonthData;
@property (nonatomic, strong) HistoryElecData *threeMonthData;
@property (nonatomic, strong) HistoryElecData *sixMonthData;
@property (nonatomic, strong) HistoryElecData *oneYearData;

@property (nonatomic, strong) UIButton *btnLastSelected;
@property (nonatomic, strong) UIView *viewShowing; //当前展示的view
@property (nonatomic, strong) HistoryElecData *currentData;
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

  self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
  self.scrollView.bounces = NO;
  self.scrollView.showsHorizontalScrollIndicator = NO;
  self.scrollView.hidden = YES;
  [self.containerView addSubview:self.scrollView];
  self.myGraph =
      [[BEMSimpleLineGraphView alloc] initWithFrame:self.containerView.bounds];
  self.myGraph.delegate = self;
  self.myGraph.dataSource = self;
  // Customization of the graph
  //  CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
  //  size_t num_locations = 2;
  //  CGFloat locations[2] = { 0.0, 1.0 };
  //  CGFloat components[8] = { 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0 };
  //  self.myGraph.gradientBottom = CGGradientCreateWithColorComponents(
  //      colorspace, components, locations, num_locations);
  self.myGraph.colorTop = [UIColor colorWithHexString:@"#CCEFD1"];
  self.myGraph.colorBottom = [UIColor colorWithHexString:@"#28B92E" alpha:0.3f];
  self.myGraph.colorLine = kThemeColor;
  self.myGraph.colorXaxisLabel = [UIColor blackColor];
  self.myGraph.colorYaxisLabel = [UIColor whiteColor];
  self.myGraph.colorPoint = kThemeColor;
  self.myGraph.animationGraphEntranceTime = 0.5f;
  self.myGraph.widthLine = 1.0;
  self.myGraph.sizePoint = 5.f;
  //  self.myGraph.labelFont = [UIFont systemFontOfSize:10.f];
  self.myGraph.enableTouchReport = YES;
  self.myGraph.enablePopUpReport = YES;
  self.myGraph.enableBezierCurve = YES;
  self.myGraph.enableYAxisLabel = NO;
  self.myGraph.autoScaleYAxis = YES;
  self.myGraph.alwaysDisplayDots = YES;
  self.myGraph.alwaysDisplayPopUpLabels = YES;
  self.myGraph.enableReferenceXAxisLines = YES;
  self.myGraph.enableReferenceYAxisLines = YES;
  self.myGraph.enableReferenceAxisFrame = YES;
  self.myGraph.animationGraphStyle = BEMLineAnimationDraw;
  self.myGraph.enableBezierCurve = NO;
  [self.scrollView addSubview:self.myGraph];
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
    self.scrollView.hidden = YES;
  } else if (btn == self.btnOneDay) {
    dateType = OneDay;
    self.viewShowing = self.scrollView;
    shouldGetData = !self.oneDayDataRecived;
    if (!shouldGetData) {
      self.currentData = self.oneDayData;
      [self showGraph:OneDay];
    }
  } else if (btn == self.btnOneWeek) {
    dateType = OneWeek;
    self.viewShowing = self.scrollView;
    shouldGetData = !self.oneWeekDataRecived;
    if (!shouldGetData) {
      self.currentData = self.oneWeekData;
      [self showGraph:OneWeek];
    }
  } else if (btn == self.btnOneMonth) {
    dateType = OneMonth;
    self.viewShowing = self.scrollView;
    shouldGetData = !self.oneMonthDataRecived;
    if (!shouldGetData) {
      self.currentData = self.oneMonthData;
      [self showGraph:OneMonth];
    }
  } else if (btn == self.btnThreeMonth) {
    dateType = ThreeMonth;
    self.viewShowing = self.scrollView;
    shouldGetData = !self.threeMonthDataRecived;
    if (!shouldGetData) {
      self.currentData = self.threeMonthData;
      [self showGraph:ThreeMonth];
    }
  } else if (btn == self.btnSixMonth) {
    dateType = SixMonth;
    self.viewShowing = self.scrollView;
    shouldGetData = !self.sixMonthDataRecived;
    if (!shouldGetData) {
      self.currentData = self.sixMonthData;
      [self showGraph:SixMonth];
    }
  } else if (btn == self.btnOneYear) {
    dateType = OneYear;
    self.viewShowing = self.scrollView;
    shouldGetData = !self.oneYearDataRecived;
    if (!shouldGetData) {
      self.currentData = self.oneYearData;
      [self showGraph:OneYear];
    }
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
  } else if (dateType == SixMonth || dateType == OneYear) {
    [self.dateFormatter setDateFormat:@"yy-MM"];
  } else {
    [self.dateFormatter setDateFormat:@"MM-dd"];
  }
}

- (void)showChart:(HistoryElecData *)data
         dateType:(HistoryElecDateType)dateType {
  switch (dateType) {
    case OneDay:
      self.oneDayData = data;
      self.oneDayDataRecived = YES;
      break;
    case OneWeek:
      self.oneWeekData = data;
      self.oneWeekDataRecived = YES;
      break;
    case OneMonth:
      self.oneMonthData = data;
      self.oneMonthDataRecived = YES;
      break;
    case ThreeMonth:
      self.threeMonthData = data;
      self.threeMonthDataRecived = YES;
      break;
    case SixMonth:
      self.sixMonthData = data;
      self.sixMonthDataRecived = YES;
      break;
    case OneYear:
      self.oneYearData = data;
      self.oneYearDataRecived = YES;
      break;
    default:
      break;
  }
  self.currentData = data;
  [self showGraph:dateType];
}

- (void)showGraph:(HistoryElecDateType)dateType {
  int dataCount = [self.currentData.times count];
  self.scrollView.frame = CGRectMake(0, 0, self.containerView.frame.size.width,
                                     self.containerView.frame.size.height);
  self.scrollView.contentSize =
      CGSizeMake(dataCount * kWidth, self.containerView.frame.size.height);
  CGRect graphFrame = self.myGraph.frame;
  graphFrame.size =
      CGSizeMake(dataCount * kWidth, self.containerView.frame.size.height);
  self.myGraph.frame = graphFrame;
  [self.myGraph reloadGraph];
  self.scrollView.hidden = NO;
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

#pragma mark - SimpleLineGraph Data Source

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
  //  return (int)[self.arrayOfValues count];
  return [self.currentData.values count];
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph
    valueForPointAtIndex:(NSInteger)index {
  return [[self.currentData.values objectAtIndex:index] doubleValue];
}

#pragma mark - SimpleLineGraph Delegate

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:
                 (BEMSimpleLineGraphView *)graph {
  return 0;
}

- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph
    labelOnXAxisForIndex:(NSInteger)index {
  NSTimeInterval intervalStr =
      [[self.currentData.times objectAtIndex:index] doubleValue];
  //  NSString *label =
  //    self.dateFormatter
  return [self.dateFormatter
      stringFromDate:[NSDate dateWithTimeIntervalSince1970:intervalStr]];
  //  return [label stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
}

- (CGFloat)staticPaddingForLineGraph:(BEMSimpleLineGraphView *)graph {
  return 50.f;
}

//- (NSInteger)numberOfYAxisLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
//  return 3;
//}
//
//- (CGFloat)minValueForLineGraph:(BEMSimpleLineGraphView *)graph {
//  return 0.f;
//}
//
//- (CGFloat)maxValueForLineGraph:(BEMSimpleLineGraphView *)graph {
//  return 10000.f;
//}
@end
