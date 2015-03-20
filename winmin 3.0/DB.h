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

- (BOOL)removeScene:(id)object;

- (BOOL)removeSceneBySwitch:(SDZGSwitch *)aSwitch;

#pragma mark - 临时表
- (void)addSceneToSceneDetailTmp:(id)object;
- (void)addDetailTmpWithSwitchMac:(NSString *)mac groupId:(int)groupid;
- (void)addDetailTmpWithSwitchMac:(NSString *)mac
                          groupId:(int)groupid
                             isOn:(BOOL)isOn;
- (void)removeDetailTmpWithSwitchMac:(NSString *)mac groupId:(int)groupid;
- (void)updateDetailTmpWithSwitchMac:(NSString *)mac
                             groupId:(int)groupid
                         onOffStatus:(BOOL)onOffStatus;
- (NSArray *)allSceneDetailsTmp;
- (void)removeAllSceneDetailTmp;

#pragma mark - 历史消息
- (void)saveNotificationHistorys:(NSArray *)messages;

- (NSArray *)getHistoryMessagesWithCount:(int)count offset:(int)offset;

- (void)removeAllHistoryMessages;
@end
