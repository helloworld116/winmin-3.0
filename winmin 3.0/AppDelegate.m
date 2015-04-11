//
//  AppDelegate.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-15.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "AppDelegate.h"
#import "ShakeWindow.h"
#import <ShareSDK/ShareSDK.h>
//#import <TencentOpenAPI/TencentOpenSDK.h>
#import <QZoneConnection/ISSQZoneApp.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
//#import "WeiboApi.h"
#import "APService.h"
#import "APServiceUtil.h"
#import <CRToast.h>
#import <FIR/FIR.h>
#import "Scene.h"
#import "BackgroundAudioPlay.h"
#import "SwitchSyncService.h"

@interface AppDelegate ()
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundUpdateTask;
@property (nonatomic, strong) NSTimer* backgroundTimer;
@property (nonatomic, strong) NetUtil* netUtil;
@property (nonatomic, assign) int totalBackgroundSeconds;
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication*)application
    didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
  // Override point for customization after application launch.
  [self setLog];
  self.currnetLanguage = [self getPreferredLanguage];
  self.networkStatus = ReachableViaWiFi; //这里必不可少,必须在view展现前执行
  self.netUtil = [NetUtil sharedInstance];
  //  DDLogDebug(@"ip is %@",
  //           [self.netUtil getIPWithHostName:@"server.itouchco.com"]);
  [self.netUtil addNetWorkChangeNotification];
  [self checkVersion];
  [self setData];
  [self setDefaultUserSettingValue];
  [self registPlatform];
  [self registJPush:launchOptions];
  [self setStyle];
  [self registCrashLog];
  return YES;
}

- (void)applicationWillResignActive:(UIApplication*)application {
  // Sent when the application is about to move from active to
  // inactive state.
  // This can occur for certain types of temporary interruptions
  // (such
  // as an
  // incoming phone call or SMS message) or when the user quits the
  // application
  // and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and
  // throttle down
  // OpenGL ES frame rates. Games should use this method to pause
  // the
  // game.
}

- (void)applicationDidEnterBackground:(UIApplication*)application {
  // Use this method to release shared resources, save user data, invalidate
  // timers, and store enough application state information to restore your
  // application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called
  // instead of applicationWillTerminate: when the user quits.

  //  NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
  //  BOOL motionEnable = [[userDefaults objectForKey:acceleration] boolValue];
  //  int shakeId = [[userDefaults objectForKey:@"shakeId"] intValue];
  //  if (motionEnable && shakeId) {
  //    self.backgroundUpdateTask = [[UIApplication sharedApplication]
  //        beginBackgroundTaskWithExpirationHandler:nil];
  //    [[DBUtil sharedInstance]
  //        saveSwitchs:[[SwitchDataCeneter sharedInstance] switchs]];
  //    SwitchSyncService* service = [[SwitchSyncService alloc] init];
  //    [service uploadSwitchs:^(BOOL isSuccess){}];
  //    dispatch_after(
  //        dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
  //        dispatch_get_main_queue(), ^{ [self startBackgroundTimer]; });
  //  } else {
  //    self.backgroundUpdateTask = [[UIApplication sharedApplication]
  //        beginBackgroundTaskWithExpirationHandler:^{
  //            [[UIApplication sharedApplication]
  //                endBackgroundTask:self.backgroundUpdateTask];
  //            self.backgroundUpdateTask = UIBackgroundTaskInvalid;
  //        }];
  //    [[DBUtil sharedInstance]
  //        saveSwitchs:[[SwitchDataCeneter sharedInstance] switchs]];
  //    SwitchSyncService* service = [[SwitchSyncService alloc] init];
  //    [service uploadSwitchs:^(BOOL isSuccess) {
  //        [[UIApplication sharedApplication]
  //            endBackgroundTask:self.backgroundUpdateTask];
  //        self.backgroundUpdateTask = UIBackgroundTaskInvalid;
  //    }];
  //  }
  self.backgroundUpdateTask = [[UIApplication sharedApplication]
      beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication]
            endBackgroundTask:self.backgroundUpdateTask];
        self.backgroundUpdateTask = UIBackgroundTaskInvalid;
      }];
  [[DBUtil sharedInstance]
      saveSwitchs:[[SwitchDataCeneter sharedInstance] switchs]];
  SwitchSyncService* service = [[SwitchSyncService alloc] init];
  [service uploadSwitchs:^(BOOL isSuccess) {
    [[UIApplication sharedApplication]
        endBackgroundTask:self.backgroundUpdateTask];
    self.backgroundUpdateTask = UIBackgroundTaskInvalid;
  }];
}

