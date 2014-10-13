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

- (id)initWithUsername:(NSString *)username password:(NSString *)password {
  self = [super init];
  if (self) {
    self.username = username;
    self.password = password;
  }
  return self;
}

- (id)initWithUsername:(NSString *)username
              password:(NSString *)password
                 email:(NSString *)email {
  self = [self initWithUsername:username password:password];
  self.email = email;
  return self;
}

- (id)initWithQQUid:(NSString *)qqUid {
  self = [self init];
  self.qqUid = qqUid;
  return self;
}

- (id)initWithSinaUid:(NSString *)sinaUid {
  self = [self init];
  self.sinaUid = sinaUid;
  return self;
}

static NSString *const BaseURLString = @"http://192.168.0.89:8080/ais/api/";
- (void)loginRequest {
  NSString *loginUrl =
      [NSString stringWithFormat:@"%@login/login", BaseURLString];
  AFHTTPRequestOperationManager *manager =
      [AFHTTPRequestOperationManager manager];
  manager.responseSerializer = [AFHTTPResponseSerializer serializer];
  NSMutableDictionary *parameters = [@{} mutableCopy];
  if (self.username && self.password) {
    [parameters setObject:__ENCRYPT(self.username) forKey:@"username"];
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
  if (self.username && self.password && self.email) {
    [parameters setObject:__ENCRYPT(self.username) forKey:@"username"];
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
@end
