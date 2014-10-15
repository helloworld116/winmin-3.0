//
//  TextUtil.m
//  winmin 3.0
//
//  Created by sdzg on 14-10-15.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "TextUtil.h"

@implementation TextUtil
+ (BOOL)isEmailAddress:(NSString *)email {
  NSString *emailRegex = @"^\\w+((\\-\\w+)|(\\.\\w+))*@[A-Za-z0-9]+((\\.|\\-)["
                         @"A-Za-z0-9]+)*.[A-Za-z0-9]+$";

  NSPredicate *emailTest =
      [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];

  return [emailTest evaluateWithObject:email];
}
@end
