//
//  FindPassword.h
//  winmin 3.0
//
//  Created by sdzg on 14-10-28.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FindPassword : NSObject
- (void)sendEmail:(NSString *)email;

- (void)resetPassword:(NSString *)password
            withEmail:(NSString *)email
             withCode:(NSString *)code;
@end
