//
//  SceneCell.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-25.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SceneCell.h"
#import "Scene.h"

@interface SceneCell ()
@property(nonatomic, strong) IBOutlet UILabel *lblName;
@property(nonatomic, strong) IBOutlet UIView *viewBg;
@property(nonatomic, strong) IBOutlet UIImageView *imgViewScene;
@end

@implementation SceneCell

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
  }
  return self;
}

- (void)awakeFromNib {
  self.viewBg.layer.cornerRadius = 15.f;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)setSelected:(BOOL)selected {
  if (selected) {
    self.viewBg.backgroundColor = kThemeColor;
    //        self.imgViewScene.image
  } else {
    self.viewBg.backgroundColor = [UIColor whiteColor];
  }
}

- (void)setCellInfo:(id)scene {
  Scene *_scene = (Scene *)scene;
  self.lblName.text = _scene.name;
  self.imgViewScene.image = [Scene imgNameToImage:_scene.imageName];
}
@end
