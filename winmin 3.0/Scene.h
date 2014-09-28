//
//  Scene.h
//  SmartSwitch
//
//  Created by 文正光 on 14-9-2.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Scene : NSObject
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *imageName;
@property(nonatomic, assign)
    NSInteger indentifier;  //数据库的索引，便于后续添加或修改操作
@property(nonatomic, strong) NSArray *detailList;

+ (UIImage *)imgNameToImage:(NSString *)imgName;
@end
