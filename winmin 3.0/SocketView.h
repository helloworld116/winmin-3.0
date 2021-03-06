//
//  SocketView.h
//  winmin 3.0
//
//  Created by sdzg on 14-9-18.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SocketView;

@protocol SocketViewDelegate<NSObject>
- (void)touchSocket:(int)socketId withSelf:(SocketView *)_self;
- (void)touchOnOrOffWithSelf:(SocketView *)_self;
- (void)touchTimerWithSelf:(SocketView *)_self;
- (void)touchDelayWithSelf:(SocketView *)_self;
@end

@interface ArcImgView : UIView
@end

@interface SocketView : UIView
@property (assign, nonatomic) int groupId; //标识插孔所属分组的id
@property (assign, nonatomic) id<SocketViewDelegate> sockeViewDelegate;
@property (weak, nonatomic) IBOutlet UIButton *btnSocket1;
@property (weak, nonatomic) IBOutlet UIButton *btnSocket2;
@property (weak, nonatomic) IBOutlet UIButton *btnSocket3;
@property (weak, nonatomic) IBOutlet UIButton *btnOnOrOff;
@property (weak, nonatomic) IBOutlet UIButton *btnOnOrOff2;
@property (weak, nonatomic) IBOutlet UIButton *btnTimer;
@property (weak, nonatomic) IBOutlet UIButton *btnDelay;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewBg;
@property (weak, nonatomic) IBOutlet ArcImgView *arcView;
- (IBAction)touchSocket1:(id)sender;
- (IBAction)touchSocket2:(id)sender;
- (IBAction)touchSocket3:(id)sender;
- (IBAction)touchTimer:(id)sender;
- (IBAction)touchDelay:(id)sender;
- (IBAction)touchOnOrOff:(id)sender;

- (void)setSocketInfo:(SDZGSocket *)socket;
- (void)changeSocketState:(SDZGSocket *)socket;
- (void)removeRotateAnimation;
- (void)timerState:(BOOL)hasTimer;
- (void)delayState:(BOOL)hasDelay;
@end
