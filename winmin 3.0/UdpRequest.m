//
//  UdpRequest.m
//  SmartSwitch
//
//  Created by 文正光 on 14-8-17.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//#import "UdpRequest.h"

#define kNotReachable @"网络不可用"
#define kNotViaWiFi @"不在WIFI网络条件"

@interface UdpRequest ()<GCDAsyncUdpSocketDelegate>

#pragma mark - 发送请求计数变量
@property(nonatomic, assign) int msg5SendCount;
@property(nonatomic, assign) int msg9SendCount;
@property(nonatomic, assign) int msgBSendCount;
@property(nonatomic, assign) int msgDSendCount;  //指定设备查询
@property(nonatomic, strong)
    NSMutableDictionary *msgDSendCountDict;  //所有设备查询，{"mac":"count"}
@property(nonatomic, assign) int msg11SendCount;
@property(nonatomic, assign) int msg13SendCount;
@property(nonatomic, assign) int msg17SendCount;
@property(nonatomic, assign) int msg19SendCount;
@property(nonatomic, assign) int msg1DSendCount;
@property(nonatomic, assign) int msg1FSendCount;
@property(nonatomic, assign) int msg25SendCount;
@property(nonatomic, assign) int msg27SendCount;
@property(nonatomic, assign) int msg33SendCount;
@property(nonatomic, assign) int msg35SendCount;
@property(nonatomic, assign) int msg39SendCount;
@property(nonatomic, assign) int msg3BSendCount;
@property(nonatomic, assign) int msg3FSendCount;
@property(nonatomic, assign) int msg41SendCount;
@property(nonatomic, assign) int msg47SendCount;
@property(nonatomic, assign) int msg49SendCount;
@property(nonatomic, assign) int msg4DSendCount;
@property(nonatomic, assign) int msg4FSendCount;
@property(nonatomic, assign) int msg53SendCount;
@property(nonatomic, assign) int msg55SendCount;
@property(nonatomic, assign) int msg59SendCount;
@property(nonatomic, assign) int msg5DSendCount;
@property(nonatomic, assign) int msg5FSendCount;
@property(nonatomic, assign) int msg63SendCount;
@property(nonatomic, assign) int msg65SendCount;
@property(nonatomic, assign) int msg67SendCount;
@property(nonatomic, assign) int msg69SendCount;
#pragma mark - 请求响应数据
@property(nonatomic, strong) NSData *responseData6;
@property(nonatomic, strong) NSData *responseDataA;
@property(nonatomic, strong) NSData *responseDataC;
@property(nonatomic, strong) NSData *responseDataE;  //指定设备查询
@property(nonatomic, strong)
    NSMutableDictionary *responseDictE;  //所有设备查询，{@"mac":"data"}
@property(nonatomic, strong) NSData *responseData12;
@property(nonatomic, strong) NSData *responseData14;
@property(nonatomic, strong) NSData *responseData18;
@property(nonatomic, strong) NSData *responseData1A;
@property(nonatomic, strong) NSData *responseData1E;
@property(nonatomic, strong) NSData *responseData20;
@property(nonatomic, strong) NSData *responseData26;
@property(nonatomic, strong) NSData *responseData28;
@property(nonatomic, strong) NSData *responseData34;
@property(nonatomic, strong) NSData *responseData36;
@property(nonatomic, strong) NSData *responseData3A;
@property(nonatomic, strong) NSData *responseData3C;
@property(nonatomic, strong) NSData *responseData40;
@property(nonatomic, strong) NSData *responseData42;
@property(nonatomic, strong) NSData *responseData48;
@property(nonatomic, strong) NSData *responseData4A;
@property(nonatomic, strong) NSData *responseData4E;
@property(nonatomic, strong) NSData *responseData50;
@property(nonatomic, strong) NSData *responseData54;
@property(nonatomic, strong) NSData *responseData56;
@property(nonatomic, strong) NSData *responseData5A;
@property(nonatomic, strong) NSData *responseData5E;
@property(nonatomic, strong) NSData *responseData60;
@property(nonatomic, strong) NSData *responseData64;
@property(nonatomic, strong) NSData *responseData66;
@property(nonatomic, strong) NSData *responseData68;
@property(nonatomic, strong) NSData *responseData6A;
#pragma mark -
@property(nonatomic, strong) GCDAsyncUdpSocket *udpSocket;
@property(nonatomic, strong) SDZGSwitch *aSwitch;
@property(nonatomic, strong) NSString *mac;
@property(nonatomic, assign) int socketGroupId;
@property(nonatomic, strong) NSArray *timeList;
@property(nonatomic, strong) NSData *msg;
@property(nonatomic, strong) NSString *host;
@property(nonatomic, assign) uint16_t port;
@property(nonatomic, assign) long tag;
@property(nonatomic, assign) BOOL on;
@property(nonatomic, assign) int type;
@property(nonatomic, assign) int delayTime;
@property(nonatomic, assign) int beginTime;
@property(nonatomic, assign) int endTime;
@property(nonatomic, assign) int interval;
@property(nonatomic, strong) NSString *name;  //设备名称
@property(nonatomic, strong) NSString *cityName;
@property(nonatomic, strong) NSString *oldPassword;
@property(nonatomic, strong) NSString *password;
@end
@implementation UdpRequest

static dispatch_queue_t delegateQueue;
- (id)initWithPort:(int)port {
  self = [super init];
  if (self) {
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
                                                   delegateQueue:GLOBAL_QUEUE];
    [self setupUdpSocket:self.udpSocket port:port];
    self.msgDSendCountDict = [@{} mutableCopy];
    self.responseDictE = [@{} mutableCopy];
  }
  return self;
}

+ (instancetype)manager {
  UdpRequest *request;
  request = [[UdpRequest alloc] initWithPort:0];
  return request;
}

+ (instancetype)managerConfig {
  UdpRequest *request;
  request = [[UdpRequest alloc] initWithPort:APP_PORT];
  return request;
}

- (void)dealloc {
  [self.udpSocket close];
}

- (void)setupUdpSocket:(GCDAsyncUdpSocket *)socket port:(uint16_t)aPort {
  NSError *error = nil;
  if (![socket enableBroadcast:YES error:&error]) {
    debugLog(@"Error starting server (enableBroadcast): %@", error);
  }
  if (![socket bindToPort:aPort error:&error]) {
    debugLog(@"Error starting server (bind): %@", error);
    return;
  }
  if (![socket beginReceiving:&error]) {
    [socket close];
    debugLog(@"Error starting server (recv): %@", error);
    return;
  }
  [self setReceiveFilterForSocket:socket];
}

- (void)setReceiveFilterForSocket:(GCDAsyncUdpSocket *)socket {
  dispatch_queue_t filterQueue =
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  GCDAsyncUdpSocketReceiveFilterBlock filter =
      ^BOOL(NSData *data, NSData *address, id *context) {
      CC3xMessage *msg = [CC3xMessageUtil parseMessage:data];
      *context = msg;
      return (msg != nil);
  };
  [socket setReceiveFilter:filter withQueue:filterQueue];
}

#pragma mark - UDP发送请求
- (void)sendDataToHost {
  if (self.udpSocket.isClosed) {
    [self setupUdpSocket:self.udpSocket port:0];
  }
  //  [self.udpSocket sendData:self.msg
  //                    toHost:self.host
  //                      port:self.port
  //               withTimeout:kUDPTimeOut
  //                       tag:self.tag];
  //  dispatch_sync(GLOBAL_QUEUE, ^{ [NSThread sleepForTimeInterval:0.1]; });

  dispatch_async(SOCKET_SERIAL_QUEUE, ^{
      [self.udpSocket sendData:self.msg
                        toHost:self.host
                          port:self.port
                   withTimeout:kUDPTimeOut
                           tag:self.tag];
      //      [NSThread sleepForTimeInterval:5];
  });
}

- (void)sendMsg05:(NSString *)ip port:(uint16_t)port mode:(SENDMODE)mode {
  //  dispatch_async(GLOBAL_QUEUE, ^{
  //      if (kSharedAppliction.networkStatus == ReachableViaWiFi) {
  //             } else {
  //        //不在内网的情况下的处理
  //      }
  //  });
  if (mode == ActiveMode) {
    self.msg5SendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg5SendCount++;
  }
  self.msg = [CC3xMessageUtil getP2dMsg05];
  self.host = ip;
  self.port = port;
  self.tag = P2D_SERVER_INFO_05;
  [self sendDataToHost];
}

