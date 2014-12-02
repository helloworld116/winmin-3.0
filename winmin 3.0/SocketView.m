//
//  SocketView.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-18.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SocketView.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation ArcImgView

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();

  //  CGContextSetRGBStrokeColor(context, 1, 0, 0, 1); //改变画笔颜色
  CGContextSetStrokeColorWithColor(
      context, [UIColor colorWithHexString:@"#ff9900"].CGColor);

  CGContextMoveToPoint(context, rect.origin.x + rect.size.width / 2,
                       rect.origin.y); //开始坐标p1
  // CGContextAddArcToPoint(CGContextRef c, CGFloat x1, CGFloat y1,CGFloat x2,
  // CGFloat y2, CGFloat radius)
  // x1,y1跟p1形成一条线的坐标p2，x2,y2结束坐标跟p3形成一条线的p3,radius半径,注意,
  // 需要算好半径的长度,
  CGContextAddArcToPoint(context, rect.origin.x + rect.size.width / 2 + 17.3f,
                         rect.origin.y + (rect.size.width / 2 - 17.3),
                         rect.origin.x + rect.size.width,
                         rect.origin.y + rect.size.width / 2,
                         rect.size.width / 2);
  CGContextStrokePath(context); //绘画路径
}
@end

@interface SocketView ()
@property (nonatomic, strong) UIImage *defaultSelectBgImage;
@property (nonatomic, strong) UIImage *customSelectBgImage;
@end
@implementation SocketView

- (void)awakeFromNib {
  self.defaultSelectBgImage = [UIImage imageNamed:@"socket_bg_selected"];
  self.customSelectBgImage = [UIImage imageNamed:@"socket_bg_custom"];
}

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
  }
  return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)touchSocket:(int)socketId {
  if (self.sockeViewDelegate &&
      [self.sockeViewDelegate
          respondsToSelector:@selector(touchSocket:withSelf:)]) {
    [self.sockeViewDelegate touchSocket:socketId withSelf:self];
  }
}
- (IBAction)touchSocket1:(id)sender {
  [self touchSocket:1];
}
- (IBAction)touchSocket2:(id)sender {
  [self touchSocket:2];
}
- (IBAction)touchSocket3:(id)sender {
  [self touchSocket:3];
}
- (IBAction)touchTimer:(id)sender {
  if (self.sockeViewDelegate &&
      [self.sockeViewDelegate
          respondsToSelector:@selector(touchTimerWithSelf:)]) {
    [self.sockeViewDelegate touchTimerWithSelf:self];
  }
}

- (IBAction)touchDelay:(id)sender {
  if (self.sockeViewDelegate &&
      [self.sockeViewDelegate
          respondsToSelector:@selector(touchDelayWithSelf:)]) {
    [self.sockeViewDelegate touchDelayWithSelf:self];
  }
}

- (IBAction)touchOnOrOff:(id)sender {
  if (self.sockeViewDelegate &&
      [self.sockeViewDelegate
          respondsToSelector:@selector(touchOnOrOffWithSelf:)]) {
    [self.sockeViewDelegate touchOnOrOffWithSelf:self];
    BOOL shake = [
        [[NSUserDefaults standardUserDefaults] valueForKey:keyShake] boolValue];
    if (shake) {
      AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    [self addRotateAnimation];
  }
}

- (void)setSocketInfo:(SDZGSocket *)socket {
  [self changeSocketState:socket];
}

- (void)changeSocketState:(SDZGSocket *)socket {
  if (socket.socketStatus == SocketStatusOn) {
    self.btnOnOrOff.selected = YES;
    self.imgViewBg.highlighted = YES;
    self.btnSocket1.selected = YES;
    self.btnSocket2.selected = YES;
    self.btnSocket3.selected = YES;
  } else {
    self.btnOnOrOff.selected = NO;
    self.imgViewBg.highlighted = NO;
    self.btnSocket1.selected = NO;
    self.btnSocket2.selected = NO;
    self.btnSocket3.selected = NO;
  }
  [self.btnSocket1 setImage:[SDZGSocket imgNameToImage:socket.imageNames[0]
                                                status:socket.socketStatus]
                   forState:UIControlStateNormal];
  [self.btnSocket2 setImage:[SDZGSocket imgNameToImage:socket.imageNames[1]
                                                status:socket.socketStatus]
                   forState:UIControlStateNormal];
  [self.btnSocket3 setImage:[SDZGSocket imgNameToImage:socket.imageNames[2]
                                                status:socket.socketStatus]
                   forState:UIControlStateNormal];

  if ([socket.imageNames[0] isEqualToString:socket_default_image]) {
    [self.btnSocket1 setBackgroundImage:self.defaultSelectBgImage
                               forState:UIControlStateSelected];
  } else {
    [self.btnSocket1 setBackgroundImage:self.customSelectBgImage
                               forState:UIControlStateSelected];
  }
  if ([socket.imageNames[1] isEqualToString:socket_default_image]) {
    [self.btnSocket2 setBackgroundImage:self.defaultSelectBgImage
                               forState:UIControlStateSelected];
  } else {
    [self.btnSocket2 setBackgroundImage:self.customSelectBgImage
                               forState:UIControlStateSelected];
  }
  if ([socket.imageNames[2] isEqualToString:socket_default_image]) {
    [self.btnSocket3 setBackgroundImage:self.defaultSelectBgImage
                               forState:UIControlStateSelected];
  } else {
    [self.btnSocket3 setBackgroundImage:self.customSelectBgImage
                               forState:UIControlStateSelected];
  }
}

- (void)addRotateAnimation {
  CABasicAnimation *rotationAnimation;
  rotationAnimation =
      [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
  rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
  rotationAnimation.duration = 3.f;
  rotationAnimation.cumulative = YES;
  rotationAnimation.repeatCount =
      HUGE_VALF; // huge巨大的 value float 浮点数形式
  [self.arcView.layer addAnimation:rotationAnimation
                            forKey:@"rotationAnimation"];
  self.arcView.hidden = NO;
  self.btnOnOrOff.enabled = NO;
  self.btnOnOrOff2.enabled = NO;
}

- (void)removeRotateAnimation {
  [self.arcView.layer removeAnimationForKey:@"rotationAnimation"];
  self.arcView.hidden = YES;
  self.btnOnOrOff.enabled = YES;
  self.btnOnOrOff2.enabled = YES;
}
@end
