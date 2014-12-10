//
//  MessageCenterModel.h
//  winmin 3.0
//
//  Created by sdzg on 14-12-9.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>
const int successCode;
@interface MessageCenterModel : NSObject
- (void)requestWithStartId:(int)startId
                completion:(void (^)(int status, NSArray *messages,
                                     int totalCount))compeltion;
@end