- (void)sendMsg09:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == ReachableViaWiFi) {
        if (mode == ActiveMode) {
          self.msg9SendCount = 0;
        } else if (mode == PassiveMode) {
          self.msg9SendCount++;
        }
        self.msg = [CC3xMessageUtil getP2dMsg09];
        self.host = BROADCAST_ADDRESS;
        self.port = DEVICE_PORT;
        self.tag = P2D_SCAN_DEV_09;
        [self sendDataToHost];
      } else {
        //不在内网的情况下的处理
        if ([self.delegate respondsToSelector:@selector(errorMsg:)]) {
          [self.delegate errorMsg:kNotViaWiFi];
        }
      }
  });
}

- (void)sendMsg0B:(SENDMODE)mode {
  //  dispatch_async(GLOBAL_QUEUE, ^{
  //      if (kSharedAppliction.networkStatus == ReachableViaWiFi) {
  //
  //      } else {
  //        //不在内网的情况下的处理
  //        if ([self.delegate respondsToSelector:@selector(errorMsg:)]) {
  //          [self.delegate errorMsg:kNotViaWiFi];
  //        }
  //      }
  //  });
  if (mode == ActiveMode) {
    self.msgBSendCount = 0;
  } else if (mode == PassiveMode) {
    self.msgBSendCount++;
  }
  self.msg = [CC3xMessageUtil getP2dMsg0B];
  self.host = BROADCAST_ADDRESS;
  self.port = DEVICE_PORT;
  self.tag = P2D_STATE_INQUIRY_0B;
  [self sendDataToHost];
}

- (void)sendMsg0B:(SDZGSwitch *)aSwitch sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msgBSendCount = 0;
  } else if (mode == PassiveMode) {
    self.msgBSendCount++;
  }
  self.msg = [CC3xMessageUtil getP2dMsg0B];
  self.aSwitch = aSwitch;
  self.host = aSwitch.ip;
  self.port = aSwitch.port;
  self.tag = P2D_STATE_INQUIRY_0B;
  [self sendDataToHost];
}

- (void)sendMsg0D:(NSString *)mac sendMode:(SENDMODE)mode tag:(long)tag {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == NotReachable) {
        if ([self.delegate respondsToSelector:@selector(errorMsg:)]) {
          [self.delegate errorMsg:kNotReachable];
        }
      } else {
        if (mode == ActiveMode) {
          [self.msgDSendCountDict setObject:@(0) forKey:mac];
        } else if (mode == PassiveMode) {
          int count = [[self.msgDSendCountDict objectForKey:mac] intValue];
          count++;
          [self.msgDSendCountDict setObject:@(count) forKey:mac];
        }
        self.msg = [CC3xMessageUtil getP2SMsg0D:mac];
        self.mac = mac;
        self.host = SERVER_IP;
        self.port = SERVER_PORT;
        self.tag = tag;
        [self sendDataToHost];
      }
  });
}

- (void)sendMsg0D:(SDZGSwitch *)aSwitch sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msgDSendCount = 0;
  } else if (mode == PassiveMode) {
    self.msgDSendCount++;
  }
  self.msg = [CC3xMessageUtil getP2SMsg0D:aSwitch.mac];
  self.aSwitch = aSwitch;
  self.host = SERVER_IP;
  self.port = SERVER_PORT;
  self.tag = P2S_STATE_INQUIRY_0D;
  [self sendDataToHost];
}

- (void)sendMsg11WithSwitch:(SDZGSwitch *)aSwitch
              socketGroupId:(int)socketGroupId
                   sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg11SendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg11SendCount++;
  }
  SDZGSocket *socket = [aSwitch.sockets objectAtIndex:socketGroupId - 1];
  self.msg = [CC3xMessageUtil getP2dMsg11:!socket.socketStatus
                            socketGroupId:socketGroupId];
  self.aSwitch = aSwitch;
  self.socketGroupId = socketGroupId;
  self.host = aSwitch.ip;
  self.port = aSwitch.port;
  self.tag = P2D_CONTROL_REQ_11;
  [self sendDataToHost];
}

- (void)sendMsg13WithSwitch:(SDZGSwitch *)aSwitch
              socketGroupId:(int)socketGroupId
                   sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg13SendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg13SendCount++;
  }
  SDZGSocket *socket = [aSwitch.sockets objectAtIndex:socketGroupId - 1];
  self.msg = [CC3xMessageUtil getP2sMsg13:aSwitch.mac
                                  aSwitch:!socket.socketStatus
                            socketGroupId:socketGroupId];
  self.aSwitch = aSwitch;
  self.socketGroupId = socketGroupId;
  self.host = SERVER_IP;
  self.port = SERVER_PORT;
  self.tag = P2S_CONTROL_REQ_13;
  [self sendDataToHost];
}

- (void)sendMsg17WithSwitch:(SDZGSwitch *)aSwitch
              socketGroupId:(int)socketGroupId
                   sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg17SendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg17SendCount++;
  }
  self.msg = [CC3xMessageUtil getP2dMsg17:socketGroupId];
  self.aSwitch = aSwitch;
  self.socketGroupId = socketGroupId;
  self.host = aSwitch.ip;
  self.port = aSwitch.port;
  self.tag = P2D_GET_TIMER_REQ_17;
  [self sendDataToHost];
}

- (void)sendMsg19WithSwitch:(SDZGSwitch *)aSwitch
              socketGroupId:(int)socketGroupId
                   sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg19SendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg19SendCount++;
  }
  self.msg =
      [CC3xMessageUtil getP2SMsg19:aSwitch.mac socketGroupId:socketGroupId];
  self.aSwitch = aSwitch;
  self.socketGroupId = socketGroupId;
  self.host = SERVER_IP;
  self.port = SERVER_PORT;
  self.tag = P2S_GET_TIMER_REQ_19;
  [self sendDataToHost];
}

- (void)sendMsg1DWithSwitch:(SDZGSwitch *)aSwitch
              socketGroupId:(int)socketGroupId
                   timeList:(NSArray *)timeList
                   sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg1DSendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg1DSendCount++;
  }
  //获取公历日期,相对的当前时间
  NSCalendar *gregorian =
      [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  NSDateComponents *comps =
      [gregorian components:NSWeekdayCalendarUnit | NSHourCalendarUnit |
                            NSMinuteCalendarUnit
                   fromDate:[NSDate date]];
  int weekday = ([comps weekday] + 5) % 7;
  int hour = (int)[comps hour];
  int min = (int)[comps minute];
  //获取当前时间离本周一0点开始的秒数
  NSInteger currentTime = weekday * 24 * 3600 + hour * 3600 + min * 60;
  self.msg = [CC3xMessageUtil getP2dMsg1D:currentTime
                                 password:aSwitch.password
                            socketGroupId:socketGroupId
                                timerList:timeList];
  self.aSwitch = aSwitch;
  self.socketGroupId = socketGroupId;
  self.timeList = timeList;
  self.host = aSwitch.ip;
  self.port = aSwitch.port;
  self.tag = P2D_SET_TIMER_REQ_1D;
  [self sendDataToHost];
}

- (void)sendMsg1FWithSwitch:(SDZGSwitch *)aSwitch
              socketGroupId:(int)socketGroupId
                   timeList:(NSArray *)timeList
                   sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg1FSendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg1FSendCount++;
  }
  //获取公历日期,相对的当前时间
  NSCalendar *gregorian =
      [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  NSDateComponents *comps =
      [gregorian components:NSWeekdayCalendarUnit | NSHourCalendarUnit |
                            NSMinuteCalendarUnit
                   fromDate:[NSDate date]];
  int weekday = ([comps weekday] + 5) % 7;
  int hour = (int)[comps hour];
  int min = (int)[comps minute];
  //获取当前时间离本周一0点开始的秒数
  NSInteger currentTime = weekday * 24 * 3600 + hour * 3600 + min * 60;
  self.msg = [CC3xMessageUtil getP2SMsg1F:currentTime
                                 password:aSwitch.password
                            socketGroupId:socketGroupId
                                timerList:timeList
                                      mac:aSwitch.mac];
  self.aSwitch = aSwitch;
  self.socketGroupId = socketGroupId;
  self.timeList = timeList;
  self.host = SERVER_IP;
  self.port = SERVER_PORT;
  self.tag = P2S_SET_TIMER_REQ_1F;
  [self sendDataToHost];
}

