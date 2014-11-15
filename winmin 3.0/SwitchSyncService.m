//
//  SwitchSyncService.m
//  winmin 3.0
//
//  Created by sdzg on 14-11-15.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SwitchSyncService.h"
#import "UserInfo.h"
#import "ServerResponse.h"

@interface SwitchSyncService ()
@property (nonatomic, strong) UserInfo *userInfo;
@property (nonatomic, strong) NSArray *switchs;
@end

@implementation SwitchSyncService

- (id)init {
  self = [super init];
  if (self) {
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(loginResponseNotification:)
               name:kLoginResponse
             object:nil];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification
- (void)uploadSwitchs:(NSArray *)switchs {
  if ([UserInfo userInfoInDisk]) {
    BOOL needSync = NO;
    for (SDZGSwitch *aSwitch in switchs) {
      if (aSwitch.tag == 0) {
        needSync = YES;
        break;
      }
    }
    if (needSync) {
      self.switchs = switchs;
      [self autoLogin];
    }
  }
}

- (void)loginResponseNotification:(NSNotification *)notif {
  NSDictionary *info = notif.userInfo;
  int status = [[info objectForKey:@"status"] intValue];
  if (status == 1) {
    [self upload];
  }
}

- (void)upload {
  NSString *uploadUrl =
      [NSString stringWithFormat:@"%@device/add", BaseURLString];
  AFHTTPRequestOperationManager *manager =
      [AFHTTPRequestOperationManager manager];
  manager.responseSerializer = [AFHTTPResponseSerializer serializer];
  manager.requestSerializer = [AFHTTPRequestSerializer serializer];
  NSMutableDictionary *parameters = [@{} mutableCopy];
  NSMutableArray *macs = [@[] mutableCopy];
  NSMutableArray *keys = [@[] mutableCopy];
  for (SDZGSwitch *aSwitch in self.switchs) {
    if (aSwitch.tag == 0) {
      [keys addObject:@"mac"];
      [macs addObject:__ENCRYPT(aSwitch.mac)];
      break;
    }
  }
  [parameters setObject:macs forKey:@"mac"];
  [manager POST:uploadUrl
      parameters:parameters
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSString *string =
              [[NSString alloc] initWithData:responseObject
                                    encoding:NSUTF8StringEncoding];
          NSString *responseStr = __DECRYPT(string);
          ServerResponse *response =
              [[ServerResponse alloc] initWithResponseString:responseStr];
          debugLog(@"response is %@", responseStr);

      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error){

      }];
}

- (void)downloadSwitchs:(int)benginId {
}

- (void)download:(int)benginId {
}

- (void)autoLogin {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  NSString *loginType = [userDefaults objectForKey:@"loginType"];
  NSString *nickname = [userDefaults objectForKey:@"nickname"];
  if ([loginType isEqualToString:@"email"]) {
    NSString *email = [userDefaults objectForKey:@"email"];
    NSString *password = [userDefaults objectForKey:@"password"];
    self.userInfo = [[UserInfo alloc] initWithEmail:email
                                           password:password
                                           nickName:nickname];
  } else if ([loginType isEqualToString:@"qq"]) {
    NSString *qqUid = [userDefaults objectForKey:@"qqUid"];
    self.userInfo = [[UserInfo alloc] initWithQQUid:qqUid nickname:nickname];
  } else if ([loginType isEqualToString:@"sina"]) {
    NSString *sinaUid = [userDefaults objectForKey:@"sinaUid"];
    self.userInfo =
        [[UserInfo alloc] initWithSinaUid:sinaUid nickname:nickname];
  }
  [self.userInfo loginRequest];
}
@end