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

- (id)copyWithZone:(NSZone *)zone {
  Scene *copy = [[[self class] allocWithZone:zone] init];
  copy->_name = [_name copy];
  copy->_imageName = [_imageName copy];
  copy->_indentifier = _indentifier;
  copy->_detailList = [_detailList mutableCopy];
  return copy;
}
@end
