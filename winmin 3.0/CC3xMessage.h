//
//  CC3xMessage.h
//  CC3x
//
//  Created by hq on 3/24/14.
//  Copyright (c) 2014 Purpletalk. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
  P2D_SERVER_INFO_05 = 1000,
  P2D_SCAN_DEV_09,
  P2D_STATE_INQUIRY_0B,
  P2S_STATE_INQUIRY_0D,
  P2D_CONTROL_REQ_11,
  P2S_CONTROL_REQ_13,
  P2D_GET_TIMER_REQ_17,
  P2S_GET_TIMER_REQ_19,
  P2D_SET_TIMER_REQ_1D,
  P2S_SET_TIMER_REQ_1F,
  P2D_GET_PROPERTY_REQ_25,
  P2S_GET_PROPERTY_REQ_27,
  P2D_GET_POWER_INFO_REQ_33,
  P2S_GET_POWER_INFO_REQ_35,
  P2D_LOCATE_REQ_39,
  P2S_LOCATE_REQ_3B,
  P2D_SET_NAME_REQ_3F,
  P2S_SET_NAME_REQ_41,
  P2D_DEV_LOCK_REQ_47,
  P2S_DEV_LOCK_REQ_49,
  P2D_SET_DELAY_REQ_4D,
  P2S_SET_DELAY_REQ_4F,
  P2D_GET_DELAY_REQ_53,
  P2S_GET_DELAY_REQ_55,
  P2S_PHONE_INIT_REQ_59,
  P2D_GET_NAME_REQ_5D,
  P2S_GET_NAME_REQ_5F,
  P2S_GET_POWER_LOG_REQ_63,
  P2S_GET_CITY_REQ_65,
  P2S_GET_CITY_WEATHER_REQ_67,
  P2D_SET_PASSWD_REQ_69
};

@class CC3xMessage;

@interface CC3xMessageUtil : NSObject

+ (NSData *)string2Data:(NSString *)aString;
+ (Byte *)ip2HexBytes:(NSString *)ip;
+ (NSString *)hexString2Ip:(NSString *)string;
+ (NSString *)hexString:(NSData *)data;
+ (NSString *)data2Ip:(NSData *)data;
+ (CC3xMessage *)parseMessage:(NSData *)data;

+ (NSData *)getP2dMsg05;
+ (NSData *)getP2dMsg09;
+ (NSData *)getP2dMsg0B;
+ (NSData *)getP2SMsg0D:(NSString *)mac;
+ (NSData *)getP2dMsg11:(BOOL)on socketGroupId:(int)socketGroupId;
+ (NSData *)getP2sMsg13:(NSString *)mac
                aSwitch:(BOOL)on
          socketGroupId:(int)socketGroupId;
+ (NSData *)getP2dMsg17:(int)socketGroupId;
+ (NSData *)getP2SMsg19:(NSString *)mac socketGroupId:(int)socketGroupId;
+ (NSData *)getP2dMsg25;
+ (NSData *)getP2SMsg27:(NSString *)mac;
+ (NSData *)getP2dMsg1D:(NSUInteger)currentTime
               password:(NSString *)password
          socketGroupId:(int)socketGroupId
              timerList:(NSArray *)timerList;
+ (NSData *)getP2SMsg1F:(NSUInteger)currentTime
               password:(NSString *)password
          socketGroupId:(int)socketGroupId
              timerList:(NSArray *)timerList
                    mac:(NSString *)aMac;
+ (NSData *)getP2DMsg33;
+ (NSData *)getP2SMsg35:(NSString *)mac;
+ (NSData *)getP2dMsg39:(BOOL)on;
+ (NSData *)getP2SMsg3B:(NSString *)mac on:(BOOL)on;
+ (NSData *)getP2dMsg3F:(NSString *)name
                   type:(int)type
               password:(NSString *)password;
+ (NSData *)getP2sMsg41:(NSString *)mac
                   name:(NSString *)name
                   type:(int)type
               password:(NSString *)password;
+ (NSData *)getP2dMsg47:(BOOL)isLock password:(NSString *)password;
+ (NSData *)getP2sMsg49:(NSString *)mac
                   lock:(BOOL)isLock
               password:(NSString *)password;
+ (NSData *)getP2dMsg4D:(NSInteger)delay
                     on:(BOOL)on
          socketGroupId:(int)socketGroupId
               password:(NSString *)password;
+ (NSData *)getP2SMsg4F:(NSString *)mac
                  delay:(NSInteger)delay
                     on:(BOOL)on
          socketGroupId:(int)socketGroupId
               password:(NSString *)password;
+ (NSData *)getP2dMsg53:(int)socketGroupId;
+ (NSData *)getP2SMsg55:(NSString *)mac socketGroupId:(int)socketGroupId;
+ (NSData *)getP2SMsg59:(NSString *)mac;
+ (NSData *)getP2DMsg5D;
+ (NSData *)getP2SMsg5F:(NSString *)mac;
+ (NSData *)getP2SMsg63:(NSString *)mac
              beginTime:(int)beginTime
                endTime:(int)endTime
               interval:(int)interval;
+ (NSData *)getP2SMsg65:(NSString *)mac type:(int)type;
+ (NSData *)getP2SMsg67:(NSString *)mac
                   type:(int)type
               cityName:(NSString *)cityName;
+ (NSData *)getP2DMsg69:(NSString *)oldPassword
            newPassword:(NSString *)newPassword;
@end

@interface CC3xMessage : NSObject

@property(nonatomic, assign) unsigned char msgId;
@property(nonatomic, assign) unsigned char msgDir;
@property(nonatomic, assign) unsigned short msgLength;

@property(nonatomic, strong) NSString *mac;
@property(nonatomic, strong) NSString *ip;
@property(nonatomic, assign) unsigned short port;
@property(nonatomic, assign) int socketGroupId;  //当前操作的socket的id

@property(nonatomic, strong) NSString *deviceName;
@property(nonatomic, strong) NSArray *socketNames;
@property(nonatomic, assign) char state;  // 0表示成功；-1表示无控制权
@property(nonatomic, assign) char version;
@property(nonatomic, assign) char onStatus;
@property(nonatomic, assign) char lockStatus;
@property(nonatomic, assign) unsigned int currentTime;
@property(nonatomic, assign) char timerTaskNumber;
@property(nonatomic, strong) NSArray *timerTaskList;
@property(nonatomic, assign) short delay;

@property(nonatomic, assign) NSInteger update;
@property(nonatomic, assign) NSString *updateUrl;

@property(nonatomic, assign) int historyElecCount;
@property(nonatomic, strong) NSArray *historyElecs;

@property(nonatomic, assign) unsigned short pmTwoPointFive;
@property(nonatomic, assign) float temperature;
@property(nonatomic, assign) unsigned char humidity;  //湿度
@property(nonatomic, assign) float power;             //功率
@property(nonatomic, assign) unsigned char airTag;    //空气质量代号
@property(nonatomic, strong) NSString *airDesc;       //空气质量说明
@property(nonatomic, assign) unsigned short crc;
@end
