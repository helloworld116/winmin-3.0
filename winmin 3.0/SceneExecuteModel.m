//
//  SceneExecuteModel.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-29.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SceneExecuteModel.h"
#import "SceneDetail.h"

@interface SceneExecuteModel ()<UdpRequestDelegate>
@property(nonatomic, strong) NSOperationQueue *queue;
@property(nonatomic, strong) UdpRequest *request;
@end

@implementation SceneExecuteModel
- (id)init {
  self = [super init];
  if (self) {
    self.request = [UdpRequest manager];
    self.request.delegate = self;
    self.queue = [[NSOperationQueue alloc] init];
    [self.queue setMaxConcurrentOperationCount:1];
  }
  return self;
}

- (void)executeSceneDetails:(NSArray *)sceneDetails {
  //    dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL)
  dispatch_async(GLOBAL_QUEUE, ^{
      for (SceneDetail *sceneDetail in sceneDetails) {
        SDZGSwitch *aSwitch = sceneDetail.aSwitch;
        SDZGSocket *socket = aSwitch.sockets[sceneDetail.groupId - 1];
        socket.socketStatus = !sceneDetail.onOrOff;

        NSBlockOperation *operation =
            [NSBlockOperation blockOperationWithBlock:^{
                [self sendMsg11Or13:aSwitch groupId:sceneDetail.groupId];
            }];
        [self.queue addOperation:operation];
        debugLog(@"######## %@", [sceneDetail description]);
        sleep(2);
      }
  });
}

- (void)cancelExecute {
  [self.queue cancelAllOperations];
}

- (void)sendMsg11Or13:(SDZGSwitch *)aSwitch groupId:(int)groupId {
  if (!self.request) {
    self.request = [UdpRequest manager];
    self.request.delegate = self;
  }
  [self.request sendMsg11Or13:aSwitch
                socketGroupId:groupId
                     sendMode:ActiveMode];
}

#pragma mark - UdpRequestDelegate
- (void)responseMsg:(CC3xMessage *)message address:(NSData *)address {
  switch (message.msgId) {
    //开关控制
    case 0x12:
    case 0x14:
      [self responseMsg12Or14:message];
      break;
  }
}

- (void)responseMsg12Or14:(CC3xMessage *)message {
  if (message.state == 0) {
    //    SDZGSocket *socket =
    //        [self.aSwitch.sockets objectAtIndex:message.socketGroupId - 1];
    //    socket.socketStatus = !socket.socketStatus;
    //    [self.aSwitch.sockets replaceObjectAtIndex:message.socketGroupId - 1
    //                                    withObject:socket];
    //    NSDictionary *userInfo = @{
    //      @"switch" : self.aSwitch,
    //      @"socketGroupId" : @(message.socketGroupId)
    //    };
    //    [[NSNotificationCenter defaultCenter]
    //        postNotificationName:kSwitchOnOffStateChange
    //                      object:self
    //                    userInfo:userInfo];
    debugLog(@"recive info msg 12and14");
  }
}
@end
