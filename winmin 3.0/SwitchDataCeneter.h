//
//  SwitchDataCeneter.h
//  SmartSwitch
//
//  Created by sdzg on 14-8-19.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kSwitchUpdate @"SwitchUpdateNotification"
#define kOneSwitchUpdate @"OneSwitchUpdateNotification"

@interface SwitchDataCeneter : NSObject
@property(strong, atomic, readonly) NSMutableDictionary *switchsDict;
@property(strong, nonatomic) NSArray *switchs;
@property(strong, nonatomic) NSIndexPath *selectedIndexPath;
+ (instancetype)sharedInstance;

/**
 *  网络不可用时将所有设备修改为离线
 */
- (void)updateAllSwitchStautsToOffLine;
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
                           mac:(NSString *)mac;
/**
 *  加解锁后执行
 *
 *  @param lockStatus <#lockStatus description#>
 *  @param mac        <#mac description#>
 *
 *  @return <#return value description#>
 */
- (NSArray *)updateSwitchLockStaus:(LockStatus)lockStatus mac:(NSString *)mac;

/**
 *  修改图片
 *
 *  @param imgName <#imgName description#>
 *  @param mac     <#mac description#>
 *
 */
- (void)updateSwitchImageName:(NSString *)imgName mac:(NSString *)mac;
/**
 *  查询到设备状态后执行
 *
 *  @param aSwitch <#aSwitch description#>
 *
 *  @return <#return value description#>
 */
- (NSArray *)updateSwitch:(SDZGSwitch *)aSwitch;
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
               socketGroupId:(int)socketGroupId;
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
               socketGroupId:(int)socketGroupId;
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
                          mac:(NSString *)mac;

/**
 *  退出前保存到数据库
 */
- (void)saveSwitchsToDB;

/**
 *  保存图片信息
 *
 *  @param groupId     socket所在分组，值为1和2
 *  @param socketId    socket的编号，值为1、2、3
 *  @param whichSwitch socket所属的switch
 */
- (void)updateSocketImage:imgName
                  groupId:(int)groupId
                 socketId:(int)socketId
              whichSwitch:(SDZGSwitch *)whichSwitch;

/**
 *  删除
 *
 *  @param aSwtich
 *
 *  @return
 */
- (BOOL)removeSwitch:(SDZGSwitch *)aSwtich;
@end
