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
@property (nonatomic, strong) IBOutlet UILabel *lblName;
@property (nonatomic, strong) IBOutlet UIView *viewBg;
@property (nonatomic, strong) IBOutlet UIImageView *imgViewScene;
@property (nonatomic, strong) NSString *imgName;
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
    self.lblName.textColor = [UIColor whiteColor];
    NSString *imgNewName = self.imgName;
    if (self.imgName.length < 10) {
      imgNewName = [NSString stringWithFormat:@"%@_", self.imgName];
    }
    self.imgViewScene.image = [Scene imgNameToImage:imgNewName];
  } else {
    self.viewBg.backgroundColor = [UIColor whiteColor];
    self.lblName.textColor = kThemeColor;
    self.imgViewScene.image = [Scene imgNameToImage:self.imgName];
  }
}

- (void)setCellInfo:(id)scene {
  Scene *_scene = (Scene *)scene;
  self.lblName.text = _scene.name;
  self.imgName = _scene.imageName;
  self.imgViewScene.image = [Scene imgNameToImage:_scene.imageName];
}
@end