//- (void)sendMsg25:(GCDAsyncUdpSocket *)udpSocket
//          aSwitch:(SDZGSwitch *)aSwitch
//         sendMode:(SENDMODE)mode {
//  if (mode == ActiveMode) {
//    self.msg25Or27SendCount = 0;
//  } else if (mode == PassiveMode) {
//    self.msg25Or27SendCount++;
//  }
//  self.udpSocket = udpSocket;
//  self.msg = [CC3xMessageUtil getP2dMsg25];
//  self.host = aSwitch.ip;
//  self.port = aSwitch.port;
//  self.tag = P2D_GET_PROPERTY_REQ_25;
//  [self sendDataToHost];
//}
//
//- (void)sendMsg27:(GCDAsyncUdpSocket *)udpSocket
//          aSwitch:(SDZGSwitch *)aSwitch
//         sendMode:(SENDMODE)mode {
//  if (mode == ActiveMode) {
//    self.msg25Or27SendCount = 0;
//  } else if (mode == PassiveMode) {
//    self.msg25Or27SendCount++;
//  }
//  self.udpSocket = udpSocket;
//  self.msg = [CC3xMessageUtil getP2SMsg27:aSwitch.mac];
//  self.host = SERVER_IP;
//  self.port = SERVER_PORT;
//  self.tag = P2S_GET_PROPERTY_REQ_27;
//  [self sendDataToHost];
//}

- (void)sendMsg33WithSwitch:(SDZGSwitch *)aSwitch sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg33SendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg33SendCount++;
  }
  self.msg = [CC3xMessageUtil getP2DMsg33];
  self.aSwitch = aSwitch;
  self.host = aSwitch.ip;
  self.port = aSwitch.port;
  self.tag = P2D_GET_POWER_INFO_REQ_33;
  [self sendDataToHost];
}

- (void)sendMsg35WithSwitch:(SDZGSwitch *)aSwitch sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg35SendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg35SendCount++;
  }
  self.msg = [CC3xMessageUtil getP2SMsg35:aSwitch.mac];
  self.aSwitch = aSwitch;
  self.host = SERVER_IP;
  self.port = SERVER_PORT;
  self.tag = P2S_GET_POWER_INFO_REQ_35;
  [self sendDataToHost];
}

- (void)sendMsg39WithSwitch:(SDZGSwitch *)aSwitch
                         on:(BOOL)on
                   sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg39SendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg39SendCount++;
  }
  self.msg = [CC3xMessageUtil getP2dMsg39:on];
  self.aSwitch = aSwitch;
  self.host = aSwitch.ip;
  self.port = aSwitch.port;
  self.on = on;
  self.tag = P2D_LOCATE_REQ_39;
  [self sendDataToHost];
}

- (void)sendMsg3BWithSwitch:(SDZGSwitch *)aSwitch
                         on:(BOOL)on
                   sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg3BSendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg3BSendCount++;
  }
  self.msg = [CC3xMessageUtil getP2SMsg3B:aSwitch.mac on:on];
  self.aSwitch = aSwitch;
  self.host = SERVER_IP;
  self.port = SERVER_PORT;
  self.on = on;
  self.tag = P2S_LOCATE_REQ_3B;
  [self sendDataToHost];
}

// type:0代表插座名字，1-n表示插孔n的名字
- (void)sendMsg3FWithSwitch:(SDZGSwitch *)aSwitch
                       type:(int)type
                       name:(NSString *)name
                   sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg3FSendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg3FSendCount++;
  }
  self.msg =
      [CC3xMessageUtil getP2dMsg3F:name type:type password:aSwitch.password];
  self.aSwitch = aSwitch;
  self.host = aSwitch.ip;
  self.port = aSwitch.port;
  self.type = type;
  self.name = name;
  self.tag = P2D_SET_NAME_REQ_3F;
  [self sendDataToHost];
}

- (void)sendMsg41WithSwitch:(SDZGSwitch *)aSwitch
                       type:(int)type
                       name:(NSString *)name
                   sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg41SendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg41SendCount++;
  }
  self.msg = [CC3xMessageUtil getP2sMsg41:aSwitch.mac
                                     name:name
                                     type:type
                                 password:aSwitch.password];
  self.aSwitch = aSwitch;
  self.host = SERVER_IP;
  self.port = SERVER_PORT;
  self.type = type;
  self.name = name;
  self.tag = P2S_SET_NAME_REQ_41;
  [self sendDataToHost];
}

- (void)sendMsg47WithSwitch:(SDZGSwitch *)aSwitch sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg47SendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg47SendCount++;
  }
  self.msg = [CC3xMessageUtil getP2dMsg47:!aSwitch.lockStatus
                                 password:aSwitch.password];
  self.aSwitch = aSwitch;
  self.host = aSwitch.ip;
  self.port = aSwitch.port;
  self.tag = P2D_DEV_LOCK_REQ_47;
  [self sendDataToHost];
}

- (void)sendMsg49WithSwitch:(SDZGSwitch *)aSwitch sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg49SendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg49SendCount++;
  }
  self.msg = [CC3xMessageUtil getP2sMsg49:aSwitch.mac
                                     lock:!aSwitch.lockStatus
                                 password:aSwitch.password];
  self.aSwitch = aSwitch;
  self.host = SERVER_IP;
  self.port = SERVER_PORT;
  self.tag = P2S_DEV_LOCK_REQ_49;
  [self sendDataToHost];
}

- (void)sendMsg4DWithSwitch:(SDZGSwitch *)aSwitch
              socketGroupId:(int)socketGroupId
                  delayTime:(NSInteger)delayTime
                   switchOn:(BOOL)on
                   sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg4DSendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg4DSendCount++;
  }
  self.msg = [CC3xMessageUtil getP2dMsg4D:delayTime
                                       on:on
                            socketGroupId:socketGroupId
                                 password:aSwitch.password];
  self.aSwitch = aSwitch;
  self.socketGroupId = socketGroupId;
  self.host = aSwitch.ip;
  self.port = aSwitch.port;
  self.delayTime = delayTime;
  self.on = on;
  self.tag = P2D_SET_DELAY_REQ_4D;
  [self sendDataToHost];
}

- (void)sendMsg4FWithSwitch:(SDZGSwitch *)aSwitch
              socketGroupId:(int)socketGroupId
                  delayTime:(NSInteger)delayTime
                   switchOn:(BOOL)on
                   sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg4FSendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg4FSendCount++;
  }
  self.msg = [CC3xMessageUtil getP2SMsg4F:aSwitch.mac
                                    delay:delayTime
                                       on:on
                            socketGroupId:socketGroupId
                                 password:aSwitch.password];
  self.aSwitch = aSwitch;
  self.socketGroupId = socketGroupId;
  self.host = SERVER_IP;
  self.port = SERVER_PORT;
  self.delayTime = delayTime;
  self.on = on;
  self.tag = P2S_SET_DELAY_REQ_4F;
  [self sendDataToHost];
}

- (void)sendMsg53WithSwitch:(SDZGSwitch *)aSwitch
              socketGroupId:(int)socketGroupId
                   sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg53SendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg53SendCount++;
  }
  self.msg = [CC3xMessageUtil getP2dMsg53:socketGroupId];
  self.aSwitch = aSwitch;
  self.socketGroupId = socketGroupId;
  self.host = aSwitch.ip;
  self.port = aSwitch.port;
  self.tag = P2D_GET_DELAY_REQ_53;
  [self sendDataToHost];
}

- (void)sendMsg55WithSwitch:(SDZGSwitch *)aSwitch
              socketGroupId:(int)socketGroupId
                   sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg55SendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg55SendCount++;
  }
  self.msg =
      [CC3xMessageUtil getP2SMsg55:aSwitch.mac socketGroupId:socketGroupId];
  self.aSwitch = aSwitch;
  self.socketGroupId = socketGroupId;
  self.host = SERVER_IP;
  self.port = SERVER_PORT;
  self.tag = P2S_GET_DELAY_REQ_55;
  [self sendDataToHost];
}

