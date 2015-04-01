//
//  FirewareUpdateViewController.m
//  winmin 3.0
//
//  Created by sdzg on 15-1-27.
//  Copyright (c) 2015年 itouchco.com. All rights reserved.
//

#import "FirewareUpdateViewController.h"
#import "FirewareModel.h"
@interface FirewareInfoCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblValue;
@end

@interface FirewareUpdateCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UIButton *btnUpdate;
@end

@interface FirewareUpdateViewController () <
    UITableViewDataSource, MBProgressHUDDelegate, UIAlertViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *infos;
@property (nonatomic, strong) FirewareModel *model;
@property (nonatomic, strong) NSString *deviceType;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSString *lastVersionInServer;
@property (nonatomic, strong) NSString *deviceVersion;
@property (nonatomic, strong) NSTimer *timer; //终止更新线程
@property (nonatomic, strong)
    NSTimer *timerCheck; //升级成功广播包未收到，检查固件是否已更新
@property (nonatomic, assign) BOOL isFinishedUpdate; //更新固件操作是否已结束
- (IBAction)updateAction:(id)sender;
@end

@implementation FirewareInfoCell

@end

@implementation FirewareUpdateCell

@end

@implementation FirewareUpdateViewController
- (void)setup {
  NSString *lastFirewareVersion =
      kSharedAppliction.dictOfFireware[self.aSwitch.deviceType];
  NSString *deviceFirewareVersion = self.aSwitch.firewareVersion;
  NSString *deviceType = self.aSwitch.deviceType;
  if (!lastFirewareVersion) {
    lastFirewareVersion = @"";
  }
  if (!deviceType) {
    deviceType = @"";
  }
  if (!deviceFirewareVersion) {
    deviceFirewareVersion = @"";
  }
  self.lastVersionInServer = lastFirewareVersion;
  self.deviceVersion = deviceFirewareVersion;
  self.deviceType = deviceType;
  self.infos = @[
    @{
      @"title" : NSLocalizedString(@"Device_Name", nil),
      @"value" : self.aSwitch.name
    },
    @{
      @"title" : NSLocalizedString(@"Device_Mac", nil),
      @"value" : self.aSwitch.mac
    },
    [@{
      @"title" : NSLocalizedString(@"Device_Type", nil),
      @"value" : deviceType
    } mutableCopy],
    [@{
      @"title" : NSLocalizedString(@"Device_FirewareVersion", nil),
      @"value" : deviceFirewareVersion
    } mutableCopy],
    [@{
      @"title" : NSLocalizedString(@"Device_LastVesion", nil),
      @"value" : lastFirewareVersion
    } mutableCopy],
    @{
      @"title" : NSLocalizedString(@"Upgrade", nil),
      @"value" : @""
    }
  ];

  [self.view addSubview:self.hud];
  self.navigationItem.title = NSLocalizedString(@"Fireware Upgrade", nil);
  self.tableView.dataSource = self;
  self.model = [[FirewareModel alloc] initWithSwitch:self.aSwitch];
  [self.model getSwitchFirewareInfo:^(NSString *firewareVersion,
                                      NSString *deviceType_) {
    DDLogDebug(@"local version is %@ and type is %@", firewareVersion,
               _deviceType);
    self.deviceType = deviceType_;
    self.deviceVersion = firewareVersion;
    [self.infos[2] setValue:deviceType_ forKey:@"value"];
    [self.infos[3] setValue:firewareVersion forKey:@"value"];
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.tableView reloadData];
      [self setUpdateBtnEnable];
    });
  }];

  [self.model
      getFirewareInfoWithType:self.aSwitch.deviceType
                   completion:^(NSString *firewareVersion,
                                NSString *deviceType_) {
                     DDLogDebug(@"server version is %@ and type is %@",
                                firewareVersion, _deviceType);
                     kSharedAppliction.dictOfFireware[self.aSwitch.deviceType] =
                         firewareVersion;
                     if (firewareVersion &&
                         ![firewareVersion
                             isEqualToString:lastFirewareVersion]) {
                       [self.infos[4] setValue:firewareVersion forKey:@"value"];
                       self.lastVersionInServer = firewareVersion;
                       dispatch_async(dispatch_get_main_queue(), ^{
                         [self.tableView reloadData];
                         [self setUpdateBtnEnable];
                       });
                     }
                   }];
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

