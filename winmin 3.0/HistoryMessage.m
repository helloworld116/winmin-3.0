//
//  HistoryMessage.m
//  winmin 3.0
//
//  Created by sdzg on 14-12-9.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "HistoryMessage.h"

@implementation HistoryMessage
- (id)initWithMessage:(NSDictionary *)message {
  self = [super init];
  if (self) {
    self.content = message[@"content"];
    self._id = [message[@"id"] intValue];
    self.insertDate = message[@"insertDate"];
    self.mac = message[@"mac"];
    self.title = message[@"title"];
    self.type = [message[@"type"] intValue];
  }
  return self;
}
@end
