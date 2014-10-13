//
//  ServerResponse.h
//  SmartSwitch
//
//  Created by sdzg on 14-9-5.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerResponse : NSObject
@property(nonatomic, assign) int status;
@property(nonatomic, strong) NSString *errorMsg;
@property(nonatomic, strong) NSDictionary *data;
//{"data":{"email":"an","id":4,"lastLoginIp":"192.168.0.105","lastLoginTime":"2014-09-05
// 13:45:27","userType":0,"username":"nil"},"status":1}

- (id)initWithResponseString:(NSString *)response;
@end
