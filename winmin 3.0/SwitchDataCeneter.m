//
//  SwitchDataCeneter.m
//  SmartSwitch
//
//  Created by sdzg on 14-8-19.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SwitchDataCeneter.h"
@interface SwitchDataCeneter ()
@property(strong, atomic) NSMutableDictionary *switchsDict;
@property(nonatomic, assign) UIBackgroundTaskIdentifier backgroundUpdateTask;
@end

@implementation SwitchDataCeneter
- (id)init {
  self = [super init];
  if (self) {
    // TODO: 从本地文件加载
    self.switchs = [[DBUtil sharedInstance] getSwitchs];
    self.switchsDict = [[NSMutableDictionary alloc] init];
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

//- (void)updateSwitch:(SDZGSwitch *)aSwitch {
//  @synchronized(self) {
//    debugLog(@"update switch ceneter");
//    NSDictionary *userInfo;
//    if ([[self.switchsDict allKeys] containsObject:aSwitch.mac]) {
//      //修改
//      userInfo = @{ @"type" : @0, @"mac" : aSwitch.mac };
//    } else {
//      //新增一条记录
//      userInfo = @{ @"type" : @1 };
//    }
//    [self.switchsDict setObject:aSwitch forKey:aSwitch.mac];
//    self.switchs = [self.switchsDict allValues];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kSwitchUpdate
//                                                        object:self
//                                                      userInfo:userInfo];
//  }
//}

/**
 *  socket开关状态更改
 *
 *  @param socketStaus <#socketStaus description#>
 *  @param socketGroupId    <#socketGroupId description#>
 *  @param mac         <#mac description#>
 *
 *  @return <#return value description#>
 */
- (NSArray *)updateSocketStaus:(SocketStatus)socketStaus
                 socketGroupId:(int)socketGroupId
                           mac:(NSString *)mac {
  @synchronized(self) {
    //一定存在
    SDZGSwitch *aSwitch = [self.switchsDict objectForKey:mac];
    SDZGSocket *socket = [aSwitch.sockets objectAtIndex:socketGroupId - 1];
    socket.socketStatus = socketStaus;
    return [self.switchsDict allValues];
  }
}

/**
 *  加解锁后执行
 *
 *  @param lockStatus <#lockStatus description#>
 *  @param mac        <#mac description#>
 *
 *  @return <#return value description#>
 */
- (NSArray *)updateSwitchLockStaus:(LockStatus)lockStatus mac:(NSString *)mac {
  @synchronized(self) {
    //一定存在
    SDZGSwitch *aSwitch = [self.switchsDict objectForKey:mac];
    aSwitch.lockStatus = lockStatus;
    return [self.switchsDict allValues];
  }
}

/**
 *  查询到设备状态后执行
 *
 *  @param aSwitch <#aSwitch description#>
 *
 *  @return <#return value description#>
 */
- (NSArray *)updateSwitch:(SDZGSwitch *)aSwitch {
  @synchronized(self) {
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
    return [self.switchsDict allValues];
  }
}

/**
 *  定时任务修改后执行
 *
 *  @param timerList <#timerList description#>
 *  @param mac       <#mac description#>
 *  @param socketGroupId  <#socketGroupId description#>
 *
 *  @return <#return value description#>
 */
- (NSArray *)updateTimerList:(NSArray *)timerList
                         mac:(NSString *)mac
               socketGroupId:(int)socketGroupId {
  @synchronized(self) {
    //一定存在
    SDZGSwitch *aSwitch = [self.switchsDict objectForKey:mac];
    SDZGSocket *socket = [aSwitch.sockets objectAtIndex:socketGroupId - 1];
    socket.timerList = [timerList mutableCopy];
    [self.switchsDict setObject:aSwitch forKey:mac];
    return [self.switchsDict allValues];
  }
}

/**
 *  延迟时间更改后执行
 *
 *  @param delayTime   <#delayTime description#>
 *  @param delayAction <#delayAction description#>
 *  @param mac         <#mac description#>
 *  @param socketGroupId    <#socketGroupId description#>
 *
 *  @return <#return value description#>
 */
- (NSArray *)updateDelayTime:(int)delayTime
                 delayAction:(DelayAction)delayAction
                         mac:(NSString *)mac
               socketGroupId:(int)socketGroupId {
  @synchronized(self) {
    //一定存在
    SDZGSwitch *aSwitch = [self.switchsDict objectForKey:mac];
    SDZGSocket *socket = [aSwitch.sockets objectAtIndex:socketGroupId - 1];
    socket.delayTime = delayTime;
    socket.delayAction = delayAction;
    [self.switchsDict setObject:aSwitch forKey:mac];
    return [self.switchsDict allValues];
  }
}

/**
 *  设备名字更改后执行
 *
 *  @param switchName  <#switchName description#>
 *  @param socketNames <#socketNames description#>
 *  @param mac         <#mac description#>
 *
 *  @return <#return value description#>
 */
- (NSArray *)updateSwitchName:(NSString *)switchName
                  socketNames:(NSArray *)socketNames
                          mac:(NSString *)mac {
  @synchronized(self) {
    //一定存在
    SDZGSwitch *aSwitch = [self.switchsDict objectForKey:mac];
    aSwitch.name = switchName;
    NSArray *sockets = aSwitch.sockets;
    for (int i = 0; i < socketNames.count; i++) {
      SDZGSocket *socket = sockets[i];
      socket.name = socketNames[i];
    }
    [self.switchsDict setObject:aSwitch forKey:mac];
    return [self.switchsDict allValues];
  }
}

- (void)updateSocketImage:imgName
                  groupId:(int)groupId
                 socketId:(int)socketId
              whichSwitch:(SDZGSwitch *)whichSwitch {
  @synchronized(self) {
    //一定存在
    SDZGSwitch *aSwitch = [self.switchsDict objectForKey:whichSwitch.mac];
    SDZGSocket *socket = [aSwitch.sockets objectAtIndex:groupId - 1];
    NSMutableArray *imageNames =
        [NSMutableArray arrayWithArray:socket.imageNames];
    [imageNames replaceObjectAtIndex:socketId - 1 withObject:imgName];
    socket.imageNames = imageNames;
  }
}

- (NSArray *)switchs {
  return [self.switchsDict allValues];
}

- (void)saveSwitchsToDB {
  dispatch_async(GLOBAL_QUEUE, ^{
      [self beginBackgroundUpdateTask];
      [[DBUtil sharedInstance] saveSwitchs:self.switchs];
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
  @synchronized(self) {
    [self.switchsDict removeObjectForKey:aSwtich.mac];
    [[DBUtil sharedInstance] deleteSwitch:aSwtich.mac];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSwitchUpdate
                                                        object:self
                                                      userInfo:nil];
  }
  return YES;
}
@end