- (void)sendMsg59:(SDZGSwitch *)aSwitch sendMode:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (mode == ActiveMode) {
        self.msg59SendCount = 0;
      } else if (mode == PassiveMode) {
        self.msg59SendCount++;
      }
      self.msg = [CC3xMessageUtil getP2SMsg59:aSwitch.mac];
      self.aSwitch = aSwitch;
      self.host = SERVER_IP;
      self.port = SERVER_PORT;
      self.tag = P2S_PHONE_INIT_REQ_59;
      [self sendDataToHost];
  });
}

- (void)sendMsg5DWithSwitch:(SDZGSwitch *)aSwitch sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg5DSendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg5DSendCount++;
  }
  self.msg = [CC3xMessageUtil getP2DMsg5D];
  self.aSwitch = aSwitch;
  self.host = aSwitch.ip;
  self.port = aSwitch.port;
  self.tag = P2D_GET_NAME_REQ_5D;
  [self sendDataToHost];
}

- (void)sendMsg5FWithSwitch:(SDZGSwitch *)aSwitch sendMode:(SENDMODE)mode {
  if (mode == ActiveMode) {
    self.msg5FSendCount = 0;
  } else if (mode == PassiveMode) {
    self.msg5FSendCount++;
  }
  self.msg = [CC3xMessageUtil getP2SMsg5F:aSwitch.mac];
  self.aSwitch = aSwitch;
  self.host = SERVER_IP;
  self.port = SERVER_PORT;
  self.tag = P2S_GET_NAME_REQ_5F;
  [self sendDataToHost];
}

- (void)sendMsg63:(SDZGSwitch *)aSwitch
        beginTime:(int)beginTime
          endTime:(int)endTime
         interval:(int)interval
         sendMode:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == NotReachable) {
        if ([self.delegate respondsToSelector:@selector(errorMsg:)]) {
          [self.delegate errorMsg:kNotReachable];
        }
      } else {
        if (mode == ActiveMode) {
          self.msg63SendCount = 0;
        } else if (mode == PassiveMode) {
          self.msg63SendCount++;
        }
        self.msg = [CC3xMessageUtil getP2SMsg63:aSwitch.mac
                                      beginTime:beginTime
                                        endTime:endTime
                                       interval:interval];
        self.aSwitch = aSwitch;
        self.host = SERVER_IP;
        self.port = SERVER_PORT;
        self.beginTime = beginTime;
        self.endTime = endTime;
        self.interval = interval;
        self.tag = P2S_GET_POWER_LOG_REQ_63;
        [self sendDataToHost];
      }
  });
}

// type 0 为获取设备当地的城市 1为获取换手机当地的城市
- (void)sendMsg65:(NSString *)mac type:(int)type sendMode:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == NotReachable) {
        if ([self.delegate respondsToSelector:@selector(errorMsg:)]) {
          [self.delegate errorMsg:kNotReachable];
        }
      } else {
        if (mode == ActiveMode) {
          self.msg65SendCount = 0;
        } else if (mode == PassiveMode) {
          self.msg65SendCount++;
        }
        self.msg = [CC3xMessageUtil getP2SMsg65:mac type:type];
        self.host = SERVER_IP;
        self.port = SERVER_PORT;
        self.type = type;
        self.mac = mac;
        self.tag = P2S_GET_CITY_REQ_65;
        [self sendDataToHost];
      }
  });
}

- (void)sendMsg67:(NSString *)mac
             type:(int)type
         cityName:(NSString *)cityName
         sendMode:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == NotReachable) {
        if ([self.delegate respondsToSelector:@selector(errorMsg:)]) {
          [self.delegate errorMsg:kNotReachable];
        }
      } else {
        if (mode == ActiveMode) {
          self.msg67SendCount = 0;
        } else if (mode == PassiveMode) {
          self.msg67SendCount++;
        }
        self.msg =
            [CC3xMessageUtil getP2SMsg67:mac type:type cityName:cityName];
        self.host = SERVER_IP;
        self.port = SERVER_PORT;
        self.mac = mac;
        self.type = type;
        self.cityName = cityName;
        self.tag = P2S_GET_CITY_WEATHER_REQ_67;
        [self sendDataToHost];
      }
  });
}

- (void)sendMsg69:(NSString *)oldPassword
      newPassword:(NSString *)newPassword
         sendMode:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == NotReachable) {
        if ([self.delegate respondsToSelector:@selector(errorMsg:)]) {
          [self.delegate errorMsg:kNotReachable];
        }
      } else {
        if (mode == ActiveMode) {
          self.msg69SendCount = 0;
        } else if (mode == PassiveMode) {
          self.msg69SendCount++;
        }
        self.msg =
            [CC3xMessageUtil getP2DMsg69:oldPassword newPassword:newPassword];
        self.host = BROADCAST_ADDRESS;
        self.port = DEVICE_PORT;
        self.oldPassword = oldPassword;
        self.password = newPassword;
        self.tag = P2D_SET_PASSWD_REQ_69;
        [self sendDataToHost];
      }
  });
}

#pragma mark - 处理内外网请求
- (void)sendMsg0BOr0D:(SDZGSwitch *)aSwitch sendMode:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == ReachableViaWiFi) {
        //根据不同的网络环境，发送 本地/远程 消息
        if (aSwitch.networkStatus == SWITCH_LOCAL) {
          [self sendMsg0B:aSwitch sendMode:mode];
        } else if (aSwitch.networkStatus == SWITCH_REMOTE) {
          [self sendMsg0D:aSwitch sendMode:mode];
        }
      } else if (kSharedAppliction.networkStatus == ReachableViaWWAN) {
        [self sendMsg0D:aSwitch sendMode:mode];
      } else if (kSharedAppliction.networkStatus == NotReachable) {
        if ([self.delegate respondsToSelector:@selector(errorMsg:)]) {
          [self.delegate errorMsg:kNotReachable];
        }
      }
  });
}

- (void)sendMsg11Or13:(SDZGSwitch *)aSwitch
        socketGroupId:(int)socketGroupId
             sendMode:(SENDMODE)mode {
  //  debugLog(@"networkStatus is %d", kSharedAppliction.networkStatus);
  //  debugLog(@"switch net is %d", aSwitch.networkStatus);
  if (kSharedAppliction.networkStatus == ReachableViaWiFi) {
    //根据不同的网络环境，发送 本地/远程 消息
    if (aSwitch.networkStatus == SWITCH_LOCAL ||
        aSwitch.networkStatus == SWITCH_NEW) {
      [self sendMsg11WithSwitch:aSwitch
                  socketGroupId:socketGroupId
                       sendMode:mode];
    } else if (aSwitch.networkStatus == SWITCH_REMOTE) {
      [self sendMsg13WithSwitch:aSwitch
                  socketGroupId:socketGroupId
                       sendMode:mode];
    }
  } else if (kSharedAppliction.networkStatus == ReachableViaWWAN) {
    [self sendMsg13WithSwitch:aSwitch
                socketGroupId:socketGroupId
                     sendMode:mode];
  } else if (kSharedAppliction.networkStatus == NotReachable) {
    if ([self.delegate respondsToSelector:@selector(errorMsg:)]) {
      [self.delegate errorMsg:kNotReachable];
    }
  }
}

- (void)sendMsg17Or19:(SDZGSwitch *)aSwitch
        socketGroupId:(int)socketGroupId
             sendMode:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == ReachableViaWiFi) {
        //根据不同的网络环境，发送 本地/远程 消息
        if (aSwitch.networkStatus == SWITCH_LOCAL) {
          [self sendMsg17WithSwitch:aSwitch
                      socketGroupId:socketGroupId
                           sendMode:mode];
        } else if (aSwitch.networkStatus == SWITCH_REMOTE) {
          [self sendMsg19WithSwitch:aSwitch
                      socketGroupId:socketGroupId
                           sendMode:mode];
        }
      } else if (kSharedAppliction.networkStatus == ReachableViaWWAN) {
        [self sendMsg19WithSwitch:aSwitch
                    socketGroupId:socketGroupId
                         sendMode:mode];
      } else if (kSharedAppliction.networkStatus == NotReachable) {
        if ([self.delegate respondsToSelector:@selector(errorMsg:)]) {
          [self.delegate errorMsg:kNotReachable];
        }
      }
  });
}

