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
#import "APServiceUtil.h"

@interface SwitchSyncService ()
@property (nonatomic, strong) UserInfo *userInfo;
@property (nonatomic, strong) NSArray *switchs;
@property (nonatomic, assign) int type; // 1表示上传设备，2表示下载设备
@property (nonatomic, assign) BOOL isLogin;
@property (nonatomic, strong) SyncDeviceCompletionBlcok completionBlock;
@end

@implementation SwitchSyncService

- (id)init {
  self = [super init];
  if (self) {
    self.isLogin = [UserInfo userInfoInDisk];
    self.switchs = [SwitchDataCeneter sharedInstance].switchs;
  }
  return self;
}

- (void)dealloc {
}

#pragma mark - Notification
- (void)uploadSwitchs:(SyncDeviceCompletionBlcok)block {
  self.completionBlock = block;
  if (self.isLogin) {
    self.type = 1;
    [self autoLogin];
  } else {
    if (self.completionBlock) {
      self.completionBlock(NO);
    }
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
  for (SDZGSwitch *aSwitch in self.switchs) {
    NSString *newMac = [APServiceUtil aSwitchToTag:aSwitch];
    [macs addObject:__ENCRYPT(newMac)];
  }
  NSString *macString = [macs componentsJoinedByString:@","];
  [parameters setObject:macString forKey:@"mac"];
  [manager POST:uploadUrl
      parameters:parameters
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSString *string =
              [[NSString alloc] initWithData:responseObject
                                    encoding:NSUTF8StringEncoding];
          NSString *responseStr = __DECRYPT(string);
          ServerResponse *response =
              [[ServerResponse alloc] initWithResponseString:responseStr];
          int status = response.status;
          DDLogDebug(@"response is %@", responseStr);
          if (self.completionBlock) {
            if (status == 1) {
              self.completionBlock(YES);
            } else {
              self.completionBlock(NO);
            }
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          if (self.completionBlock) {
            self.completionBlock(NO);
          }
      }];
}

- (void)downloadSwitchs {
  if (self.isLogin) {
    self.type = 2;
    [self autoLogin];
  }
}

- (void)download {
  NSString *downloadUrl =
      [NSString stringWithFormat:@"%@device/list", BaseURLString];
  AFHTTPRequestOperationManager *manager =
      [AFHTTPRequestOperationManager manager];
  manager.responseSerializer = [AFHTTPResponseSerializer serializer];
  manager.requestSerializer = [AFHTTPRequestSerializer serializer];
  NSMutableDictionary *parameters = [@{} mutableCopy];
  [parameters setObject:__ENCRYPT(@"0") forKey:@"id"];
  [manager POST:downloadUrl
      parameters:parameters
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSString *string =
              [[NSString alloc] initWithData:responseObject
                                    encoding:NSUTF8StringEncoding];
          NSString *responseStr = __DECRYPT(string);
          ServerResponse *response =
              [[ServerResponse alloc] initWithResponseString:responseStr];
          DDLogDebug(@"response is %@", responseStr);
          NSArray *switchs = [response.data objectForKey:@"devices"];
          NSArray *needAddSwitchs = [self switchsToSdzgSwitch:switchs];
          if (needAddSwitchs.count) {
            DDLogDebug(@"有新设备");
            [[SwitchDataCeneter sharedInstance]
                addSwitchFromServer:needAddSwitchs];
          } else {
            DDLogDebug(@"没有新设备");
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error){

      }];
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
  [self.userInfo loginRequestWithResponse:^(int status, id response) {
      if (status == 1) {
        if (self.type == 1) {
          dispatch_async(GLOBAL_QUEUE, ^{ [self upload]; });
        } else if (self.type == 2) {
          dispatch_async(GLOBAL_QUEUE, ^{ [self download]; });
        }
      }
  }];
}

- (NSArray *)switchsToSdzgSwitch:(NSArray *)jsonSwitchs {
  NSMutableArray *switchs = [@[] mutableCopy];
  for (NSDictionary *jsonSwitch in jsonSwitchs) {
    NSMutableArray *macs = [@[] mutableCopy];
    NSMutableArray *passwords = [@[] mutableCopy];
    NSString *mac = [jsonSwitch objectForKey:@"mac"];
    NSString *password = [jsonSwitch objectForKey:@"password"];
    if (mac.length == 12 && password.length == 12) {
      //服务器端mac地址转本地mac地址，00199447E16A转为00:19:94:47:E1:6A
      for (int i = 0; i < 6; i++) {
        NSRange range = NSMakeRange(i * 2, 2);
        NSString *macSub = [mac substringWithRange:range];
        NSString *passwordSub = [password substringWithRange:range];
        macs[i] = macSub;
        passwords[i] = passwordSub;
      }
      NSString *localMac = [macs componentsJoinedByString:@":"];
      NSString *localPassword = [passwords componentsJoinedByString:@":"];
      BOOL isNeedAdd = NO;
      if (self.switchs.count) {
        for (int i = 0; i < self.switchs.count; i++) {
          SDZGSwitch *aSwtich = self.switchs[i];
          if ([aSwtich.mac isEqualToString:localMac]) {
            isNeedAdd = NO;
            break;
          } else {
            if (i == self.switchs.count - 1) {
              isNeedAdd = YES;
            }
          }
        }
      } else {
        isNeedAdd = YES;
      }
      if (isNeedAdd) {
        NSString *name = [jsonSwitch objectForKey:@"name"];
        int locked = [[jsonSwitch objectForKey:@"locked"] intValue];
        int version = [[jsonSwitch objectForKey:@"fw_version"] intValue];
        SDZGSwitch *parseSwtich = [SDZGSwitch parseSyncSwitch:localMac
                                                     password:localPassword
                                                         name:name
                                                      version:version
                                                   lockStauts:locked];
        [switchs addObject:parseSwtich];
      }
    }
  }
  return switchs;
}
@end