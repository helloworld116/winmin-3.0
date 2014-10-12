//
//  SwitchListViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-16.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SwitchListViewController.h"
#import "SwitchDetailViewController.h"
#import "SwitchListCell.h"
#import "SwitchListModel.h"

@interface SwitchListViewController () <UIActionSheetDelegate>
@property (nonatomic, strong) SwitchListModel *model;
@property (nonatomic, strong) NSArray *switchs;
@property (nonatomic, strong) NSIndexPath *longPressIndexPath;
@property (nonatomic, strong) UIView *noDataView;
@end

@implementation SwitchListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)setupStyle {
  UIView *view = [[UIView alloc] init];
  view.backgroundColor = [UIColor clearColor];
  self.tableView.tableFooterView = view;

  UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
  backButtonItem.title = @"返回";
  self.navigationItem.backBarButtonItem = backButtonItem;
}

- (void)setup {
  [self setupStyle];
  self.noDataView =
      [[UIView alloc] initWithSize:self.view.frame.size
                           imgName:@"noswitch"
                           message:@"您暂时还未添加任何设备"];
  self.noDataView.hidden = YES;
  [self.view addSubview:self.noDataView];
  self.switchs = [[SwitchDataCeneter sharedInstance] switchsWithChangeStatus];
  if (!self.switchs || self.switchs.count == 0) {
    self.noDataView.hidden = NO;
  } else {
    [self.tableView reloadData];
  }
  self.model = [[SwitchListModel alloc] init];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateSwitchList:)
                                               name:kSwitchUpdate
                                             object:nil];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(netChangedNotification:)
             name:kNetChangedNotification
           object:nil];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.model startScan];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  [self.model stopScan];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 通知
- (void)updateSwitchList:(NSNotification *)notification {
  //  if (notification.object == self.model) {
  //
  //  }
  self.switchs = [[SwitchDataCeneter sharedInstance] switchsWithChangeStatus];
  if (!self.switchs || self.switchs.count == 0) {
    self.noDataView.hidden = NO;
  } else {
    dispatch_async(MAIN_QUEUE, ^{
        self.noDataView.hidden = YES;
        [self.tableView reloadData];
    });
  }
}

- (void)netChangedNotification:(NSNotification *)notification {
  NetworkStatus status = kSharedAppliction.networkStatus;
  if (status == NotReachable) {
    //网络不可用时修改所有设备状态为离线并停止扫描
    [self.model stopScan];
    [[SwitchDataCeneter sharedInstance] updateAllSwitchStautsToOffLine];
    [self.tableView reloadData];
  } else {
    if (!self.model.isScanning) {
      [self.model startScan];
    }
  }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return [self.switchs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellId = @"SwitchListCell";
  SwitchListCell *cell =
      [self.tableView dequeueReusableCellWithIdentifier:CellId];

  SDZGSwitch *aSwitch = [self.switchs objectAtIndex:indexPath.row];
  [cell setCellInfo:aSwitch];
  UILongPressGestureRecognizer *longPressGesture =
      [[UILongPressGestureRecognizer alloc]
          initWithTarget:self
                  action:@selector(handlerLongPress:)];
  longPressGesture.minimumPressDuration = 0.5;
  [cell addGestureRecognizer:longPressGesture];
  return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  SDZGSwitch *aSwitch = [self.switchs objectAtIndex:indexPath.row];
  if (aSwitch.networkStatus == SWITCH_OFFLINE) {
    [self.view makeToast:@"设" @"备" @"已" @"离"
               @"线,请检查手机或设备网络情况"];
    return;
  }

  SwitchDetailViewController *detailViewController = [self.storyboard
      instantiateViewControllerWithIdentifier:@"SwitchDetailViewController"];
  detailViewController.aSwitch = aSwitch;
  [self.navigationController pushViewController:detailViewController
                                       animated:YES];
}

#pragma mark - 长按处理
- (void)handlerLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
  CGPoint p = [gestureRecognizer locationInView:self.tableView];
  NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
  //  SDZGSwitch *aSwitch = [self.switchs objectAtIndex:indexPath.row];
  if (indexPath && gestureRecognizer.state == UIGestureRecognizerStateBegan) {
    self.longPressIndexPath = indexPath;
    //    if (aSwitch.lockStatus == LockStatusOn) {
    //      UIActionSheet *actionSheet = [[UIActionSheet alloc]
    //                   initWithTitle:@"请选择操作"
    //                        delegate:self
    //               cancelButtonTitle:@"取消"
    //          destructiveButtonTitle:nil
    //               otherButtonTitles:@"解锁", @"闪烁", @"删除", nil];
    //      [actionSheet showInView:self.view];
    //    } else {
    //      UIActionSheet *actionSheet = [[UIActionSheet alloc]
    //                   initWithTitle:@"请选择操作"
    //                        delegate:self
    //               cancelButtonTitle:@"取消"
    //          destructiveButtonTitle:nil
    //               otherButtonTitles:@"加锁", @"闪烁", @"删除", nil];
    //      [actionSheet showInView:self.view];
    //    }
    UIActionSheet *actionSheet =
        [[UIActionSheet alloc] initWithTitle:@"请选择操作"
                                    delegate:self
                           cancelButtonTitle:@"取消"
                      destructiveButtonTitle:nil
                           otherButtonTitles:@"闪烁", @"删除", nil];
    //    [actionSheet showInView:self.view];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
  }
}

- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  SDZGSwitch *aSwitch =
      [self.switchs objectAtIndex:self.longPressIndexPath.row];
  switch (buttonIndex) {
    //    case 0:
    //      //加锁
    //      if ([self.switchTableViewDelegate
    //              respondsToSelector:@selector(changeSwitchLockStatus:)]) {
    //        [self.switchTableViewDelegate changeSwitchLockStatus:aSwitch];
    //      }
    //      break;
    case 0:
      //闪烁
      [self.model blinkSwitch:aSwitch];
      break;
    case 1:
      //删除
      [[SwitchDataCeneter sharedInstance] removeSwitch:aSwitch];
      break;
    default:
      break;
  }
}
@end
