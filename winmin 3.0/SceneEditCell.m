//
//  SceneEditCell.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-25.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SceneEditCell.h"
#define kSelectColor kThemeColor
#define kUnselectColor [UIColor colorWithHexString:@"#F0EFEF"]

@interface SceneSocketView : UIView
@property(strong, nonatomic) IBOutlet UIImageView *imgViewSocket1;
@property(strong, nonatomic) IBOutlet UIImageView *imgViewSocket2;
@property(strong, nonatomic) IBOutlet UIImageView *imgViewSocket3;
@property(strong, nonatomic) IBOutlet UIView *bgView;
@property(strong, nonatomic) IBOutlet UILabel *lblStatus;
@property(strong, nonatomic) IBOutlet UIButton *btnOnOff;
- (IBAction)btnTouched:(id)sender;
@end

@implementation SceneSocketView
- (void)awakeFromNib {
  self.lblStatus.layer.cornerRadius = 15.f;
  //默认关闭
  self.lblStatus.backgroundColor = kUnselectColor;
  self.lblStatus.textColor = [UIColor colorWithHexString:@"#CCCCCC"];
  self.lblStatus.text = @"关";
  self.bgView.backgroundColor = kUnselectColor;
}

- (IBAction)btnTouched:(id)sender {
  self.btnOnOff.selected = !self.btnOnOff.selected;
  if (self.btnOnOff.selected) {
    self.lblStatus.backgroundColor = kSelectColor;
    self.lblStatus.textColor = [UIColor whiteColor];
    self.lblStatus.text = @"开";
    self.bgView.backgroundColor = kSelectColor;
  } else {
    self.lblStatus.backgroundColor = kUnselectColor;
    self.lblStatus.textColor = [UIColor colorWithHexString:@"#CCCCCC"];
    self.lblStatus.text = @"关";
    self.bgView.backgroundColor = kUnselectColor;
  }
}

- (void)setSocketInfo:(SDZGSocket *)socket {
  NSString *socket1ImageName = socket.imageNames[0];
  socket1ImageName = socket1ImageName.length < 10
                         ? [NSString stringWithFormat:@"%@_", socket1ImageName]
                         : socket1ImageName;
  NSString *socket2ImageName = socket.imageNames[1];
  socket2ImageName = socket2ImageName.length < 10
                         ? [NSString stringWithFormat:@"%@_", socket2ImageName]
                         : socket2ImageName;
  NSString *socket3ImageName = socket.imageNames[2];
  socket3ImageName = socket3ImageName.length < 10
                         ? [NSString stringWithFormat:@"%@_", socket3ImageName]
                         : socket3ImageName;

  self.imgViewSocket1.image = [SDZGSocket imgNameToImage:socket1ImageName];
  self.imgViewSocket2.image = [SDZGSocket imgNameToImage:socket2ImageName];
  self.imgViewSocket3.image = [SDZGSocket imgNameToImage:socket3ImageName];
}
@end

@interface SceneEditCell ()
@property(strong, nonatomic) IBOutlet SceneSocketView *sceneSocketView1;
@property(strong, nonatomic) IBOutlet SceneSocketView *sceneSocketView2;
@property(strong, nonatomic) IBOutlet UITextField *textFieldSwitchName;
@property(strong, nonatomic) IBOutlet UIView *topLineView;
@end

@implementation SceneEditCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    // Initialization code
  }
  return self;
}

- (void)awakeFromNib {
  // Initialization code
  self.textFieldSwitchName.layer.borderColor = [kThemeColor CGColor];
  self.textFieldSwitchName.layer.borderWidth = 1.f;
  self.textFieldSwitchName.layer.cornerRadius = 12.f;
  self.textFieldSwitchName.enabled = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

- (void)setSwitchInfo:(SDZGSwitch *)aSwitch row:(NSInteger)row {
  if (row == 0) {
    self.topLineView.hidden = YES;
  } else {
    self.topLineView.hidden = NO;
  }
  self.textFieldSwitchName.text = aSwitch.name;
  [self.sceneSocketView1 setSocketInfo:aSwitch.sockets[0]];
  [self.sceneSocketView2 setSocketInfo:aSwitch.sockets[1]];
}

@end