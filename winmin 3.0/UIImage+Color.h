//
//  UIImage+Color.h
//  winmin 3.0
//
//  Created by sdzg on 14-9-17.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Color)
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

+ (UIImage *)circleImage:(UIImage *)image withParam:(CGFloat)inset;

+ (UIImage *)grayImage:(UIImage *)sourceImage;
@end
