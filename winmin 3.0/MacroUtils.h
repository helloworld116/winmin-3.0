//
//  MacroUtils.h
//  SmartSwitch
//
//  Created by 文正光 on 14-8-21.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#ifdef __OBJC__
#import <Reachability.h>
#import <GCDAsyncUdpSocket.h>
#import <MBProgressHUD.h>
#import <EGORefreshTableHeaderView.h>
#import <HexColor.h>
#import <UIView+Toast.h>
#import <AFNetworking.h>
#import <UIViewController+MJPopupViewController.h>
#import <ShareSDK/ShareSDK.h>
#import <CocoaLumberjack.h>

#import "CC3xMessage.h"
#import "SDZGSwitch.h"
#import "UdpRequest.h"
#import "PassValueDelegate.h"
#import "ViewUtil.h"
#import "FirstTimeConfig.h"
#import "SwitchDataCeneter.h"
#import "DB.h"
#import "DESUtil.h"
#import "UIImage+Color.h"
#import "NetUtil.h"
#import "UIView+NoDataView.h"
#import "AppDelegate.h"
#endif

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define STATUSBAR_HEIGHT 20
#define NAVIGATIONBAR_HEIGHT 44
#define kSharedAppliction                                                      \
  ((AppDelegate *)[UIApplication sharedApplication].delegate)

#define kCheckNetworkWebsite @"www.baidu.com"

//发送UDP内网请求后，检查是否有响应数据的间隔，单位为秒
#define kCheckPrivateResponseInterval 1.0
//发送UDP外网请求后，检查是否有响应数据的间隔，单位为秒
#define kCheckPublicResponseInterval 2.0
//请求失败后自动尝试次数
#define kTryCount 2

// UDP内网过期时间,单位秒
#define kPrivateUDPTimeOut 0.001
// UDP外网过期时间,单位秒
#define kPublicUDPTimeOut kCheckPublicResponseInterval

//日志
#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_DEBUG;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif

#define isEqualOrGreaterToiOS7                                                 \
  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define is4Inch ([[UIScreen mainScreen] bounds].size.height == 568)

#define PATH_OF_APP_HOME NSHomeDirectory()
#define PATH_OF_TEMP NSTemporaryDirectory()
#define PATH_OF_DOCUMENT                                                       \
  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,  \
                                       YES) objectAtIndex:0]
//延迟最大时间
#define kDelayMax 1440

#define DEFAULT_SWITCH_NAME NSLocalizedString(@"Smart Switch", nil)
#define DEFAULT_SOCKET1_NAME NSLocalizedString(@"Socket1", nil)
#define DEFAULT_SOCKET2_NAME NSLocalizedString(@"Socket2", nil)
#define socket_default_image @"099"
#define switch_default_image @"100"
#define switch_default_image_offline @"100_"
#define kSceneTemplateDict                                                     \
  @{                                                                           \
    @"101" : NSLocalizedString(@"Living room", nil),                           \
    @"102" : NSLocalizedString(@"Kitchen", nil),                               \
    @"103" : NSLocalizedString(@"Bedroom", nil),                               \
    @"104" : NSLocalizedString(@"Studyroom", nil),                             \
    @"105" : NSLocalizedString(@"Kids room", nil),                             \
    @"106" : NSLocalizedString(@"Vestibule", nil),                             \
  }

//在家测试
#define isHome 0
#define kThemeColor [UIColor colorWithHexString:@"#28B92E"]

