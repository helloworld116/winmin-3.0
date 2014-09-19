//
//  DESUtil.h
//  SmartSwitch
//
//  Created by sdzg on 14-9-2.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DESUtil : NSObject
+ (NSString *)encryptString:(NSString *)string;
+ (NSString *)decryptString:(NSString *)string;
@end
