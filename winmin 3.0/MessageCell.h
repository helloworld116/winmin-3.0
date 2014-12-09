//
//  MessageCell.h
//  winmin 3.0
//
//  Created by sdzg on 14-12-9.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistoryMessage.h"

@interface MessageCell : UITableViewCell
- (void)setInfo:(HistoryMessage *)message;
@end