- (void)applicationWillEnterForeground:(UIApplication*)application {
  // Called as part of the transition from
  // the background to the inactive
  // state;
  // here you can undo many of the changes
  // made on entering the background.
  //  [APService resetBadge];
  [APService setBadge:0];
  [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
  //  [self endBackgroundTimer];
  //  [self endBackgroundUpdateTask];
}

- (void)applicationDidBecomeActive:(UIApplication*)application {
  // Restart any tasks that were paused (or not yet started)
  // while the
  // application was inactive. If the application was
  // previously in
  // the
  // background, optionally refresh the user interface.
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
                   NSUserDefaults* defaults =
                       [NSUserDefaults standardUserDefaults];
                   BOOL reciveRemoteNotification =
                       [[defaults objectForKey:remoteNotification] boolValue];
                   if (reciveRemoteNotification) {
                     [APServiceUtil openRemoteNotification:^(BOOL result){
                     }];
                   } else {
                     [APServiceUtil closeRemoteNotification:^(BOOL result){
                     }];
                   }
                 });
}

- (void)applicationWillTerminate:(UIApplication*)application {
  // Called when the application is about to terminate. Save
  // data if
  // appropriate. See also applicationDidEnterBackground:.
  self.backgroundUpdateTask = [[UIApplication sharedApplication]
      beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication]
            endBackgroundTask:self.backgroundUpdateTask];
        self.backgroundUpdateTask = UIBackgroundTaskInvalid;
      }];
  [[DBUtil sharedInstance]
      saveSwitchs:[[SwitchDataCeneter sharedInstance] switchs]];
  SwitchSyncService* service = [[SwitchSyncService alloc] init];
  [service uploadSwitchs:^(BOOL isSuccess) {
    [[UIApplication sharedApplication]
        endBackgroundTask:self.backgroundUpdateTask];
    self.backgroundUpdateTask = UIBackgroundTaskInvalid;
  }];
}

- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url {
  return [ShareSDK handleOpenURL:url wxDelegate:self];
}

- (BOOL)application:(UIApplication*)application
              openURL:(NSURL*)url
    sourceApplication:(NSString*)sourceApplication
           annotation:(id)annotation {
  return [ShareSDK handleOpenURL:url
               sourceApplication:sourceApplication
                      annotation:annotation
                      wxDelegate:self];
}

