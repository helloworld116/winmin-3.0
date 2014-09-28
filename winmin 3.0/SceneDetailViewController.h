//
//  SceneDetailViewController.h
//  winmin 3.0
//
//  Created by sdzg on 14-9-25.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Scene;

@interface SceneDetailViewController : UIViewController
@property(nonatomic, strong) Scene *scene;
@property(nonatomic, assign) int row;
@end
