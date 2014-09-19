//
//  ViewUtil.m
//  winmin
//
//  Created by 文正光 on 14-8-1.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "ViewUtil.h"

@implementation ViewUtil
+ (instancetype)sharedInstance {
  static ViewUtil *viewUtil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{ viewUtil = [[ViewUtil alloc] init]; });
  return viewUtil;
}

- (void)showMessageInViewController:(UIViewController *)viewController
                            message:(NSString *)messsage {
  dispatch_async(dispatch_get_main_queue(), ^{
      MBProgressHUD *hud =
          [MBProgressHUD showHUDAddedTo:viewController.navigationController.view
                               animated:YES];
      hud.mode = MBProgressHUDModeText;
      hud.cornerRadius = 5.f;
      hud.labelText = messsage;
      hud.labelFont = [UIFont systemFontOfSize:13];
      hud.margin = 3.f;
      hud.yOffset = 170.f;
      hud.removeFromSuperViewOnHide = YES;

      [hud hide:YES afterDelay:1];
  });
}

@end
