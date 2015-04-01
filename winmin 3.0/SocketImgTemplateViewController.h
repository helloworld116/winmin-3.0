//
//  SocketImgTemplateViewController.h
//  winmin 3.0
//
//  Created by sdzg on 14-9-18.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocketView.h"
#import "SnakeSocketView.h"

@protocol SocketImgTemplateDelegate<NSObject>
- (void)socketView:(UIView *)socketView
          socketId:(int)socketId
           imgName:(NSString *)imgName;
@end

@interface SocketImgTemplateViewController : UIViewController
@property (nonatomic, assign) id<SocketImgTemplateDelegate> delegate;
@property (nonatomic, assign) int socketId;
@property (nonatomic, strong) SocketView *socketView;
@property (nonatomic, strong) SnakeSocketView *snakeSocketView;
@property (nonatomic, strong) SDZGSwitch *aSwitch;
@end
