//
//  FeedbackModel.m
//  winmin 3.0
//
//  Created by sdzg on 14-12-10.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "FeedbackModel.h"
const int FeedbackSuccessCode = 1;
@implementation FeedbackModel
- (void)requestWithFeedbackType:(FeedbackType)type
                         detail:(NSString *)detail
                          email:(NSString *)email
                     completion:(void (^)(BOOL result))compeltion {
  NSString *messageUrl =
      [NSString stringWithFormat:@"%@/advice/submit", BaseURLString];
  AFHTTPRequestOperationManager *manager =
      [AFHTTPRequestOperationManager manager];
  manager.responseSerializer = [AFHTTPResponseSerializer serializer];
  NSMutableDictionary *parameters = [@{} mutableCopy];
  NSString *tType = [NSString stringWithFormat:@"%d", type];
  [parameters setObject:__ENCRYPT(tType) forKey:@"type"];
  [parameters setObject:__ENCRYPT(detail) forKey:@"detail"];
  [parameters setObject:__ENCRYPT(email) forKey:@"email"];
  [parameters setObject:__ENCRYPT(@"0") forKey:@"source"]; // iOS
  [parameters
      setObject:__ENCRYPT([[NSBundle mainBundle]
                    objectForInfoDictionaryKey:@"CFBundleShortVersionString"])
         forKey:@"appVersion"];
  [parameters setObject:__ENCRYPT([[UIDevice currentDevice] systemVersion])
                 forKey:@"osVersion"];
  [parameters setObject:__ENCRYPT([[UIDevice currentDevice] model])
                 forKey:@"model"];
  [parameters setObject:__ENCRYPT(@"Apple Inc.") forKey:@"manufacture"];
  [manager POST:messageUrl
      parameters:parameters
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSString *string =
              [[NSString alloc] initWithData:responseObject
                                    encoding:NSUTF8StringEncoding];
          NSString *responseStr = __DECRYPT(string);
          DDLogDebug(@"response msg is %@", responseStr);
          NSDictionary *responseData = __JSON(responseStr);
          int status = [responseData[@"status"] intValue];
          if (status == FeedbackSuccessCode) {
            compeltion(YES);
          } else {
            compeltion(NO);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          compeltion(NO);
      }];
}
@end
