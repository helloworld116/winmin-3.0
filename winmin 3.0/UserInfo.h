//
//  UserInfo.h
//  SmartSwitch
//
//  Created by sdzg on 14-9-3.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerResponse.h"

@interface UserInfo : NSObject
@property(nonatomic, strong) NSString *username;
@property(nonatomic, strong) NSString *password;
@property(nonatomic, strong) NSString *qqUid;
@property(nonatomic, strong) NSString *sinaUid;
@property(nonatomic, strong) NSString *email;

- (id)initWithUsername:(NSString *)username password:(NSString *)password;

- (id)initWithUsername:(NSString *)username
              password:(NSString *)password
                 email:(NSString *)email;

- (id)initWithQQUid:(NSString *)qqUid;

- (id)initWithSinaUid:(NSString *)sinaUid;

- (void)loginRequest;

- (void)registerRequest;
@end
