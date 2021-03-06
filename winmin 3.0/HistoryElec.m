//
//  HistoryElec.m
//  SmartSwitch
//
//  Created by sdzg on 14-8-26.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "HistoryElec.h"
#import <NSDate+Calendar.h>
#define kTimeIntervalDay 3600
#define kTimeIntervalMonth 3600 * 24

@implementation HistoryElecParam

@end

@implementation HistoryElecData

@end

@interface HistoryElec ()
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation HistoryElec
- (id)init {
  self = [super init];
  if (self) {
    self.dateFormatter = [[NSDateFormatter alloc] init];
  }
  return self;
}

- (HistoryElecParam *)getParam:(int)currentYear
                 selectedMonth:(int)selectedMonth
                      startDay:(int)startDay
                        endDay:(int)endDay {
  [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
  NSString *startDateString =
      [NSString stringWithFormat:@"%d-%d-%d 00:00:00", currentYear,
                                 selectedMonth, startDay];
  NSString *endDateString;
  int interval;
  if (startDay == endDay) {
    //开始日和结束日相同，则说明查询的是某一天，否则查询的是某一月
    interval = kTimeIntervalDay;
    endDateString =
        [NSString stringWithFormat:@"%d-%d-%d 23:59:59", currentYear,
                                   selectedMonth, startDay];
  } else {
    interval = kTimeIntervalMonth;
    endDateString =
        [NSString stringWithFormat:@"%d-%d-%d 23:59:59", currentYear,
                                   selectedMonth, endDay];
  }
  NSTimeInterval start = [[self.dateFormatter
      dateFromString:startDateString] timeIntervalSince1970];
  NSTimeInterval end =
      [[self.dateFormatter dateFromString:endDateString] timeIntervalSince1970];
  HistoryElecParam *param = [[HistoryElecParam alloc] init];
  param.beginTime = start;
  param.endTime = end;
  param.interval = interval;
  return param;
}

//- (HistoryElecData *)parseResponse:(NSArray *)responseArray
//                             param:(HistoryElecParam *)param {
//  NSMutableDictionary *needDict = [@{} mutableCopy];
//  int needCount = (param.endTime + 1 - param.beginTime) / param.interval;
//  NSString *key;
//  //设置默认值为0
//  for (int i = 0; i < needCount; i++) {
//    key = [NSString
//        stringWithFormat:@"%d", (int)(param.beginTime + i * param.interval)];
//    [needDict setObject:@(0) forKey:key];
//  }
//  //替换服务器响应的数据
//  if (responseArray && responseArray.count) {
//    for (HistoryElecResponse *response in responseArray) {
//      NSString *key = [NSString stringWithFormat:@"%d", response.time];
//      [needDict setObject:@(response.power) forKey:key];
//    }
//  }
//
//  HistoryElecData *data = [[HistoryElecData alloc] init];
//  if (param.interval == kTimeIntervalDay) {
//    [self.dateFormatter setDateFormat:@"HH:mm"];
//  } else if (param.interval == kTimeIntervalMonth) {
//    [self.dateFormatter setDateFormat:@"MM-dd"];
//  }
//  NSMutableArray *times = [@[] mutableCopy];
//  NSMutableArray *values = [@[] mutableCopy];
//  NSString *formatterDateStr;
//  int value;
//  //排序后的时间戳
//  NSArray *timeArray = [[needDict allKeys]
//      sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//          return [obj1 intValue] - [obj2 intValue];
//      }];
//  for (NSString *dateInterval in timeArray) {
//    NSDate *date =
//        [NSDate dateWithTimeIntervalSince1970:[dateInterval intValue]];
//    formatterDateStr = [self.dateFormatter stringFromDate:date];
//    value = [[needDict objectForKey:dateInterval] intValue];
//    [times addObject:formatterDateStr];
//    [values addObject:@(value)];
//  }
//  data.times = times;
//  data.values = values;
//  return data;
//}

static const int oneDayInterval = 3600 * 24;
//- (HistoryElecParam *)getParam:(NSTimeInterval)timeInterval
//                      dateType:(HistoryElecDateType)dateType {
//  long interval = 0;
//  NSDate *currentDate = [[NSDate alloc] init];
//  NSDate *startDate;
//  switch (dateType) {
//    case OneDay:
//      interval = oneDayInterval / 48; //一天取48个样本，30分钟一个样本
//      startDate = [currentDate dateByAddingDays:-1];
//      break;
//    case OneWeek:
//      interval = oneDayInterval / 8; //一周取56个样本，3小时一个样本
//      startDate = [currentDate dateByAddingWeek:-1];
//      break;
//    case OneMonth:
//      interval = oneDayInterval / 2; //一个月取60个样本，12小时一个样本
//      startDate = [currentDate dateByAddingMonth:-1];
//      break;
//    case ThreeMonth:
//      interval = 2 * oneDayInterval;
//      startDate = [currentDate dateByAddingMonth:-3];
//      break;
//    case SixMonth:
//      interval = 3 * oneDayInterval;
//      startDate = [currentDate dateByAddingMonth:-6];
//      break;
//    case OneYear:
//      interval = 6 * oneDayInterval;
//      startDate = [currentDate dateByAddingYear:-1];
//      break;
//    default:
//      break;
//  }
//  HistoryElecParam *param = [[HistoryElecParam alloc] init];
//  param.beginTime = [startDate timeIntervalSince1970];
//  param.endTime = timeInterval;
//  param.interval = interval;
//  return param;
//}
//
//- (HistoryElecData *)parseResponse:(NSArray *)responseArray
//                             param:(HistoryElecParam *)param {
//  NSMutableDictionary *needDict = [@{} mutableCopy];
//  int needCount =
//      ((long)param.endTime - (long)param.beginTime) / param.interval + 1;
//  NSString *key;
//  //设置默认值为0
//  for (int i = 0; i < needCount; i++) {
//    key = [NSString
//        stringWithFormat:@"%d", (int)(param.beginTime + i * param.interval)];
//    [needDict setObject:@(0) forKey:key];
//  }
//  //替换服务器响应的数据
//  if (responseArray && responseArray.count) {
//    for (HistoryElecResponse *response in responseArray) {
//      NSString *key = [NSString stringWithFormat:@"%d", response.time];
//      [needDict setObject:@(response.power) forKey:key];
//    }
//  }
//
//  HistoryElecData *data = [[HistoryElecData alloc] init];
//  //  if (param.interval < oneDayInterval) {
//  //    [self.dateFormatter setDateFormat:@"HH:mm"];
//  //  } else {
//  //    [self.dateFormatter setDateFormat:@"MM-dd"];
//  //  }
//  NSMutableArray *times = [@[] mutableCopy];
//  NSMutableArray *values = [@[] mutableCopy];
//  //  NSString *formatterDateStr;
//  int value;
//  //排序后的时间戳
//  NSArray *timeArray = [[needDict allKeys]
//      sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//          return [obj1 intValue] - [obj2 intValue];
//      }];
//  for (NSString *dateInterval in timeArray) {
//    value = [[needDict objectForKey:dateInterval] intValue];
//    [times addObject:dateInterval];
//    [values addObject:@(value)];
//  }
//  [values replaceObjectAtIndex:values.count - 1
//                    withObject:[values objectAtIndex:values.count - 2]];
//  data.times = times;
//  data.values = values;
//  return data;
//}

- (HistoryElecParam *)getParam:(NSTimeInterval)timeInterval
                      dateType:(HistoryElecDateType)dateType {
  long interval = 0;
  NSDate *currentDate = [[NSDate alloc] init];
  int currentYear = currentDate.year;
  int currentMonth = currentDate.month;
  int currentDay = currentDate.day;
  int currentHour = currentDate.hour;
  int currentMinute = currentDate.minute;
  NSDate *startDate;
  NSDate *endDate;
  int type;
  switch (dateType) {
    case OneDay:
      if (currentMinute < 30) {
        currentMinute = 0;
      } else if (currentMinute) {
        currentMinute = 30;
      }
      endDate = [NSDate dateWithYear:currentYear
                               month:currentMonth
                                 day:currentDay
                                hour:currentHour
                              minute:currentMinute
                              second:0];
      startDate = [[endDate dateByAddingDays:-1] dateByAddingMinute:-30];
      type = 0; //间隔半小时
      interval = oneDayInterval / 48;
      break;
    case OneWeek:
      startDate = [[currentDate dateByAddingDays:-7] dateByAddingDays:-1];
      startDate = [startDate dateBySettingHour:0 minute:0 second:0];
      endDate = [currentDate dateByAddingDays:-1];
      endDate = [endDate dateBySettingHour:0 minute:0 second:0];
      type = 1; //间隔1天
      interval = oneDayInterval;
      break;
    case OneMonth:
      startDate = [[currentDate dateByAddingMonth:-1] dateByAddingDays:-1];
      startDate = [startDate dateBySettingHour:0 minute:0 second:0];
      endDate = [currentDate dateByAddingDays:-1];
      endDate = [endDate dateBySettingHour:0 minute:0 second:0];
      type = 1; //间隔1天
      interval = oneDayInterval;
      break;
    case ThreeMonth:
      startDate = [[currentDate dateByAddingMonth:-3] dateByAddingDays:-1];
      startDate = [startDate dateBySettingHour:0 minute:0 second:0];
      endDate = [currentDate dateByAddingDays:-1];
      endDate = [endDate dateBySettingHour:0 minute:0 second:0];
      type = 1;
      interval = oneDayInterval;
      break;
    case SixMonth:
      startDate = [[currentDate dateByAddingMonth:-6] dateByAddingMonth:-1];
      startDate = [startDate dateBySettingHour:0 minute:0 second:0];
      endDate = [[currentDate dateMonthEnd] dateByAddingMonth:-1];
      endDate = [endDate dateBySettingHour:0 minute:0 second:0];
      type = 2;
      interval = oneDayInterval * 31;
      break;
    case OneYear:
      startDate = [[currentDate dateByAddingYear:-1] dateByAddingMonth:-1];
      startDate = [startDate dateBySettingHour:0 minute:0 second:0];
      endDate = [[currentDate dateMonthEnd] dateByAddingMonth:-1];
      endDate = [endDate dateBySettingHour:0 minute:0 second:0];
      type = 2; //间隔1月
      interval = oneDayInterval * 31;
      break;
    default:
      break;
  }
  HistoryElecParam *param = [[HistoryElecParam alloc] init];
  param.beginTime = [startDate timeIntervalSince1970];
  param.endTime = [endDate timeIntervalSince1970];
  param.type = type;
  param.dateType = dateType;
  param.interval = interval;
  return param;
}

//- (HistoryElecData *)parseResponse:(NSArray *)responseArray
//                             param:(HistoryElecParam *)param {
//  NSMutableDictionary *needDict = [@{} mutableCopy];
//  int needCount =
//      ((long)param.endTime - (long)param.beginTime) / param.interval + 1;
//  NSString *key;
//  //设置默认值为0
//  for (int i = 0; i < needCount; i++) {
//    key = [NSString
//        stringWithFormat:@"%d", (int)(param.beginTime + i * param.interval)];
//    [needDict setObject:@(0) forKey:key];
//  }
//  //替换服务器响应的数据
//  if (responseArray && responseArray.count) {
//    for (NSDictionary *response in responseArray) {
//      NSString *key =
//          [NSString stringWithFormat:@"%@", response[@"insertTimes"]];
//      [needDict
//          setObject:[NSString
//                        stringWithFormat:@"%.2f",
//                                         [response[@"md"] doubleValue] / 100]
//             forKey:key];
//    }
//  }
//
//  HistoryElecData *data = [[HistoryElecData alloc] init];
//  NSMutableArray *times = [@[] mutableCopy];
//  NSMutableArray *values = [@[] mutableCopy];
//  //  NSString *formatterDateStr;
//  double value;
//  //排序后的时间戳
//  NSArray *timeArray = [[needDict allKeys]
//      sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//          return [obj1 intValue] - [obj2 intValue];
//      }];
//  for (int i = 0; i < timeArray.count; i++) {
//    NSString *dateInterval = timeArray[i];
//    value = [[needDict objectForKey:dateInterval] doubleValue];
//    [times addObject:dateInterval];
//    if (value == 0 && i > 0) {
//      NSString *preDateInterval = timeArray[i - 1];
//      value = [[needDict objectForKey:preDateInterval] doubleValue];
//      [needDict setObject:@(value) forKey:dateInterval];
//    }
//    [values addObject:@(value)];
//  }
//  //  [values replaceObjectAtIndex:values.count - 1
//  //                    withObject:[values objectAtIndex:values.count - 2]];
//  data.times = times;
//  data.values = values;
//  return data;
//}

- (HistoryElecData *)parseResponse:(NSArray *)responseArray
                             param:(HistoryElecParam *)param {
  NSMutableDictionary *needDict = [@{} mutableCopy];
  //替换服务器响应的数据
  if (responseArray && responseArray.count) {
    for (NSDictionary *response in responseArray) {
      NSString *key =
          [NSString stringWithFormat:@"%@", response[@"insertTimes"]];
      [needDict
          setObject:[NSString
                        stringWithFormat:@"%.2f",
                                         [response[@"md"] doubleValue] / 100]
             forKey:key];
    }
  }

  HistoryElecData *data = [[HistoryElecData alloc] init];
  NSMutableArray *times = [@[] mutableCopy];
  NSMutableArray *values = [@[] mutableCopy];
  double value;
  //排序后的时间戳
  NSArray *timeArray = [[needDict allKeys]
      sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
          return [obj1 intValue] - [obj2 intValue];
      }];
  for (int i = 0; i < timeArray.count; i++) {
    NSString *dateInterval = timeArray[i];
    value = [[needDict objectForKey:dateInterval] doubleValue];
    [times addObject:dateInterval];
    //    if (value == 0 && i > 0) {
    //      NSString *preDateInterval = timeArray[i - 1];
    //      value = [[needDict objectForKey:preDateInterval] doubleValue];
    //      [needDict setObject:@(value) forKey:dateInterval];
    //    }
    [values addObject:@(value)];
  }
  //  [values replaceObjectAtIndex:values.count - 1
  //                    withObject:[values objectAtIndex:values.count - 2]];
  data.times = times;
  data.values = values;
  return data;
}

@end

@implementation HistoryElecResponse
- (id)initWithTime:(int)time power:(int)power {
  self = [super init];
  if (self) {
    self.time = time;
    self.power = power;
  }
  return self;
}
@end
