//
//  SwitchDataCeneter.h
//  SmartSwitch
//
//  Created by sdzg on 14-8-19.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kNewSwitch @"NewSwitchNotification"
#define kSwitchUpdate @"SwitchUpdateNotification"
#define kOneSwitchUpdate @"OneSwitchUpdateNotification"

@interface SwitchDataCeneter : NSObject
//临时保存扫描到的设备
@property (strong, nonatomic, readonly) NSMutableDictionary *switchTmpDict;
@property (strong, atomic, readonly) NSMutableDictionary *switchsDict;
@property (strong, nonatomic) NSArray *switchs;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
+ (instancetype)sharedInstance;

- (NSArray *)switchsWithChangeStatus;

/**
 *  添加switch
 *
 *  @param aSwitch
 */
- (void)addSwitch:(SDZGSwitch *)aSwitch;

/**
 *  网络不可用时将所有设备修改为离线
 */
- (void)updateAllSwitchStautsToOffLine;
/**
 *  socket开关状态更改
 *
 *  @param socketStaus
 *  @param socketGroupId
 *  @param mac
 *
 *  @return
 */
- (void)updateSocketStaus:(SocketStatus)socketStaus
            socketGroupId:(int)socketGroupId
                      mac:(NSString *)mac;
/**
 *  加解锁后执行
 *
 *  @param lockStatus
 *  @param mac
 *
 *  @return
 */
- (void)updateSwitchLockStaus:(LockStatus)lockStatus mac:(NSString *)mac;

/**
 *  修改图片
 *
 *  @param imgName
 *  @param mac
 *
 */
- (void)updateSwitchImageName:(NSString *)imgName mac:(NSString *)mac;
/**
 *  查询到设备状态后执行
 *
 *  @param aSwitch
 *
 *  @return
 */
- (void)updateSwitch:(SDZGSwitch *)aSwitch;
/**
 *  定时任务修改后执行
 *
 *  @param timerList
 *  @param mac
 *  @param socketGroupId
 *
 *  @return
 */
- (void)updateTimerList:(NSArray *)timerList
                    mac:(NSString *)mac
          socketGroupId:(int)socketGroupId;
/**
 *  延迟时间更改后执行
 *
 *  @param delayTime
 *  @param delayAction
 *  @param mac
 *  @param socketGroupId
 *
 *  @return
 */
- (void)updateDelayTime:(int)delayTime
            delayAction:(DelayAction)delayAction
                    mac:(NSString *)mac
          socketGroupId:(int)socketGroupId;
/**
 *  设备名字更改后执行
 *
 *  @param switchName
 *  @param socketNames
 *  @param mac
 *
 *  @return
 */
- (void)updateSwitchName:(NSString *)switchName
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

/**
 *  检测是否所有设备已离线
 *
 *  @return
 */
- (BOOL)isAllSwitchOffLine;

#pragma mark - 临时空间
- (void)addSwitchToTmp:(SDZGSwitch *)aSwitch;
- (void)removeSwitchFromTmp:(SDZGSwitch *)aSwitch;
- (SDZGSwitch *)getSwitchFromTmpByMac:(NSString *)mac;
@end