- (void)application:(UIApplication*)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {

  // Required
  [APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication*)application
    didReceiveRemoteNotification:(NSDictionary*)userInfo {

  // Required
  [APService handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication*)application
    didReceiveRemoteNotification:(NSDictionary*)userInfo
          fetchCompletionHandler:
              (void (^)(UIBackgroundFetchResult))completionHandler {
  if (application.applicationState == UIApplicationStateActive) {
    int notificationType = [userInfo[@"type"] intValue];
    //断电重启提醒
    if (notificationType == 2) {
      NSString* date = userInfo[@"date"];
      NSString* mac = userInfo[@"mac"];
      SDZGSwitch* aSwtich = [self.switchDataCeneter getSwitchByMac:mac];
      if (aSwtich) {
        aSwtich.isRestart = YES;
        aSwtich.restartMsgDateStr = date;
      }
    }
    [APService setLocalNotification:[NSDate dateWithTimeIntervalSinceNow:1]
                          alertBody:[[userInfo objectForKey:@"aps"]
                                        objectForKey:@"alert"]
                              badge:-1
                        alertAction:nil
                      identifierKey:nil
                           userInfo:userInfo
                          soundName:nil];
  } else {
    // IOS 7 Support Required
    [APService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
  }
}

- (void)application:(UIApplication*)application
    didReceiveLocalNotification:(UILocalNotification*)notification {
  NSDictionary* userInfo = notification.userInfo;
  NSDictionary* options = @{
    kCRToastTextKey : [[userInfo objectForKey:@"aps"] objectForKey:@"alert"],
    kCRToastTextAlignmentKey : @(NSTextAlignmentLeft),
    kCRToastFontKey : [UIFont systemFontOfSize:16.f],
    kCRToastTimeIntervalKey : @3,
    kCRToastBackgroundColorKey : kThemeColor,
    kCRToastAnimationInTypeKey : @(CRToastAnimationTypeLinear),
    kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeLinear),
    kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
    kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop),
    kCRToastNotificationTypeKey : @(CRToastTypeNavigationBar),
    kCRToastImageKey : [UIImage imageNamed:@"notification_warning"]
  };
  [CRToastManager showNotificationWithOptions:options
                              completionBlock:^{
                              }];
}

#pragma mark -
- (void)checkVersion {
  NSString* appVersion =
      [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
  NSString* currentVersion =
      [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentVersion];
  BOOL showed = [[[NSUserDefaults standardUserDefaults]
      objectForKey:kWelcomePageShowed] boolValue];
  if (!showed || ![appVersion isEqualToString:currentVersion]) {
    UIViewController* vc = [[self.window.rootViewController storyboard]
        instantiateViewControllerWithIdentifier:@"WelcomeViewController"];
    self.window.rootViewController = vc;
  }
}

- (void)setStyle {
  [[UIApplication sharedApplication] setStatusBarHidden:NO];
  [[UIApplication sharedApplication]
      setStatusBarStyle:UIStatusBarStyleLightContent];
  [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
  [[UINavigationBar appearance] setBarTintColor:kThemeColor];
  [[UINavigationBar appearance] setTitleTextAttributes:@{
    NSFontAttributeName : [UIFont systemFontOfSize:22],
    //    UITextAttributeTextColor : [UIColor whiteColor]
    NSForegroundColorAttributeName : [UIColor whiteColor]
  }];
  [[UITabBar appearance]
      setBarTintColor:[UIColor colorWithHexString:@"#F0EFEF"]];
  [[UITabBar appearance] setSelectedImageTintColor:[UIColor whiteColor]];
  //修复在iOS7.0下选中图片设置无效的bug
  [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
}

- (void)setData {
  self.dictOfFireware = [@{} mutableCopy];
  self.switchDataCeneter = [SwitchDataCeneter sharedInstance];
  NSArray* scenes = [[[DBUtil sharedInstance] scenes] mutableCopy];
  NSInteger shakeId = [[[NSUserDefaults standardUserDefaults]
      objectForKey:@"shakeId"] integerValue];
  if (shakeId && scenes.count) {
    for (Scene* scene in scenes) {
      if (scene.indentifier == shakeId) {
        ShakeWindow* shakeWindow = (ShakeWindow*)self.window;
        [shakeWindow setShakeScene:scene];
        break;
      }
    }
  }

  //  if (self.switchDataCeneter.switchs.count) {
  //    ShakeWindow* shakeWindow = (ShakeWindow*)self.window;
  //    [shakeWindow setSwitch:[self.switchDataCeneter.switchs objectAtIndex:0]
  //                   groupId:1];
  //  }
}

- (void)setLog {
  [DDLog addLogger:[DDTTYLogger sharedInstance]];
  DDFileLogger* fileLogger = [[DDFileLogger alloc] init];
  fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
  fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
  [DDLog addLogger:fileLogger];
  // 允许颜色
  [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
  [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor whiteColor]
                                   backgroundColor:nil
                                           forFlag:DDLogFlagDebug];
  [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor orangeColor]
                                   backgroundColor:nil
                                           forFlag:DDLogFlagWarning];
  [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor redColor]
                                   backgroundColor:nil
                                           forFlag:DDLogFlagError];
}

- (void)registPlatform {
  //  [ShareSDK registerApp:@"3603417cd788"];
  [ShareSDK registerApp:@"3d3513a6d000"];

  //添加QQ空间应用  注册网址  http://connect.qq.com/intro/login/
  [ShareSDK connectQZoneWithAppKey:@"1103439550"
                         appSecret:@"PMgcuxrYBiQT69oa"
                 qqApiInterfaceCls:[QQApiInterface class]
                   tencentOAuthCls:[TencentOAuth class]];

  //添加QQ应用  注册网址  http://mobile.qq.com/api/
  [ShareSDK connectQQWithQZoneAppKey:@"1103439550"
                   qqApiInterfaceCls:[QQApiInterface class]
                     tencentOAuthCls:[TencentOAuth class]];

  //添加新浪微博应用 注册网址 http://open.weibo.com
  [ShareSDK
      connectSinaWeiboWithAppKey:@"611419555"
                       appSecret:@"ca2db85365133fcc1e7f815acd22f038"
                     redirectUri:@"http://api.weibo.com/oauth2/default.html"];
  //开启QQ空间网页授权开关
  id<ISSQZoneApp> app =
      (id<ISSQZoneApp>)[ShareSDK getClientWithType:ShareTypeQQSpace];
  [app setIsAllowWebAuthorize:YES];
  //  [ShareSDK connectMail];
  //  [ShareSDK connectSMS];
  //  [ShareSDK connectCopy];
}

- (void)registCrashLog {
  [FIR handleCrashWithKey:@"b10fea02d906508a2702b2c68cc350f5"];
}

- (void)registJPush:(NSDictionary*)launchOptions {
// Required
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
  if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
    //可以添加自定义categories
    [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                   UIUserNotificationTypeSound |
                                                   UIUserNotificationTypeAlert)
                                       categories:nil];
  } else {
    // categories 必须为nil
    [APService
        registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                            UIRemoteNotificationTypeSound |
                                            UIRemoteNotificationTypeAlert)
                                categories:nil];
  }
