//
//  SwitchDataCeneter.m
//  SmartSwitch
//
//  Created by sdzg on 14-8-19.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SwitchDataCeneter.h"
@interface SwitchDataCeneter ()
@property(nonatomic, assign) UIBackgroundTaskIdentifier backgroundUpdateTask;
@end

@implementation SwitchDataCeneter
- (id)init {
  self = [super init];
  if (self) {
    // TODO: 从本地文件加载
    self.switchs = [[DBUtil sharedInstance] getSwitchs];
    _switchsDict = [[NSMutableDictionary alloc] init];
    //这里一定不能使用self.switchs,因为覆写了switchs的get方法
    for (SDZGSwitch *aSwitch in _switchs) {
      if (aSwitch.mac) {
        [self.switchsDict setObject:aSwitch forKey:aSwitch.mac];
      }
    }
  }
  return self;
}

+ (instancetype)sharedInstance {
  static SwitchDataCeneter *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{ instance = [[self alloc] init]; });
  return instance;
}

- (void)updateAllSwitchStautsToOffLine {
  NSArray *switchs = [self.switchsDict allValues];
  dispatch_async(SWITCHDATACENTER_SERIAL_QUEUE, ^{
      for (SDZGSwitch *aSwitch in switchs) {
        aSwitch.networkStatus = SWITCH_OFFLINE;
      }
  });
}

- (void)updateSocketStaus:(SocketStatus)socketStaus
            socketGroupId:(int)socketGroupId
                      mac:(NSString *)mac {
  dispatch_async(SWITCHDATACENTER_SERIAL_QUEUE, ^{
      SDZGSwitch *aSwitch = [self.switchsDict objectForKey:mac];
      SDZGSocket *socket = [aSwitch.sockets objectAtIndex:socketGroupId - 1];
      socket.socketStatus = socketStaus;
  });
}

- (void)updateSwitchLockStaus:(LockStatus)lockStatus mac:(NSString *)mac {
  dispatch_async(SWITCHDATACENTER_SERIAL_QUEUE, ^{
      //一定存在
      SDZGSwitch *aSwitch = [self.switchsDict objectForKey:mac];
      aSwitch.lockStatus = lockStatus;
  });
}

- (void)updateSwitch:(SDZGSwitch *)aSwitch {
  dispatch_async(SWITCHDATACENTER_SERIAL_QUEUE, ^{
      if ([[self.switchsDict allKeys] containsObject:aSwitch.mac]) {
        SDZGSwitch *oldSwitch = [self.switchsDict objectForKey:aSwitch.mac];
        oldSwitch.ip = aSwitch.ip;
        oldSwitch.port = aSwitch.port;
        oldSwitch.name = aSwitch.name;
        oldSwitch.lockStatus = aSwitch.lockStatus;
        oldSwitch.version = aSwitch.version;
        oldSwitch.networkStatus = aSwitch.networkStatus;

        NSArray *oldSockets = oldSwitch.sockets;
        NSArray *aSockets = aSwitch.sockets;
        for (int i = 0; i < oldSockets.count; i++) {
          SDZGSocket *oldSocket = oldSockets[i];
          SDZGSocket *aSocket = aSockets[i];
          oldSocket.socketStatus = aSocket.socketStatus;
        }
        [self.switchsDict setObject:oldSwitch forKey:aSwitch.mac];
      } else {
        [self.switchsDict setObject:aSwitch forKey:aSwitch.mac];
      }
  });
}

- (void)updateTimerList:(NSArray *)timerList
                    mac:(NSString *)mac
          socketGroupId:(int)socketGroupId {
  dispatch_async(SWITCHDATACENTER_SERIAL_QUEUE, ^{
      SDZGSwitch *aSwitch = [self.switchsDict objectForKey:mac];
      SDZGSocket *socket = [aSwitch.sockets objectAtIndex:socketGroupId - 1];
      socket.timerList = [timerList mutableCopy];
      [self.switchsDict setObject:aSwitch forKey:mac];
  });
}

- (void)updateSwitchImageName:(NSString *)imgName mac:(NSString *)mac {
  dispatch_async(SWITCHDATACENTER_SERIAL_QUEUE, ^{
      SDZGSwitch *aSwitch = [self.switchsDict objectForKey:mac];
      aSwitch.imageName = imgName;
      [self.switchsDict setObject:aSwitch forKey:mac];
  });
}

