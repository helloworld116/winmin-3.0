//
//  ShakeWindow+Motion.m
//  winmin 3.0
//
//  Created by sdzg on 15-1-4.
//  Copyright (c) 2015年 itouchco.com. All rights reserved.
//

#import "ShakeWindow+Motion.h"

@implementation ShakeWindow (Motion)
- (void)setSwitch:(SDZGSwitch *)aSwitch groupId:(int)groupId {
  self.aSwitch = aSwitch;
  self.groupId = groupId;
}

//默认是NO，所以得重写此方法，设成YES
- (BOOL)canBecomeFirstResponder {
  return NO;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
  NSLog(@"shake");
  //  [app.globalRequest sendMsg11Or13:app.globalSwitch
  //                     socketGroupId:app.globalGroupId
  //                          sendMode:ActiveMode];
  if (self.aSwitch && self.groupId) {
    [self.request sendMsg11Or13:self.aSwitch
                  socketGroupId:self.groupId
                       sendMode:ActiveMode];
  }
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
}

@end
