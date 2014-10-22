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
}
@end
