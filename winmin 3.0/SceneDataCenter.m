//
//  SceneDataCenter.m
//  SmartSwitch
//
//  Created by sdzg on 14-9-2.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SceneDataCenter.h"
@interface SceneDataCenter ()
@property(nonatomic, strong) NSArray *scenes;
@end

@implementation SceneDataCenter
- (id)init {
  self = [super init];
  if (self) {
    self.scenes = [[DBUtil sharedInstance] scenes];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sceneChanged:)
                                                 name:kSceneDataChanged
                                               object:nil];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:kSceneDataChanged
                                                object:nil];
}

+ (instancetype)sharedInstance {
  static SceneDataCenter *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{ instance = [[SceneDataCenter alloc] init]; });
  return instance;
}

- (NSArray *)scenes {
  return _scenes;
}

- (void)sceneChanged:(NSNotification *)notification {
  self.scenes = [[DBUtil sharedInstance] scenes];
}
@end
