//
//  SwitchListCell.h
//  winmin 3.0
//
//  Created by sdzg on 14-9-16.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwitchListCell : UITableViewCell
@property(strong, nonatomic) IBOutlet UIImageView *imgViewOfSwitch;
@property(strong, nonatomic) IBOutlet UIImageView *imgViewOfState;
@property(strong, nonatomic) IBOutlet UILabel *lblName;
@property(strong, nonatomic) IBOutlet UILabel *lblMac;
- (void)setCellInfo:(SDZGSwitch *)aSwitch;
@end
