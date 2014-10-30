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

- (id)initWithMac:(NSString *)mac groupId:(int)groupId onOrOff:(BOOL)onOrOff {
  self = [self init];
  if (self) {
    self.mac = mac;
    self.groupId = groupId;
    self.onOrOff = onOrOff;
    NSArray *switchs = [[SwitchDataCeneter sharedInstance] switchs];
    for (SDZGSwitch *aSwitch in switchs) {
      if ([aSwitch.mac isEqualToString:self.mac]) {
        self.aSwitch = aSwitch;
        self.socket = self.aSwitch.sockets[self.groupId - 1];
        break;
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
    operation = NSLocalizedString(@"Open", nil);
  } else {
    operation = NSLocalizedString(@"Close", nil);
  }
  NSString *socketName;
  if (self.groupId == 1) {
    socketName = NSLocalizedString(@"Socket1", nil);
  } else {
    socketName = NSLocalizedString(@"Socket2", nil);
  }
  return [NSString
      stringWithFormat:@"%@ %@ %@", operation, self.aSwitch.name, socketName];
}
@end
