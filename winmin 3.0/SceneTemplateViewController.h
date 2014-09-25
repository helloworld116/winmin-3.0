//
//  SceneTemplateViewController.h
//  winmin 3.0
//
//  Created by sdzg on 14-9-25.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SceneTemplateDelegate<NSObject>
- (void)imgName:(NSString *)imgName sceneName:(NSString *)sceneName;
@end

@interface SceneTemplateViewController : UIViewController
@property(nonatomic, assign) id<SceneTemplateDelegate> sceneTemplateDelegate;
@end
