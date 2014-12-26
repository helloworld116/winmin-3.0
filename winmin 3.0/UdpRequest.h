//
//  UdpRequest.h
//  SmartSwitch
//
//  Created by 文正光 on 14-8-17.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UdpRequest;

@protocol UdpRequestDelegate<NSObject>

@required
#pragma mark - 请求响应后的处理
/**
 *  为设备配置wifi后的响应
 *
 *  @param message 响应报文经过包装后的对象
 *  @param address 路由器的地址
 */
- (void)udpRequest:(UdpRequest *)request
     didReceiveMsg:(CC3xMessage *)message
           address:(NSData *)address;
@optional
#pragma mark - 请求没响应后的处理
/**
 *  UDP请求后未响应的处理
 *
 *  @param tag        UDP请求的tag
 *  @param socketGroupId socket所属id
 */
- (void)udpRequest:(UdpRequest *)request
    didNotReceiveMsgTag:(long)tag
          socketGroupId:(int)socketGroupId;

#pragma mark - 请求没有发送的处理
/**
 *  UDP请求未发送后的处理
 *
 *  @param tag        udp请求的tag
 *  @param triedCount 失败后已经尝试的次数
 */
- (void)noSendMsgtag:(long)tag triedCount:(int)triedCount;

#pragma mark - 其他错误时的处理
/**
 *  出现错误后的处理
 *
 *  @param msg 错误信息
 */
- (void)errorMsg:(NSString *)msg;
@end

@interface UdpRequest : NSObject
typedef enum { ActiveMode, PassiveMode } SENDMODE;
@property (nonatomic, assign) id<UdpRequestDelegate> delegate;
+ (instancetype)manager;
/**
 *  配置时使用，使用指定端口
 *
 *  @return <#return value description#>
 */
+ (instancetype)managerConfig;
/**
 *  P2D_SERVER_INFO
 *
 *  @param udpSocket
 *  @param address   发往的地址
 *  @param mode
 */
- (void)sendMsg05:(NSString *)ip
             port:(uint16_t)port
         password:(unsigned char[6])password
             mode:(SENDMODE)mode;

/**
 *  手机添加设备
 *
 *  @param udpSocket
 *  @param mode
 */
- (void)sendMsg09:(SENDMODE)mode;

/**
 *  手机向内网查询所有设备的开关状态
 *
 *  @param udpSocket
 *  @param mode
 */
- (void)sendMsg0B:(SENDMODE)mode;

/**
 *  手机向内网查询所有设备的开关状态
 *
 *  @param aSwitch 指定设备
 *  @param mode
 */
- (void)sendMsg0B:(SDZGSwitch *)aSwitch sendMode:(SENDMODE)mode;

/**
 *  手机向外网查询所有设备的开关状态
 *
 *  @param udpSocket
 *  @param mode
 */
- (void)sendMsg0D:(SDZGSwitch *)aSwitch sendMode:(SENDMODE)mode tag:(long)tag;

/**
 *  手机向查询指定设备的开关状态
 *
 *  @param udpSocket
 *  @param mode
 */
- (void)sendMsg0BOr0D:(SDZGSwitch *)aSwitch sendMode:(SENDMODE)mode;

/**
 *  手机控制开关“开或关”
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param isSwitchOn 开关当前状态，即发送指令前的状态
 *  @param mode
 */
- (void)sendMsg11Or13:(SDZGSwitch *)aSwitch
        socketGroupId:(int)socketId
             sendMode:(SENDMODE)mode;
/**
 *  手机获取设备定时列表
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param mode
 */
- (void)sendMsg17Or19:(SDZGSwitch *)aSwitch
        socketGroupId:(int)socketGroupId
             sendMode:(SENDMODE)mode;
/**
 *  手机设置设备定时列表
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param timeList  定时列表集合
 *  @param mode
 */
- (void)sendMsg1DOr1F:(SDZGSwitch *)aSwitch
        socketGroupId:(int)socketGroupId
             timeList:(NSArray *)timeList
             sendMode:(SENDMODE)mode;
/**
 *  手机获取设备控制权限
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param mode
 */
