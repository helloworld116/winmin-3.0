//
//  SceneSocketView2.h
//  winmin 3.0
//
//  Created by sdzg on 14-12-18.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface SceneSocketView2 : UIView
@property (weak, nonatomic) IBOutlet UIImageView *imgGroup;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewSocket1;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewSocket2;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewSocket3;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
- (void)setSocketInfo:(SDZGSocket *)socket isOn:(BOOL)isOn;
@end
