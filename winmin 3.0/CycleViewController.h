//
//  CycleViewController.h
//  SmartSwitch
//
//  Created by sdzg on 14-8-14.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CycleViewController : UITableViewController
@property(nonatomic, assign) int week;
@property(nonatomic, assign) id<PassValueDelegate> delegate;
@end
