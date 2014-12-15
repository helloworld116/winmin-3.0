//
//  HistoryElec.h
//  SmartSwitch
//
//  Created by sdzg on 14-8-26.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_OPTIONS(NSUInteger, HistoryElecDateType){
  RealTime = 0, OneDay, OneWeek, OneMonth, ThreeMonth, SixMonth, OneYear,
};

@interface HistoryElecParam : NSObject
@property (nonatomic, assign) NSTimeInterval beginTime;
@property (nonatomic, assign) NSTimeInterval endTime;
@property (nonatomic, assign) int interval;
@property (nonatomic, assign) int type;
@property (nonatomic, assign) HistoryElecDateType dateType;
@end

@interface HistoryElecData : NSObject
@property (nonatomic, strong) NSArray *times;
@property (nonatomic, strong) NSArray *values;
@end

@interface HistoryElecResponse : NSObject
@property (nonatomic, assign) int power;
@property (nonatomic, assign) int time;
- (id)initWithTime:(int)time power:(int)power;
@end

@interface HistoryElec : NSObject

- (HistoryElecParam *)getParam:(int)currentYear
                 selectedMonth:(int)selectedMonth
                      startDay:(int)startDay
                        endDay:(int)endDay;
- (HistoryElecData *)parseResponse:(NSArray *)responseArray
                             param:(HistoryElecParam *)param;

- (HistoryElecParam *)getParam:(NSTimeInterval)timeInterval
                      dateType:(HistoryElecDateType)dateType;
@end