- (void)dealloc {
  self.model = nil;
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

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return self.infos.count;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell;
  static NSString *CellId1 = @"FirewareInfoCell";
  static NSString *CellId2 = @"FirewareUpdateCell";
  if (indexPath.row < 5) {
    FirewareInfoCell *infoCell = (FirewareInfoCell *)
        [self.tableView dequeueReusableCellWithIdentifier:CellId1
                                             forIndexPath:indexPath];
    infoCell.lblTitle.text = self.infos[indexPath.row][@"title"];
    infoCell.lblValue.text = self.infos[indexPath.row][@"value"];
    cell = infoCell;
  } else {
    FirewareUpdateCell *updateCell = (FirewareUpdateCell *)
        [self.tableView dequeueReusableCellWithIdentifier:CellId2
                                             forIndexPath:indexPath];
    updateCell.lblTitle.text = self.infos[indexPath.row][@"title"];
    [updateCell.btnUpdate
        setBackgroundImage:[UIImage imageNamed:@"update_enable"]
                  forState:UIControlStateNormal];
    [updateCell.btnUpdate
        setBackgroundImage:[UIImage imageNamed:@"update_disable"]
                  forState:UIControlStateDisabled];
    [updateCell.btnUpdate setTitleColor:[UIColor whiteColor]
                               forState:UIControlStateNormal];
    [updateCell.btnUpdate setTitleColor:[UIColor grayColor]
                               forState:UIControlStateDisabled];
    cell = updateCell;
  }
  return cell;
}

- (void)setUpdateBtnEnable {
  FirewareUpdateCell *cell =
      (FirewareUpdateCell *)[[self.tableView visibleCells] lastObject];
  NSComparisonResult compareResult =
      [self.lastVersionInServer compare:self.deviceVersion];
  if (compareResult == NSOrderedAscending || compareResult == NSOrderedSame) {
    cell.btnUpdate.enabled = NO;
  } else {
    if (self.aSwitch.networkStatus == SWITCH_LOCAL &&
        kSharedAppliction.networkStatus == ReachableViaWiFi) {
      cell.btnUpdate.enabled = YES;
    } else {
      cell.btnUpdate.enabled = NO;
    }
  }
}

- (IBAction)updateAction:(id)sender {
  UIAlertView *alertView = [[UIAlertView alloc]
          initWithTitle:NSLocalizedString(@"Notice", nil)
                message:NSLocalizedString(@"UpdateFirewareWarn", nil)
               delegate:self
      cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
      otherButtonTitles:NSLocalizedString(@"Sure", nil), nil];
  [alertView show];
}

- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  switch (buttonIndex) {
    case 0:
      break;
    case 1:
      [self doUpdate];
      break;
    default:
      break;
  }
}

