//
//  SDZGSwitch.m
//  SmartSwitch
//
//  Created by sdzg on 14-8-19.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SDZGSwitch.h"
#import "APServiceUtil.h"

static dispatch_queue_t switch_parse_serial_queue() {
  static dispatch_queue_t sdzg_switch_parse_serial_queue;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sdzg_switch_parse_serial_queue = dispatch_queue_create(
        "serial.parseswitch.com.itouchco.www", DISPATCH_QUEUE_SERIAL);
  });
  return sdzg_switch_parse_serial_queue;
}

@implementation SDZGSwitch
+ (void)parseMessageCOrE:(CC3xMessage *)message
                toSwitch:(void (^)(SDZGSwitch *aSwitch))completion {
  dispatch_async(switch_parse_serial_queue(), ^{
    if ([message.deviceType isEqualToString:kDeviceType_Snake]) {
      [SDZGSwitch parseMessageSnake:message toSwitch:completion];
    } else {
      [SDZGSwitch parseMessageOther:message toSwitch:completion];
    }
  });
}

+ (void)parseMessageSnake:(CC3xMessage *)message
                 toSwitch:(void (^)(SDZGSwitch *))completion {
  NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
  BOOL needToDBImmediately; //新扫描到的设备立即添加到数据库]
  SDZGSwitch *aSwitch =
      [[SwitchDataCeneter sharedInstance] getSwitchFromTmpByMac:message.mac];
  if (aSwitch) {
    //表示新增的
    needToDBImmediately = YES;
    aSwitch.sockets = [@[] mutableCopy];
    SDZGSocket *socket1 = [[SDZGSocket alloc] init];
    socket1.groupId = 1;
    socket1.socketStatus = ((message.onStatus & 1 << 0) == 1 << 0);
    socket1.imageNames = @[
      socket_default_image,
      socket_default_image,
      socket_default_image,
      socket_default_image
    ];
    [aSwitch.sockets addObject:socket1];

    aSwitch.imageName = snake_switch_default_image;
    aSwitch.mac = message.mac;
    aSwitch.ip = message.ip;
    aSwitch.port = message.port;
    aSwitch.name = message.deviceName;
    DDLogDebug(@"device name is %@", message.deviceName);
    aSwitch.version = message.version;
    aSwitch.lockStatus = message.lockStatus;
    aSwitch.deviceType = message.deviceType;
    if (message.password) {
      aSwitch.password = message.password;
    }
    aSwitch.lastUpdateInterval = current;
  } else {
    needToDBImmediately = NO;
    aSwitch = [[SwitchDataCeneter sharedInstance].switchsDict
        objectForKey:message.mac];
    NSTimeInterval diff = current - aSwitch.lastUpdateInterval;
    //内网外网都返回时，时间间隔大于刷新时间一半就更新设备，否则不更新设备，认为是外网响应
    if (diff > REFRESH_DEV_TIME / 2) {
      DDLogDebug(@"%s", __func__);
      DDLogDebug(@"switch mac is %@ and thread is %@ diff is %f", aSwitch.mac,
                 [NSThread currentThread], diff);
      NSMutableArray *sockets = aSwitch.sockets;
      for (int i = 0; i < sockets.count; i++) {
        SDZGSocket *socket = sockets[i];
        socket.socketStatus = ((message.onStatus & 1 << i) == 1 << i);
      }
      if (aSwitch.networkStatus != SWITCH_NEW) {
        if (message.msgId == 0xc) {
          aSwitch.networkStatus = SWITCH_LOCAL;
          aSwitch.lastUpdateInterval = current;
        } else if (message.msgId == 0xe) {
          if (aSwitch.networkStatus == SWITCH_LOCAL) {
            if (diff > 1.5 * REFRESH_DEV_TIME + 0.5) {
              aSwitch.networkStatus = SWITCH_REMOTE;
              aSwitch.lastUpdateInterval = current;
            }
          } else {
            aSwitch.networkStatus = SWITCH_REMOTE;
            aSwitch.lastUpdateInterval = current;
          }
        }
      } else {
        aSwitch.lastUpdateInterval = current;
      }
      aSwitch.mac = message.mac;
      aSwitch.ip = message.ip;
      aSwitch.port = message.port;
      aSwitch.name = message.deviceName;
      aSwitch.version = message.version;
      aSwitch.lockStatus = message.lockStatus;
      aSwitch.deviceType = message.deviceType;
      if (message.password) {
        aSwitch.password = message.password;
      }
    } else {
      completion(nil);
    }
  }
  if (needToDBImmediately && aSwitch.sockets.count) {
    [[SwitchDataCeneter sharedInstance] addSwitch:aSwitch];
    [[DBUtil sharedInstance] saveSwitch:aSwitch];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL reciveRemoteNotification =
        [[defaults objectForKey:remoteNotification] boolValue];
    if (reciveRemoteNotification) {
      dispatch_after(
          dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)),
          dispatch_get_main_queue(), ^{
            [APServiceUtil openRemoteNotification:^(BOOL result){
            }];
          });
    }
  }
  completion(aSwitch);
}

