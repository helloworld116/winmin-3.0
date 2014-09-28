//
//  Scene.m
//  SmartSwitch
//
//  Created by 文正光 on 14-9-2.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "Scene.h"

@implementation Scene
+ (UIImage *)imgNameToImage:(NSString *)imgName {
  UIImage *image;
  if (imgName.length < 10) {
    image = [UIImage imageNamed:imgName];
  } else {
    image = [UIImage
        imageWithContentsOfFile:[PATH_OF_DOCUMENT
                                    stringByAppendingPathComponent:imgName]];
    if (!image) {
      image = [UIImage imageNamed:switch_default_image];
    } else {
      image = [UIImage circleImage:image withParam:0];
    }
  }
  return image;
}

@end
