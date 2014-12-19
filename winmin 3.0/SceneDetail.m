//
//  SceneDetail.m
//  SmartSwitch
//
//  Created by sdzg on 14-9-1.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SceneDetail.h"
@interface SceneDetail ()
@property (nonatomic, strong) NSArray *switchs;
@end

@implementation SceneDetail
static double interval = 1.0;

- (id)initWithMac:(NSString *)mac groupId:(int)groupId onOrOff:(BOOL)onOrOff {
  self = [self init];
  if (self) {
    self.mac = mac;
    self.groupId = groupId;
    self.onOrOff = onOrOff;
    if (!self.switchs) {
      self.switchs = [[NSMutableArray alloc]
          initWithArray:[[SwitchDataCeneter sharedInstance] switchs]
              copyItems:YES];
    }
    for (SDZGSwitch *aSwitch in self.switchs) {
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

- (id)copyWithZone:(NSZone *)zone {
  SceneDetail *copy = [[[self class] allocWithZone:zone] init];
  copy->_mac = [_mac copy];
  copy->_groupId = _groupId;
  copy->_onOrOff = _onOrOff;
  copy->_interval = _interval;
  return copy;
}

//@property (nonatomic, strong) NSString *mac;
//@property (nonatomic, assign) int groupId;
//@property (nonatomic, strong) SDZGSwitch *aSwitch;
//@property (nonatomic, strong) SDZGSocket *socket;
//@property (nonatomic, assign) BOOL onOrOff;
//@property (nonatomic, assign) double interval; //执行时间间隔
//- (id)mutableCopyWithZone:(NSZone *)zone {
//  SceneDetail *copy = NSCopyObject(self, 0, zone);
//  copy->name = [self.name mutableCopy];
//  copy->age = age;
//  return copy;
//}
@end
