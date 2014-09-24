//
//  DelaySettingViewController.h
//  winmin 3.0
//
//  Created by sdzg on 14-9-23.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DelayModel.h"

@protocol DelaySettingControllerDelegate<NSObject>
- (void)closePopViewController:(UIViewController *)controller
                  passMinitues:(int)minitues;
@end

@interface DelaySettingViewController : UIViewController
@property(nonatomic, assign) id<DelaySettingControllerDelegate> delegate;
@property(nonatomic, strong) DelayModel *model;
@end