//- (void)sendMsg25Or27:(GCDAsyncUdpSocket *)udpSocket
//              aSwitch:(SDZGSwitch *)aSwitch
//             sendMode:(SENDMODE)mode;

- (void)sendMsg33Or35:(SDZGSwitch *)aSwitch sendMode:(SENDMODE)mode;

/**
 *  设备定位，即使设备灯闪烁
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param on        定位标识，目前只有1，表示定位
 *  @param mode
 */
- (void)sendMsg39Or3B:(SDZGSwitch *)aSwitch on:(BOOL)on sendMode:(SENDMODE)mode;
/**
 *  设置设备名称
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param name      设备名称
 *  @param mode
 */
- (void)sendMsg3FOr41:(SDZGSwitch *)aSwitch
                 type:(int)type
                 name:(NSString *)name
             sendMode:(SENDMODE)mode;
/**
 *  设备加锁
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param isLock    设备当前的锁定状态，即发送指令前的状态
 *  @param mode
 */
- (void)sendMsg47Or49:(SDZGSwitch *)aSwitch sendMode:(SENDMODE)mode;
/**
 *  设置设备延时任务
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param delayTime 延时时间，单位分钟
 *  @param on        0x1表示开，0x0表示关
 *  @param mode
 */
- (void)sendMsg4DOr4F:(SDZGSwitch *)aSwitch
        socketGroupId:(int)socketGroupId
            delayTime:(NSInteger)delayTime
             switchOn:(BOOL)on
             sendMode:(SENDMODE)mode;
/**
 *  查询设备延时任务
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param mode
 */
- (void)sendMsg53Or55:(SDZGSwitch *)aSwitch
        socketGroupId:(int)socketGroupId
             sendMode:(SENDMODE)mode;

/**
 *  手机上报设备、应用信息
 *
 *  @param mode
 */
- (void)sendMsg59WithSendMode:(SENDMODE)mode;

/**
 *  查询设备名字
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param mode
 */
- (void)sendMsg5DOr5F:(SDZGSwitch *)aSwitch sendMode:(SENDMODE)mode;

/**
 *  查询历史电量
 *
 *  @param
 *  @param beginTime 开始时间 （秒）
 *  @param endTime 结束时间 （秒）
 *  @param interval 间隔时间，返回查询数量是(Endtimet-begintimet)/ interval
 */
- (void)sendMsg63:(SDZGSwitch *)aSwitch
        beginTime:(int)beginTime
          endTime:(int)endTime
         interval:(int)interval
         sendMode:(SENDMODE)mode;

/**
 *  查询终端城市
 *
 *  @param mac 设备/手机MAC地址
 *  @param type 0 为获取设备当地的城市 1为获取换手机当地的城市
 *  @param mode
 */
- (void)sendMsg65:(NSString *)mac type:(int)type sendMode:(SENDMODE)mode;

/**
 *  查询当地天气
 *
 *  @param mac
 *  @param type 设备/手机MAC地址
 *  @param mode 0 为获取设备当地的天气 1为获取换手机当地的天气
 *3为获取指定城市的天气
 */
- (void)sendMsg67:(NSString *)mac
             type:(int)type
         cityName:(NSString *)cityName
         sendMode:(SENDMODE)mode;

/**
 *  设置密码
 *
 *  @param udpSocket
 *  @param aSwitch
 *  @param mode
 */
- (void)sendMsg69:(NSString *)oldPassword
      newPassword:(NSString *)newPassword
         sendMode:(SENDMODE)mode;

- (void)sendMsg6BOr6D:(SDZGSwitch *)aSwitch
           alertUnder:(short)alertUnder
         isAlertUnder:(BOOL)isAlertUnder
         alertGreater:(short)alertGreater
       isAlertGreater:(BOOL)isAlertGreater
         turnOffUnder:(short)turnOffUnder
       isTurnOffUnder:(BOOL)isTurnOffUnder
       turnOffGreater:(short)turnOffGreater
     isTurnOffGreater:(BOOL)isTurnOffGreater
             sendMode:(SENDMODE)mode;

- (void)sendMsg71Or73:(SDZGSwitch *)aSwitch sendMode:(SENDMODE)mode;
@end
