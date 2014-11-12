//
//  AppDelegate.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-15.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "AppDelegate.h"
#import <ShareSDK/ShareSDK.h>
//#import <TencentOpenAPI/TencentOpenSDK.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WeiboApi.h"

@interface AppDelegate ()
@property (nonatomic, strong) NetUtil* netUtil;
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication*)application
    didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
  // Override point for customization after application launch.
  self.networkStatus = ReachableViaWiFi; //这里必不可少,必须在view展现前执行
  self.netUtil = [NetUtil sharedInstance];
  //  debugLog(@"ip is %@",
  //           [self.netUtil getIPWithHostName:@"server.itouchco.com"]);
  [self.netUtil addNetWorkChangeNotification];
  [self setStyle];
  self.currnetLanguage = [self getPreferredLanguage];
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
  [self setData];
  [self registPlatform];
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
  [[SwitchDataCeneter sharedInstance] syncSwitchs];
}

- (void)applicationWillEnterForeground:(UIApplication*)application {
  // Called as part of the transition from
  // the background to the inactive
  // state;
  // here you can undo many of the changes
  // made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication*)application {
  // Restart any tasks that were paused (or not yet started)
  // while the
  // application was inactive. If the application was
  // previously in
  // the
  // background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication*)application {
  // Called when the application is about to terminate. Save
  // data if
  // appropriate. See also applicationDidEnterBackground:.
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

- (void)setStyle {
  [[UIApplication sharedApplication] setStatusBarHidden:NO];
  [[UIApplication sharedApplication]
      setStatusBarStyle:UIStatusBarStyleLightContent];
  [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
  [[UINavigationBar appearance] setBarTintColor:kThemeColor];
  [[UINavigationBar appearance] setTitleTextAttributes:@{
    NSFontAttributeName : [UIFont systemFontOfSize:22],
    UITextAttributeTextColor : [UIColor whiteColor]
  }];

  [[UITabBar appearance]
      setBarTintColor:[UIColor colorWithHexString:@"#F0EFEF"]];
  [[UITabBar appearance] setSelectedImageTintColor:[UIColor whiteColor]];
  //修复在iOS7.0下选中图片设置无效的bug
  [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
}

- (void)setData {
  self.switchDataCeneter = [SwitchDataCeneter sharedInstance];
}

- (void)registPlatform {
  [ShareSDK registerApp:@"3603417cd788"];
  //添加QQ应用  注册网址  http://mobile.qq.com/api/
  [ShareSDK connectQQWithQZoneAppKey:@"1103439550"
                   qqApiInterfaceCls:[QQApiInterface class]
                     tencentOAuthCls:[TencentOAuth class]];

  //添加QQ空间应用  注册网址  http://connect.qq.com/intro/login/
  [ShareSDK connectQZoneWithAppKey:@"1103439550"
                         appSecret:@"PMgcuxrYBiQT69oa"
                 qqApiInterfaceCls:[QQApiInterface class]
                   tencentOAuthCls:[TencentOAuth class]];
  //
  //添加新浪微博应用 注册网址 http://open.weibo.com
  [ShareSDK
      connectSinaWeiboWithAppKey:@"611419555"
                       appSecret:@"ca2db85365133fcc1e7f815acd22f038"
                     redirectUri:@"http://api.weibo.com/oauth2/default.html"];
  //  [ShareSDK connectMail];
  //  [ShareSDK connectSMS];
  //  [ShareSDK connectCopy];
}

/**  *得到本机现在用的语言  * en:英文  zh-Hans:简体中文   zh-Hant:繁体中文
 * ja:日本  ......  */
- (NSString*)getPreferredLanguage {
  NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
  NSArray* languages = [defs objectForKey:@"AppleLanguages"];
  NSString* preferredLang = [languages objectAtIndex:0];
  return preferredLang;
}
@end
