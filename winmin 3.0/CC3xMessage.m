//
//  CC3xMessage.m
//  CC3x
//
//  Created by hq on 3/24/14.
//  Copyright (c) 2014 Purpletalk. All rights reserved.
//

#import "CC3xMessage.h"
//#import "CC3xUtility.h"
//#import "CC3xTimerTask.h"
#import "CRC.h"
#import "HistoryElec.h"

#define B2D(bytes) ([NSData dataWithBytes:&bytes length:sizeof(bytes)]);

#define int2charArray(array, value)                                            \
  do {                                                                         \
    array[0] = ((value >> 24) & 0xff);                                         \
    array[1] = ((value >> 16) & 0xff);                                         \
    array[2] = ((value >> 8) & 0xff);                                          \
    array[3] = ((value >> 0) & 0xff);                                          \
  } while (0);

#define charArray2int(array, value)                                            \
  do {                                                                         \
    value += array[0] << 24;                                                   \
    value += array[1] << 16;                                                   \
    value += array[2] << 8;                                                    \
    value += array[3] << 0;                                                    \
  } while (0);
@implementation CC3xMessageUtil

/* HEADER, P2D_SCAN_DEV_REQ 0x9 == P2D_STATE_INQUIRY 0xb
 * P2D_GET_TIMER_REQ 0x17 == P2D_GET_PROPERTY_REQ 0x25
 */
#pragma pack(1)

typedef struct {
  unsigned short msgLength;
  unsigned char msgId;
  unsigned char msgDir;
} msgHeader;

// D2P_CONFIG_RESULT 0x02
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned char ip[4];
  unsigned short port;
  unsigned short crc;
} d2pMsg02;

typedef struct { unsigned char name[32]; } socketInfo;

// P2D_SERVER_INFO 0x05
typedef struct {
  msgHeader header;
  unsigned char ip[4];
  unsigned short port;
  unsigned char deviceName[32];
  unsigned char count;
  socketInfo socketName[2];
  unsigned char password[6];
  unsigned short crc;
} p2dMsg05;

// P2D_SERVER_RESP 0x06
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state;
  unsigned short crc;
} d2pMsg06;

// P2D_SCAN_DEV_REQ 0x09
typedef struct {
  msgHeader header;
  unsigned short crc;
} p2dMsg09;

// D2P_SCAN_DEV_RESP 0x0a
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned char ip[4];
  unsigned short port;
  char deviceName[32];
  unsigned char FWVersion;
  char isLocked;
  unsigned char password[6];
  unsigned short crc;
} d2pMsg0A;

// P2D_STATE_INQUIRY 0x0B
typedef struct {
  msgHeader header;
  unsigned short crc;
} p2dMsg0B;

// D2P_STATE_RESP 0x0C
typedef struct {
  msgHeader header;
  char state;
  unsigned char mac[6];
  unsigned char ip[4];
  unsigned short port;
  char deviceName[32];
  unsigned char deviceLockState;
  unsigned char FWVersion;
  unsigned char onOffState;
  unsigned char password[6];
  unsigned short crc;
} d2pMsg0C;

// P2S_STATE_INQUIRY 0x0D
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned char password[6];
  unsigned short crc;
} p2sMsg0D;

// D2S_STATE_RESP 0x0E
typedef struct {
  msgHeader header;
  char state;
  unsigned char mac[6];
  unsigned char ip[4];
  unsigned short port;
  char deviceName[32];
  unsigned char deviceLockState;
  unsigned char FWVersion;
  unsigned char onOffState;
  unsigned short crc;
} d2pMsg0E;

// P2D_CONTROL_REQ 0x11
typedef struct {
  msgHeader header;
  unsigned char socketGroupId;
  unsigned char password[6];
  unsigned char on;
  unsigned short crc;
} p2dMsg11;

// D2P_CONTROL_RESP 0x12
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned char socketGroupId;
  char state;
  unsigned short crc;
} d2pMsg12;

// P2S_CONTROL_REQ 0x13
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned char socketGroupId;
  unsigned char password[6];
  unsigned char on;
  unsigned short crc;
} p2sMsg13;

// S2P_CONTROL_RESP 0x14
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned char socketGroupId;
  char state;
  unsigned short crc;
} s2pMsg14;

// P2D_GET_TIMER_REQ 0x17
typedef struct {
  msgHeader header;
  unsigned char socketGroupId;
  unsigned short crc;
} p2dMsg17;

// Timer related structure
typedef struct {
  char week;
  unsigned int actionTime;
  unsigned char takeEffect; //是否生效，1表示动作，0表示不动作
  unsigned char actionType; //动作类型，1表示开，0表示关
} timerTask;

// D2P_GET_TIMER_RESP 0x18
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned char socketGroupId;
  unsigned int currentTime;
  unsigned char count;
  unsigned short crc;
} d2pMsg18;

// P2S_CONTROL_REQ 0x19
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned char socketGroupId;
  unsigned short crc;
} p2sMsg19;

// S2P_GET_TIMER_RESP 0x1A
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned char socketGroupId;
  unsigned char currentTime[4];
  unsigned char timerNumber;
  timerTask *timerList;
  unsigned short crc;
} s2pMsg1A;

// P2D_SET_TIMER_REQ 0x1D
typedef struct {
  msgHeader header;
  unsigned char socketGroupId;
  unsigned char password[6];
  unsigned int currentTime;
  unsigned char timerNumber;
  unsigned short crc;
} p2dMsg1D;

// D2P_SET_TIMER_RESP 0x1E
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned char socketGroupId;
  char state;
  unsigned short crc;
} d2pMsg1E;

// P2S_SET_TIMER_REQ 0x1F
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned char socketGroupId;
  unsigned char password[6];
  unsigned int currentTime;
  unsigned char timerNumber;
  unsigned short crc;
} p2sMsg1F;

// S2P_CONTROL_RESP 0x20
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned char socketGroupId;
  char state;
  unsigned short crc;
} s2pMsg20;

// P2D_GET_PROPERTY_REQ 0X25
typedef struct {
  msgHeader header;
  unsigned short crc;
} p2dMsg25;
// D2P_GET_PROPERTY_RESP 0X26
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state;
  unsigned short crc;
} d2pMsg26;
// P2S_GET_PROPERTY_REQ 0X27
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned short crc;
} p2sMsg27;
// S2P_GET_PROPERTY_RESP 0X28
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state;
  unsigned short crc;
} s2pMsg28;

// P2D_GET_POWER_INFO_REQ 	0X33
typedef struct {
  msgHeader header;
  unsigned short crc;
} p2dMsg33;

// D2P_GET_POWER_INFO_RESP	0X34
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state;           // 0表示成功
  unsigned short pulse; //电量脉冲的周期值x，单位为ms 功率W=（53035.5/x）
                        //保留2位小数
  unsigned short crc;
} d2pMsg34;

// P2S_GET_POWER_INFO_REQ	 0X35
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned short crc;
} p2sMsg35;

// S2P_GET_POWER_INFO_resp	 0X36
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state;
  unsigned short pulse;
  unsigned short crc;
} s2pMsg36;

// P2D_LOCATE_REQ 0x39

typedef struct {
  msgHeader header;
  unsigned char on; // 1闪烁 0消除闪烁
  unsigned short crc;
} p2dMsg39;
// D2P_LOCATE_RESP 0x3A
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state; // 0成功，非0失败
  unsigned short crc;
} d2pMsg3A;

//  P2S_LOCATE_REQ 0x3B

typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char on; // 1闪烁 0消除闪烁
  unsigned short crc;
} p2sMsg3B;

// S2P_LOCATE_RESP 0x3C
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state; // 0成功，非0失败
  unsigned short crc;
} s2pMsg3C;

