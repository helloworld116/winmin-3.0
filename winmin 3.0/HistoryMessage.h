//
//  HistoryMessage.h
//  winmin 3.0
//
//  Created by sdzg on 14-12-9.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistoryMessage : NSObject
@property (nonatomic, assign) int type;
@property (nonatomic, assign) int _id;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *insertDate;
@property (nonatomic, strong) NSString *mac;
@property (nonatomic, strong) NSString *title;
- (id)initWithMessage:(NSDictionary *)message;
@end
