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
          onOrOff:(BOOL)onOrOff
     isInitSwitch:(BOOL)isInitSwitch {
  self = [self init];
  if (self) {
    self.mac = mac;
    self.groupId = groupId;
    self.onOrOff = onOrOff;
    if (isInitSwitch) {
      NSArray *switchs = [[SwitchDataCeneter sharedInstance] switchs];
      for (SDZGSwitch *aSwitch in switchs) {
        if ([aSwitch.mac isEqualToString:self.mac]) {
          self.aSwitch = aSwitch;
          self.socket = self.aSwitch.sockets[self.groupId - 1];
          break;
        }
      }
    }
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
  return [NSString stringWithFormat:@"%@ %@ %@", operation, self.aSwitch.name,
                                    self.socket.name];
}
@end
