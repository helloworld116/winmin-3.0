//
//  SceneEditCell.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-25.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SceneEditCell.h"
#import "SceneDetail.h"

#define kSelectColor kThemeColor
#define kUnselectColor [UIColor colorWithHexString:@"#F0EFEF"]

@interface SceneSocketView : UIView
@property (strong, nonatomic) IBOutlet UIImageView *imgViewSocket1;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewSocket2;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewSocket3;
@property (strong, nonatomic) IBOutlet UIView *bgView;
@property (strong, nonatomic) IBOutlet UILabel *lblStatus;
@property (strong, nonatomic) IBOutlet UIButton *btnOnOff;
@property (strong, nonatomic) IBOutlet UIButton *btnSelected;

@property (assign, nonatomic) int groupId;
@property (strong, nonatomic) NSString *mac;
- (IBAction)onOrOff:(id)sender;
- (IBAction)selectedOrNO:(id)sender;
@end

@implementation SceneSocketView
- (void)awakeFromNib {
  self.lblStatus.layer.cornerRadius = 15.f;
  [self setSelected:NO onOff:NO];
}

- (void)setSelected:(BOOL)selected onOff:(BOOL)onOff {
  if (selected) {
    self.bgView.backgroundColor = kSelectColor;
    self.btnSelected.selected = YES;
  } else {
    self.bgView.backgroundColor = kUnselectColor;
    self.btnSelected.selected = NO;
  }
  if (onOff) {
    self.lblStatus.backgroundColor = kSelectColor;
    self.lblStatus.textColor = [UIColor whiteColor];
    self.lblStatus.text = NSLocalizedString(@"ON_Scene", nil);
    self.btnOnOff.selected = YES;
  } else {
    //默认关闭
    self.lblStatus.backgroundColor = kUnselectColor;
    self.lblStatus.textColor = [UIColor colorWithHexString:@"#CCCCCC"];
    self.lblStatus.text = NSLocalizedString(@"OFF_Scene", nil);
    self.btnOnOff.selected = NO;
  }
}

- (IBAction)onOrOff:(id)sender {
  if (self.btnSelected.selected) {
    self.btnOnOff.selected = !self.btnOnOff.selected;
    if (self.btnOnOff.selected) {
      [self setSelected:YES onOff:YES];
    } else {
      [self setSelected:YES onOff:NO];
    }
    [[DBUtil sharedInstance]
        updateDetailTmpWithSwitchMac:self.mac
                             groupId:self.groupId
                         onOffStatus:self.btnOnOff.selected];
  }
}

- (IBAction)selectedOrNO:(id)sender {
  self.btnSelected.selected = !self.btnSelected.selected;
  if (self.btnSelected.selected) {
    [self setSelected:YES onOff:YES];
    [[DBUtil sharedInstance] addDetailTmpWithSwitchMac:self.mac
                                               groupId:self.groupId];
  } else {
    [self setSelected:NO onOff:NO];
    [[DBUtil sharedInstance] removeDetailTmpWithSwitchMac:self.mac
                                                  groupId:self.groupId];
  }
}

- (void)setSocketInfo:(SDZGSocket *)socket
                  mac:(NSString *)mac
         sceneDetails:(NSArray *)sceneDetails {
  self.mac = mac;
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

  self.imgViewSocket1.image =
      [SDZGSocket imgNameToImage:socket1ImageName status:socket.socketStatus];
  self.imgViewSocket2.image =
      [SDZGSocket imgNameToImage:socket2ImageName status:socket.socketStatus];
  self.imgViewSocket3.image =
      [SDZGSocket imgNameToImage:socket3ImageName status:socket.socketStatus];
  if (sceneDetails && sceneDetails.count) {
    for (SceneDetail *sceneDetail in sceneDetails) {
      if ([sceneDetail.mac isEqualToString:self.mac] &&
          sceneDetail.groupId == self.groupId) {
        [self setSelected:YES onOff:sceneDetail.onOrOff];
        break;
      }
    }
  }
}
@end

@interface SceneEditCell ()
@property (strong, nonatomic) IBOutlet SceneSocketView *sceneSocketView1;
@property (strong, nonatomic) IBOutlet SceneSocketView *sceneSocketView2;
@property (strong, nonatomic) IBOutlet UITextField *textFieldSwitchName;
@property (strong, nonatomic) IBOutlet UIView *topLineView;
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
  self.sceneSocketView1.groupId = 1;
  self.sceneSocketView2.groupId = 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

- (void)setSwitchInfo:(SDZGSwitch *)aSwitch row:(NSInteger)row {
  [self.sceneSocketView1 setSelected:NO onOff:NO];
  [self.sceneSocketView2 setSelected:NO onOff:NO];
  if (row == 0) {
    self.topLineView.hidden = YES;
  } else {
    self.topLineView.hidden = NO;
  }
  self.textFieldSwitchName.text = aSwitch.name;
  NSArray *sceneDetails = [[DBUtil sharedInstance] allSceneDetailsTmp];
  [self.sceneSocketView1 setSocketInfo:aSwitch.sockets[0]
                                   mac:aSwitch.mac
                          sceneDetails:sceneDetails];
  [self.sceneSocketView2 setSocketInfo:aSwitch.sockets[1]
                                   mac:aSwitch.mac
                          sceneDetails:sceneDetails];
}

@end
