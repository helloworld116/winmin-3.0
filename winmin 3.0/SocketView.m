//
//  SocketView.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-18.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SocketView.h"

@implementation SocketView

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
  }
}

- (void)setSocketInfo:(SDZGSocket *)socket {
  //  NSString *img1Name = socket.imageNames[0];
  //  NSString *img2Name = socket.imageNames[1];
  //  NSString *img3Name = socket.imageNames[2];
  //  UIImage *img1, *img2, *img3;
  //  if (img1Name.length < 5) {
  //    img1 = [UIImage imageNamed:img1Name];
  //  } else {
  //    img1 = [UIImage
  //        imageWithContentsOfFile:[PATH_OF_DOCUMENT
  //                                    stringByAppendingPathComponent:img1Name]];
  //  }
  //  if (img2Name.length < 5) {
  //    img2 = [UIImage imageNamed:img2Name];
  //  } else {
  //    img2 = [UIImage
  //        imageWithContentsOfFile:[PATH_OF_DOCUMENT
  //                                    stringByAppendingPathComponent:img2Name]];
  //  }
  //  if (img3Name.length < 5) {
  //    img3 = [UIImage imageNamed:img3Name];
  //  } else {
  //    img3 = [UIImage
  //        imageWithContentsOfFile:[PATH_OF_DOCUMENT
  //                                    stringByAppendingPathComponent:img3Name]];
  //    img3 = [UIImage circleImage:img3 withParam:0];
  //  }
  self.imgViewSocket1.image = [SDZGSocket imgNameToImage:socket.imageNames[0]];
  self.imgViewSocket2.image = [SDZGSocket imgNameToImage:socket.imageNames[1]];
  self.imgViewSocket3.image = [SDZGSocket imgNameToImage:socket.imageNames[2]];
  [self changeSocketState:socket];
}

- (void)changeSocketState:(SDZGSocket *)socket {
  if (socket.socketStatus == SocketStatusOn) {
    [self.btnOnOrOff setTitle:@"开" forState:UIControlStateNormal];
  } else {
    [self.btnOnOrOff setTitle:@"关" forState:UIControlStateNormal];
  }
}
@end
