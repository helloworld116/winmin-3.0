//
//  RealTimePowerView.h
//  winmin 3.0
//
//  Created by sdzg on 15-1-21.
//  Copyright (c) 2015年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RealTimePowerView : UIView
@property (nonatomic, weak) IBOutlet UIImageView *img1;    //个位
@property (nonatomic, weak) IBOutlet UIImageView *img2;    //十位
@property (nonatomic, weak) IBOutlet UIImageView *img3;    //百位
@property (nonatomic, weak) IBOutlet UIImageView *img4;    //千位
@property (nonatomic, weak) IBOutlet UIImageView *imgUnit; //单位
@property (nonatomic, weak) IBOutlet UILabel *lblUnit;
- (void)setPower:(int)power;
@end
