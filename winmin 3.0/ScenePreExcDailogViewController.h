//
//  ScenePreExcDailogViewController.h
//  winmin 3.0
//
//  Created by sdzg on 14-11-28.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ScenePreExcDailogControllerDelegate<NSObject>
- (void)closePopViewController:(UIViewController *)controller
                passExecutable:(BOOL)excute;
@end

@interface ScenePreExcDailogViewController : UIViewController
@property (nonatomic, assign) id<ScenePreExcDailogControllerDelegate> delegate;
@end
