//
//  UIView+NoDataView.h
//  winmin 3.0
//
//  Created by sdzg on 14-9-22.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (NoDataView)
- (UIView *)initWithSize:(CGSize)size
                 imgName:(NSString *)imgName
                 message:(NSString *)message;
@end