+ (void)parseMessageOther:(CC3xMessage *)message
                 toSwitch:(void (^)(SDZGSwitch *))completion {
  NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
  BOOL needToDBImmediately; //新扫描到的设备立即添加到数据库]
  SDZGSwitch *aSwitch =
      [[SwitchDataCeneter sharedInstance] getSwitchFromTmpByMac:message.mac];
  if (aSwitch) {
    //表示新增的
    needToDBImmediately = YES;
    aSwitch.sockets = [@[] mutableCopy];
    SDZGSocket *socket1 = [[SDZGSocket alloc] init];
    socket1.groupId = 1;
    socket1.socketStatus = ((message.onStatus & 1 << 0) == 1 << 0);
    socket1.imageNames =
        @[ socket_default_image, socket_default_image, socket_default_image ];
    [aSwitch.sockets addObject:socket1];

    SDZGSocket *socket2 = [[SDZGSocket alloc] init];
    socket2.groupId = 2;
    socket2.socketStatus = ((message.onStatus & 1 << 1) == 1 << 1);
    socket2.imageNames =
        @[ socket_default_image, socket_default_image, socket_default_image ];
    [aSwitch.sockets addObject:socket2];
    aSwitch.imageName = switch_default_image;
    aSwitch.mac = message.mac;
    aSwitch.ip = message.ip;
    aSwitch.port = message.port;
    aSwitch.name = message.deviceName;
    //        aSwitch.power = 0;
    DDLogDebug(@"device name is %@", message.deviceName);
    aSwitch.version = message.version;
    aSwitch.lockStatus = message.lockStatus;
    aSwitch.deviceType = message.deviceType;
    if (message.password) {
      aSwitch.password = message.password;
    }
    aSwitch.lastUpdateInterval = current;
  } else {
    needToDBImmediately = NO;
    aSwitch = [[SwitchDataCeneter sharedInstance].switchsDict
        objectForKey:message.mac];
    NSTimeInterval diff = current - aSwitch.lastUpdateInterval;
    //内网外网都返回时，时间间隔大于刷新时间一半就更新设备，否则不更新设备，认为是外网响应
    if (diff > REFRESH_DEV_TIME / 2) {
      DDLogDebug(@"%s", __func__);
      DDLogDebug(@"switch mac is %@ and thread is %@ diff is %f", aSwitch.mac,
                 [NSThread currentThread], diff);
      NSMutableArray *sockets = aSwitch.sockets;
      for (int i = 0; i < sockets.count; i++) {
        SDZGSocket *socket = sockets[i];
        socket.socketStatus = ((message.onStatus & 1 << i) == 1 << i);
      }
      if (aSwitch.networkStatus != SWITCH_NEW) {
        if (message.msgId == 0xc) {
          aSwitch.networkStatus = SWITCH_LOCAL;
          aSwitch.lastUpdateInterval = current;
        } else if (message.msgId == 0xe) {
          if (aSwitch.networkStatus == SWITCH_LOCAL) {
            if (diff > 1.5 * REFRESH_DEV_TIME + 0.5) {
              aSwitch.networkStatus = SWITCH_REMOTE;
              aSwitch.lastUpdateInterval = current;
            }
          } else {
            aSwitch.networkStatus = SWITCH_REMOTE;
            aSwitch.lastUpdateInterval = current;
          }
        }
      } else {
        aSwitch.lastUpdateInterval = current;
      }
      //          aSwitch.power = 0;
      aSwitch.mac = message.mac;
      aSwitch.ip = message.ip;
      aSwitch.port = message.port;
      aSwitch.name = message.deviceName;
      aSwitch.version = message.version;
      aSwitch.lockStatus = message.lockStatus;
      aSwitch.deviceType = message.deviceType;
      if (message.password) {
        aSwitch.password = message.password;
      }
    } else {
      completion(nil);
    }
  }
  if (needToDBImmediately && aSwitch.sockets.count == 2) {
    [[SwitchDataCeneter sharedInstance] addSwitch:aSwitch];
    [[DBUtil sharedInstance] saveSwitch:aSwitch];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL reciveRemoteNotification =
        [[defaults objectForKey:remoteNotification] boolValue];
    if (reciveRemoteNotification) {
      dispatch_after(
          dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)),
          dispatch_get_main_queue(), ^{
            [APServiceUtil openRemoteNotification:^(BOOL result){
            }];
          });
    }
  }
  completion(aSwitch);
}

