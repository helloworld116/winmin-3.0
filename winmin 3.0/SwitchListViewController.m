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

@interface SwitchListViewController ()<
    UIActionSheetDelegate, UIAlertViewDelegate, EGORefreshTableHeaderDelegate>
@property (nonatomic, strong) SwitchListModel *model;
@property (nonatomic, strong) SDZGSwitch *operationSwitch; //当前操作的switch
@property (nonatomic, strong) NSArray *switchs;
@property (nonatomic, strong) NSIndexPath *longPressIndexPath;
@property (nonatomic, strong) UIView *noDataView;

@property (strong, nonatomic) EGORefreshTableHeaderView *refreshHeaderView;
@property (assign, nonatomic) BOOL reloading;
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
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(doneLoadingTableViewData)
             name:kNewSwitch
           object:self.model];

  [[NSNotificationCenter defaultCenter]
      addObserverForName:kConfigNewSwitch
                  object:nil
                   queue:nil
              usingBlock:^(NSNotification *note) {
                  NSString *mac = note.userInfo[@"mac"];
                  SDZGSwitch *aSwitch =
                      [SwitchDataCeneter sharedInstance].switchsDict[mac];
                  if (aSwitch) {
                    aSwitch.networkStatus = SWITCH_NEW;
                  } else {
                    [self.model refreshSwitchList];
                  }
              }];

  //下拉刷新
  self.refreshHeaderView = [[EGORefreshTableHeaderView alloc]
       initWithFrame:CGRectMake(0.0f, 0.0f - self.view.bounds.size.height,
                                self.view.frame.size.width,
                                self.view.bounds.size.height)
      arrowImageName:@"grayArrow"
           textColor:[UIColor grayColor]];
  self.refreshHeaderView.backgroundColor = [UIColor whiteColor];
  self.refreshHeaderView.delegate = self;
  [self.view addSubview:self.refreshHeaderView];
  [self.refreshHeaderView refreshLastUpdatedDate];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.model startScanState];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  [self.model stopScanState];
}

#pragma mark - begin iOS8下cell分割线处理
#ifdef __IPHONE_8_0
- (void)viewDidLayoutSubviews {
  if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
  }

  if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
  }
}

- (void)tableView:(UITableView *)tableView
      willDisplayCell:(UITableViewCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
    [cell setSeparatorInset:UIEdgeInsetsZero];
  }

  if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
    [cell setLayoutMargins:UIEdgeInsetsZero];
  }
}
#endif
#pragma mark - end iOS8下cell分割线处理

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 通知
- (void)updateSwitchList:(NSNotification *)notification {
  self.switchs = [[SwitchDataCeneter sharedInstance] switchsWithChangeStatus];
  dispatch_async(MAIN_QUEUE, ^{
      if (!self.switchs || self.switchs.count == 0) {
        self.noDataView.hidden = NO;
      } else {
        self.noDataView.hidden = YES;
      }
      [self.tableView reloadData];
  });
}

- (void)netChangedNotification:(NSNotification *)notification {
  NetworkStatus status = kSharedAppliction.networkStatus;
  if (status == NotReachable) {
    //网络不可用时修改所有设备状态为离线并停止扫描
    [self.model stopScanState];
    [[SwitchDataCeneter sharedInstance] updateAllSwitchStautsToOffLine];
    [self.tableView reloadData];
  } else {
    if (!self.model.isScanningState) {
      [self.model startScanState];
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
  UIView *myBackView = [[UIView alloc] initWithFrame:cell.frame];
  myBackView.backgroundColor = [UIColor colorWithHexString:@"#F6F4F4"];
  cell.selectedBackgroundView = myBackView;
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
  if (aSwitch.networkStatus == SWITCH_NEW) {
    aSwitch.networkStatus = SWITCH_LOCAL;
    [[SwitchDataCeneter sharedInstance] updateSwitch:aSwitch];
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
  self.operationSwitch =
      [self.switchs objectAtIndex:self.longPressIndexPath.row];
  switch (buttonIndex) {
    case 0:
      //闪烁
      [self.model blinkSwitch:self.operationSwitch];
      break;
    case 1: {
      UIAlertView *alertView = [[UIAlertView alloc]
              initWithTitle:@"温馨提示"
                    message:@"删"
                    @"除设备将删除该设备关联下的所有"
                    @"场景，是否继续删除该设备？"
                   delegate:self
          cancelButtonTitle:@"取消"
          otherButtonTitles:@"确定", nil];
      [alertView show];
      break;
    }
    default:
      break;
  }
}

- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  switch (buttonIndex) {
    case 0:
      break;
    case 1:
      //删除
      [self.model deleteSwitch:self.operationSwitch];
      break;
    default:
      break;
  }
}

#pragma mark - Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource {
  //  should be calling your tableviews data source model to reload
  [self.model refreshSwitchList];
  _reloading = YES;
}

- (void)doneLoadingTableViewData {
  //  model should call this when its done loading
  dispatch_async(MAIN_QUEUE, ^{
      _reloading = NO;
      [_refreshHeaderView
          egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
  });
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
  [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:
            (EGORefreshTableHeaderView *)view {
  [self reloadTableViewDataSource];
  [self performSelector:@selector(doneLoadingTableViewData)
             withObject:nil
             afterDelay:3.0];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:
            (EGORefreshTableHeaderView *)view {
  return _reloading; // should return if data source model is reloading
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:
                (EGORefreshTableHeaderView *)view {
  return [NSDate date]; // should return date data source was last changed
}

@end
