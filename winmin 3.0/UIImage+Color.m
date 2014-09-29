//
//  UIImage+Color.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-17.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "UIImage+Color.h"

@implementation UIImage (Color)
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
  CGRect rect = CGRectMake(0, 0, size.width, size.height);
  UIGraphicsBeginImageContext(rect.size);
  CGContextRef context = UIGraphicsGetCurrentContext();

  CGContextSetFillColorWithColor(context, [color CGColor]);
  CGContextFillRect(context, rect);
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

+ (UIImage *)circleImage:(UIImage *)image withParam:(CGFloat)inset {
  UIGraphicsBeginImageContext(image.size);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetLineWidth(context, 0.1);
  CGContextSetStrokeColorWithColor(context, kThemeColor.CGColor);
  CGRect rect = CGRectMake(inset, inset, image.size.width - inset * 2.0f,
                           image.size.height - inset * 2.0f);
  CGContextAddEllipseInRect(context, rect);
  CGContextClip(context);

  [image drawInRect:rect];
  CGContextAddEllipseInRect(context, rect);
  CGContextStrokePath(context);
  UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newimg;
}

+ (UIImage *)grayImage:(UIImage *)sourceImage {
  int bitmapInfo = kCGImageAlphaNone;
  int width = sourceImage.size.width;
  int height = sourceImage.size.height;
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
  CGContextRef context = CGBitmapContextCreate(nil, width, height,
                                               8,  // bits per component
                                               0, colorSpace, bitmapInfo);
  CGColorSpaceRelease(colorSpace);
  if (context == NULL) {
    return nil;
  }
  CGContextDrawImage(context, CGRectMake(0, 0, width, height),
                     sourceImage.CGImage);
  UIImage *grayImage =
      [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
  CGContextRelease(context);
  return grayImage;
}

@end