/**
 *  从服务器上同步的设备加入到本地解析
 *
 *  @return
 */
static int switchId = 200000;
+ (instancetype)parseSyncSwitch:(NSString *)mac
                       password:(NSString *)password
                           name:(NSString *)name
                        version:(int)version
                     deviceType:(NSString *)deviceType
                     lockStauts:(LockStatus)lockStauts {
  SDZGSwitch *aSwitch = [[SDZGSwitch alloc] init];
  aSwitch._id = switchId++;
  aSwitch.networkStatus = SWITCH_REMOTE;
  aSwitch.mac = mac;
  aSwitch.ip = @"";
  aSwitch.port = 0;
  aSwitch.name = name;
  aSwitch.password = password;
  aSwitch.lockStatus = lockStauts;
  aSwitch.version = version;

  aSwitch.sockets = [@[] mutableCopy];
  if ([deviceType isEqualToString:kDeviceType_Snake]) {
    aSwitch.imageName = snake_switch_default_image;
    SDZGSocket *socket1 = [[SDZGSocket alloc] init];
    socket1.groupId = 1;
    socket1.socketStatus = SocketStatusOff;
    socket1.imageNames = @[
      socket_default_image,
      socket_default_image,
      socket_default_image,
      socket_default_image
    ];
    [aSwitch.sockets addObject:socket1];
  } else {
    aSwitch.imageName = switch_default_image;
    SDZGSocket *socket1 = [[SDZGSocket alloc] init];
    socket1.groupId = 1;
    socket1.socketStatus = SocketStatusOff;
    socket1.imageNames =
        @[ socket_default_image, socket_default_image, socket_default_image ];
    [aSwitch.sockets addObject:socket1];

    SDZGSocket *socket2 = [[SDZGSocket alloc] init];
    socket2.groupId = 2;
    socket2.socketStatus = SocketStatusOff;
    socket2.imageNames =
        @[ socket_default_image, socket_default_image, socket_default_image ];
    [aSwitch.sockets addObject:socket2];
  }
  return aSwitch;
}

+ (UIImage *)imgNameToImage:(NSString *)imgName {
  UIImage *image;
  if (imgName.length < 10) {
    image = [UIImage imageNamed:imgName];
  } else {
    image = [UIImage
        imageWithContentsOfFile:[PATH_OF_DOCUMENT
                                    stringByAppendingPathComponent:imgName]];
    if (!image) {
      image = [UIImage imageNamed:switch_default_image];
    } else {
      image = [UIImage circleImage:image withParam:0];
    }
  }
  return image;
}