- (void)sendMsg1DOr1F:(SDZGSwitch *)aSwitch
        socketGroupId:(int)socketGroupId
             timeList:(NSArray *)timeList
             sendMode:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == ReachableViaWiFi) {
        //根据不同的网络环境，发送 本地/远程 消息
        if (aSwitch.networkStatus == SWITCH_LOCAL) {
          [self sendMsg1DWithSwitch:aSwitch
                      socketGroupId:socketGroupId
                           timeList:timeList
                           sendMode:mode];
        } else if (aSwitch.networkStatus == SWITCH_REMOTE) {
          [self sendMsg1FWithSwitch:aSwitch
                      socketGroupId:socketGroupId
                           timeList:timeList
                           sendMode:mode];
        }
      } else if (kSharedAppliction.networkStatus == ReachableViaWWAN) {
        [self sendMsg1FWithSwitch:aSwitch
                    socketGroupId:socketGroupId
                         timeList:timeList
                         sendMode:mode];
      } else if (kSharedAppliction.networkStatus == NotReachable) {
        if ([self.delegate respondsToSelector:@selector(errorMsg:)]) {
          [self.delegate errorMsg:kNotReachable];
        }
      }
  });
}

//- (void)sendMsg25Or27:(GCDAsyncUdpSocket *)udpSocket
//              aSwitch:(SDZGSwitch *)aSwitch
//             sendMode:(SENDMODE)mode {
//  dispatch_async(GLOBAL_QUEUE, ^{
//      if (kSharedAppliction.networkStatus == ReachableViaWiFi) {
//        //根据不同的网络环境，发送 本地/远程 消息
//        if (aSwitch.switchStatus == SWITCH_LOCAL ||
//            aSwitch.switchStatus == SWITCH_LOCAL_LOCK) {
//          [self sendMsg25:udpSocket aSwitch:aSwitch sendMode:mode];
//        } else if (aSwitch.switchStatus == SWITCH_REMOTE ||
//                   aSwitch.switchStatus == SWITCH_REMOTE_LOCK) {
//          [self sendMsg27:udpSocket aSwitch:aSwitch sendMode:mode];
//        }
//      } else if (kSharedAppliction.networkStatus == ReachableViaWWAN) {
//        [self sendMsg27:udpSocket aSwitch:aSwitch sendMode:mode];
//      } else if (kSharedAppliction.networkStatus == NotReachable) {
//        [[NSNotificationCenter defaultCenter]
//            postNotificationName:kNotReachableNotification
//                          object:self
//                        userInfo:@{
//                          @"NetworkStatus" : @(NotReachable)
//                        }];
//      }
//  });
//}

- (void)sendMsg33Or35:(SDZGSwitch *)aSwitch sendMode:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == ReachableViaWiFi) {
        //根据不同的网络环境，发送 本地/远程 消息
        if (aSwitch.networkStatus == SWITCH_LOCAL) {
          [self sendMsg33WithSwitch:aSwitch sendMode:mode];
        } else if (aSwitch.networkStatus == SWITCH_REMOTE) {
          [self sendMsg35WithSwitch:aSwitch sendMode:mode];
        }
      } else if (kSharedAppliction.networkStatus == ReachableViaWWAN) {
        [self sendMsg35WithSwitch:aSwitch sendMode:mode];
      } else if (kSharedAppliction.networkStatus == NotReachable) {
        if ([self.delegate respondsToSelector:@selector(errorMsg:)]) {
          [self.delegate errorMsg:kNotReachable];
        }
      }
  });
}

- (void)sendMsg39Or3B:(SDZGSwitch *)aSwitch
                   on:(BOOL)on
             sendMode:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == ReachableViaWiFi) {
        //根据不同的网络环境，发送 本地/远程 消息
        if (aSwitch.networkStatus == SWITCH_LOCAL) {
          [self sendMsg39WithSwitch:aSwitch on:on sendMode:mode];
        } else if (aSwitch.networkStatus == SWITCH_REMOTE) {
          [self sendMsg3BWithSwitch:aSwitch on:on sendMode:mode];
        }
      } else if (kSharedAppliction.networkStatus == ReachableViaWWAN) {
        [self sendMsg3BWithSwitch:aSwitch on:on sendMode:mode];
      } else if (kSharedAppliction.networkStatus == NotReachable) {
        if ([self.delegate respondsToSelector:@selector(errorMsg:)]) {
          [self.delegate errorMsg:kNotReachable];
        }
      }
  });
}

- (void)sendMsg3FOr41:(SDZGSwitch *)aSwitch
                 type:(int)type
                 name:(NSString *)name
             sendMode:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == ReachableViaWiFi) {
        //根据不同的网络环境，发送 本地/远程 消息
        if (aSwitch.networkStatus == SWITCH_LOCAL) {
          [self sendMsg3FWithSwitch:aSwitch type:type name:name sendMode:mode];
        } else if (aSwitch.networkStatus == SWITCH_REMOTE) {
          [self sendMsg41WithSwitch:aSwitch type:type name:name sendMode:mode];
        }
      } else if (kSharedAppliction.networkStatus == ReachableViaWWAN) {
        [self sendMsg41WithSwitch:aSwitch type:type name:name sendMode:mode];
      } else if (kSharedAppliction.networkStatus == NotReachable) {
        if ([self.delegate respondsToSelector:@selector(errorMsg:)]) {
          [self.delegate errorMsg:kNotReachable];
        }
      }
  });
}

- (void)sendMsg47Or49:(SDZGSwitch *)aSwitch sendMode:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == ReachableViaWiFi) {
        //根据不同的网络环境，发送 本地/远程 消息
        if (aSwitch.networkStatus == SWITCH_LOCAL) {
          [self sendMsg47WithSwitch:aSwitch sendMode:mode];
        } else if (aSwitch.networkStatus == SWITCH_REMOTE) {
          [self sendMsg49WithSwitch:aSwitch sendMode:mode];
        }
      } else if (kSharedAppliction.networkStatus == ReachableViaWWAN) {
        [self sendMsg49WithSwitch:aSwitch sendMode:mode];
      } else if (kSharedAppliction.networkStatus == NotReachable) {
        if ([self.delegate respondsToSelector:@selector(errorMsg:)]) {
          [self.delegate errorMsg:kNotReachable];
        }
      }
  });
}

- (void)sendMsg4DOr4F:(SDZGSwitch *)aSwitch
        socketGroupId:(int)socketGroupId
            delayTime:(NSInteger)delayTime
             switchOn:(BOOL)on
             sendMode:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == ReachableViaWiFi) {
        //根据不同的网络环境，发送 本地/远程 消息
        if (aSwitch.networkStatus == SWITCH_LOCAL) {
          [self sendMsg4DWithSwitch:aSwitch
                      socketGroupId:socketGroupId
                          delayTime:delayTime
                           switchOn:on
                           sendMode:mode];
        } else if (aSwitch.networkStatus == SWITCH_REMOTE) {
          [self sendMsg4FWithSwitch:aSwitch
                      socketGroupId:socketGroupId
                          delayTime:delayTime
                           switchOn:on
                           sendMode:mode];
        }
      } else if (kSharedAppliction.networkStatus == ReachableViaWWAN) {
        [self sendMsg4FWithSwitch:aSwitch
                    socketGroupId:socketGroupId
                        delayTime:delayTime
                         switchOn:on
                         sendMode:mode];
      } else if (kSharedAppliction.networkStatus == NotReachable) {
        if ([self.delegate respondsToSelector:@selector(errorMsg:)]) {
          [self.delegate errorMsg:kNotReachable];
        }
      }
  });
}

- (void)sendMsg53Or55:(SDZGSwitch *)aSwitch
        socketGroupId:(int)socketGroupId
             sendMode:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == ReachableViaWiFi) {
        //根据不同的网络环境，发送 本地/远程 消息
        if (aSwitch.networkStatus == SWITCH_LOCAL) {
          [self sendMsg53WithSwitch:aSwitch
                      socketGroupId:socketGroupId
                           sendMode:mode];
        } else if (aSwitch.networkStatus == SWITCH_REMOTE) {
          [self sendMsg55WithSwitch:aSwitch
                      socketGroupId:socketGroupId
                           sendMode:mode];
        }
      } else if (kSharedAppliction.networkStatus == ReachableViaWWAN) {
        [self sendMsg55WithSwitch:aSwitch
                    socketGroupId:socketGroupId
                         sendMode:mode];
      } else if (kSharedAppliction.networkStatus == NotReachable) {
        if ([self.delegate respondsToSelector:@selector(errorMsg:)]) {
          [self.delegate errorMsg:kNotReachable];
        }
      }
  });
}