- (void)doUpdate {
  static NSTimeInterval time = 200.f;
  [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
  self.isFinishedUpdate = NO;
  //超过指定时间，自动停止更新固件
  self.timer = [NSTimer timerWithTimeInterval:0
                                       target:self
                                     selector:@selector(checkUpdateProgress:)
                                     userInfo:nil
                                      repeats:NO];
  [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:time]];
  [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
  //未收到升级成功的广播包，检查设备最新固件
  self.timerCheck =
      [NSTimer timerWithTimeInterval:10
                              target:self
                            selector:@selector(checkSiwtchLastFirewareVersion:)
                            userInfo:nil
                             repeats:YES];
  [self.timerCheck
      setFireDate:[NSDate dateWithTimeIntervalSinceNow:time - 100]];
  [[NSRunLoop mainRunLoop] addTimer:self.timerCheck
                            forMode:NSRunLoopCommonModes];

  self.hud = [[MBProgressHUD alloc] initWithWindow:kSharedAppliction.window];
  [kSharedAppliction.window addSubview:self.hud];
  self.hud.dimBackground = YES;
  self.hud.labelText = @"";
  self.hud.delegate = self;
  [self.hud show:YES];
  [self.model
      checkFirewareWithDeviceType:self.deviceType
                       completion:^(BOOL needContinue, BOOL success,
                                    NSString *msg) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                           self.hud.labelText = msg;
                           if (needContinue) {

                           } else {
                             [[UIApplication sharedApplication]
                                 setIdleTimerDisabled:NO];
                             self.isFinishedUpdate = YES;
                             [self.timer invalidate];
                             self.timer = nil;
                             [self.timerCheck invalidate];
                             self.timerCheck = nil;
                             [self.hud hide:YES afterDelay:2];
                             self.hud.mode = MBProgressHUDModeCustomView;
                             if (success) {
                               self.hud.customView = [[UIImageView alloc]
                                   initWithImage:
                                       [UIImage imageNamed:@"update_success"]];
                               [self.infos[3] setValue:self.lastVersionInServer
                                                forKey:@"value"];
                               [self.tableView reloadData];
                               self.aSwitch.firewareVersion =
                                   self.lastVersionInServer;
                               self.deviceVersion = self.lastVersionInServer;
                               [self setUpdateBtnEnable];
                               [kSharedAppliction.dictOfFireware
                                   setObject:self.lastVersionInServer
                                      forKey:self.deviceType];
                             } else {
                               self.hud.customView = [[UIImageView alloc]
                                   initWithImage:
                                       [UIImage imageNamed:@"update_failure"]];
                             }
                           }
                         });
                       }];
}

- (void)checkUpdateProgress:(NSTimer *)timer {
  if (!self.isFinishedUpdate) {
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    self.isFinishedUpdate = YES;
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.labelText = @"固件更新出错";
    self.hud.customView = [[UIImageView alloc]
        initWithImage:[UIImage imageNamed:@"update_failure"]];
    [self.hud hide:YES afterDelay:2];
  }
}

- (void)checkSiwtchLastFirewareVersion:(NSTimer *)timer {
  //  if (!self.isFinishedUpdate) {
  //    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
  //    self.isFinishedUpdate = YES;
  //    self.hud.mode = MBProgressHUDModeCustomView;
  //    self.hud.labelText = @"固件更新出错";
  //    self.hud.customView = [[UIImageView alloc]
  //        initWithImage:[UIImage imageNamed:@"update_failure"]];
  //    [self.hud hide:YES afterDelay:2];
  //  }
  [self.model
      getFirewareInfoWithType:self.aSwitch.deviceType
                   completion:^(NSString *firewareVersion,
                                NSString *deviceType_) {
                     if ([self.lastVersionInServer
                             isEqualToString:firewareVersion]) {
                       //已是最新版本
                       dispatch_async(dispatch_get_main_queue(), ^{
                         [[UIApplication sharedApplication]
                             setIdleTimerDisabled:NO];
                         self.isFinishedUpdate = YES;
                         [self.timer invalidate];
                         self.timer = nil;
                         [self.timerCheck invalidate];
                         self.timerCheck = nil;
                         [self.hud hide:YES afterDelay:2];
                         self.hud.mode = MBProgressHUDModeCustomView;
                         self.hud.customView = [[UIImageView alloc]
                             initWithImage:[UIImage
                                               imageNamed:@"update_success"]];
                         [self.infos[3] setValue:self.lastVersionInServer
                                          forKey:@"value"];
                         [self.tableView reloadData];
                         self.aSwitch.firewareVersion =
                             self.lastVersionInServer;
                         self.deviceVersion = self.lastVersionInServer;
                         [self setUpdateBtnEnable];
                         [kSharedAppliction.dictOfFireware
                             setObject:self.lastVersionInServer
                                forKey:self.deviceType];
                       });
                     }
                   }];
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud {
  // Remove HUD from screen when the HUD was hidded
  [self.hud removeFromSuperview];
  self.hud = nil;
}
@end
