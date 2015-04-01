//
//  SnakeSocketView.h
//  winmin 3.0
//
//  Created by sdzg on 15-3-24.
//  Copyright (c) 2015年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SnakeSocketView;

@protocol SnakeSocketViewDelegate<NSObject>
- (void)touchSocket:(int)socketId withSelf:(SnakeSocketView *)_self;
- (void)touchOnOrOffWithSelf:(SnakeSocketView *)_self;
- (void)touchTimerWithSelf:(SnakeSocketView *)_self;
- (void)touchDelayWithSelf:(SnakeSocketView *)_self;
@end

@interface SnakeArcImgView : UIView
@end

@interface SnakeSocketView : UIView
@property (assign, nonatomic) int groupId; //标识插孔所属分组的id
@property (assign, nonatomic) id<SnakeSocketViewDelegate> sockeViewDelegate;
@property (weak, nonatomic) IBOutlet UIButton *btnSocket1;
@property (weak, nonatomic) IBOutlet UIButton *btnSocket2;
@property (weak, nonatomic) IBOutlet UIButton *btnSocket3;
@property (weak, nonatomic) IBOutlet UIButton *btnSocket4;
@property (weak, nonatomic) IBOutlet UIButton *btnOnOrOff;
@property (weak, nonatomic) IBOutlet UIButton *btnTimer;
@property (weak, nonatomic) IBOutlet UIButton *btnDelay;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewBg;
@property (weak, nonatomic) IBOutlet SnakeArcImgView *arcView;
- (IBAction)touchSocket1:(id)sender;
- (IBAction)touchSocket2:(id)sender;
- (IBAction)touchSocket3:(id)sender;
- (IBAction)touchSocket4:(id)sender;
- (IBAction)touchTimer:(id)sender;
- (IBAction)touchDelay:(id)sender;
- (IBAction)touchOnOrOff:(id)sender;

- (void)setSocketInfo:(SDZGSocket *)socket;
- (void)changeSocketState:(SDZGSocket *)socket;
- (void)removeRotateAnimation;
- (void)timerState:(BOOL)hasTimer;
- (void)delayState:(BOOL)hasDelay;

@end
