//
//  APServiceUtil.m
//  winmin 3.0
//
//  Created by sdzg on 14-11-21.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "APServiceUtil.h"
#import "APService.h"

@interface APServiceUtil ()
@property (strong) finishCallbackBlock finishBlock;
@end

@implementation APServiceUtil

+ (void)closeRemoteNotification:(finishCallbackBlock)block {
  APServiceUtil *util = [[APServiceUtil alloc] init];
  util.finishBlock = block;
  [APService setTags:[NSSet set]
      callbackSelector:@selector(tagsAliasCallback:tags:alias:)
                object:util];
}

+ (void)openRemoteNotification:(finishCallbackBlock)block {
  APServiceUtil *util = [[APServiceUtil alloc] init];
  util.finishBlock = block;
  NSArray *switchs = [[SwitchDataCeneter sharedInstance] switchs];
  NSMutableSet *tags = [self switchsToTags:switchs];

  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSMutableArray *jPushTagArray =
      [[defaults objectForKey:jPushTagArrayKey] mutableCopy];
  NSSet *defaultTags = [NSSet setWithArray:jPushTagArray];
  if (![tags isEqualToSet:defaultTags]) {
    [APService setTags:tags
        callbackSelector:@selector(tagsAliasCallback:tags:alias:)
                  object:util];
  } else {
    DDLogDebug(@"tags未改动，无需注册");
  }
}

+ (void)removeSwitchRemoteNotification:(SDZGSwitch *)aSwitch
                           finishBlock:(finishCallbackBlock)block {
  APServiceUtil *util = [[APServiceUtil alloc] init];
  util.finishBlock = block;
  NSString *tag = [self aSwitchToTag:aSwitch];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSMutableArray *jPushTagArray =
      [[defaults objectForKey:jPushTagArrayKey] mutableCopy];
  [jPushTagArray removeObject:tag];
  NSSet *tags = [NSSet setWithArray:jPushTagArray];
  [APService setTags:tags
      callbackSelector:@selector(tagsAliasCallback:tags:alias:)
                object:util];
}

+ (NSMutableSet *)switchsToTags:(NSArray *)switchs {
  NSMutableSet *tags = [NSMutableSet setWithCapacity:switchs.count];
  for (SDZGSwitch *aSwitch in switchs) {
    NSString *tag = [self aSwitchToTag:aSwitch];
    [tags addObject:tag];
  }
  return tags;
}

+ (NSString *)aSwitchToTag:(SDZGSwitch *)aSwitch {
  NSString *mac =
      [aSwitch.mac stringByReplacingOccurrencesOfString:@":" withString:@""];
  NSString *password =
      [aSwitch.password stringByReplacingOccurrencesOfString:@":"
                                                  withString:@""];
  NSString *tag; //新老版本兼容
  if (password) {
    tag = [NSString stringWithFormat:@"%@%@", mac, password];
  } else {
    tag = mac;
  }
  return tag;
}

- (void)tagsAliasCallback:(int)iResCode
                     tags:(NSSet *)tags
                    alias:(NSString *)alias {
  if (iResCode == 0) {
    NSArray *successTags = [tags allObjects];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:successTags forKey:jPushTagArrayKey];
    [defaults synchronize];
    self.finishBlock(YES);
  } else {
    self.finishBlock(NO);
  }
  DDLogDebug(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags, alias);
}
@end
