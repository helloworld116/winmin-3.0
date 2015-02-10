//
//  SDZGHttpResponse.m
//  winmin 3.0
//
//  Created by sdzg on 15-2-4.
//  Copyright (c) 2015年 itouchco.com. All rights reserved.
//

#import "SDZGHttpResponse.h"

@implementation SDZGHttpResponse
- (id)initWithResponseCode:(int)responseCode
                   message:(NSString *)message
                     error:(NSError *)error {
  self = [super init];
  if (self) {
    if (responseCode == HttpSuccessCode) {
      self.isSuccess = YES;
    }
    self.message = message;
    self.error = error;
  }
  return self;
}

- (id)initWithResponseCode:(int)responseCode data:(id)data {
  self = [self initWithResponseCode:responseCode message:nil error:nil];
  if (self) {
    self.data = data;
  }
  return self;
}
@end
