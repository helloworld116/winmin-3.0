//
//  SwitchInfoModel.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-22.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SwitchInfoModel.h"
NSString *const kGetElecPowerInfoSuccess = @"GetElecPowerInfoSuccess";
NSString *const kSetElecPowerInfoSuccess = @"SetElecPowerInfoSuccess";

@interface SwitchInfoModel () <UdpRequestDelegate>
@property (nonatomic, strong) SDZGSwitch *aSwitch;
@property (nonatomic, strong) UdpRequest *request1;
@property (nonatomic, strong) UdpRequest *request2;
@property (nonatomic, strong) UdpRequest *request3;
@property (nonatomic, strong) CompetionBlock competion;
@end

@implementation SwitchInfoModel
- (id)initWithSwitch:(SDZGSwitch *)aSwitch {
  self = [super init];
  if (self) {
    self.aSwitch = aSwitch;
    self.request1 = [UdpRequest manager];
    self.request1.delegate = self;
  }
  return self;
}

- (void)dealloc {
  self.request1.delegate = nil;
  self.request2.delegate = nil;
  self.request3.delegate = nil;
}

- (void)changeSwitchLockStatus {
  [self sendMsg47Or49];
}

- (void)setSwitchName:(NSString *)name {
  [self sendMsg3FOr41WithName:name];
}

- (void)getElecPowerInfo {
  [self.request1 sendMsg71Or73:self.aSwitch sendMode:ActiveMode];
}

- (void)getSwitchsFireware:(CompetionBlock)block {
  if (!self.request2) {
    self.request2 = [UdpRequest manager];
    self.request2.delegate = self;
  }
  [self.request2 sendMsg7BWithSwitch:self.aSwitch sendMode:ActiveMode];
  self.competion = block;
}

- (void)setElecInfoWithAlertUnder:(short)alertUnder
                     isAlertUnder:(BOOL)isAlertUnder
                     alertGreater:(short)alertGreater
                   isAlertGreater:(BOOL)isAlertGreater
                     turnOffUnder:(short)turnOffUnder
                   isTurnOffUnder:(BOOL)isTurnOffUnder
                   turnOffGreater:(short)turnOffGreater
                 isTurnOffGreater:(BOOL)isTurnOffGreater {
  [self.request1 sendMsg6BOr6D:self.aSwitch
                    alertUnder:alertUnder
                  isAlertUnder:isAlertUnder
                  alertGreater:alertGreater
                isAlertGreater:isAlertGreater
                  turnOffUnder:turnOffUnder
                isTurnOffUnder:isTurnOffUnder
                turnOffGreater:turnOffGreater
              isTurnOffGreater:isTurnOffGreater
                      sendMode:ActiveMode];
}

- (void)sendMsg3FOr41WithName:(NSString *)name {
  if (!self.request2) {
    self.request2 = [UdpRequest manager];
    self.request2.delegate = self;
  }
  [self.request2 sendMsg3FOr41:self.aSwitch
                          type:0
                          name:name
                      sendMode:ActiveMode];
}

- (void)sendMsg47Or49 {
  if (!self.request3) {
    self.request3 = [UdpRequest manager];
    self.request3.delegate = self;
  }
  [self.request3 sendMsg47Or49:self.aSwitch sendMode:ActiveMode];
}

#pragma mark - UdpRequest代理
- (void)udpRequest:(UdpRequest *)request
     didReceiveMsg:(CC3xMessage *)message
           address:(NSData *)address {
  DDLogDebug(@"response request is %@", request);
  switch (message.msgId) {
    case 0x40:
    case 0x42:
      [self responseMsg40Or42:message];
      break;
    case 0x48:
    case 0x4A:
      [self responseMsg48Or4A:message];
      break;
    case 0x6C:
    case 0x6E:
      [self responseMsg6COr6E:message];
      break;
    case 0x72:
    case 0x74:
      [self responseMsg72Or74:message];
      break;
    case 0x7c:
      [self responseMsg7C:message];
      break;
    default:
      break;
  }
}

- (void)udpRequest:(UdpRequest *)request
    didNotReceiveMsgTag:(long)tag
          socketGroupId:(int)socketGroupId {
  DDLogDebug(@"tag is %ld and socketGroupId is %d", tag, socketGroupId);
  NSDictionary *userInfo = @{
    @"tag" : @(tag),
    @"socketGroupId" : @(socketGroupId)
  };
  [[NSNotificationCenter defaultCenter]
      postNotificationName:kNoResponseNotification
                    object:self
                  userInfo:userInfo];
}

- (void)responseMsg40Or42:(CC3xMessage *)message {
  //  message.socketGroupId;  // 0代表插座名字，1-n表示插孔n的名字
  //  message.state;
  if (message.state == kUdpResponseSuccessCode) {
    //成功
    [[NSNotificationCenter defaultCenter] postNotificationName:kSwitchNameChange
                                                        object:self
                                                      userInfo:nil];
  }
}

- (void)responseMsg48Or4A:(CC3xMessage *)message {
  if (message.state == kUdpResponseSuccessCode) {
    //成功
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kSwitchOnOffStateChange
                      object:self
                    userInfo:nil];
  }
}

- (void)responseMsg6COr6E:(CC3xMessage *)message {
  if (message.state == kUdpResponseSuccessCode) {
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kSetElecPowerInfoSuccess
                      object:self
                    userInfo:nil];
  }
}

- (void)responseMsg72Or74:(CC3xMessage *)message {
  if (message.state == kUdpResponseSuccessCode) {
    NSDictionary *userInfo = @{ @"message" : message };
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kGetElecPowerInfoSuccess
                      object:self
                    userInfo:userInfo];
  }
}

- (void)responseMsg7C:(CC3xMessage *)message {
  //  SDZGSwitch *aSwitch =
  //      [[SwitchDataCeneter sharedInstance] getSwitchByMac:message.mac];
  if ([self.aSwitch.mac isEqualToString:message.mac]) {
    self.aSwitch.firewareVersion = message.firmwareVersion;
    self.aSwitch.deviceType = message.deviceType;
    dispatch_async(dispatch_get_main_queue(), ^{ self.competion(); });
  }
}
@end
