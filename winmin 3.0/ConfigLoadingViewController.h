//
//  ConfigLoadingViewController.h
//  winmin 3.0
//
//  Created by sdzg on 14-9-16.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MJConfigLoadingDelegate;
@interface ConfigLoadingViewController : UIViewController
@property (assign, nonatomic) id<MJConfigLoadingDelegate> delegate;
@property (strong, nonatomic) NSString *ssid;
@property (strong, nonatomic) NSString *password;
@end

@protocol MJConfigLoadingDelegate<NSObject>
@optional
- (void)cancelButtonClicked:
            (ConfigLoadingViewController *)configLoadingViewController
                    success:(BOOL)success;
@end
