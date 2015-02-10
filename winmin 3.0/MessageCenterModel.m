//
//  MessageCenterModel.m
//  winmin 3.0
//
//  Created by sdzg on 14-12-9.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "MessageCenterModel.h"
#import "HistoryMessage.h"
const int successCode = 1;
@implementation MessageCenterModel
- (void)requestMsgWithMac:(NSString *)mac
                     type:(int)type
                  startId:(int)startId
                    count:(int)count
               completion:(void (^)(int status, NSArray *messages,
                                    int totalCount))compeltion {
  NSString *messageUrl =
      [NSString stringWithFormat:@"%@message/list", BaseURLStringWithNoEncrypt];
  AFHTTPRequestOperationManager *manager =
      [AFHTTPRequestOperationManager manager];
  manager.responseSerializer = [AFHTTPResponseSerializer serializer];
  NSMutableDictionary *parameters = [@{} mutableCopy];
  [parameters setObject:mac forKey:@"mac"];
  [parameters setObject:@(type) forKey:@"type"];
  [parameters setObject:@(startId) forKey:@"id"];
  [parameters setObject:@(count) forKey:@"count"];
  [manager POST:messageUrl
      parameters:parameters
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSString *string =
              [[NSString alloc] initWithData:responseObject
                                    encoding:NSUTF8StringEncoding];
          //          DDLogDebug(@"response msg is %@",string);
          NSDictionary *responseData = __JSON(string);
          int status = [responseData[@"status"] intValue];
          if (status == successCode) {
            NSDictionary *data = responseData[@"data"];
            int responseCount = [data[@"count"] intValue];
            int totalCount = [data[@"total"] intValue];
            NSMutableArray *messageArray =
                [NSMutableArray arrayWithCapacity:responseCount];
            NSArray *messages = data[@"message"];
            for (NSDictionary *message in messages) {
              HistoryMessage *historyMessage =
                  [[HistoryMessage alloc] initWithMessage:message];
              [messageArray addObject:historyMessage];
            }
            compeltion(status, messageArray, totalCount);
          } else {
            compeltion(status, nil, 0);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          compeltion(-1, nil, 0);
      }];
}

- (void)requestWithStartId:(int)startId
                completion:(void (^)(int status, NSArray *messages,
                                     int totalCount))compeltion {
  NSArray *switchs = [[SwitchDataCeneter sharedInstance] switchs];
  NSMutableString *macStr = [NSMutableString string];
  for (int i = 0; i < [switchs count]; i++) {
    SDZGSwitch *aSwitch = switchs[i];
    [macStr appendString:[self aSwitchToTag:aSwitch]];
    [macStr appendString:@","];
  }
  NSString *macs = [macStr substringToIndex:macStr.length];
  [self requestMsgWithMac:macs
                     type:1
                  startId:startId
                    count:20
               completion:compeltion];
}

- (NSString *)aSwitchToTag:(SDZGSwitch *)aSwitch {
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

@end