- (void)sendMsg5DOr5F:(SDZGSwitch *)aSwitch sendMode:(SENDMODE)mode {
  dispatch_async(GLOBAL_QUEUE, ^{
      if (kSharedAppliction.networkStatus == ReachableViaWiFi) {
        //根据不同的网络环境，发送 本地/远程 消息
        if (aSwitch.networkStatus == SWITCH_LOCAL) {
          [self sendMsg5DWithSwitch:aSwitch sendMode:mode];
        } else if (aSwitch.networkStatus == SWITCH_REMOTE) {
          [self sendMsg5FWithSwitch:aSwitch sendMode:mode];
        }
      } else if (kSharedAppliction.networkStatus == ReachableViaWWAN) {
        [self sendMsg5FWithSwitch:aSwitch sendMode:mode];
      } else if (kSharedAppliction.networkStatus == NotReachable) {
        if ([self.delegate respondsToSelector:@selector(errorMsg:)]) {
          [self.delegate errorMsg:kNotReachable];
        }
      }
  });
}

#pragma mark - 线程检查器，检查指定时间内是否有数据返回
- (void)checkResponseDataAfterSettingIntervalWithTag:(long)tag {
  float delay;
  switch (tag) {
    case P2D_SERVER_INFO_05:
    case P2D_SCAN_DEV_09:
    case P2D_STATE_INQUIRY_0B:
    case P2D_CONTROL_REQ_11:
    case P2D_GET_TIMER_REQ_17:
    case P2D_SET_TIMER_REQ_1D:
    case P2D_GET_PROPERTY_REQ_25:
    case P2D_GET_POWER_INFO_REQ_33:
    case P2D_LOCATE_REQ_39:
    case P2D_SET_NAME_REQ_3F:
    case P2D_DEV_LOCK_REQ_47:
    case P2D_SET_DELAY_REQ_4D:
    case P2D_GET_DELAY_REQ_53:
    case P2D_GET_NAME_REQ_5D:
    case P2D_SET_PASSWD_REQ_69:
      delay = kCheckPrivateResponseInterval;
      break;
    case P2S_STATE_INQUIRY_0D:
    case P2S_CONTROL_REQ_13:
    case P2S_GET_TIMER_REQ_19:
    case P2S_SET_TIMER_REQ_1F:
    case P2S_GET_PROPERTY_REQ_27:
    case P2S_GET_POWER_INFO_REQ_35:
    case P2S_LOCATE_REQ_3B:
    case P2S_SET_NAME_REQ_41:
    case P2S_DEV_LOCK_REQ_49:
    case P2S_SET_DELAY_REQ_4F:
    case P2S_GET_DELAY_REQ_55:
    case P2S_PHONE_INIT_REQ_59:
    case P2S_GET_NAME_REQ_5F:
    case P2S_GET_POWER_LOG_REQ_63:
    case P2S_GET_CITY_REQ_65:
    case P2S_GET_CITY_WEATHER_REQ_67:
      delay = kCheckPublicResponseInterval;
      break;
    default:
      delay = kCheckPublicResponseInterval;
      break;
  }
  if (delay) {
    dispatch_time_t delayInNanoSeconds =
        dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    dispatch_after(delayInNanoSeconds, GLOBAL_QUEUE,
                   ^{ [self checkWithTag:tag]; });
  }
}

