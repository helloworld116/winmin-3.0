//
//  ElecView.h
//  winmin 3.0
//
//  Created by sdzg on 14-9-30.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistoryElec.h"

@protocol ElecViewDelegate<NSObject>
- (void)selectedDatetype:(HistoryElecDateType)dateType
             needGetData:(BOOL)needGetData;
@end

@interface ElecView : UIView
@property(nonatomic, assign) id<ElecViewDelegate> delegate;

- (void)showChart:(HistoryElecData *)data
         dateType:(HistoryElecDateType)dateType;

- (void)showRealTimeData:(NSMutableArray *)powers;
@end