+ (UIImage *)imgNameToImageSnake:(NSString *)imgName {
  UIImage *image;
  if (imgName.length < 10) {
    image = [UIImage imageNamed:imgName];
  } else {
    image = [UIImage
        imageWithContentsOfFile:[PATH_OF_DOCUMENT
                                    stringByAppendingPathComponent:imgName]];
    if (!image) {
      image = [UIImage imageNamed:snake_switch_default_image];
    } else {
      image = [UIImage circleImage:image withParam:0];
    }
  }
  return image;
}

+ (UIImage *)imgNameToImageOffline:(NSString *)imgName {
  UIImage *image;
  if (imgName.length < 10) {
    image = [UIImage imageNamed:switch_default_image_offline];
  } else {
    image = [UIImage
        imageWithContentsOfFile:[PATH_OF_DOCUMENT
                                    stringByAppendingPathComponent:imgName]];
    if (!image) {
      image = [UIImage imageNamed:switch_default_image_offline];
    } else {
      image = [UIImage circleImage:[UIImage grayImage:image] withParam:0];
    }
  }
  return image;
}

+ (UIImage *)imgNameToImageOfflineSnake:(NSString *)imgName {
  UIImage *image;
  if (imgName.length < 10) {
    image = [UIImage imageNamed:snake_switch_default_image_offline];
  } else {
    image = [UIImage
        imageWithContentsOfFile:[PATH_OF_DOCUMENT
                                    stringByAppendingPathComponent:imgName]];
    if (!image) {
      image = [UIImage imageNamed:snake_switch_default_image_offline];
    } else {
      image = [UIImage circleImage:[UIImage grayImage:image] withParam:0];
    }
  }
  return image;
}

- (id)copyWithZone:(NSZone *)zone {
  SDZGSwitch *copy = [[[self class] allocWithZone:zone] init];
  copy->_name = [_name copy];
  copy->_networkStatus = _networkStatus;
  copy->_mac = [_mac copy];
  copy->_ip = [_ip copy];
  copy->_port = _port;
  copy->_lockStatus = _lockStatus;
  copy->_sockets = [_sockets mutableCopy];
  copy->_version = _version;
  copy->_tag = _tag;
  copy->_imageName = [_imageName copy];
  copy->_password = [_password copy];
  copy->_lastUpdateInterval = _lastUpdateInterval;
  copy->_firewareVersion = [_firewareVersion copy];
  copy->_deviceType = [_deviceType copy];
  copy->_isRestart = _isRestart;
  return copy;
}

@end

@implementation SDZGSocket
+ (UIImage *)imgNameToImage:(NSString *)imgName status:(SocketStatus)status {
  UIImage *image;
  if (imgName.length < 10) {
    image = [UIImage imageNamed:imgName];
  } else {
    image = [UIImage
        imageWithContentsOfFile:[PATH_OF_DOCUMENT
                                    stringByAppendingPathComponent:imgName]];
    if (!image) {
      image = [UIImage imageNamed:socket_default_image];
    } else {
      if (status == SocketStatusOff) {
        image = [UIImage grayImage:image];
      }
      image = [UIImage circleImage:image withParam:0];
    }
  }
  return image;
}

- (id)copyWithZone:(NSZone *)zone {
  SDZGSocket *copy = [[[self class] allocWithZone:zone] init];
  copy->_groupId = _groupId;
  copy->_name = [_name copy];
  copy->_timerList = [_timerList mutableCopy];
  copy->_delayTime = _delayTime;
  copy->_delayAction = _delayAction;
  copy->_socketStatus = _socketStatus;
  copy->_imageNames = [_imageNames mutableCopy];
  return copy;
}
@end

@implementation SDZGTimerTask
- (id)initWithWeek:(unsigned char)week
         actionTime:(unsigned int)actionTime
        isEffective:(BOOL)isEffective
    timerActionType:(TimerActionType)timerActionType {
  self = [super init];
  if (self) {
    self.week = week;
    self.actionTime = actionTime;
    self.isEffective = isEffective;
    self.timerActionType = timerActionType;
  }
  return self;
}

- (BOOL)isDayOn:(DAYTYPE)aDay {
  return (self.week & aDay) == aDay;
}

