//
//  SceneDetail.m
//  SmartSwitch
//
//  Created by sdzg on 14-9-1.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SceneDetail.h"

@implementation SceneDetail
static double interval = 0.5;

- (id)initWithMac:(NSString *)mac
          groupId:(int)groupId
       switchName:(NSString *)switchName
       socketName:(NSString *)socketName
          onOrOff:(BOOL)onOrOff {
  self = [super init];
  if (self) {
    self.mac = mac;
    self.switchName = switchName;
    self.groupId = groupId;
    self.socketName = socketName;
    self.onOrOff = onOrOff;
    self.interval = interval;
  }
  return self;
}

- (id)init {
  self = [super init];
  if (self) {
    self.interval = interval;
  }
  return self;
}

- (NSString *)description {
  NSString *operation;
  if (self.onOrOff) {
    operation = @"打开";
  } else {
    operation = @"关闭";
  }
  return [NSString stringWithFormat:@"%@ %@ %@", operation, self.switchName,
                                    self.socketName];
}
@end
