//
//  SceneSwitchListController.m
//  winmin 3.0
//
//  Created by sdzg on 14-12-17.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SceneSwitchListController.h"

@interface SceneSwitchListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgViewOfSwitch;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblMac;
- (void)setCellInfo:(SDZGSwitch *)aSwitch;
@end

@implementation SceneSwitchListCell
- (void)setCellInfo:(SDZGSwitch *)aSwitch {
  self.lblName.text = aSwitch.name;
  BOOL sMac =
      [[[NSUserDefaults standardUserDefaults] objectForKey:showMac] boolValue];
  if (sMac) {
    self.lblMac.text = aSwitch.mac;
  } else {
    self.lblMac.text = @"";
  }
  self.imgViewOfSwitch.image = [SDZGSwitch imgNameToImage:aSwitch.imageName];
}

@end

@interface SceneSwitchListController () <UITableViewDelegate,
                                         UITableViewDataSource>
@property (nonatomic, strong) NSArray *switchs;
@end

@implementation SceneSwitchListController

- (void)setup {
  self.switchs = [[SwitchDataCeneter sharedInstance] switchs];
  [self.btn addTarget:self
                action:@selector(cancelSelectSwitch:)
      forControlEvents:UIControlEventTouchUpInside];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self setup];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 44.f;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return self.switchs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  //  static NSString *cellId = @"SceneSwitchListCell";
  //    = [tableView dequeueReusableCellWithIdentifier:cellId];
  UITableViewCell *cell;
  if (!cell) {
    cell = [[[NSBundle mainBundle] loadNibNamed:@"SceneSwitchListCell"
                                          owner:self
                                        options:nil] objectAtIndex:0];
  }
  SceneSwitchListCell *sceneSwitchListCell = (SceneSwitchListCell *)cell;
  SDZGSwitch *aSwitch = self.switchs[indexPath.row];
  [sceneSwitchListCell setCellInfo:aSwitch];
  return cell;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  SDZGSwitch *aSwitch = self.switchs[indexPath.row];
  if ([self.delegate respondsToSelector:@selector(touchSceneCallbackSwitch:)]) {
    [self.delegate touchSceneCallbackSwitch:aSwitch];
  }
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
- (void)cancelSelectSwitch:(id)sender {
  if ([self.delegate respondsToSelector:@selector(touchSceneCallbackSwitch:)]) {
    [self.delegate touchSceneCallbackSwitch:nil];
  }
}
@end
