//
//  MoreCellTypeThird.h
//  winmin 3.0
//
//  Created by sdzg on 14-10-15.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreCellTypeThird : UITableViewCell
@property(nonatomic, strong) IBOutlet UILabel *lblUsername;
@property(nonatomic, strong) IBOutlet UIButton *btn;
- (IBAction)loginOut:(id)sender;
@end