// P2D_SET_NAME_REQ 0x3F
typedef struct {
  msgHeader header;
  unsigned char type; // 0代表插座名字，1-n表示插孔n的名字
  unsigned char password[6];
  char name[32];
  unsigned short crc;
} p2dMsg3F;

// D2P_SET_NAME_RESP 0x40
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned char type; // 0代表插座名字，1-n表示插孔n的名字
  char state;         // 0表示成功
  unsigned short crc;
} d2pMsg40;

// P2S_SET_NAME_REQ 0x41
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned char type; // 0代表插座名字，1-n表示插孔n的名字
  unsigned char password[6];
  char name[32];
  unsigned short crc;
} p2sMsg41;

// S2P_SET_NAME_RESP 0x42
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned char type; // 0代表插座名字，1-n表示插孔n的名字
  char state;         // 0表示成功
  unsigned short crc;
} s2pMsg42;

// P2D_DEV_LOCK_REQ 0x47
typedef struct {
  msgHeader header;
  unsigned char password[6];
  char lock; // 0X1加锁；0X0解锁
  unsigned short crc;
} p2dMsg47;

// D2P_DEV_LOCK_RESP 0x48
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state; // 0成功
  unsigned short crc;
} d2pMsg48;

// P2S_DEV_LOCK_REQ 0x49
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned char password[6];
  char lock; // 0X1加锁；0X0解锁
  unsigned short crc;
} p2sMsg49;

// S2P_DEV_LOCK_RESP 0x4A
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state; // 0成功
  unsigned short crc;
} s2pMsg4A;

// P2D_SET_DELAY_REQ 0x4D
typedef struct {
  msgHeader header;
  unsigned char socketGroupId;
  unsigned char password[6];
  unsigned int delay; // max= 1440分钟
  char on;            // 0x1表示开，0x0表示关
  unsigned short crc;
} p2dMsg4D;

// D2P_SET_DELAY_RESP 0x4E
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned char socketGroupId;
  char state; // 0表示成功
  unsigned short crc;
} d2pMsg4E;

// P2S_SET_DELAY_REQ 0x4F
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned char socketGroupId;
  unsigned char password[6];
  unsigned int delay;
  char on; // 0x1表示开，0x0表示关
  unsigned short crc;
} p2sMsg4F;

// S2P_SET_DELAY_RESP 0x50
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned char socketGroupId;
  char state; // 0表示成功
  unsigned short crc;
} s2pMsg50;

// P2D_GET_DELAY_REQ 0x53
typedef struct {
  msgHeader header;
  unsigned char socketGroupId;
  unsigned short crc;
} p2dMsg53;

// D2P_GET_DELAY_RESP 0x54
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned char socketGroupId;
  unsigned int delay;
  unsigned char on; // 0x1表示开，0x0表示关
  unsigned short crc;
} d2pMsg54;

// P2S_GET_DELAY_REQ 0x55
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned char socketGroupId;
  unsigned short crc;
} p2sMsg55;

// S2P_GET_DELAY_RESP 0X56
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned char socketGroupId;
  unsigned int delay;
  unsigned char on; // 0x1表示开，0x0表示关
  unsigned short crc;
} s2pmsg56;

// P2S_PHONE_INIT_REQ 0x59
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char phoneType[20];  //手机型号
  char systemName[20]; //手机操作系统版本
  char appVersion[10]; // app软件版本
  unsigned short crc;
} p2sMsg59;

// S2P_PHONE_INIT_RESP 0x5A
typedef struct {
  msgHeader header;
  char update;
  char updateUrl[100];
  unsigned short crc;
} s2pMsg5A;

// P2D_GET_NAME_REQ	0X5D
typedef struct {
  msgHeader header;
  unsigned short crc;
} p2dMsg5D;

// D2P_GET_NAME_RESP	0X5E
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char deviceName[32];
  unsigned char count;
  char socket1Name[32];
  char socket2Name[32];
  unsigned short crc;
} d2pMsg5E;

// P2S_GET_NAME_REQ 	0X5F
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned short crc;
} p2sMsg5F;

// S2P_GET_NAME_RESP	0X60
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char deviceName[32];
  unsigned char count;
  socketInfo *socketName;
  unsigned short crc;
} s2pMsg60;

// P2S_GET_POWER_LOG_REQ	 0X63
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  int beginTime; //开始时间 （秒）
  int endTime;   //开始时间 （秒）
  int interval; //间隔时间，返回查询数量是(endtime-begintime)/ interval
  unsigned short crc;
} p2sMsg63;

//电量信息，时间和功率
typedef struct {
  int time;
  int power; //功率,单位(1/100)瓦
} elecInfo;

// S2P_GET_POWER_LOG_RESP 0X64
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state; // 0表示成功
  char count; //结果数量
  unsigned short crc;
} s2pMsg64;

// P2S_GET_CITY_REQ	 0X65
typedef struct {
  msgHeader header;
  unsigned char mac[6]; //设备/手机MAC地址
  char type; // 0 为获取设备当地的城市 1为获取换手机当地的城市
  unsigned short crc;
} p2sMsg65;

// S2P_GET_ CITY_RESP 0X66
typedef struct {
  msgHeader header;
  unsigned char mac[6]; //设备MAC地址
  char state;           // 0成功
  char city[10];
  unsigned short crc;
} s2pMsg66;

// P2S_GET_CITY_WEATHER_REQ	 0X67
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char type; // 0 为获取设备当地的天气 1为获取换手机当地的天气
  // 3为获取指定城市的天气
  char cityName[20]; //城市名称
  unsigned short crc;
} p2sMSg67;

// S2P_GET_ CITY_WEATHER _RESP 0X68
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state;                // 0表示成功
  char city[10];             //城市
  char temperature[10];      //温度
  char humidity[10];         //湿度
  char weather[20];          //天气
  char wind[20];             //风速
  char pm2point5[5];         // pm2.5
  char dayPictureUrl[100];   //白天图片
  char nightPictureUrl[100]; //晚上图片
  unsigned short crc;
} s2pMsg68;

// P2D_SET_PASSWD_REQ	  0X69
typedef struct {
  msgHeader header;
  char oldPassword[6];
  char newPassword[6];
  unsigned short crc;
} p2dMSg69;

// D2P_SET_PASSWD_RESP	0X6A
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state; // 0表示成功
  unsigned short crc;
} d2pMSg6A;

// P2D_SET_POWERACTION_REQ 0X6B
typedef struct {
  msgHeader header;
  unsigned short alertUnder;
  unsigned short alertGreater;
  unsigned short turnOffUnder;
  unsigned short turnOffGreater;
  unsigned short crc;
} p2dMSg6B;

// D2P_SET_POWERACTION_RESP	0X6C
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state; // 0表示成功
  unsigned short crc;
} d2pMsg6C;

// P2S_SET_POWERACTION_REQ  0X6D
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned short alertUnder;
  unsigned short alertGreater;
  unsigned short turnOffUnder;
  unsigned short turnOffGreater;
  unsigned short crc;
} p2sMsg6D;

// S2P_SET_DELAY_RESP  0X6E
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state; // 0表示成功
  unsigned short crc;
} s2pMsg6E;

// P2D_GET_POWERACTION_REQ 0X71
typedef struct {
  msgHeader header;
  unsigned short crc;
} p2dMsg71;

// D2P_GET_POWERACTION_RESP	0X72
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state;
  unsigned short alertUnder;
  unsigned short alertGreater;
  unsigned short turnOffUnder;
  unsigned short turnOffGreater;
  unsigned short crc;
} d2pMsg72;

// P2S_GET_POWERACTION_REQ 0X73
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  unsigned short crc;
} p2sMsg73;

// S2P_GET_POWERACTION_RESP	0X74
typedef struct {
  msgHeader header;
  unsigned char mac[6];
  char state;
  unsigned short alertUnder;
  unsigned short alertGreater;
  unsigned short turnOffUnder;
  unsigned short turnOffGreater;
  unsigned short crc;
} s2pMsg74;

