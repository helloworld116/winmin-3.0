//
//  LoadmoreCell.h
//  winmin 3.0
//
//  Created by sdzg on 14-12-10.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LoadmoreCell;
@protocol LoadmoreDelegate
- (void)beginLoad:(void (^)(BOOL))result;
@end

@interface LoadmoreCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIButton *btnLoadmore;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) id<LoadmoreDelegate> delegate;

- (void)firstLoad;
- (void)noMoreData;
@end
