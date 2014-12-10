//
//  FeedbackModel.h
//  winmin 3.0
//
//  Created by sdzg on 14-12-10.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>
const int FeedbackSuccessCode;
typedef NS_OPTIONS(NSUInteger, FeedbackType){
  FeedbackOther, FeedbackQuestion, FeedbackSuggestion, FeedbackUsage,
};
@interface FeedbackModel : NSObject
- (void)requestWithFeedbackType:(FeedbackType)type
                         detail:(NSString *)detail
                          email:(NSString *)email
                     completion:(void (^)(BOOL result))compeltion;
@end