#pragma pack()
#pragma mark - method implementation 将信息转换为Data ，用于发送

//	P2D_SERVER_INFO  0X05
+ (NSData *)getP2dMsg05:(unsigned char[6])password {
  p2dMsg05 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x5;
  msg.header.msgDir = 0xAD;
  msg.header.msgLength = htons(sizeof(msg));

  char *ipadd = "";
  struct hostent *h = gethostbyname([SERVER_IP UTF8String]);
  if (h != NULL) {
    ipadd = inet_ntoa(*((struct in_addr *)h->h_addr_list[0]));
  }
  Byte *bytes = [CC3xMessageUtil
      ip2HexBytes:[NSString stringWithCString:ipadd
                                     encoding:NSUTF8StringEncoding]];

  memcpy(msg.ip, bytes, sizeof(msg.ip));
  free(bytes);
  msg.port = htons(SERVER_PORT);

  const char *defaultSwitchName = [DEFAULT_SWITCH_NAME UTF8String];
  memset(msg.deviceName, 0, 32);
  memcpy(msg.deviceName, defaultSwitchName, strlen(defaultSwitchName));
  // socket info
  msg.count = 2;
  socketInfo *socket1 = (socketInfo *)malloc(sizeof(socketInfo));
  memset(socket1, 0, sizeof(socketInfo));
  const char *defaultSocket1Name = [DEFAULT_SOCKET1_NAME UTF8String];
  memcpy(socket1, defaultSocket1Name, strlen(defaultSocket1Name));

  socketInfo *socket2 = (socketInfo *)malloc(sizeof(socketInfo));
  memset(socket2, 0, sizeof(socketInfo));
  const char *defaultSocket2Name = [DEFAULT_SOCKET2_NAME UTF8String];
  memcpy(socket2, defaultSocket2Name, strlen(defaultSocket2Name));
  memcpy(&msg.socketName[0], socket1, sizeof(socketInfo));
  memcpy(&msg.socketName[1], socket2, sizeof(socketInfo));
  free(socket1);
  free(socket2);
  memcpy(msg.password, password, sizeof(msg.password));
  msg.header.msgLength = htons(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2D_SCAN_DEV_REQ	0X09
+ (NSData *)getP2dMsg09 {
  p2dMsg09 msg;
  memset(&msg, 0, sizeof(msgHeader));
  msg.header.msgId = 0x9;
  msg.header.msgDir = 0xAD;
  msg.header.msgLength = htons(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2D_STATE_INQUIRY	0X0B
+ (NSData *)getP2dMsg0B {
  p2dMsg0B msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0xB;
  msg.header.msgDir = 0xAD;
  msg.header.msgLength = htons(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2S_STATE_INQUIRY	0X0D
+ (NSData *)getP2SMsg0D:(NSString *)mac password:(NSString *)password {
  p2sMsg0D msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0xD;
  msg.header.msgDir = 0xA5;
  msg.header.msgLength = htons(sizeof(msg));
  Byte *macBytes = [CC3xMessageUtil mac2HexBytes:mac];
  memcpy(msg.mac, macBytes, sizeof(msg.mac));
  free(macBytes);
  Byte *passwordBytes = [CC3xMessageUtil mac2HexBytes:password];
  memcpy(msg.password, passwordBytes, sizeof(msg.password));
  free(passwordBytes);
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2D_CONTROL_REQ	0X11
+ (NSData *)getP2dMsg11:(BOOL)on
          socketGroupId:(int)socketGroupId
               password:(NSString *)password {
  p2dMsg11 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x11;
  msg.header.msgDir = 0xAD;
  msg.socketGroupId = socketGroupId;
  msg.on = on;
  msg.header.msgLength = htons(sizeof(msg));
  Byte *passwordBytes = [CC3xMessageUtil mac2HexBytes:password];
  memcpy(msg.password, passwordBytes, sizeof(msg.password));
  free(passwordBytes);
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2S_CONTROL_REQ	0X13
+ (NSData *)getP2sMsg13:(NSString *)mac
                aSwitch:(BOOL)on
          socketGroupId:(int)socketGroupId
               password:(NSString *)password {
  p2sMsg13 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x13;
  msg.header.msgDir = 0xA5;
  Byte *macBytes = [CC3xMessageUtil mac2HexBytes:mac];
  memcpy(&msg.mac, macBytes, sizeof(msg.mac));
  free(macBytes);
  msg.on = on;
  msg.socketGroupId = socketGroupId;
  msg.header.msgLength = htons(sizeof(msg));
  Byte *passwordBytes = [CC3xMessageUtil mac2HexBytes:password];
  memcpy(msg.password, passwordBytes, sizeof(msg.password));
  free(passwordBytes);
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2D_GET_TIMER_REQ	0X17
+ (NSData *)getP2dMsg17:(int)socketGroupId {
  p2dMsg17 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x17;
  msg.header.msgDir = 0xAD;
  msg.header.msgLength = htons(sizeof(msg));
  msg.socketGroupId = socketGroupId;
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2S_GET_TIMER_REQ	0X19
+ (NSData *)getP2SMsg19:(NSString *)mac socketGroupId:(int)socketGroupId {
  p2sMsg19 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgLength = htons(sizeof(msg));
  msg.header.msgId = 0x19;
  msg.header.msgDir = 0xA5;
  Byte *macBytes = [CC3xMessageUtil mac2HexBytes:mac];
  memcpy(msg.mac, macBytes, sizeof(msg.mac));
  free(macBytes);
  msg.socketGroupId = socketGroupId;
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2D_SET_TIMER_REQ	0X1D
+ (NSData *)getP2dMsg1D:(NSUInteger)currentTime
               password:(NSString *)password
          socketGroupId:(int)socketGroupId
              timerList:(NSArray *)timerList {
  p2dMsg1D msg;
  memset(&msg, 0, sizeof(msg));
  unsigned short size = sizeof(msg) + sizeof(timerTask) * timerList.count;
  msg.header.msgLength = htons(size);
  msg.header.msgId = 0x1D;
  msg.header.msgDir = 0xAD;
  msg.socketGroupId = socketGroupId;
  Byte *passwordBytes = [CC3xMessageUtil mac2HexBytes:password];
  memcpy(msg.password, passwordBytes, sizeof(msg.password));
  free(passwordBytes);
  msg.currentTime = htonl(currentTime);
  msg.timerNumber = timerList.count;
  NSData *data1 = [NSData dataWithBytes:&msg length:sizeof(msg) - 2];

  timerTask tasks[timerList.count];
  for (int i = 0; i < timerList.count; i++) {
    SDZGTimerTask *task = [timerList objectAtIndex:i];
    timerTask timerTask;
    memset(&timerTask, 0, sizeof(timerTask));
    timerTask.week = task.week;
    timerTask.actionTime = htonl(task.actionTime);
    timerTask.takeEffect = task.isEffective;
    timerTask.actionType = task.timerActionType;
    tasks[i] = timerTask;
  }
  NSData *data2 = [NSData dataWithBytes:&tasks length:sizeof(tasks)];
  NSMutableData *data = [[NSMutableData alloc] init];
  [data appendData:data1];
  [data appendData:data2];
  unsigned short crc =
      htons(CRC16((unsigned char *)[data bytes], [data length]));
  [data appendData:[NSData dataWithBytes:&crc length:2]];
  return data;
}
// P2S_SET_TIMER_REQ	0X1F
+ (NSData *)getP2SMsg1F:(NSUInteger)currentTime
               password:(NSString *)password
          socketGroupId:(int)socketGroupId
              timerList:(NSArray *)timerList
                    mac:(NSString *)mac {
  p2sMsg1F msg;
  memset(&msg, 0, sizeof(msg));
  unsigned short size = sizeof(msg) + sizeof(timerTask) * timerList.count;
  msg.header.msgLength = htons(size);
  msg.header.msgId = 0x1F;
  msg.header.msgDir = 0xA5;
  Byte *macBytes = [CC3xMessageUtil mac2HexBytes:mac];
  memcpy(&msg.mac, macBytes, sizeof(msg.mac));
  free(macBytes);
  msg.socketGroupId = socketGroupId;
  Byte *passwordBytes = [CC3xMessageUtil mac2HexBytes:password];
  memcpy(msg.password, passwordBytes, sizeof(msg.password));
  free(passwordBytes);
  msg.currentTime = htonl(currentTime);
  msg.timerNumber = timerList.count;
  NSData *data1 = [NSData dataWithBytes:&msg length:sizeof(msg) - 2];

  timerTask tasks[timerList.count];
  for (int i = 0; i < timerList.count; i++) {
    SDZGTimerTask *task = [timerList objectAtIndex:i];
    timerTask timerTask;
    memset(&timerTask, 0, sizeof(timerTask));
    timerTask.week = task.week;
    timerTask.actionTime = htonl(task.actionTime);
    timerTask.takeEffect = task.isEffective;
    timerTask.actionType = task.timerActionType;
    tasks[i] = timerTask;
  }
  NSData *data2 = [NSData dataWithBytes:&tasks length:sizeof(tasks)];
  NSMutableData *data = [[NSMutableData alloc] init];
  [data appendData:data1];
  [data appendData:data2];
  unsigned short crc = CRC16((unsigned char *)[data bytes], [data length]);
  [data appendData:[NSData dataWithBytes:&crc length:2]];
  return data;
}

// P2D_GET_PROPERTY_REQ	0X25
+ (NSData *)getP2dMsg25 {
  p2dMsg25 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x25;
  msg.header.msgDir = 0xAD;
  msg.header.msgLength = htons(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2S_GET_PROPERTY_REQ	0X27
+ (NSData *)getP2SMsg27:(NSString *)mac {
  p2sMsg27 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x27;
  msg.header.msgDir = 0xA5;
  Byte *macBytes = [CC3xMessageUtil mac2HexBytes:mac];
  memcpy(msg.mac, macBytes, sizeof(msg.mac));
  free(macBytes);
  msg.header.msgLength = htons(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2D_GET_POWER_INFO_REQ 	0X33
+ (NSData *)getP2DMsg33 {
  p2dMsg33 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x33;
  msg.header.msgDir = 0xAD;
  msg.header.msgLength = htons(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2S_GET_POWER_INFO_REQ	 0X35
+ (NSData *)getP2SMsg35:(NSString *)mac {
  p2sMsg35 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x35;
  msg.header.msgDir = 0xA5;
  Byte *macBytes = [CC3xMessageUtil mac2HexBytes:mac];
  memcpy(msg.mac, macBytes, sizeof(msg.mac));
  free(macBytes);
  msg.header.msgLength = htons(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2S_LOCATE_REQ 0x39
+ (NSData *)getP2dMsg39:(BOOL)on {
  p2dMsg39 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x39;
  msg.header.msgDir = 0xAD;
  msg.on = on;
  msg.header.msgLength = htons(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2S_LOCATE_REQ 0x3b
+ (NSData *)getP2SMsg3B:(NSString *)mac on:(BOOL)on {
  p2sMsg3B msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x3b;
  msg.header.msgDir = 0xA5;
  Byte *macBytes = [CC3xMessageUtil mac2HexBytes:mac];
  memcpy(&msg.mac, macBytes, sizeof(msg.mac));
  msg.on = on;
  free(macBytes);
  msg.header.msgLength = htons(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2D_SET_NAME_REQ 0x3f
+ (NSData *)getP2dMsg3F:(NSString *)name
                   type:(int)type
               password:(NSString *)password {
  p2dMsg3F msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x3f;
  msg.header.msgDir = 0xAD;
  NSData *nameData = [name dataUsingEncoding:NSUTF8StringEncoding];
  memcpy(&msg.name, [nameData bytes], [nameData length]);
  msg.type = type;
  Byte *passwordBytes = [CC3xMessageUtil mac2HexBytes:password];
  memcpy(msg.password, passwordBytes, sizeof(msg.password));
  free(passwordBytes);
  msg.header.msgLength = htons(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2S_SET_NAME_REQ 0x41
+ (NSData *)getP2sMsg41:(NSString *)mac
                   name:(NSString *)name
                   type:(int)type
               password:(NSString *)password {
  p2sMsg41 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x41;
  msg.header.msgDir = 0xA5;
  Byte *macBytes = [CC3xMessageUtil mac2HexBytes:mac];
  memcpy(&msg.mac, macBytes, sizeof(msg.mac));
  free(macBytes);
  NSData *nameData = [name dataUsingEncoding:NSUTF8StringEncoding];
  memcpy(&msg.name, [nameData bytes], [nameData length]);
  Byte *passwordBytes = [CC3xMessageUtil mac2HexBytes:password];
  memcpy(msg.password, passwordBytes, sizeof(msg.password));
  free(passwordBytes);
  msg.type = type;
  msg.header.msgLength = htons(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2D_DEV_LOCK_REQ	 0X47
+ (NSData *)getP2dMsg47:(BOOL)isLock password:(NSString *)password {
  p2dMsg47 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x47;
  msg.header.msgDir = 0xAD;
  msg.lock = isLock;
  Byte *passwordBytes = [CC3xMessageUtil mac2HexBytes:password];
  memcpy(msg.password, passwordBytes, sizeof(msg.password));
  free(passwordBytes);
  msg.header.msgLength = htons(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2S_DEV_LOCK_REQ 	0X49
+ (NSData *)getP2sMsg49:(NSString *)mac
                   lock:(BOOL)isLock
               password:(NSString *)password {
  p2sMsg49 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x49;
  msg.header.msgDir = 0xA5;
  Byte *macBytes = [CC3xMessageUtil mac2HexBytes:mac];
  memcpy(&msg.mac, macBytes, sizeof(msg.mac));
  free(macBytes);
  msg.lock = isLock;
  Byte *passwordBytes = [CC3xMessageUtil mac2HexBytes:password];
  memcpy(msg.password, passwordBytes, sizeof(msg.password));
  free(passwordBytes);
  msg.header.msgLength = htons(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2D_SET_DELAY_REQ 0x4D
+ (NSData *)getP2dMsg4D:(NSInteger)delay
                     on:(BOOL)on
          socketGroupId:(int)socketGroupId
               password:(NSString *)password {
  p2dMsg4D msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x4D;
  msg.header.msgDir = 0xAD;
  msg.header.msgLength = htons(sizeof(msg));
  msg.delay = htonl(delay * 60);
  msg.socketGroupId = socketGroupId;
  msg.on = on;
  Byte *passwordBytes = [CC3xMessageUtil mac2HexBytes:password];
  memcpy(msg.password, passwordBytes, sizeof(msg.password));
  free(passwordBytes);
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2S_SET_DELAY_REQ 0x4F
+ (NSData *)getP2SMsg4F:(NSString *)mac
                  delay:(NSInteger)delay
                     on:(BOOL)on
          socketGroupId:(int)socketGroupId
               password:(NSString *)password {
  p2sMsg4F msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x4F;
  msg.header.msgDir = 0xA5;
  msg.header.msgLength = htons(sizeof(msg));
  Byte *macBytes = [CC3xMessageUtil mac2HexBytes:mac];
  memcpy(&msg.mac, macBytes, sizeof(msg.mac));
  free(macBytes);
  msg.delay = htonl(delay * 60);
  msg.socketGroupId = socketGroupId;
  msg.on = on;
  Byte *passwordBytes = [CC3xMessageUtil mac2HexBytes:password];
  memcpy(msg.password, passwordBytes, sizeof(msg.password));
  free(passwordBytes);
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2D_GET_DELAY_REQ 0x53
+ (NSData *)getP2dMsg53:(int)socketGroupId {
  p2dMsg53 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x53;
  msg.header.msgDir = 0xAD;
  msg.header.msgLength = htons(sizeof(msg));
  msg.socketGroupId = socketGroupId;
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2S_GET_DELAY_REQ 0x55
+ (NSData *)getP2SMsg55:(NSString *)mac socketGroupId:(int)socketGroupId {
  p2sMsg55 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x55;
  msg.header.msgDir = 0xA5;
  msg.header.msgLength = htons(sizeof(msg));
  Byte *macBytes = [CC3xMessageUtil mac2HexBytes:mac];
  memcpy(&msg.mac, macBytes, sizeof(msg.mac));
  free(macBytes);
  msg.socketGroupId = socketGroupId;
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2S_PHONE_INIT_REQ 0x59
+ (NSData *)getP2SMsg59:(NSString *)mac {
  p2sMsg59 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x59;
  msg.header.msgDir = 0xA5;
  msg.header.msgLength = htons(sizeof(msg));
  Byte *macBytes = [CC3xMessageUtil mac2HexBytes:mac];
  memcpy(&msg.mac, macBytes, sizeof(msg.mac));
  free(macBytes);
  const char *name = [[[UIDevice currentDevice] name] UTF8String];
  const char *systemName =
      [[[UIDevice currentDevice] systemVersion] UTF8String];
  if (sizeof(name) > 20) {
    memcpy(msg.phoneType, name, 20);
  } else {
    strcpy(msg.phoneType, name);
  }
  if (sizeof(systemName) > 20) {
    memcpy(msg.systemName, systemName, 20);
  } else {
    strcpy(msg.systemName, systemName);
  }
  strcpy(msg.appVersion, "2.0");
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2D_GET_NAME_REQ	0X5D
+ (NSData *)getP2DMsg5D {
  p2dMsg5D msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x5D;
  msg.header.msgDir = 0xAD;
  msg.header.msgLength = htons(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

// P2S_GET_NAME_REQ 	0X5F
+ (NSData *)getP2SMsg5F:(NSString *)mac {
  p2sMsg5F msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x5F;
  msg.header.msgDir = 0xA5;
  msg.header.msgLength = htons(sizeof(msg));
  Byte *macBytes = [CC3xMessageUtil mac2HexBytes:mac];
  memcpy(&msg.mac, macBytes, sizeof(msg.mac));
  free(macBytes);
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

+ (NSData *)getP2SMsg63:(NSString *)mac
              beginTime:(int)beginTime
                endTime:(int)endTime
               interval:(int)interval {
  p2sMsg63 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x63;
  msg.header.msgDir = 0xA5;
  msg.header.msgLength = htons(sizeof(msg));
  Byte *macBytes = [CC3xMessageUtil mac2HexBytes:mac];
  memcpy(&msg.mac, macBytes, sizeof(msg.mac));
  free(macBytes);
  msg.beginTime = htonl(beginTime);
  msg.endTime = htonl(endTime);
  msg.interval = htonl(interval);
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

+ (NSData *)getP2SMsg65:(NSString *)mac type:(int)type {
  p2sMsg65 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x65;
  msg.header.msgDir = 0xA5;
  msg.header.msgLength = htons(sizeof(msg));
  Byte *macBytes = [CC3xMessageUtil mac2HexBytes:mac];
  memcpy(&msg.mac, macBytes, sizeof(msg.mac));
  free(macBytes);
  msg.type = type;
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

+ (NSData *)getP2SMsg67:(NSString *)mac
                   type:(int)type
               cityName:(NSString *)cityName {
  return nil;
}
+ (NSData *)getP2DMsg69:(NSString *)oldPassword
            newPassword:(NSString *)newPassword {
  return nil;
}

+ (NSData *)getP2DMsg6B:(short)alertUnder
           isAlertUnder:(BOOL)isAlertUnder
           alertGreater:(short)alertGreater
         isAlertGreater:(BOOL)isAlertGreater
           turnOffUnder:(short)turnOffUnder
         isTurnOffUnder:(BOOL)isTurnOffUnder
         turnOffGreater:(short)turnOffGreater
       isTurnOffGreater:(BOOL)isTurnOffGreater {
  p2dMSg6B msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x6B;
  msg.header.msgDir = 0xAD;
  msg.header.msgLength = htons(sizeof(msg));
  float alertUnderValue;
  if (isAlertUnder) {
    alertUnderValue = alertUnder | (1 << 15);
  } else {
    alertUnderValue = alertUnder | (0 << 15);
  }
  msg.alertUnder = htons(alertUnderValue);
  float alertGreaterValue;
  if (isAlertGreater) {
    alertGreaterValue = alertGreater | (1 << 15);
  } else {
    alertGreaterValue = alertGreater | (0 << 15);
  }
  msg.alertGreater = htons(alertGreaterValue);
  float turnOffUnderValue;
  if (isTurnOffUnder) {
    turnOffUnderValue = turnOffUnder | (1 << 15);
  } else {
    turnOffUnderValue = turnOffUnder | (0 << 15);
  }
  msg.turnOffUnder = htons(turnOffUnderValue);
  float turnOffGreaterValue;
  if (isTurnOffGreater) {
    turnOffGreaterValue = turnOffGreater | (1 << 15);
  } else {
    turnOffGreaterValue = turnOffGreater | (0 << 15);
  }
  msg.turnOffGreater = htons(turnOffGreaterValue);
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

+ (NSData *)getP2SMsg6D:(NSString *)mac
             alertUnder:(short)alertUnder
           isAlertUnder:(BOOL)isAlertUnder
           alertGreater:(short)alertGreater
         isAlertGreater:(BOOL)isAlertGreater
           turnOffUnder:(short)turnOffUnder
         isTurnOffUnder:(BOOL)isTurnOffUnder
         turnOffGreater:(short)turnOffGreater
       isTurnOffGreater:(BOOL)isTurnOffGreater {
  p2sMsg6D msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x6D;
  msg.header.msgDir = 0xA5;
  msg.header.msgLength = htons(sizeof(msg));
  Byte *macBytes = [CC3xMessageUtil mac2HexBytes:mac];
  memcpy(&msg.mac, macBytes, sizeof(msg.mac));
  free(macBytes);
  float alertUnderValue;
  if (isAlertUnder) {
    alertUnderValue = alertUnder | (1 << 15);
  } else {
    alertUnderValue = alertUnder | (0 << 15);
  }
  msg.alertUnder = htons(alertUnderValue);
  float alertGreaterValue;
  if (isAlertGreater) {
    alertGreaterValue = alertGreater | (1 << 15);
  } else {
    alertGreaterValue = alertGreater | (0 << 15);
  }
  msg.alertGreater = htons(alertGreaterValue);
  float turnOffUnderValue;
  if (isTurnOffUnder) {
    turnOffUnderValue = turnOffUnder | (1 << 15);
  } else {
    turnOffUnderValue = turnOffUnder | (0 << 15);
  }
  msg.turnOffUnder = htons(turnOffUnderValue);
  float turnOffGreaterValue;
  if (isTurnOffGreater) {
    turnOffGreaterValue = turnOffGreater | (1 << 15);
  } else {
    turnOffGreaterValue = turnOffGreater | (0 << 15);
  }
  msg.turnOffGreater = htons(turnOffGreaterValue);
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

+ (NSData *)getP2DMsg71 {
  p2dMsg71 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x71;
  msg.header.msgDir = 0xAD;
  msg.header.msgLength = htons(sizeof(msg));
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

+ (NSData *)getP2SMsg73:(NSString *)mac {
  p2sMsg73 msg;
  memset(&msg, 0, sizeof(msg));
  msg.header.msgId = 0x73;
  msg.header.msgDir = 0xA5;
  msg.header.msgLength = htons(sizeof(msg));
  Byte *macBytes = [CC3xMessageUtil mac2HexBytes:mac];
  memcpy(&msg.mac, macBytes, sizeof(msg.mac));
  free(macBytes);
  msg.crc = CRC16((unsigned char *)&msg, sizeof(msg) - 2);
  return B2D(msg);
}

#pragma mark - response message 解析收到的data数据，转为其他数据类型

+ (CC3xMessage *)parseD2P02:(NSData *)aData {
  CC3xMessage *message = nil;
  d2pMsg02 msg;
  [aData getBytes:&msg length:sizeof(d2pMsg02)];
  message = [[CC3xMessage alloc] init];
  message.msgId = msg.header.msgId;
  message.msgDir = msg.header.msgDir;
  message.mac = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                           msg.mac[0], msg.mac[1], msg.mac[2],
                                           msg.mac[3], msg.mac[4], msg.mac[5]];

  message.ip = [NSString stringWithFormat:@"%d.%d.%d.%d", msg.ip[0], msg.ip[1],
                                          msg.ip[2], msg.ip[3]];
  message.port = ntohs(msg.port);
  message.crc = msg.crc;

  return message;
}

+ (CC3xMessage *)parseD2P06:(NSData *)aData {
  CC3xMessage *message = nil;
  d2pMsg06 msg;
  [aData getBytes:&msg length:sizeof(msg)];

  message = [[CC3xMessage alloc] init];
  message.msgId = msg.header.msgId;
  message.msgDir = msg.header.msgDir;
  message.mac = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                           msg.mac[0], msg.mac[1], msg.mac[2],
                                           msg.mac[3], msg.mac[4], msg.mac[5]];
  message.state = msg.state;
  message.crc = msg.crc;
  return message;
}

+ (CC3xMessage *)parseD2P0A:(NSData *)aData {
  CC3xMessage *message = nil;
  d2pMsg0A msg;
  [aData getBytes:&msg length:sizeof(msg)];
  message = [[CC3xMessage alloc] init];
  message.msgId = msg.header.msgId;
  message.msgDir = msg.header.msgDir;
  message.mac = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                           msg.mac[0], msg.mac[1], msg.mac[2],
                                           msg.mac[3], msg.mac[4], msg.mac[5]];

  message.ip = [NSString stringWithFormat:@"%d.%d.%d.%d", msg.ip[0], msg.ip[1],
                                          msg.ip[2], msg.ip[3]];
  message.port = ntohs(msg.port);

  message.deviceName = [[NSString alloc] initWithBytes:msg.deviceName
                                                length:strlen(msg.deviceName)
                                              encoding:NSUTF8StringEncoding];
  message.version = msg.FWVersion;
  message.lockStatus = msg.isLocked;
  message.password = [NSString
      stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", msg.password[0],
                       msg.password[1], msg.password[2], msg.password[3],
                       msg.password[4], msg.password[5]];
  message.crc = msg.crc;
  return message;
}

+ (CC3xMessage *)parseD2P0C:(NSData *)aData {
  CC3xMessage *message = nil;
  d2pMsg0C msg;
  [aData getBytes:&msg length:sizeof(msg)];
  message = [[CC3xMessage alloc] init];
  message.msgId = msg.header.msgId;
  message.msgDir = msg.header.msgDir;
  message.state = msg.state;
  message.mac = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                           msg.mac[0], msg.mac[1], msg.mac[2],
                                           msg.mac[3], msg.mac[4], msg.mac[5]];
  message.ip = [NSString stringWithFormat:@"%d.%d.%d.%d", msg.ip[0], msg.ip[1],
                                          msg.ip[2], msg.ip[3]];
  message.port = ntohs(msg.port);
  NSString *deviceName = [[NSString alloc] initWithBytes:msg.deviceName
                                                  length:strlen(msg.deviceName)
                                                encoding:NSUTF8StringEncoding];
  message.deviceName = deviceName;
  message.version = msg.FWVersion;
  message.lockStatus = msg.deviceLockState;
  message.onStatus = msg.onOffState;
  message.password = [NSString
      stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", msg.password[0],
                       msg.password[1], msg.password[2], msg.password[3],
                       msg.password[4], msg.password[5]];
  message.crc = msg.crc;
  return message;
}

+ (CC3xMessage *)parseS2P0E:(NSData *)aData {
  CC3xMessage *message = nil;
  d2pMsg0C msg;
  [aData getBytes:&msg length:sizeof(msg)];
  message = [[CC3xMessage alloc] init];
  message.msgId = msg.header.msgId;
  message.msgDir = msg.header.msgDir;
  message.state = msg.state;
  message.mac = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                           msg.mac[0], msg.mac[1], msg.mac[2],
                                           msg.mac[3], msg.mac[4], msg.mac[5]];
  message.ip = [NSString stringWithFormat:@"%d.%d.%d.%d", msg.ip[0], msg.ip[1],
                                          msg.ip[2], msg.ip[3]];
  message.port = ntohs(msg.port);
  //  DDLogDebug(@"#########port is %d", msg.port);
  //  DDLogDebug(@"*********port is %d", message.port);
  NSString *deviceName = [[NSString alloc] initWithBytes:msg.deviceName
                                                  length:strlen(msg.deviceName)
                                                encoding:NSUTF8StringEncoding];
  message.deviceName = deviceName;
  message.version = msg.FWVersion;
  message.lockStatus = msg.deviceLockState;
  message.onStatus = msg.onOffState;
  message.crc = msg.crc;
  return message;
}

+ (CC3xMessage *)parseD2P12:(NSData *)aData {
  CC3xMessage *message = nil;
  d2pMsg12 msg;
  [aData getBytes:&msg length:sizeof(msg)];

  message = [[CC3xMessage alloc] init];
  message.msgId = msg.header.msgId;
  message.msgDir = msg.header.msgDir;
  message.mac = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                           msg.mac[0], msg.mac[1], msg.mac[2],
                                           msg.mac[3], msg.mac[4], msg.mac[5]];
  message.socketGroupId = msg.socketGroupId;
  message.state = msg.state;
  message.crc = msg.crc;
  return message;
}

+ (CC3xMessage *)parseS2P14:(NSData *)aData {
  CC3xMessage *message = [CC3xMessageUtil parseD2P12:aData];

  return message;
}

// 00 19 18 da 00 19 94 37 a2 88 02 00 00 0a 6d 01 00 00 00 e2 2c 01 01 f6 d1
+ (CC3xMessage *)parseD2P18:(NSData *)aData {
  CC3xMessage *message = nil;
  d2pMsg18 msg;
  [aData getBytes:&msg length:sizeof(msg)];
  message = [[CC3xMessage alloc] init];
  message.msgId = msg.header.msgId;
  message.msgDir = msg.header.msgDir;
  message.msgLength = msg.header.msgLength;
  message.mac = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                           msg.mac[0], msg.mac[1], msg.mac[2],
                                           msg.mac[3], msg.mac[4], msg.mac[5]];

  message.socketGroupId = msg.socketGroupId;
  message.currentTime = ntohl(msg.currentTime);
  message.timerTaskNumber = msg.count;
  if (msg.count > 0) {
    timerTask tasks[msg.count];
    [aData getBytes:&tasks
              range:NSMakeRange(sizeof(d2pMsg18) - 2,
                                sizeof(timerTask) * msg.count)];
    NSMutableArray *timers = [NSMutableArray arrayWithCapacity:msg.count];
    for (int i = 0; i < msg.count; i++) {
      timerTask task = tasks[i];
      unsigned char week = task.week;
      unsigned char effective = task.takeEffect;
      unsigned int actionTime = ntohl(task.actionTime);
      unsigned char actionType = task.actionType;
      SDZGTimerTask *sdzgTask = [[SDZGTimerTask alloc] initWithWeek:week
                                                         actionTime:actionTime
                                                        isEffective:effective
                                                    timerActionType:actionType];
      [timers addObject:sdzgTask];
    }
    message.timerTaskList = timers;
    unsigned short crc;
    [aData getBytes:&crc range:NSMakeRange(aData.length - 2, 2)];
    message.crc = ntohs(crc);
  } else {
    message.crc = msg.crc;
  }
  return message;
}

+ (CC3xMessage *)parseD2P34:(NSData *)aData {
  CC3xMessage *message = nil;
  d2pMsg34 msg;
  [aData getBytes:&msg length:sizeof(msg)];
  message = [[CC3xMessage alloc] init];
  message.msgId = msg.header.msgId;
  message.msgDir = msg.header.msgDir;
  message.msgLength = msg.header.msgLength;
  message.state = msg.state;
  if (msg.pulse == 0) {
    message.power = 0;
  } else {
    message.power = 46246.9f / ntohs(msg.pulse);
  }
  return message;
}

+ (CC3xMessage *)parseS2P36:(NSData *)aData {
  CC3xMessage *message = nil;
  s2pMsg36 msg;
  [aData getBytes:&msg length:sizeof(msg)];
  message = [[CC3xMessage alloc] init];
  message.msgId = msg.header.msgId;
  message.msgDir = msg.header.msgDir;
  message.msgLength = msg.header.msgLength;
  message.mac = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                           msg.mac[0], msg.mac[1], msg.mac[2],
                                           msg.mac[3], msg.mac[4], msg.mac[5]];
  message.state = msg.state;
  if (msg.pulse == 0) {
    message.power = 0;
  } else {
    message.power = 53035.5f / ntohs(msg.pulse);
  }
  return message;
}

+ (CC3xMessage *)parseD2P3A:(NSData *)aData {
  CC3xMessage *message = nil;
  d2pMsg3A msg;
  [aData getBytes:&msg length:sizeof(msg)];

  message = [[CC3xMessage alloc] init];
  message.msgId = msg.header.msgId;
  message.msgDir = msg.header.msgDir;
  message.mac = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                           msg.mac[0], msg.mac[1], msg.mac[2],
                                           msg.mac[3], msg.mac[4], msg.mac[5]];
  message.state = msg.state;
  message.crc = msg.crc;
  return message;
}

+ (CC3xMessage *)parseD2P54:(NSData *)aData {
  CC3xMessage *message = nil;
  d2pMsg54 msg;
  [aData getBytes:&msg length:sizeof(msg)];
  message = [[CC3xMessage alloc] init];
  message.msgId = msg.header.msgId;
  message.msgDir = msg.header.msgDir;
  message.msgLength = msg.header.msgLength;
  message.mac = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                           msg.mac[0], msg.mac[1], msg.mac[2],
                                           msg.mac[3], msg.mac[4], msg.mac[5]];
  message.socketGroupId = msg.socketGroupId;
  //高低字节互换了
  message.delay = ntohl(msg.delay);
  message.onStatus = msg.on;
  message.crc = msg.crc;
  return message;
}

+ (CC3xMessage *)parseS2P6A:(NSData *)aData {
  CC3xMessage *message = nil;
  s2pMsg5A *msg;
  [aData getBytes:&msg length:sizeof(msg)];
  message = [[CC3xMessage alloc] init];
  message.msgId = msg->header.msgId;
  message.msgDir = msg->header.msgDir;
  message.msgLength = msg->header.msgLength;
  message.update = msg->update;
  message.updateUrl =
      [NSString stringWithCString:msg->updateUrl encoding:NSUTF8StringEncoding];
  return message;
}

// 00 3d 0c da 00 00 19 94 37 a2 ca c0 a8 00 76 dd dd 53 6d 61 72 74 20 53 77 69
// 74 63 68 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 01 00
// 1a 17 fd 63 00 00 00 d0 08
+ (CC3xMessage *)parseD2P5E:(NSData *)aData {
  CC3xMessage *message = nil;
  d2pMsg5E msg;
  [aData getBytes:&msg length:sizeof(msg)];
  message = [[CC3xMessage alloc] init];
  message.msgId = msg.header.msgId;
  message.msgDir = msg.header.msgDir;
  message.msgLength = msg.header.msgLength;
  message.mac = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                           msg.mac[0], msg.mac[1], msg.mac[2],
                                           msg.mac[3], msg.mac[4], msg.mac[5]];
  message.deviceName = [[NSString alloc] initWithBytes:msg.deviceName
                                                length:sizeof(msg.deviceName)
                                              encoding:NSUTF8StringEncoding];
  NSString *socket1Name =
      [[NSString alloc] initWithBytes:msg.socket1Name
                               length:sizeof(msg.socket1Name)
                             encoding:NSUTF8StringEncoding];
  NSString *socket2Name =
      [[NSString alloc] initWithBytes:msg.socket2Name
                               length:sizeof(msg.socket1Name)
                             encoding:NSUTF8StringEncoding];
  if (socket1Name && socket2Name) {
    message.socketNames = @[ socket1Name, socket2Name ];
  }
  message.crc = msg.crc;
  return message;
}

+ (CC3xMessage *)parseS2P64:(NSData *)aData {
  CC3xMessage *message = nil;
  s2pMsg64 msg;
  [aData getBytes:&msg length:sizeof(msg)];
  message = [[CC3xMessage alloc] init];
  message.msgId = msg.header.msgId;
  message.msgDir = msg.header.msgDir;
  message.msgLength = msg.header.msgLength;
  message.mac = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                           msg.mac[0], msg.mac[1], msg.mac[2],
                                           msg.mac[3], msg.mac[4], msg.mac[5]];
  message.state = msg.state;
  message.historyElecCount = msg.count;
  if (msg.count > 0) {
    elecInfo elecInfos[msg.count];
    [aData getBytes:&elecInfos
              range:NSMakeRange(sizeof(s2pMsg64) - 2,
                                sizeof(elecInfo) * msg.count)];
    NSMutableArray *elecs = [NSMutableArray arrayWithCapacity:msg.count];
    for (int i = 0; i < msg.count; i++) {
      elecInfo elecInfo = elecInfos[i];
      int time = ntohl(elecInfo.time);
      int power = ntohl(elecInfo.power) / 100;
      HistoryElecResponse *historyInfo =
          [[HistoryElecResponse alloc] initWithTime:time power:power];
      [elecs addObject:historyInfo];
    }
    message.historyElecs = elecs;
    unsigned short crc;
    [aData getBytes:&crc range:NSMakeRange(aData.length - 2, 2)];
    message.crc = ntohs(crc);
  } else {
    message.crc = msg.crc;
  }
  return message;
}

+ (CC3xMessage *)parseD2P72:(NSData *)aData {
  CC3xMessage *message = nil;
  d2pMsg72 msg;
  [aData getBytes:&msg length:sizeof(msg)];
  message = [[CC3xMessage alloc] init];
  message.msgId = msg.header.msgId;
  message.msgDir = msg.header.msgDir;
  message.msgLength = msg.header.msgLength;
  message.mac = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                           msg.mac[0], msg.mac[1], msg.mac[2],
                                           msg.mac[3], msg.mac[4], msg.mac[5]];
  message.state = msg.state;
  short _alertUnder = ntohs(msg.alertUnder);
  message.isAlertUnderOn = (_alertUnder >> 15) & 1;
  message.alertUnder = _alertUnder & 0x7fff;
  short _alertGreater = ntohs(msg.alertGreater);
  message.isAlertGreaterOn = (_alertGreater >> 15) & 1;
  message.alertGreater = _alertGreater & 0x7fff;
  short _turnOffUnder = ntohs(msg.turnOffUnder);
  message.isTurnOffUnderOn = (_turnOffUnder >> 15) & 1;
  message.turnOffUnder = _turnOffUnder & 0x7fff;
  short _turnOffGreater = ntohs(msg.turnOffGreater);
  message.isTurnOffGreaterOn = (_turnOffGreater >> 15) & 1;
  message.turnOffGreater = _turnOffGreater & 0x7fff;
  message.crc = ntohs(msg.crc);
  return message;
}

+ (CC3xMessage *)parseMessage:(NSData *)data {
  CC3xMessage *result = nil;
  msgHeader header;
  [data getBytes:&header length:sizeof(msgHeader)];

  switch (header.msgId) {
    case 0x2:
      result = [CC3xMessageUtil parseD2P02:data];
      break;
    case 0x6:
      result = [CC3xMessageUtil parseD2P06:data];
      break;
    case 0xc:
      result = [CC3xMessageUtil parseD2P0C:data];
      break;
    case 0xe:
      result = [CC3xMessageUtil parseS2P0E:data];
      break;
    case 0xa:
      result = [CC3xMessageUtil parseD2P0A:data];
      break;
    case 0x18:
    case 0x1a:
      result = [CC3xMessageUtil parseD2P18:data];
      break;
    case 0x12:
    case 0x14:
    case 0x1e:
    case 0x20:
    case 0x26:
    case 0x28:
    case 0x40:
    case 0x42:
    case 0x4e:
    case 0x50:
      result = [CC3xMessageUtil parseD2P12:data];
      break;
    case 0x3a:
    case 0x3c:
    case 0x48:
    case 0x4a:
    case 0x6c:
    case 0x6e:
      result = [CC3xMessageUtil parseD2P3A:data];
      break;
    case 0x54:
    case 0x56:
      result = [CC3xMessageUtil parseD2P54:data];
      break;
    case 0x6A:
      result = [CC3xMessageUtil parseS2P6A:data];
      break;
    case 0x34:
      result = [CC3xMessageUtil parseD2P34:data];
      break;
    case 0x36:
      result = [CC3xMessageUtil parseS2P36:data];
      break;
    case 0x5e:
    case 0x60:
      result = [CC3xMessageUtil parseD2P5E:data];
      break;
    case 0x64:
      result = [CC3xMessageUtil parseS2P64:data];
      break;
    case 0x72:
    case 0x74:
      result = [CC3xMessageUtil parseD2P72:data];
      break;
    default:
      break;
  }
  // TODO:本地crc对服务器报文进行校验
  //    unsigned short crc = [data CRC16];
  //    if (crc == result.crc)
  //    {
  //        return result;
  //    } else
  //    {
  //        dispatch_async(dispatch_get_main_queue(), ^{
  //            UIAlertView *alertView =
  //            [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",
  //            nil)
  //                                       message:NSLocalizedString(@"Message
  //                                       error, please try again", nil)
  //                                      delegate:nil
  //                             cancelButtonTitle:NSLocalizedString(@"OK", nil)
  //                             otherButtonTitles:nil, nil];
  //            [alertView show];
  //            [alertView release];
  //        });
  //        return nil;
  //    }

  return result;
}

#pragma mark - util method 数据转换方法

+ (NSData *)string2Data:(NSString *)aString {
  return [aString dataUsingEncoding:NSUTF8StringEncoding];
}

+ (Byte *)mac2HexBytes:(NSString *)mac {
  NSArray *macArray = [mac componentsSeparatedByString:@":"];
  Byte *bytes = malloc(macArray.count);
  char byte_char[3] = { '\0', '\0', '\0' };
  for (int i = 0; i < macArray.count; i++) {
    NSString *str = macArray[i];
    byte_char[0] = [str characterAtIndex:0];
    byte_char[1] = [str characterAtIndex:1];
    bytes[i] = strtol(byte_char, NULL, 16);
  }
  return bytes;
}

+ (Byte *)ip2HexBytes:(NSString *)ip {
  NSArray *ipArray = [ip componentsSeparatedByString:@"."];
  Byte *bytes = malloc(ipArray.count);
  for (int i = 0; i < ipArray.count; i++) {
    NSString *item = ipArray[i];
    bytes[i] = (unsigned long)[item integerValue];
  }
  return bytes;
}

+ (NSString *)hexString2Ip:(NSString *)string {
  NSMutableString *res = [NSMutableString string];
  for (int i = 0; i < string.length; i += 2) {
    unsigned int value;
    NSRange range = NSMakeRange(i, 2);
    NSString *s1 = [string substringWithRange:range];
    NSScanner *pScaner = [NSScanner scannerWithString:s1];
    [pScaner scanHexInt:&value];
    NSString *s2 = [NSString stringWithFormat:@"%d", value];
    [res appendString:s2];
    if (i < string.length - 2) {
      [res appendString:@"."];
    }
  }

  return res;
}

+ (NSString *)data2Ip:(NSData *)data {
  NSString *str =
      [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  return [CC3xMessageUtil hexString2Ip:str];
}

+ (NSData *)hexString2Data:(NSString *)hexString {
  int j = 0;
  Byte bytes[128];
  for (int i = 0; i < [hexString length]; i++) {
    int int_ch;

    unichar hex_char1 = [hexString characterAtIndex:i];
    int int_ch1;
    if (hex_char1 >= '0' && hex_char1 <= '9')
      int_ch1 = (hex_char1 - '0') * 16;
    else if (hex_char1 >= 'A' && hex_char1 <= 'F')
      int_ch1 = (hex_char1 - 'A') * 16;
    else
      int_ch1 = (hex_char1 - 'a') * 16;
    i++;

    unichar hex_char2 = [hexString characterAtIndex:i];
    int int_ch2;
    if (hex_char2 >= '0' && hex_char2 <= '9')
      int_ch2 = (hex_char2 - 48);
    else if (hex_char1 >= 'A' && hex_char1 <= 'F')
      int_ch2 = hex_char2 - 'A';
    else
      int_ch2 = hex_char2 - 'a';

    int_ch = int_ch1 + int_ch2;
    DDLogDebug(@"int_ch=%d", int_ch);
    bytes[j] = int_ch;
    j++;
  }
  NSData *newData = [[NSData alloc] initWithBytes:bytes length:128];
  DDLogDebug(@"newData=%@", newData);
  return newData;
}

+ (NSString *)hexString:(NSData *)data {
  const unsigned char *dbytes = [data bytes];
  NSMutableString *hexStr =
      [NSMutableString stringWithCapacity:[data length] * 2];
  int i;
  for (i = 0; i < [data length]; i++) {
    [hexStr appendFormat:@"%02x ", dbytes[i]];
  }
  return [NSString stringWithString:hexStr];
}

//+ (NSData *)data2HexData:(NSData *)data {
//  char buf[3];
//  buf[2] = '\0';
//  int length = data.length;
//  NSAssert(0 == length % 2,
//           @"Hex strings should have an even number of digits");
//  Byte *bytes = (Byte *)[data bytes];
//  unsigned char *newBytes = malloc(length / 2);
//  unsigned char *bp = newBytes;
//  for (CFIndex i = 0; i < length; i += 2) {
//    buf[0] = bytes[i];
//    buf[1] = bytes[i + 1];
//    char *b2 = NULL;
//    *bp++ = strtol(buf, &b2, 16);
//    NSAssert(b2 == buf + 2,
//             @"String should be all hex digits: (bad digit around %ld) ", i);
//  }
//  return
//      [NSData dataWithBytesNoCopy:newBytes length:length / 2
//      freeWhenDone:YES];
//}

@end
@implementation CC3xMessage
- (id)init {
  self = [super init];
  if (self) {
    self.state = 127;
    //    self.password = nil;
  }
  return self;
}

- (void)setAirTag:(unsigned char)airTag {
  //  self.airTag = airTag;
  switch (airTag) {
    case 1:
      self.airDesc = @"优";
      break;
    case 2:
      self.airDesc = @"良";
      break;
    case 3:
      self.airDesc = @"轻度污染";
      break;
    case 4:
      self.airDesc = @"中度污染";
      break;
    default:
      self.airDesc = @"优";
      break;
  }
}
@end