#else
  // categories 必须为nil
  [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                 UIRemoteNotificationTypeSound |
                                                 UIRemoteNotificationTypeAlert)
                                     categories:nil];
#endif
  // Required
  [APService setupWithOption:launchOptions];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(didReceivejPushMessage:)
             name:kJPFNetworkDidReceiveMessageNotification
           object:nil];
}

- (void)didReceivejPushMessage:(NSNotification*)notification {
  //  NSDictionary* userInfo = [notification userInfo];
  //  NSString* content = [userInfo valueForKey:@"content"];
  //  NSString* extras = [userInfo valueForKey:@"extras"];
  //  NSString* customizeField1 =
  //      [extras valueForKey:@"customizeField1"];
  //      //自定义参数，key是自己定义的
}

/**  *得到本机现在用的语言  * en:英文  zh-Hans:简体中文 zh-Hant:繁体中文
 * ja:日本  ......  */
- (NSString*)getPreferredLanguage {
  NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
  NSArray* languages = [defs objectForKey:@"AppleLanguages"];
  NSString* preferredLang = [languages objectAtIndex:0];
  return preferredLang;
}

- (void)setDefaultUserSettingValue {
  NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
  id showmac = [userDefaults objectForKey:showMac];
  id shake = [userDefaults objectForKey:keyShake];
  id warn = [userDefaults objectForKey:wwanWarn];
  id remoteNotifi = [userDefaults objectForKey:remoteNotification];
  id acceleratio = [userDefaults objectForKey:acceleration];
  if (!showmac) {
    [userDefaults setObject:@(YES) forKey:showMac];
  }
  if (!shake) {
    [userDefaults setObject:@(NO) forKey:keyShake];
  }
  if (!warn) {
    [userDefaults setObject:@(YES) forKey:wwanWarn];
  }
  if (!remoteNotifi) {
    [userDefaults setObject:@(YES) forKey:remoteNotification];
  }
  if (!acceleratio) {
    [userDefaults setObject:@(YES) forKey:acceleration];
  }
  [userDefaults synchronize];
}

#pragma mark - touch
//开始摸
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
  NSArray* subViews = [[UIApplication sharedApplication].keyWindow subviews];
  for (UIView* view in subViews) {
    if (view.tag == switchListPulldownRefreshViewTag) {
      [view removeFromSuperview];
      [[NSUserDefaults standardUserDefaults]
          setObject:@(YES)
             forKey:switchListPulldownRefresh];
    } else if (view.tag == switchListLongPressDeleteViewTag) {
      [view removeFromSuperview];
      [[NSUserDefaults standardUserDefaults]
          setObject:@(YES)
             forKey:switchListLongPressDelete];
    }
  }
}

#pragma mark - shake
- (ShakeWindow*)window {
  static ShakeWindow* shakeWindow = nil;
  if (!shakeWindow)
    shakeWindow =
        [[ShakeWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  return shakeWindow;
}

#pragma mark - 后台执行定时器
- (void)startBackgroundTimer {
  self.backgroundTimer = [NSTimer timerWithTimeInterval:60
                                                 target:self
                                               selector:@selector(tik)
                                               userInfo:nil
                                                repeats:YES];
  [self.backgroundTimer fire];
  [[NSRunLoop mainRunLoop] addTimer:self.backgroundTimer
                            forMode:NSRunLoopCommonModes];
}

- (void)endBackgroundTimer {
  if (self.backgroundTimer) {
    [self.backgroundTimer invalidate];
    self.backgroundTimer = nil;
  }
}

- (void)tik {
  DDLogDebug(@"##############后台执行%d秒##############",
             self.totalBackgroundSeconds);
  self.totalBackgroundSeconds += 60;
  NSTimeInterval leftSeconds =
      [[UIApplication sharedApplication] backgroundTimeRemaining];
  DDLogDebug(@"applicationDidEnterBackground left seconds is %f", leftSeconds);
  if ([[UIApplication sharedApplication] backgroundTimeRemaining] < 61.0) {
    [[BackgroundAudioPlay sharedInstance] playSound];
    self.backgroundUpdateTask = [[UIApplication sharedApplication]
        beginBackgroundTaskWithExpirationHandler:nil];
  }
}

- (void)endBackgroundUpdateTask {
  [[UIApplication sharedApplication]
      endBackgroundTask:self.backgroundUpdateTask];
  self.backgroundUpdateTask = UIBackgroundTaskInvalid;
}

@end
