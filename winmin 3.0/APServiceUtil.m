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

+ (void)openRemoteNotification:(NSSet *)tags
                   finishBlock:(finishCallbackBlock)block {
  APServiceUtil *util = [[APServiceUtil alloc] init];
  util.finishBlock = block;
  [APService setTags:tags
      callbackSelector:@selector(tagsAliasCallback:tags:alias:)
                object:util];
}

- (void)tagsAliasCallback:(int)iResCode
                     tags:(NSSet *)tags
                    alias:(NSString *)alias {
  if (iResCode == 0) {
    self.finishBlock(YES);
  } else {
    self.finishBlock(NO);
  }
  debugLog(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags, alias);
}

@end