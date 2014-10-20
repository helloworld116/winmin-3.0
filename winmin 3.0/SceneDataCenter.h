//
//  SceneDataCenter.h
//  SmartSwitch
//
//  Created by sdzg on 14-9-2.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SceneDataCenter : NSObject
+ (instancetype)sharedInstance;

- (NSArray *)scenes;
@end