//是否当前版本第一次打开
#define kWelcomePageShowed @"WelcomePageShowed"
#define kCurrentVersion @"CurrentVersion"
extern NSString *const keyShake;
extern NSString *const showMac;
extern NSString *const wwanWarn;
extern NSString *const remoteNotification;
extern NSString *const jPushTagArrayKey;
extern NSString *const acceleration;
static NSString *const switchListLongPressDelete = @"switchListLongPressDelete";
static NSString *const switchListPulldownRefresh = @"switchListPulldownRefresh";
static long switchListPulldownRefreshViewTag = 100101;
static long switchListLongPressDeleteViewTag = 100102;
//通知
#define kNoResponseNotification @"NoResponseNotification"
#define kConfigNewSwitch @"ConfigNewSwitch"
#define kNetChangedNotification @"NetChangedNotification"
#define kSceneDataChanged @"SceneDataChanged"
#define kLoginResponse @"LoginResponse"
#define kRegisterResponse @"RegisterResponse"
#define kLoginSuccess @"LoginSuccess"
#define kLoginOut @"LoginOut"
#define kSwitchOnOffStateChange @"SwitchOnOffStateChange"
#define kSwitchNameChange @"SwitchNameChange"
#define kDelayQueryNotification @"DelayQueryNotification"
#define kDelaySettingNotification @"DelaySettingNotification"
#define kHistoryElecNotification @"HistoryElecNotification"
#define kRealTimeElecNotification @"RealTimeElecNotification"
#define kSwitchDeleteSceneNotification @"SwitchDeleteSceneNotification"

#define kTimerListChanged @"TimerListChanged"
#define kTimerAddNotification @"TimerAddNotification"
#define kTimerUpdateNotification @"TimerUpdateNotification"
#define kTimerDeleteNotification @"TimerDeleteNotification"
#define kTimerEffectiveChangedNotifcation @"TimerEffectiveChangedNotifcation"

#define kSceneAddOrUpdateNotification @"SceneAddOrUpdateNotification"
#define kSceneExecuteBeginNotification @"SceneExecuteBeginNotification"
#define kSceneExecuteLeftTimeNotification @"SceneExecuteLeftTimeNotification"
#define kSceneExecuteResultNotification @"SceneExecuteResultNotification"
#define kSceneExecuteFinishedNotification @"SceneExecuteFinishedNotification"
#define kSceneFinishedWindowViewRemoveNotification                             \
  @"SceneFinishedWindowViewRemoveNotification"

#define kSendEmailResponse @"SendEmailResponse"
#define kResetPasswordResponse @"ResetPasswordResponse"
#define kNewPasswordLogin @"NewPasswordLogin"

//加密
#define __ENCRYPT(str) [DESUtil encryptString:str]
#define __DECRYPT(str) [DESUtil decryptString:str]

// json
#define __JSON(str)                                                            \
  [NSJSONSerialization                                                         \
      JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding]          \
                 options:kNilOptions                                           \
                   error:nil]

#ifdef DEBUG
//#define SERVER_IP @"183.63.35.203"
//#define SERVER_IP @"192.168.0.89"
#define SERVER_IP @"120.24.75.50"
// static NSString *const BaseURLString = @"http://192.168.0.188:8080/ais/app/";
static NSString *const BaseURLString = @"http://120.24.75.50:18080/ais/api/";
static NSString *const MessageURLString = @"http://120.24.75.50:18080/ais/app/";
#else
#define SERVER_IP @"120.24.75.50"
static NSString *const BaseURLString = @"http://120.24.75.50:18080/ais/api/";
static NSString *const MessageURLString = @"http://120.24.75.50:18080/ais/app/";
#endif
static float const kHardwareVersion = 2.0;
static int const kUdpResponseSuccessCode = 0;
static int const kUdpResponsePasswordErrorCode = 4;
// static NSString *const BaseURLString =
// @"http://183.63.35.203:18080/ais/api/";

static NSString *const AboutUsURLString = @"http://www.itouchco.com/";
typedef void (^NotReceiveDataBlock)(long tag, int socktGroupId);

#define SERVER_PORT 20002

#define APP_PORT 43690

#define DEVICE_PORT 56797

#define REFRESH_DEV_TIME 5

static float const kElecRefreshInterval = 3.f;
static float const kElecDiff = 2.7f;
static float const kElecFactor = 46246.9f;

#define BROADCAST_ADDRESS @"255.255.255.255"

#define GLOBAL_QUEUE                                                           \
  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define MAIN_QUEUE dispatch_get_main_queue()