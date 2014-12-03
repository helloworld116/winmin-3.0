//
//  ElecRealTimeView.m
//  SmartSwitch
//
//  Created by 文正光 on 14-8-23.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "ElecRealTimeView.h"

#define kLineColor kThemeColor
#define kFillColor [UIColor colorWithWhite:1.0 alpha:0.2]
#define kBigRoundStrokeColor kThemeColor
#define kBigRoundFillColor kThemeColor
#define kTextColor [UIColor blackColor]
#define str(value) [NSString stringWithFormat:@"%.0fW", value]
#define kTopMargin 12 //上边距
#define kLeftMargin 4 //左边距
#define kCount 8      //显示点个数

@interface ElecRealTimeView ()
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) NSArray *points;
@end
@implementation ElecRealTimeView

static CGFloat scaleX;

- (void)awakeFromNib {
  self.powers = [@[] mutableCopy];
  scaleX = (self.frame.size.width - kLeftMargin * 2) / (kCount - 1);
}

- (void)start {
  __weak id weakSelf = self;
  self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,
                                      dispatch_get_main_queue());
  dispatch_time_t delayTime =
      dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
  dispatch_source_set_timer(_timer, delayTime,
                            (unsigned)(kElecRefreshInterval * NSEC_PER_SEC), 0);
  dispatch_source_set_event_handler(_timer, ^{ [weakSelf updateView]; });
  dispatch_resume(_timer);
}

- (void)stop {
  if (self.timer)
    dispatch_source_cancel(self.timer);
}

//- (void)updateView {
//  //随机取0到2000的值
//  int value = (arc4random() % 2500);
//  //  int value = 0;
//  //  NSLog(@"next value is %d", value);
//  [self.powers addObject:@(value)];
//  if (self.powers.count > kCount) {
//    NSRange range = NSMakeRange(self.powers.count - kCount, kCount);
//    self.points = [self.powers subarrayWithRange:range];
//  } else {
//    self.points = self.powers;
//  }
//  [self setNeedsDisplay];
//}

- (void)updateView {
  DDLogDebug(@"point count is %d", self.powers.count);
  if (self.powers.count > kCount) {
    NSRange range = NSMakeRange(self.powers.count - kCount, kCount);
    self.points = [self.powers subarrayWithRange:range];
  } else {
    self.points = self.powers;
  }
  [self setNeedsDisplay];
}

