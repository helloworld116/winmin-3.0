//
//  DatePickerViewController.h
//  winmin 3.0
//
//  Created by sdzg on 14-9-24.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DatePickerControllerDelegate<NSObject>
- (void)okBtnClicked:(UIViewController *)viewController
         passSeconds:(int)seconds
          dateString:(NSString *)dateString;
- (void)cancelBtnClicked:(UIViewController *)viewController;
@end

@interface DatePickerViewController : UIViewController
@property(nonatomic, assign) id<DatePickerControllerDelegate> delegate;
@end