- (void)updateDelayTime:(int)delayTime
            delayAction:(DelayAction)delayAction
                    mac:(NSString *)mac
          socketGroupId:(int)socketGroupId {
  dispatch_async(SWITCHDATACENTER_SERIAL_QUEUE, ^{
      SDZGSwitch *aSwitch = [self.switchsDict objectForKey:mac];
      SDZGSocket *socket = [aSwitch.sockets objectAtIndex:socketGroupId - 1];
      socket.delayTime = delayTime;
      socket.delayAction = delayAction;
      [self.switchsDict setObject:aSwitch forKey:mac];
  });
}

- (void)updateSwitchName:(NSString *)switchName
             socketNames:(NSArray *)socketNames
                     mac:(NSString *)mac {
  dispatch_async(SWITCHDATACENTER_SERIAL_QUEUE, ^{
      SDZGSwitch *aSwitch = [self.switchsDict objectForKey:mac];
      aSwitch.name = switchName;
      NSArray *sockets = aSwitch.sockets;
      for (int i = 0; i < socketNames.count; i++) {
        SDZGSocket *socket = sockets[i];
        socket.name = socketNames[i];
      }
      [self.switchsDict setObject:aSwitch forKey:mac];
  });
}

- (void)updateSocketImage:imgName
                  groupId:(int)groupId
                 socketId:(int)socketId
              whichSwitch:(SDZGSwitch *)whichSwitch {
  dispatch_async(SWITCHDATACENTER_SERIAL_QUEUE, ^{
      SDZGSwitch *aSwitch = [self.switchsDict objectForKey:whichSwitch.mac];
      SDZGSocket *socket = [aSwitch.sockets objectAtIndex:groupId - 1];
      NSMutableArray *imageNames =
          [NSMutableArray arrayWithArray:socket.imageNames];
      [imageNames replaceObjectAtIndex:socketId - 1 withObject:imgName];
      socket.imageNames = imageNames;
  });
}

- (NSArray *)switchsWithChangeStatus {
  NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
  NSArray *switchs = [self.switchsDict allValues];
  for (SDZGSwitch *aSwitch in switchs) {
    if (current - aSwitch.lastUpdateInterval > 2 * REFRESH_DEV_TIME) {
      aSwitch.networkStatus = SWITCH_OFFLINE;
    }
  }
  return [self.switchsDict allValues];
}

- (NSArray *)switchs {
  return [self.switchsDict allValues];
}

- (BOOL)isAllSwitchOffLine {
  BOOL result = YES;
  NSArray *switchs = [self.switchsDict allValues];
  for (SDZGSwitch *aSwitch in switchs) {
    if (aSwitch.networkStatus != SWITCH_OFFLINE) {
      result = NO;
      break;
    }
  }
  return result;
}

- (void)saveSwitchsToDB {
  dispatch_async(GLOBAL_QUEUE, ^{
      [self beginBackgroundUpdateTask];
      [[DBUtil sharedInstance] saveSwitchs:[self switchs]];
      [self endBackgroundUpdateTask];
  });
}

- (void)beginBackgroundUpdateTask {
  self.backgroundUpdateTask = [[UIApplication sharedApplication]
      beginBackgroundTaskWithExpirationHandler:^{
          [self endBackgroundUpdateTask];
      }];
}

- (void)endBackgroundUpdateTask {
  [[UIApplication sharedApplication]
      endBackgroundTask:self.backgroundUpdateTask];
  self.backgroundUpdateTask = UIBackgroundTaskInvalid;
}

- (BOOL)removeSwitch:(SDZGSwitch *)aSwtich {
  dispatch_async(SWITCHDATACENTER_SERIAL_QUEUE,
                 ^{ [self.switchsDict removeObjectForKey:aSwtich.mac]; });
  [[DBUtil sharedInstance] deleteSwitch:aSwtich.mac];
  [[NSNotificationCenter defaultCenter] postNotificationName:kSwitchUpdate
                                                      object:self
                                                    userInfo:nil];
  return YES;
}
@end
