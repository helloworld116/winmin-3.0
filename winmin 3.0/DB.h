//
//  DB.h
//  SmartSwitch
//
//  Created by 文正光 on 14-8-25.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBUtil : NSObject
+ (instancetype)sharedInstance;

- (void)saveSwitch:(SDZGSwitch *)aSwitch;

- (void)saveSwitchs:(NSArray *)switchs;

- (NSArray *)getSwitchs;

- (void)deleteSwitch:(NSString *)mac;

- (BOOL)updateSwitch:(SDZGSwitch *)aSwitch imageName:(NSString *)imageName;

- (BOOL)updateSocketImage:(NSString *)imageName
                  groupId:(int)groupId
                 socketId:(int)socketId
              whichSwitch:(id)aSwitch;

- (NSArray *)scenes;

- (BOOL)saveScene:(id)scene;

- (BOOL)deleteScene:(id)object;
@end
