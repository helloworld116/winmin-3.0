//
//  ServerResponse.m
//  SmartSwitch
//
//  Created by sdzg on 14-9-5.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "ServerResponse.h"

@implementation ServerResponse
- (id)initWithResponseString:(NSString *)response {
  self = [super init];
  if (self) {
    NSDictionary *responseDict = __JSON(response);
    self.status = [[responseDict objectForKey:@"status"] intValue];
    self.errorMsg = [responseDict objectForKey:@"errorMsg"];
    self.data = [responseDict objectForKey:@"data"];
  }
  return self;
}

@end
