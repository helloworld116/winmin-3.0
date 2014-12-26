//
//  UIWindow+Motion.m
//  winmin 3.0
//
//  Created by sdzg on 14-12-26.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "UIWindow+Motion.h"

@implementation UIWindow (Motion)
//默认是NO，所以得重写此方法，设成YES
- (BOOL)canBecomeFirstResponder {
  return NO;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
  NSLog(@"shake");
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
}
@end
