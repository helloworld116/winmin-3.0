//
//  SensorModel.m
//  winmin 3.0
//
//  Created by sdzg on 15-4-9.
//  Copyright (c) 2015年 itouchco.com. All rights reserved.
//

#import "SensorModel.h"

@interface SensorModel () <UdpRequestDelegate>

@property (strong, nonatomic) UdpRequest *request1; //用于获取服务器天气信息
@property (strong, nonatomic) UdpRequest *request2; //用于获取传感器数据
@property (strong, nonatomic) SDZGSwitch *aSwitch;
@property (strong, nonatomic) CityWeatherBlock cityWeatherBlock;
@property (strong, nonatomic) SensorDataBlock sensorBlock;
@end

@implementation SensorModel

- (id)initWithSwitch:(SDZGSwitch *)aSwitch {
  self = [super init];
  if (self) {
    self.aSwitch = aSwitch;
    self.request1 = [[UdpRequest alloc] init];
    self.request1.delegate = self;
    self.request2 = [[UdpRequest alloc] init];
    self.request2.delegate = self;
  }
  return self;
}

- (void)dealloc {
  self.request1.delegate = nil;
  self.request2.delegate = nil;
}

- (void)queryWeatherInfo:(CityWeatherBlock)weatherBlock {
  self.cityWeatherBlock = weatherBlock;
  [self.request1 sendMsg67:self.aSwitch.mac
                      type:0
                  cityName:nil
                  sendMode:ActiveMode];
}

- (void)querySensorInfo:(SensorDataBlock)sensorBlock {
  self.sensorBlock = sensorBlock;
  [self.request2 sendMsg33Or35:self.aSwitch sendMode:ActiveMode];
}

#pragma mark - UdpRequestDelegate
- (void)udpRequest:(UdpRequest *)request
     didReceiveMsg:(CC3xMessage *)message
           address:(NSData *)address {
  switch (message.msgId) {
    //传感器数据
    case 0x34:
    case 0x36:
      [self responseMsg34Or36:message];
      break;
    case 0x68:
      //服务端天气数据
      [self responseMsg68:message];
      break;
    default:
      break;
  }
}

- (void)responseMsg34Or36:(CC3xMessage *)message {
}

- (void)responseMsg68:(CC3xMessage *)message {
}
@end