- (void)checkWithTag:(long)tag {
  if (kSharedAppliction.networkStatus != NotReachable) {
    switch (tag) {
      case P2D_SERVER_INFO_05:
        if (!self.responseData6) {
          if (kSharedAppliction.networkStatus == ReachableViaWiFi &&
              self.msg5SendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msg5SendCount + 1);
            [self sendMsg05:self.host port:self.port mode:PassiveMode];
          }
        }
        break;
      case P2D_SCAN_DEV_09:
        if (!self.responseDataA) {
          if (self.msg9SendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msg9SendCount + 1);
            [self sendMsg09:PassiveMode];
          }
        }
        break;
      case P2D_STATE_INQUIRY_0B:
        if (!self.responseDataC) {
          if (kSharedAppliction.networkStatus == ReachableViaWiFi &&
              self.msgBSendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msgBSendCount + 1);
            [self sendMsg0B:PassiveMode];
          }
        }
        break;
      case P2S_STATE_INQUIRY_0D:
        if (self.msgDSendCount <= kTryCount) {
          debugLog(@"tag %ld 重新发送%d次", tag, self.msgDSendCount + 1);
          [self sendMsg0D:self.aSwitch sendMode:PassiveMode];
        }
        break;
      case P2D_CONTROL_REQ_11:
        if (!self.responseData12) {
          if (self.msg11SendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msg11SendCount + 1);
            [self sendMsg11WithSwitch:self.aSwitch
                        socketGroupId:self.socketGroupId
                             sendMode:PassiveMode];
          }
        }
        break;
      case P2S_CONTROL_REQ_13:
        if (!self.responseData14) {
          if (self.msg13SendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msg13SendCount + 1);
            [self sendMsg13WithSwitch:self.aSwitch
                        socketGroupId:self.socketGroupId
                             sendMode:PassiveMode];
          }
        }
        break;
      case P2D_GET_TIMER_REQ_17:
        if (!self.responseData18) {
          if (self.msg17SendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msg17SendCount + 1);
            [self sendMsg17Or19:self.aSwitch
                  socketGroupId:self.socketGroupId
                       sendMode:PassiveMode];
          }
        }
        break;
      case P2S_GET_TIMER_REQ_19:
        if (!self.responseData1A) {
          if (self.msg19SendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msg19SendCount + 1);
            [self sendMsg19WithSwitch:self.aSwitch
                        socketGroupId:self.socketGroupId
                             sendMode:PassiveMode];
          }
        }
        break;
      case P2D_SET_TIMER_REQ_1D:
        if (!self.responseData1E) {
          if (self.msg1DSendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msg1DSendCount + 1);
            [self sendMsg1DWithSwitch:self.aSwitch
                        socketGroupId:self.socketGroupId
                             timeList:self.timeList
                             sendMode:PassiveMode];
          }
        }
        break;
      case P2S_SET_TIMER_REQ_1F:
        if (!self.responseData20) {
          if (self.msg1FSendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msg1FSendCount + 1);
            [self sendMsg1FWithSwitch:self.aSwitch
                        socketGroupId:self.socketGroupId
                             timeList:self.timeList
                             sendMode:PassiveMode];
          }
        }
        break;
      case P2D_GET_PROPERTY_REQ_25:
        if (!self.responseData26) {
          if (self.msg25SendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msg25SendCount + 1);
          }
        }
        break;
      case P2S_GET_PROPERTY_REQ_27:
        if (!self.responseData28) {
          if (self.msg27SendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msg27SendCount + 1);
          }
        }
        break;
      case P2D_GET_POWER_INFO_REQ_33:
        if (!self.responseData34) {
          if (self.msg33SendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msg33SendCount + 1);
            [self sendMsg33WithSwitch:self.aSwitch sendMode:PassiveMode];
          }
        }
        break;
      case P2S_GET_POWER_INFO_REQ_35:
        if (!self.responseData36) {
          if (self.msg35SendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msg35SendCount + 1);
            [self sendMsg35WithSwitch:self.aSwitch sendMode:PassiveMode];
          }
        }
        break;
      case P2D_LOCATE_REQ_39:
        if (!self.responseData3A) {
          if (self.msg39SendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msg39SendCount + 1);
            [self sendMsg39WithSwitch:self.aSwitch on:NO sendMode:PassiveMode];
          }
        }
        break;
      case P2S_LOCATE_REQ_3B:
        if (!self.responseData3C) {
          if (self.msg3BSendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msg3BSendCount + 1);
            [self sendMsg3BWithSwitch:self.aSwitch
                                   on:self.on
                             sendMode:PassiveMode];
          }
        }
        break;
      case P2D_SET_NAME_REQ_3F:
        if (!self.responseData40) {
          if (self.msg3FSendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msg3FSendCount + 1);
            [self sendMsg3FOr41:self.aSwitch
                           type:self.type
                           name:self.name
                       sendMode:PassiveMode];
          }
        }
        break;
      case P2S_SET_NAME_REQ_41:
        if (!self.responseData42) {
          if (self.msg41SendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msg41SendCount + 1);
            [self sendMsg41WithSwitch:self.aSwitch
                                 type:self.type
                                 name:self.name
                             sendMode:PassiveMode];
          }
        }
        break;
      case P2D_DEV_LOCK_REQ_47:
        if (!self.responseData48) {
          if (self.msg47SendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msg47SendCount + 1);
            [self sendMsg47Or49:self.aSwitch sendMode:PassiveMode];
          }
        }
        break;
      case P2S_DEV_LOCK_REQ_49:
        if (!self.responseData5A) {
          if (self.msg49SendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msg49SendCount + 1);
            [self sendMsg49WithSwitch:self.aSwitch sendMode:PassiveMode];
          }
        }
        break;
      case P2D_SET_DELAY_REQ_4D:
        if (!self.responseData4E) {
          if (self.msg4DSendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msg4DSendCount + 1);
            [self sendMsg4DWithSwitch:self.aSwitch
                        socketGroupId:self.socketGroupId
                            delayTime:self.delayTime
                             switchOn:self.on
                             sendMode:PassiveMode];
          }
        }
        break;
      case P2S_SET_DELAY_REQ_4F:
        if (!self.responseData50) {
          if (self.msg4FSendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msg4FSendCount + 1);
            [self sendMsg4FWithSwitch:self.aSwitch
                        socketGroupId:self.socketGroupId
                            delayTime:self.delayTime
                             switchOn:self.on
                             sendMode:PassiveMode];
          }
        }
        break;
      case P2D_GET_DELAY_REQ_53:
        if (!self.responseData54) {
          if (self.msg53SendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msg53SendCount + 1);
            [self sendMsg53WithSwitch:self.aSwitch
                        socketGroupId:self.socketGroupId
                             sendMode:PassiveMode];
          }
        }
        break;
      case P2S_GET_DELAY_REQ_55:
        if (!self.responseData56) {
          if (self.msg55SendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msg55SendCount + 1);
            [self sendMsg55WithSwitch:self.aSwitch
                        socketGroupId:self.socketGroupId
                             sendMode:PassiveMode];
          }
        }
        break;
      case P2S_PHONE_INIT_REQ_59:
        if (!self.responseData5A) {
          if (self.msg59SendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msg59SendCount + 1);
            [self sendMsg59:self.aSwitch sendMode:PassiveMode];
          }
        }
        break;
      case P2D_GET_NAME_REQ_5D:
        if (!self.responseData5E) {
          if (self.msg5DSendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msg5DSendCount + 1);
            [self sendMsg5DWithSwitch:self.aSwitch sendMode:PassiveMode];
          }
        }
        break;
      case P2S_GET_NAME_REQ_5F:
        if (!self.responseData60) {
          if (self.msg5FSendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msg5FSendCount + 1);
            [self sendMsg5FWithSwitch:self.aSwitch sendMode:PassiveMode];
          }
        }
        break;
      case P2S_GET_POWER_LOG_REQ_63:
        if (!self.responseData64) {
          if (self.msg63SendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msg63SendCount + 1);
            [self sendMsg63:self.aSwitch
                  beginTime:self.beginTime
                    endTime:self.endTime
                   interval:self.interval
                   sendMode:PassiveMode];
          }
        }
        break;
      case P2S_GET_CITY_REQ_65:
        if (!self.responseData66) {
          if (self.msg65SendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msg65SendCount + 1);
            [self sendMsg65:self.mac type:self.type sendMode:PassiveMode];
          }
        }
        break;
      case P2S_GET_CITY_WEATHER_REQ_67:
        if (!self.responseData68) {
          if (self.msg67SendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msg67SendCount + 1);
            [self sendMsg67:self.mac
                       type:self.type
                   cityName:self.cityName
                   sendMode:PassiveMode];
          }
        }
        break;
      case P2D_SET_PASSWD_REQ_69:
        if (!self.responseData6A) {
          if (self.msg69SendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, self.msg69SendCount + 1);
            [self sendMsg69:self.oldPassword
                newPassword:self.password
                   sendMode:PassiveMode];
          }
        }
        break;
      default: {
        // TODO:设备在保存到数据库等本地文件时，设置一个tag标志，通过tag标识可以找到mac，然后设置数据为空
        NSString *mac;
        if ([self.responseDictE objectForKey:mac] == [NSNull null]) {
          int msgDSendCount =
              [[self.msgDSendCountDict objectForKey:mac] intValue];
          if (msgDSendCount <= kTryCount) {
            debugLog(@"tag %ld 重新发送%d次", tag, msgDSendCount + 1);
          }
        }
        break;
      }
    }
  }
}

#pragma mark - GCDAsyncUdpSocket Delegate
/**
 * By design, UDP is a connectionless protocol, and connecting is not needed.
 * However, you may optionally choose to connect to a particular host for
 * reasons
 * outlined in the documentation for the various connect methods listed above.
 *
 * This method is called if one of the connect methods are invoked, and the
 * connection is successful.
 */
- (void)udpSocket:(GCDAsyncUdpSocket *)sock
    didConnectToAddress:(NSData *)address {
  debugLog(@"didConnectToAddress");
}

/**
  * By design, UDP is a connectionless protocol, and connecting is not needed.
  * However, you may optionally choose to connect to a particular host for
  * reasons
  * outlined in the documentation for the various connect methods listed above.
  *
  * This method is called if one of the connect methods are invoked, and the
  * connection fails.
  * This may happen, for example, if a domain name is given for the host and the
  * domain name is unable to be resolved.
  */
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error {
  debugLog(@"didNotConnect");
}

/**
 *  Called when the datagram with the given tag has been sent.
 *
 *  @param sock
 *  @param tag
 */
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
  //  debugLog(@"didSendDataWithTag :%ld", tag);
  //需要执行的操作：
  // 1、清空响应数据
  // 2、指定时间后检查数据是否为空，为空说明未响应，触发请求重发
  switch (tag) {
    case P2D_SERVER_INFO_05:
      self.responseData6 = nil;
      break;
    case P2D_SCAN_DEV_09:
      self.responseDataA = nil;
      break;
    case P2D_STATE_INQUIRY_0B:
      self.responseDataC = nil;
      break;
    case P2S_STATE_INQUIRY_0D:
      self.responseDataE = nil;
      break;
    case P2D_CONTROL_REQ_11:
      self.responseData12 = nil;
      break;
    case P2S_CONTROL_REQ_13:
      self.responseData14 = nil;
      break;
    case P2D_GET_TIMER_REQ_17:
      self.responseData18 = nil;
      break;
    case P2S_GET_TIMER_REQ_19:
      self.responseData1A = nil;
      break;
    case P2D_SET_TIMER_REQ_1D:
      self.responseData1E = nil;
      break;
    case P2S_SET_TIMER_REQ_1F:
      self.responseData20 = nil;
      break;
    case P2D_GET_PROPERTY_REQ_25:
      self.responseData26 = nil;
      break;
    case P2S_GET_PROPERTY_REQ_27:
      self.responseData28 = nil;
      break;
    case P2D_GET_POWER_INFO_REQ_33:
      self.responseData34 = nil;
      break;
    case P2S_GET_POWER_INFO_REQ_35:
      self.responseData36 = nil;
      break;
    case P2D_LOCATE_REQ_39:
      self.responseData3A = nil;
      break;
    case P2S_LOCATE_REQ_3B:
      self.responseData3C = nil;
      break;
    case P2D_SET_NAME_REQ_3F:
      self.responseData40 = nil;
      break;
    case P2S_SET_NAME_REQ_41:
      self.responseData42 = nil;
      break;
    case P2D_DEV_LOCK_REQ_47:
      self.responseData48 = nil;
      break;
    case P2S_DEV_LOCK_REQ_49:
      self.responseData4A = nil;
      break;
    case P2D_SET_DELAY_REQ_4D:
      self.responseData4E = nil;
      break;
    case P2S_SET_DELAY_REQ_4F:
      self.responseData50 = nil;
      break;
    case P2D_GET_DELAY_REQ_53:
      self.responseData54 = nil;
      break;
    case P2S_GET_DELAY_REQ_55:
      self.responseData56 = nil;
      break;
    case P2S_PHONE_INIT_REQ_59:
      self.responseData5A = nil;
      break;
    case P2D_GET_NAME_REQ_5D:
      self.responseData5E = nil;
      break;
    case P2S_GET_NAME_REQ_5F:
      self.responseData60 = nil;
      break;
    case P2S_GET_POWER_LOG_REQ_63:
      self.responseData64 = nil;
      break;
    case P2S_GET_CITY_REQ_65:
      self.responseData66 = nil;
      break;
    case P2S_GET_CITY_WEATHER_REQ_67:
      self.responseData68 = nil;
      break;
    case P2D_SET_PASSWD_REQ_69:
      self.responseData6A = nil;
      break;
    default: {
      // TODO:设备在保存到数据库等本地文件时，设置一个tag标志，通过tag标识可以找到mac
      //        NSString *mac;
      //        [self.responseDictE setObject:[NSNull null] forKey:mac];
      break;
    }
  }
  [self checkResponseDataAfterSettingIntervalWithTag:tag];
}

