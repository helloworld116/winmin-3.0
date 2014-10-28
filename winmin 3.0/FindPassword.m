//
//  FindPassword.m
//  winmin 3.0
//
//  Created by sdzg on 14-10-28.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "FindPassword.h"
#import "ServerResponse.h"

@interface FindPassword ()
@end

@implementation FindPassword
- (void)sendEmail:(NSString *)email {
  NSString *url = [NSString stringWithFormat:@"%@/pass/reset", BaseURLString];
  AFHTTPRequestOperationManager *manager =
      [AFHTTPRequestOperationManager manager];
  manager.responseSerializer = [AFHTTPResponseSerializer serializer];
  NSMutableDictionary *parameters = [@{} mutableCopy];
  [parameters setObject:__ENCRYPT(email) forKey:@"email"];
  [manager POST:url
      parameters:parameters
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSString *string =
              [[NSString alloc] initWithData:responseObject
                                    encoding:NSUTF8StringEncoding];
          NSString *responseStr = __DECRYPT(string);
          ServerResponse *response =
              [[ServerResponse alloc] initWithResponseString:responseStr];
          NSDictionary *userInfo = @{
            @"status" : @(response.status),
            @"msg" : response.errorMsg ? response.errorMsg : [NSNull null]
          };
          [[NSNotificationCenter defaultCenter]
              postNotificationName:kSendEmailResponse
                            object:self
                          userInfo:userInfo];
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSDictionary *userInfo = @{ @"status" : @0, @"msg" : error };
          [[NSNotificationCenter defaultCenter]
              postNotificationName:kSendEmailResponse
                            object:self
                          userInfo:userInfo];
      }];
}

- (void)resetPassword:(NSString *)password
            withEmail:(NSString *)email
             withCode:(NSString *)code {
  NSString *url = [NSString stringWithFormat:@"%@/pass/save", BaseURLString];
  AFHTTPRequestOperationManager *manager =
      [AFHTTPRequestOperationManager manager];
  manager.responseSerializer = [AFHTTPResponseSerializer serializer];
  NSMutableDictionary *parameters = [@{} mutableCopy];
  [parameters setObject:__ENCRYPT(email) forKey:@"email"];
  [parameters setObject:__ENCRYPT(code) forKey:@"code"];
  [parameters setObject:__ENCRYPT(password) forKey:@"password"];
  [manager POST:url
      parameters:parameters
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSString *string =
              [[NSString alloc] initWithData:responseObject
                                    encoding:NSUTF8StringEncoding];
          NSString *responseStr = __DECRYPT(string);
          ServerResponse *response =
              [[ServerResponse alloc] initWithResponseString:responseStr];
          NSDictionary *userInfo = @{
            @"status" : @(response.status),
            @"msg" : response.errorMsg ? response.errorMsg : [NSNull null]
          };
          [[NSNotificationCenter defaultCenter]
              postNotificationName:kResetPasswordResponse
                            object:self
                          userInfo:userInfo];
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSDictionary *userInfo = @{ @"status" : @0, @"msg" : error };
          [[NSNotificationCenter defaultCenter]
              postNotificationName:kResetPasswordResponse
                            object:self
                          userInfo:userInfo];
      }];
}
@end
