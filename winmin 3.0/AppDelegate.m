//
//  AppDelegate.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-15.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.
  self.networkStatus = ReachableViaWiFi;
  [self setStyle];
  [self setData];
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state.
  // This can occur for certain types of temporary interruptions (such as an
  // incoming phone call or SMS message) or when the user quits the application
  // and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down
  // OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate
  // timers, and store enough application state information to restore your
  // application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called
  // instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state;
  // here you can undo many of the changes made on entering the background.
  [[SwitchDataCeneter sharedInstance] saveSwitchsToDB];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the
  // application was inactive. If the application was previously in the
  // background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if
  // appropriate. See also applicationDidEnterBackground:.
}

- (void)setStyle {
  [[UIApplication sharedApplication] setStatusBarHidden:NO];
  [[UIApplication sharedApplication]
      setStatusBarStyle:UIStatusBarStyleLightContent];
  [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
  [[UINavigationBar appearance] setBarTintColor:kThemeColor];
  [[UINavigationBar appearance]
      setTitleTextAttributes:@{
                               NSFontAttributeName :
                                   [UIFont boldSystemFontOfSize:22],
                               UITextAttributeTextColor : [UIColor whiteColor]
                             }];

  [[UITabBar appearance]
      setBarTintColor:[UIColor colorWithHexString:@"#F0EFEF"]];
  //  [[UITabBar appearance] setBarStyle:UIBarStyleDefault];
  //  [[UITabBar appearance] setSelectionIndicatorImage:[UIImage
  //  imageNamed:@""]];
  [[UITabBar appearance] setSelectedImageTintColor:[UIColor whiteColor]];
}

- (void)setData {
  self.switchDataCeneter = [SwitchDataCeneter sharedInstance];
}
@end
