//
//  UserInfo.m
//  SmartSwitch
//
//  Created by sdzg on 14-9-3.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo
- (id)init {
  self = [super init];
  if (self) {
  }
  return self;
}

- (id)initWithEmail:(NSString *)email password:(NSString *)password {
  self = [super init];
  if (self) {
    self.email = email;
    self.password = password;
  }
  return self;
}

- (id)initWithEmail:(NSString *)email
           password:(NSString *)password
           nickName:(NSString *)nickName {
  self = [self initWithEmail:email password:password];
  if (self) {
    self.nickName = nickName;
  }
  return self;
}

- (id)initWithQQUid:(NSString *)qqUid nickname:(NSString *)nickname {
  self = [self init];
  self.qqUid = qqUid;
  self.nickName = nickname;
  return self;
}

- (id)initWithSinaUid:(NSString *)sinaUid nickname:(NSString *)nickname {
  self = [self init];
  self.sinaUid = sinaUid;
  self.nickName = nickname;
  return self;
}

- (void)loginRequest {
  NSString *loginUrl =
      [NSString stringWithFormat:@"%@login/login", BaseURLString];
  AFHTTPRequestOperationManager *manager =
      [AFHTTPRequestOperationManager manager];
  manager.responseSerializer = [AFHTTPResponseSerializer serializer];
  NSMutableDictionary *parameters = [@{} mutableCopy];
  if (self.email && self.password) {
    [parameters setObject:__ENCRYPT(self.email) forKey:@"username"];
    [parameters setObject:__ENCRYPT(self.password) forKey:@"password"];
  } else if (self.qqUid) {
    [parameters setObject:__ENCRYPT(self.qqUid) forKey:@"qqUid"];
  } else if (self.sinaUid) {
    [parameters setObject:__ENCRYPT(self.sinaUid) forKey:@"sinaUid"];
  }
  [manager POST:loginUrl
      parameters:parameters
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSString *string =
              [[NSString alloc] initWithData:responseObject
                                    encoding:NSUTF8StringEncoding];
          NSString *responseStr = __DECRYPT(string);
          ServerResponse *response =
              [[ServerResponse alloc] initWithResponseString:responseStr];
          //保存用户信息到本地
          if (response.status == 1) {
            NSString *nickname = response.data[@"username"];
            if (self.qqUid || self.sinaUid) {
              nickname = self.nickName;
            }
            [UserInfo saveUserInfo:self.email
                          password:self.password
                             qqUid:self.qqUid
                           sinaUid:self.sinaUid
                          nickname:nickname];
          }

          NSDictionary *userInfo = @{ @"status" : @1, @"data" : response };
          [[NSNotificationCenter defaultCenter]
              postNotificationName:kLoginResponse
                            object:self
                          userInfo:userInfo];
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSDictionary *userInfo = @{ @"status" : @0, @"data" : error };
          [[NSNotificationCenter defaultCenter]
              postNotificationName:kLoginResponse
                            object:self
                          userInfo:userInfo];
      }];
}

- (void)registerRequest {
  NSString *registerUrl =
      [NSString stringWithFormat:@"%@user/register", BaseURLString];
  AFHTTPRequestOperationManager *manager =
      [AFHTTPRequestOperationManager manager];
  manager.responseSerializer = [AFHTTPResponseSerializer serializer];
  NSMutableDictionary *parameters = [@{} mutableCopy];
  if (self.email && self.password && self.nickName) {
    [parameters setObject:__ENCRYPT(self.nickName) forKey:@"username"];
    [parameters setObject:__ENCRYPT(self.password) forKey:@"password"];
    [parameters setObject:__ENCRYPT(self.email) forKey:@"email"];
  } else if (self.qqUid) {
    [parameters setObject:__ENCRYPT(self.qqUid) forKey:@"qqUid"];
  } else if (self.sinaUid) {
    [parameters setObject:__ENCRYPT(self.sinaUid) forKey:@"sinaUid"];
  }
  [manager POST:registerUrl
      parameters:parameters
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSString *string =
              [[NSString alloc] initWithData:responseObject
                                    encoding:NSUTF8StringEncoding];
          NSString *responseStr = __DECRYPT(string);
          ServerResponse *response =
              [[ServerResponse alloc] initWithResponseString:responseStr];
          if (response.status == 1) {
            //保存用户信息到本地
            [UserInfo saveUserInfo:self.email
                          password:self.password
                             qqUid:nil
                           sinaUid:nil
                          nickname:self.nickName];
          }
          NSDictionary *userInfo = @{ @"status" : @1, @"data" : response };
          [[NSNotificationCenter defaultCenter]
              postNotificationName:kRegisterResponse
                            object:self
                          userInfo:userInfo];
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSDictionary *userInfo = @{ @"status" : @0, @"data" : error };
          [[NSNotificationCenter defaultCenter]
              postNotificationName:kRegisterResponse
                            object:self
                          userInfo:userInfo];
      }];
}

+ (void)saveUserInfo:(NSString *)email
            password:(NSString *)password
               qqUid:(NSString *)qqUid
             sinaUid:(NSString *)sinaUid
            nickname:(NSString *)nickname {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  if (email && password) {
    [userDefaults setObject:email forKey:@"email"];
    [userDefaults setObject:password forKey:@"password"];
  } else if (qqUid) {
    [userDefaults setObject:qqUid forKey:@"qqUid"];
  } else if (sinaUid) {
    [userDefaults setObject:sinaUid forKey:@"sinaUid"];
  }
  [userDefaults setObject:nickname forKey:@"nickname"];
  [userDefaults synchronize];
}

+ (BOOL)userInfoInDisk {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  if ([userDefaults objectForKey:@"nickname"]) {
    return YES;
  }
  return NO;
}
@end
