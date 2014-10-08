//
//  HistoryElec.h
//  SmartSwitch
//
//  Created by sdzg on 14-8-26.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistoryElecParam : NSObject
@property(nonatomic, assign) NSTimeInterval beginTime;
@property(nonatomic, assign) NSTimeInterval endTime;
@property(nonatomic, assign) int interval;
@end

@interface HistoryElecData : NSObject
@property(nonatomic, strong) NSArray *times;
@property(nonatomic, strong) NSArray *values;
@end

@interface HistoryElecResponse : NSObject
@property(nonatomic, assign) int power;
@property(nonatomic, assign) int time;
- (id)initWithTime:(int)time power:(int)power;
@end

@interface HistoryElec : NSObject
typedef NS_OPTIONS(NSUInteger, HistoryElecDateType) {
    OneDay = 0, OneWeek, OneMonth, ThreeMonth, SixMonth, OneYear,
};

- (HistoryElecParam *)getParam:(int)currentYear
                 selectedMonth:(int)selectedMonth
                      startDay:(int)startDay
                        endDay:(int)endDay;
- (HistoryElecData *)parseResponse:(NSArray *)responseArray
                             param:(HistoryElecParam *)param;

- (HistoryElecParam *)getParam:(NSTimeInterval)timeInterval
                      dateType:(HistoryElecDateType)dateType;
@end
