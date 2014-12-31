//
//  UserInfo.h
//  SmartSwitch
//
//  Created by sdzg on 14-9-3.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerResponse.h"
typedef void (^ResponseBlock)(int status, id response);

@interface UserInfo : NSObject
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *qqUid;
@property (nonatomic, strong) NSString *sinaUid;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) ResponseBlock responseBlock;

- (id)initWithEmail:(NSString *)email password:(NSString *)password;

- (id)initWithEmail:(NSString *)email
           password:(NSString *)password
           nickName:(NSString *)nickName;

- (id)initWithQQUid:(NSString *)qqUid nickname:(NSString *)nickname;

- (id)initWithSinaUid:(NSString *)sinaUid nickname:(NSString *)nickname;

- (void)loginRequestWithResponse:(ResponseBlock)responseBlock;

- (void)registerRequestWithResponse:(ResponseBlock)responseBlock;

+ (BOOL)userInfoInDisk;

+ (void)userLoginout;
@end
