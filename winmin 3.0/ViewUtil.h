//
//  ViewUtil.h
//  winmin
//
//  Created by 文正光 on 14-8-1.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViewUtil : NSObject
+ (instancetype)sharedInstance;
- (void)showMessageInViewController:(UIViewController *)viewController
                            message:(NSString *)messsage;
@end
