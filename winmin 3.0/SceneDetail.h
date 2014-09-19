//
//  SceneDetail.h
//  SmartSwitch
//
//  Created by sdzg on 14-9-1.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SceneDetail : NSObject
@property(nonatomic, strong) NSString *mac;
@property(nonatomic, strong) NSString *switchName;
@property(nonatomic, assign) int groupId;
@property(nonatomic, strong) NSString *socketName;
@property(nonatomic, assign) BOOL onOrOff;
@property(nonatomic, assign) double interval;  //执行时间间隔

- (id)initWithMac:(NSString *)mac
          groupId:(int)groupId
       switchName:(NSString *)switchName
       socketName:(NSString *)socketName
          onOrOff:(BOOL)onOrOff;
@end