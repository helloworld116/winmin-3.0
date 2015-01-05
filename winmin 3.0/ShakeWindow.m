//
//  ShakeWindow.m
//  winmin 3.0
//
//  Created by sdzg on 15-1-4.
//  Copyright (c) 2015年 itouchco.com. All rights reserved.
//

#import "ShakeWindow.h"
@interface ShakeWindow () <UdpRequestDelegate>
@end

@implementation ShakeWindow

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.request = [UdpRequest manager];
    self.request.delegate = self;
  }
  return self;
}

#pragma mark - UdpRequestDelegate
- (void)udpRequest:(UdpRequest *)request
     didReceiveMsg:(CC3xMessage *)message
           address:(NSData *)address {
  switch (message.msgId) { //开关控制
    case 0x12:
    case 0x14:
      [self responseMsg12Or14:message request:request];
      break;
  }
}

- (void)responseMsg12Or14:(CC3xMessage *)message request:(UdpRequest *)request {
  DDLogDebug(@"%s socketGroupId is %d", __func__, message.socketGroupId);
  if (message.state == kUdpResponseSuccessCode) {
    SDZGSocket *socket =
        [self.aSwitch.sockets objectAtIndex:message.socketGroupId - 1];
    socket.socketStatus = !socket.socketStatus;
    [self.aSwitch.sockets replaceObjectAtIndex:message.socketGroupId - 1
                                    withObject:socket];
  }
}

@end
