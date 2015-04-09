//
//  SensorModel.h
//  winmin 3.0
//
//  Created by sdzg on 15-4-9.
//  Copyright (c) 2015年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SensorModel : NSObject
typedef void (^CityWeatherBlock)(CityEnvironment *cityEnviroment);
typedef void (^SensorDataBlock)(SensorInfo *sensorInfo);
- (id)initWithSwitch:(SDZGSwitch *)aSwitch;
@end
