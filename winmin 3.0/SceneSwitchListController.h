//
//  SceneSwitchListController.h
//  winmin 3.0
//
//  Created by sdzg on 14-12-17.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SceneSwitchListDelegate;

@interface SceneSwitchListController : UIViewController
@property (nonatomic, strong) IBOutlet UILabel *lblTitle;
@property (nonatomic, strong) IBOutlet UIButton *btn;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, assign) id<SceneSwitchListDelegate> delegate;
@end

@protocol SceneSwitchListDelegate<NSObject>
@optional
- (void)touchSceneCallbackSwitch:(SDZGSwitch *)aSwitch;
@end
