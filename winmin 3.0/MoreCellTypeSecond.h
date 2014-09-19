//
//  MoreCellTypeSecond.h
//  winmin 3.0
//
//  Created by sdzg on 14-9-17.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreCellTypeSecond : UITableViewCell
@property(nonatomic, strong) IBOutlet UIImageView *imgIcon;
@property(nonatomic, strong) IBOutlet UIImageView *imgArrow;
@property(nonatomic, strong) IBOutlet UILabel *lblTitle;
- (void)setTitle:(NSString *)title icon:(NSString *)icon;
@end
