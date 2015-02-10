//
//  SwitchRestartModel.h
//  winmin 3.0
//
//  Created by sdzg on 15-2-4.
//  Copyright (c) 2015年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface SwitchRestartModel : NSObject
- (void)resetDeviceMove:(NSString *)switchMac
                   flag:(int)flag
             completion:(HttpCompletionBlock)completion;
@end
