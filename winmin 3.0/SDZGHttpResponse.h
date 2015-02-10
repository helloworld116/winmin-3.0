//
//  SDZGHttpResponse.h
//  winmin 3.0
//
//  Created by sdzg on 15-2-4.
//  Copyright (c) 2015年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDZGHttpResponse : NSObject
@property (nonatomic, assign) BOOL isSuccess;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) id data;
- (id)initWithResponseCode:(int)responseCode
                   message:(NSString *)message
                     error:(NSError *)error;

- (id)initWithResponseCode:(int)responseCode data:(id)data;
@end
