//
//  SwitchSyncService.h
//  winmin 3.0
//
//  Created by sdzg on 14-11-15.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^SyncDeviceCompletionBlcok)(BOOL isSuccess);

@interface SwitchSyncService : NSObject
- (void)uploadSwitchs:(SyncDeviceCompletionBlcok)block;
- (void)downloadSwitchs;
@end