/**
 *  Called if an error occurs while trying to send a datagram.
 *  This could be due to a timeout, or something more serious such as the data
 *  being too large to fit in a sigle packet.
 *
 *  @param sock
 *  @param tag
 *  @param error
 */
- (void)udpSocket:(GCDAsyncUdpSocket *)sock
    didNotSendDataWithTag:(long)tag
               dueToError:(NSError *)error {
  int triedCount = 0;
  debugLog(@"didNotSendDataWithTag :%ld", tag);
  switch (tag) {
    case P2D_SERVER_INFO_05:
      triedCount = self.msg5SendCount;
      break;
    case P2D_SCAN_DEV_09:
      triedCount = self.msg9SendCount;
      break;
    case P2D_STATE_INQUIRY_0B:
      triedCount = self.msgBSendCount;
      break;
    case P2S_STATE_INQUIRY_0D:
      triedCount = self.msgDSendCount;
      break;
    case P2D_CONTROL_REQ_11:
      triedCount = self.msg11SendCount;
      break;
    case P2S_CONTROL_REQ_13:
      triedCount = self.msg13SendCount;
      break;
    case P2D_GET_TIMER_REQ_17:
      triedCount = self.msg17SendCount;
      break;
    case P2S_GET_TIMER_REQ_19:
      triedCount = self.msg19SendCount;
      break;
    case P2D_SET_TIMER_REQ_1D:
      triedCount = self.msg1DSendCount;
      break;
    case P2S_SET_TIMER_REQ_1F:
      triedCount = self.msg1FSendCount;
      break;
    case P2D_GET_PROPERTY_REQ_25:
      triedCount = self.msg25SendCount;
      break;
    case P2S_GET_PROPERTY_REQ_27:
      triedCount = self.msg27SendCount;
      break;
    case P2D_GET_POWER_INFO_REQ_33:
      triedCount = self.msg33SendCount;
      break;
    case P2S_GET_POWER_INFO_REQ_35:
      triedCount = self.msg35SendCount;
      break;
    case P2D_LOCATE_REQ_39:
      triedCount = self.msg39SendCount;
      break;
    case P2S_LOCATE_REQ_3B:
      triedCount = self.msg3BSendCount;
      break;
    case P2D_SET_NAME_REQ_3F:
      triedCount = self.msg3FSendCount;
      break;
    case P2S_SET_NAME_REQ_41:
      triedCount = self.msg41SendCount;
      break;
    case P2D_DEV_LOCK_REQ_47:
      triedCount = self.msg47SendCount;
      break;
    case P2S_DEV_LOCK_REQ_49:
      triedCount = self.msg49SendCount;
      break;
    case P2D_SET_DELAY_REQ_4D:
      triedCount = self.msg4DSendCount;
      break;
    case P2S_SET_DELAY_REQ_4F:
      triedCount = self.msg4FSendCount;
      break;
    case P2D_GET_DELAY_REQ_53:
      triedCount = self.msg53SendCount;
      break;
    case P2S_GET_DELAY_REQ_55:
      triedCount = self.msg55SendCount;
      break;
    case P2S_PHONE_INIT_REQ_59:
      triedCount = self.msg59SendCount;
      break;
    case P2D_GET_NAME_REQ_5D:
      triedCount = self.msg5DSendCount;
      break;
    case P2S_GET_NAME_REQ_5F:
      triedCount = self.msg5FSendCount;
      break;
    case P2S_GET_POWER_LOG_REQ_63:
      triedCount = self.msg63SendCount;
      break;
    case P2S_GET_CITY_REQ_65:
      triedCount = self.msg65SendCount;
      break;
    case P2S_GET_CITY_WEATHER_REQ_67:
      triedCount = self.msg67SendCount;
      break;
    case P2D_SET_PASSWD_REQ_69:
      triedCount = self.msg69SendCount;
      break;
    default: {
      // TODO:设备在保存到数据库等本地文件时，设置一个tag标志，通过tag标识可以找到mac
      NSString *mac;
      triedCount = [[self.msgDSendCountDict objectForKey:mac] integerValue];
      break;
    }
  }
  if ([self.delegate respondsToSelector:@selector(noSendMsgtag:triedCount:)]) {
    [self.delegate noSendMsgtag:tag triedCount:triedCount];
  }
}

/**
 *  Called when the socket has received the requested datagram.
 *
 *  @param sock
 *  @param data
 *  @param address
 *  @param filterContext
 */
- (void)udpSocket:(GCDAsyncUdpSocket *)sock
       didReceiveData:(NSData *)data
          fromAddress:(NSData *)address
    withFilterContext:(id)filterContext {
  debugLog(@"receiveData is %@", [CC3xMessageUtil hexString:data]);
  if (data) {
    CC3xMessage *msg = (CC3xMessage *)filterContext;
    if ([self.delegate respondsToSelector:@selector(responseMsg:address:)]) {
      [self.delegate responseMsg:msg address:address];
    }
    switch (msg.msgId) {
      case 0x2:
        break;
      case 0x6:
        self.responseData6 = data;
        break;
      case 0xa:
        self.responseDataA = data;
        break;
      case 0xc:
        if (msg.version == 2) {
          self.responseDataC = data;
        }
        break;
      case 0xe:
        self.responseDataE = data;
        [self.responseDictE setObject:data forKey:msg.mac];
        break;
      case 0x12:
        self.responseData12 = data;
        break;
      case 0x14:
        self.responseData14 = data;
        break;
      case 0x18:
        self.responseData18 = data;
        break;
      case 0x1a:
        self.responseData1A = data;
        break;
      case 0x1e:
        self.responseData1E = data;
        break;
      case 0x20:
        self.responseData20 = data;
        break;
      case 0x26:
        self.responseData26 = data;
        break;
      case 0x28:
        self.responseData28 = data;
        break;
      case 0x34:
        self.responseData34 = data;
        break;
      case 0x36:
        self.responseData36 = data;
        break;
      case 0x3A:
        self.responseData3A = data;
        break;
      case 0x3C:
        self.responseData3C = data;
        break;
      case 0x40:
        self.responseData40 = data;
        break;
      case 0x42:
        self.responseData42 = data;
        break;
      case 0x48:
        self.responseData48 = data;
        break;
      case 0x4a:
        self.responseData4A = data;
        break;
      case 0x4e:
        self.responseData4E = data;
        break;
      case 0x50:
        self.responseData50 = data;
        break;
      case 0x54:
        self.responseData54 = data;
        break;
      case 0x56:
        self.responseData56 = data;
        break;
      case 0x5a:
        self.responseData5A = data;
        break;
      case 0x5e:
        self.responseData5E = data;
        break;
      case 0x60:
        self.responseData60 = data;
        break;
      case 0x64:
        self.responseData64 = data;
        break;
      case 0x66:
        self.responseData66 = data;
        break;
      case 0x68:
        self.responseData68 = data;
        break;
      case 0x6a:
        self.responseData6A = data;
        break;
      default:
        break;
    }
  }
}

/**
 *  Called when the socket is closed.
 *
 *  @param sock
 *  @param error
 */
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error {
  debugLog(@"UdpSocketUtil udpSocketDidClose");
}
@end