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
@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UIButton *btn;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, assign) id<SceneSwitchListDelegate> delegate;
@end

@protocol SceneSwitchListDelegate<NSObject>
@optional
- (void)touchScene:(SceneSwitchListController *)sceneSwitchListController
           aSwitch:(SDZGSwitch *)aSwitch;
@end
