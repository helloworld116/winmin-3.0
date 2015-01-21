//
//  SDZGSwitch.h
//  SmartSwitch
//
//  Created by sdzg on 14-8-19.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_OPTIONS(NSUInteger, SwitchStatus){
  SWITCH_NEW, SWITCH_LOCAL, SWITCH_REMOTE, SWITCH_OFFLINE,
};

typedef NS_OPTIONS(NSUInteger, DelayAction){
  DelayActionOff = 0, DelayActionOn,
};
typedef NS_OPTIONS(NSUInteger, SocketStatus){
  SocketStatusOff = 0, SocketStatusOn,
};
typedef NS_OPTIONS(NSUInteger, TimerActionType){
  TimerActionTypeOff = 0, TimerActionTypeOn,
};
typedef NS_OPTIONS(NSUInteger, LockStatus){
  LockStatusOff = 0, LockStatusOn,
};
typedef NS_OPTIONS(NSUInteger, DAYTYPE){ MONDAY = 1 << 0,  TUESDAY = 1 << 1,
                                         WENSDAY = 1 << 2, THURSDAY = 1 << 3,
                                         FRIDAY = 1 << 4,  SATURDAY = 1 << 5,
                                         SUNDAY = 1 << 6 };

@interface SDZGSwitch : NSObject<NSCopying>
@property (nonatomic, assign) int _id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) SwitchStatus networkStatus;
@property (nonatomic, strong) NSString *mac;
@property (nonatomic, strong) NSString *ip;
@property (nonatomic, assign) unsigned short port;
@property (nonatomic, assign) LockStatus lockStatus;
@property (nonatomic, strong) NSMutableArray *sockets; //插孔
@property (nonatomic, assign) char version;
@property (nonatomic, assign) long tag; // 0表示设备未同步，1表示设备已同步
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *
    password;                                                    //设置的设备密码，添加修改设备相关信息需要使用，未设置的情况下默认为空
@property (nonatomic, assign) NSTimeInterval lastUpdateInterval; //最近修改时间
@property (nonatomic, assign) int power;                         //显示功率
+ (void)parseMessageCOrE:(CC3xMessage *)message
                toSwitch:(void (^)(SDZGSwitch *aSwitch))completion;
/**
 *  从服务器上同步的设备加入到本地解析
 *
 *  @return
 */
+ (instancetype)parseSyncSwitch:(NSString *)mac
                       password:(NSString *)password
                           name:(NSString *)name
                        version:(int)version
                     lockStauts:(LockStatus)lockStauts;
+ (UIImage *)imgNameToImage:(NSString *)imgName;
+ (UIImage *)imgNameToImageOffline:(NSString *)imgName;

@end
@interface SDZGSocket : NSObject<NSCopying>
@property (nonatomic, assign) int groupId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *timerList;
@property (nonatomic, assign) short delayTime; //延迟剩余时间，单位分钟
@property (nonatomic, assign)
    DelayAction delayAction; //延迟操作 on为开操作，off为关操作
@property (nonatomic, assign)
    SocketStatus socketStatus; //开关状态，on为开，off为关
@property (nonatomic, strong) NSArray *imageNames;

+ (UIImage *)imgNameToImage:(NSString *)imgName status:(SocketStatus)status;
@end

@interface SDZGTimerTask : NSObject<NSCopying>
@property (nonatomic, assign) unsigned char week;
@property (nonatomic, assign) unsigned int actionTime; //动作时间
@property (nonatomic, assign) BOOL isEffective;        //是否生效
@property (nonatomic, assign)
    TimerActionType timerActionType; //动作类型，on表示开，off表示关

- (id)initWithWeek:(unsigned char)week
         actionTime:(unsigned int)actionTime
        isEffective:(BOOL)isEffective
    timerActionType:(TimerActionType)timerActionType;

- (BOOL)isDayOn:(DAYTYPE)aDay;
+ (int)getShowSeconds:(NSArray *)timers;
- (NSString *)actionWeekString;
- (NSString *)actionTimeString;
- (NSString *)actionTypeString;
- (BOOL)actionEffective;
@end