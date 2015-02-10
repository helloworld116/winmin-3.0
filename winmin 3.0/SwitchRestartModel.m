//
//  SwitchRestartModel.m
//  winmin 3.0
//
//  Created by sdzg on 15-2-4.
//  Copyright (c) 2015年 itouchco.com. All rights reserved.
//

#import "SwitchRestartModel.h"

@implementation SwitchRestartModel
- (void)resetDeviceMove:(NSString *)switchMac
                   flag:(int)flag
             completion:(HttpCompletionBlock)completion {
  NSString *requestUrl = [NSString
      stringWithFormat:@"%@deviceMove/reset", BaseURLStringWithNoEncrypt];
  AFHTTPRequestOperationManager *manager =
      [AFHTTPRequestOperationManager manager];
  manager.responseSerializer = [AFHTTPResponseSerializer serializer];
  NSMutableDictionary *parameters = [@{} mutableCopy];
  [parameters setObject:switchMac forKey:@"mac"];
  [parameters setObject:@(flag) forKey:@"flag"];
  [manager POST:requestUrl
      parameters:parameters
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSString *string =
              [[NSString alloc] initWithData:responseObject
                                    encoding:NSUTF8StringEncoding];
          DDLogDebug(@"response msg is %@", string);
          NSDictionary *responseData = __JSON(string);
          int status = [responseData[@"status"] intValue];
          if (status == HttpSuccessCode) {
            SDZGHttpResponse *response =
                [[SDZGHttpResponse alloc] initWithResponseCode:status
                                                       message:nil
                                                         error:nil];
            completion(response);
          } else {
            DDLogDebug(@"服务器错误，请稍后再试");
            SDZGHttpResponse *response = [[SDZGHttpResponse alloc]
                initWithResponseCode:status
                             message:@"服务器错误，请稍后再试"
                               error:nil];
            completion(response);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          DDLogDebug(@"网络错误，请稍后再试");
          SDZGHttpResponse *response = [[SDZGHttpResponse alloc]
              initWithResponseCode:-1
                           message:@"网络错误，请稍后再试"
                             error:error];
          completion(response);
      }];
}
@end
