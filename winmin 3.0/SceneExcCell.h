//
//  SceneExcCell.h
//  winmin 3.0
//
//  Created by sdzg on 14-9-26.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SceneDetail;

@interface SceneExcCell : UITableViewCell
- (void)setSceneDetail:(SceneDetail *)sceneDetail row:(int)row;
- (void)updatePage:(BOOL)success;
@end
