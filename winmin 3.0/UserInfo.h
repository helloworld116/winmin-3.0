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
@property(nonatomic, strong) NSString *nickName;
@property(nonatomic, strong) NSString *password;
@property(nonatomic, strong) NSString *qqUid;
@property(nonatomic, strong) NSString *sinaUid;
@property(nonatomic, strong) NSString *email;

- (id)initWithEmail:(NSString *)email password:(NSString *)password;

- (id)initWithEmail:(NSString *)email
           password:(NSString *)password
           nickName:(NSString *)nickName;

- (id)initWithQQUid:(NSString *)qqUid nickname:(NSString *)nickname;

- (id)initWithSinaUid:(NSString *)sinaUid nickname:(NSString *)nickname;

- (void)loginRequest;

- (void)registerRequest;

+ (BOOL)userInfoInDisk;

+ (void)userLoginout;
@end