- (void)dealloc {
  if (self.timer) {
    dispatch_source_cancel(self.timer);
  }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
  float maxValue = [[self.points valueForKeyPath:@"@max.self"] floatValue];
  //  int minValue = [[self.points valueForKeyPath:@"@min.self"] integerValue];
  //  int diff = maxValue - minValue;
  CGFloat height = rect.size.height - kTopMargin; //离上边距
  CGFloat scaleY = 1;
  //  if (diff <= 10) {
  //    scaleY *= 0.3;
  //  } else {
  //    if (maxValue != 0) {
  //      scaleY = height / maxValue;
  //      if (height > maxValue) {
  //        scaleY *= 0.6;
  //      }
  //    }
  //  }
  if (maxValue != 0) {
    scaleY = height / maxValue;
    if (height > maxValue) {
      scaleY *= 0.9f;
    }
  }

  // Drawing code
  CGContextRef context = UIGraphicsGetCurrentContext();

  //创建句柄
  //绘制分割线
  CGMutablePathRef pathRef = CGPathCreateMutable();
  CGContextSetLineWidth(context, 0.5f);
  CGContextSetStrokeColorWithColor(context, kThemeColor.CGColor);
  for (int i = 0; i < kCount; i++) {
    CGPathMoveToPoint(pathRef, NULL, kLeftMargin + i * scaleX, 0);
    CGPathAddLineToPoint(pathRef, NULL, kLeftMargin + i * scaleX,
                         rect.size.height);
  }
  CGContextAddPath(context, pathRef);
  CGContextDrawPath(context, kCGPathStroke);
  CGPathRelease(pathRef);
  if (self.points.count == 0) {
    return;
  }

  //画线
  pathRef = CGPathCreateMutable();
  CGContextSetLineCap(context, kCGLineCapRound);
  CGContextSetLineJoin(context, kCGLineJoinRound);
  CGContextSetLineWidth(context, 1);
  CGContextSetStrokeColorWithColor(context, kLineColor.CGColor);
  CGContextSetFillColorWithColor(context, kFillColor.CGColor);
  for (int i = 0; i < self.points.count; i++) {
    double point = [[self.points objectAtIndex:i] doubleValue];
    CGFloat x = scaleX * i + kLeftMargin,
            y = height - (point * scaleY) + kTopMargin / 2;
    if (i == 0) {
      CGPathMoveToPoint(pathRef, NULL, x, y);
    } else {
      CGPathAddLineToPoint(pathRef, NULL, x, y);
    }
    //    if (i == self.points.count - 1) {
    //      CGPathAddLineToPoint(pathRef, NULL, x + 5, y);
    //    }
  }
  //填充颜色
  //  CGPathAddLineToPoint(pathRef, NULL,
  //                       (scaleX * (self.points.count - 1) + kLeftMargin + 5),
  //                       height + kTopMargin + 1);
  //  CGPathAddLineToPoint(pathRef, NULL, -2, height + kTopMargin + 1);
  //  CGPathAddLineToPoint(
  //      pathRef, NULL, -2,
  //      height - ([self.points[0] doubleValue] * scaleY) + kTopMargin / 2);
  //  CGPathCloseSubpath(pathRef);
  //将path添加到上下文
  CGContextAddPath(context, pathRef);
  CGContextDrawPath(context, kCGPathStroke);
  CGPathRelease(pathRef);

  //大圆
  pathRef = CGPathCreateMutable();
  CGContextSetLineWidth(context, 0.5f);
  CGContextSetStrokeColorWithColor(context, kBigRoundStrokeColor.CGColor);
  CGContextSetFillColorWithColor(context, kBigRoundFillColor.CGColor);
  for (int i = 0; i < self.points.count; i++) {
    double point = [[self.points objectAtIndex:i] doubleValue];
    CGFloat x = scaleX * i + kLeftMargin,
            y = height - (point * scaleY) + kTopMargin / 2;
    double bigRoundRadius = 2.0f; //大圆半径
    CGContextAddEllipseInRect(
        context, CGRectMake(x - bigRoundRadius, y - bigRoundRadius,
                            2 * bigRoundRadius, 2 * bigRoundRadius));
  }
  CGContextAddPath(context, pathRef);
  CGContextDrawPath(context, kCGPathFillStroke);
  CGPathRelease(pathRef);

  //  //小圆
  //  pathRef = CGPathCreateMutable();
  //  CGContextSetFillColorWithColor(context, kBigRoundStrokeColor.CGColor);
  //  for (int i = 0; i < self.points.count; i++) {
  //    double point = [[self.points objectAtIndex:i] doubleValue];
  //    CGFloat x = scaleX * i + kLeftMargin,
  //            y = height - (point * scaleY) + kTopMargin / 2;
  //    double smallRoundRadius = 1.5f;  //小圆半径
  //    CGContextAddEllipseInRect(
  //        context, CGRectMake(x - smallRoundRadius, y - smallRoundRadius,
  //                            2 * smallRoundRadius, 2 * smallRoundRadius));
  //  }
  //  CGContextAddPath(context, pathRef);
  //  CGContextDrawPath(context, kCGPathFill);
  //  CGPathRelease(pathRef);

  //文字
  CGContextSaveGState(context);
  CGContextSetFillColorWithColor(context, kTextColor.CGColor);
  //  [kTextColor set];
  for (int i = 0; i < self.points.count; i++) {
    double point = [[self.points objectAtIndex:i] doubleValue];
    CGFloat textOffset;
    if (i == 0) {
      textOffset = 1.f;
    } else {
      textOffset = -8.f;
    }
    if (self.points.count >= kCount && i == self.points.count - 1) {
      textOffset = -16.f;
    }
    CGFloat y = height - (point * scaleY);
    if (height - y < 2 * kTopMargin) {
      y -= kTopMargin;
    } else if (height - y >= height) {
      y += kTopMargin;
      //    }
      //
      //    if (point <= 10) {
      //      //值小于10，文字显示在上方
      //      if (y < kTopMargin) {
      //        y += kTopMargin;
      //      } else {
      //        y -= kTopMargin;
      //      }
      //    } else if (point > height * scaleY - kTopMargin) {
      //      y += kTopMargin;
    } else {
      //根据位置显示在上方或下方
      if (i % 2 == 0) {
        y -= kTopMargin;
      } else {
        y += kTopMargin;
      }
    }

    CGPoint cPoint = CGPointMake(scaleX * i + textOffset, y);
    [self drawAtPoint:cPoint withStr:str(point)];
  }
  CGContextRestoreGState(context);
}

- (void)drawAtPoint:(CGPoint)point withStr:(NSString *)str {
  if (isEqualOrGreaterToiOS7) {
    [str drawAtPoint:point
        withAttributes:@{
          NSFontAttributeName : [UIFont systemFontOfSize:12],
          NSForegroundColorAttributeName : kTextColor
        }];

  } else {
    [str drawAtPoint:point withFont:[UIFont systemFontOfSize:12]];
  }
}

@end