- (NSString *)actionWeekString {
  NSMutableString *weekStr = [NSMutableString string];
  if (self.week == 127) {
    [weekStr appendString:NSLocalizedString(@"Everyday", nil)];
  } else if (self.week == 0) {
    [weekStr appendString:NSLocalizedString(@"Operating One Time", nil)];
  } else {
    if ([self isDayOn:MONDAY]) {
      [weekStr appendString:NSLocalizedString(@"Mon", nil)];
    }
    if ([self isDayOn:TUESDAY]) {
      if ([weekStr length]) {
        [weekStr appendString:@" "];
      }
      [weekStr appendString:NSLocalizedString(@"Tues", nil)];
    }
    if ([self isDayOn:WENSDAY]) {
      if ([weekStr length]) {
        [weekStr appendString:@" "];
      }
      [weekStr appendString:NSLocalizedString(@"Wed", nil)];
    }
    if ([self isDayOn:THURSDAY]) {
      if ([weekStr length]) {
        [weekStr appendString:@" "];
      }
      [weekStr appendString:NSLocalizedString(@"Thurs", nil)];
    }
    if ([self isDayOn:FRIDAY]) {
      if ([weekStr length]) {
        [weekStr appendString:@" "];
      }
      [weekStr appendString:NSLocalizedString(@"Fri", nil)];
    }
    if ([self isDayOn:SATURDAY]) {
      if ([weekStr length]) {
        [weekStr appendString:@" "];
      }
      [weekStr appendString:NSLocalizedString(@"Sat", nil)];
    }
    if ([self isDayOn:SUNDAY]) {
      if ([weekStr length]) {
        [weekStr appendString:@" "];
      }
      [weekStr appendString:NSLocalizedString(@"Sun", nil)];
    }
  }
  return weekStr;
}

- (NSString *)actionTimeString {
  return [NSString stringWithFormat:@"%02d:%02d", self.actionTime / 3600,
                                    (self.actionTime % 3600) / 60];
}

- (NSString *)actionTypeString {
  if (TimerActionTypeOn == self.timerActionType) {
    return NSLocalizedString(@"ON", nil);
  } else {
    return NSLocalizedString(@"OFF", nil);
  }
}

- (BOOL)actionEffective {
  return self.isEffective;
}

#pragma mark 定时获取需要显示的最近时间
+ (int)getShowSeconds:(NSArray *)timers {
  if (timers && timers.count) {
    //当前时间
    NSDate *currentDate = [NSDate date];
    NSCalendar *gregorian =
        [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps =
        [gregorian components:NSWeekdayCalendarUnit fromDate:currentDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd 00:00:00"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    //当日零时
    NSDate *zeroDate = [dateFormatter dateFromString:dateString];
    //当前时间距离零时的秒数
    NSTimeInterval diff =
        [currentDate timeIntervalSince1970] - [zeroDate timeIntervalSince1970];
    //公历，国外的习惯，周日是一周的开始，也就是说周日返回1，周六返回7
    int weekday = [comps weekday];
    if (weekday == 1) {
      weekday = 8;
    }
    weekday -= 2;
    //保存操作打开，且今天包含在定时列表、设定时间晚于当前时间并且操作打开的task集合
    NSMutableArray *actionTimeList = [NSMutableArray array];
    for (SDZGTimerTask *task in timers) {
      if (task.week & (1 << weekday)) {
        //时间还未到并且操作打开
        if (diff <= task.actionTime && task.isEffective) {
          [actionTimeList addObject:@(task.actionTime)];
        }
      } else if (task.week == 0 && diff <= task.actionTime &&
                 task.isEffective) {
        //执行一次并生效的
        [actionTimeList addObject:@(task.actionTime)];
      }
    }
    int min = 0;
    if (actionTimeList.count) {
      min = [[actionTimeList valueForKeyPath:@"@min.self"] integerValue];
    }
    return min;
  }
  return 0;
}

- (id)copyWithZone:(NSZone *)zone {
  SDZGTimerTask *copy = [[[self class] allocWithZone:zone] init];
  copy->_week = _week;
  copy->_actionTime = _actionTime;
  copy->_isEffective = _isEffective;
  copy->_timerActionType = _timerActionType;
  return copy;
}
@end
