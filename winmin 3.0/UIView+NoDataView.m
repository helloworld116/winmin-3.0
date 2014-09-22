//
//  UIView+NoDataView.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-22.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "UIView+NoDataView.h"

@implementation UIView (NoDataView)
- (UIView *)initWithSize:(CGSize)size
                 imgName:(NSString *)imgName
                 message:(NSString *)message {
  UIView *view =
      [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
  view.backgroundColor = [UIColor whiteColor];

  UIImageView *imgView =
      [[UIImageView alloc] initWithFrame:CGRectMake(60, 50, 200, 200)];
  imgView.image = [UIImage imageNamed:imgName];
  [view addSubview:imgView];

  UILabel *lblMessage =
      [[UILabel alloc] initWithFrame:CGRectMake(0, 260, 320, 30)];
  lblMessage.textAlignment = NSTextAlignmentCenter;
  lblMessage.backgroundColor = [UIColor clearColor];
  lblMessage.text = message;
  lblMessage.textColor = [UIColor colorWithHexString:@"#F0EFEF"];
  [view addSubview:lblMessage];
  return view;
}
@end
