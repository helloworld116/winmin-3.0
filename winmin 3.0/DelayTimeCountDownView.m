//
//  DelayTimeCountDownView.m
//  SmartSwitch
//
//  Created by sdzg on 14-8-27.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "DelayTimeCountDownView.h"
@interface DelayTimeCountDownView ()
@property(nonatomic, strong) IBOutlet UILabel *lblHour1;
@property(nonatomic, strong) IBOutlet UILabel *lblHour2;
@property(nonatomic, strong) IBOutlet UILabel *lblMin1;
@property(nonatomic, strong) IBOutlet UILabel *lblMin2;
@property(nonatomic, strong) IBOutlet UILabel *lblSec1;
@property(nonatomic, strong) IBOutlet UILabel *lblSec2;

@property(nonatomic, assign) int seconds;  //需要倒计时的秒数
@property(nonatomic, strong) dispatch_source_t timer;
@end

@implementation DelayTimeCountDownView

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
  }
  return self;
}

- (void)awakeFromNib {
  [self setToZero];
}

- (void)countDown:(int)seconds {
  if (seconds) {
    self.seconds = seconds;
    __weak id weakSelf = self;
    if (self.timer) {
      dispatch_source_cancel(self.timer);
    }
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,
                                        dispatch_get_main_queue());
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0),
                              (unsigned)(1 * NSEC_PER_SEC), 0);
    dispatch_source_set_event_handler(_timer, ^{ [weakSelf updateView]; });
    dispatch_resume(_timer);
  }
}

- (void)updateView {
  if (self.seconds) {
    NSString *imgHour1Name, *imgHour2Name, *imgMin1Name, *imgMin2Name,
        *imgSec1Name, *imgSec2Name;
    int hour = self.seconds / 3600;                           //小时
    int minutes = (self.seconds - 3600 * hour) / 60;          //分钟
    int seconds = self.seconds - 3600 * hour - 60 * minutes;  //秒
    imgHour1Name = [NSString stringWithFormat:@"%d", hour / 10];
    imgHour2Name = [NSString stringWithFormat:@"%d", hour % 10];
    imgMin1Name = [NSString stringWithFormat:@"%d", minutes / 10];
    imgMin2Name = [NSString stringWithFormat:@"%d", minutes % 10];
    imgSec1Name = [NSString stringWithFormat:@"%d", seconds / 10];
    imgSec2Name = [NSString stringWithFormat:@"%d", seconds % 10];
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.lblHour1.text = imgHour1Name;
                             self.lblHour2.text = imgHour2Name;
                             self.lblMin1.text = imgMin1Name;
                             self.lblMin2.text = imgMin2Name;
                             self.lblSec1.text = imgSec1Name;
                             self.lblSec2.text = imgSec2Name;
                         }];
        self.seconds--;
    });
  } else {
    [self setToZero];
    dispatch_source_cancel(self.timer);
  }
}

- (void)setToZero {
  static NSString *text = @"0";
  dispatch_async(dispatch_get_main_queue(), ^{
      [UIView animateWithDuration:0.3
                       animations:^{
                           self.lblHour1.text = text;
                           self.lblHour2.text = text;
                           self.lblMin1.text = text;
                           self.lblMin2.text = text;
                           self.lblSec1.text = text;
                           self.lblSec2.text = text;
                       }];
  });
}

- (void)dealloc {
  if (self.timer) {
    dispatch_source_cancel(self.timer);
  }
}
@end
