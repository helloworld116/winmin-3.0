//
//  RealTimePowerView.m
//  winmin 3.0
//
//  Created by sdzg on 15-1-21.
//  Copyright (c) 2015年 itouchco.com. All rights reserved.
//

#import "RealTimePowerView.h"

@implementation RealTimePowerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)setPower:(int)power {
  if (power) {
    unsigned int qian, bai, shi, ge;
    NSString *qian_img, *bai_img, *shi_img, *ge_img, *unit_img;
    ge = power % 10;
    shi = (power / 10) % 10;
    bai = (power / 100) % 10;
    qian = (power / 1000) % 10;
    if (power <= 500) {
      //绿色
      self.img4.hidden = YES;
      if (power >= 100) {
        self.img3.hidden = NO;
        self.img2.hidden = NO;
      } else {
        self.img3.hidden = YES;
        if (power >= 10) {
          self.img2.hidden = NO;
        } else {
          self.img2.hidden = YES;
        }
      }
      qian_img = [NSString stringWithFormat:@"realtime_power_green_%d", qian];
      bai_img = [NSString stringWithFormat:@"realtime_power_green_%d", bai];
      shi_img = [NSString stringWithFormat:@"realtime_power_green_%d", shi];
      ge_img = [NSString stringWithFormat:@"realtime_power_green_%d", ge];
      unit_img = @"realtime_power_green_unit";
    } else if (power > 500 && power <= 1500) {
      //橙色
      if (power >= 1000) {
        self.img4.hidden = NO;
      } else {
        self.img4.hidden = YES;
      }
      self.img1.hidden = NO;
      self.img2.hidden = NO;
      self.img3.hidden = NO;
      qian_img = [NSString stringWithFormat:@"realtime_power_orange_%d", qian];
      bai_img = [NSString stringWithFormat:@"realtime_power_orange_%d", bai];
      shi_img = [NSString stringWithFormat:@"realtime_power_orange_%d", shi];
      ge_img = [NSString stringWithFormat:@"realtime_power_orange_%d", ge];
      unit_img = @"realtime_power_orange_unit";
    } else if (power > 1500) {
      self.img1.hidden = NO;
      self.img2.hidden = NO;
      self.img3.hidden = NO;
      self.img4.hidden = NO;
      //红色
      qian_img = [NSString stringWithFormat:@"realtime_power_red_%d", qian];
      bai_img = [NSString stringWithFormat:@"realtime_power_red_%d", bai];
      shi_img = [NSString stringWithFormat:@"realtime_power_red_%d", shi];
      ge_img = [NSString stringWithFormat:@"realtime_power_red_%d", ge];
      unit_img = @"realtime_power_red_unit";
    }
    self.img4.image = [UIImage imageNamed:qian_img];
    self.img3.image = [UIImage imageNamed:bai_img];
    self.img2.image = [UIImage imageNamed:shi_img];
    self.img1.image = [UIImage imageNamed:ge_img];
    self.imgUnit.image = [UIImage imageNamed:unit_img];
  } else {
    self.img1.hidden = NO;
    self.img2.hidden = YES;
    self.img3.hidden = YES;
    self.img4.hidden = YES;
    self.img1.image = [UIImage imageNamed:@"realtime_power_green_0"];
    self.imgUnit.image = [UIImage imageNamed:@"realtime_power_green_unit"];
  }
}
@end
