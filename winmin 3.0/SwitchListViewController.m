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

@interface SwitchListViewController () <
    UIActionSheetDelegate, UIAlertViewDelegate, EGORefreshTableHeaderDelegate>
@property (nonatomic, strong) SwitchListModel *model;
@property (nonatomic, strong) SDZGSwitch *operationSwitch; //当前操作的switch
@property (nonatomic, strong) NSArray *switchs;
@property (nonatomic, strong) NSIndexPath *longPressIndexPath;
@property (nonatomic, strong) UIView *noDataView;
@property (nonatomic, strong) NSTimer *timerUpdateList;
@property (nonatomic, assign)
    float delayInterval; //设备状态请求成功后，延时多长时间刷新页面上的设备状态
@property (strong, nonatomic) EGORefreshTableHeaderView *refreshHeaderView;
@property (assign, nonatomic) BOOL reloading;
@property (nonatomic, strong) NSString *mac; //刚配置好的设备mac
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
  backButtonItem.title = NSLocalizedString(@"Back", nil);
  self.navigationItem.backBarButtonItem = backButtonItem;

  self.tableView.showsVerticalScrollIndicator = NO;
}

- (void)setup {
  [self setupStyle];
  self.delayInterval = 1.f;
  self.noDataView = [[UIView alloc]
      initWithSize:self.view.frame.size
           imgName:@"noswitch"
           message:NSLocalizedString(@"You have not configure any device!",
                                     nil)];
  self.noDataView.hidden = YES;
  [self.view addSubview:self.noDataView];

  NSArray *switchs = [[SwitchDataCeneter sharedInstance] switchs];
  //  NSSortDescriptor *netDescriptor =
  //      [[NSSortDescriptor alloc] initWithKey:@"networkStatus" ascending:YES];
  //  NSSortDescriptor *macDescriptor =
  //      [[NSSortDescriptor alloc] initWithKey:@"mac" ascending:YES];
  //  [switchs sortedArrayUsingDescriptors:@[ netDescriptor, macDescriptor ]];
  self.switchs = switchs;
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
  //  [[NSNotificationCenter defaultCenter]
  //      addObserver:self
  //         selector:@selector(doneLoadingTableViewData)
  //             name:kNewSwitch
  //           object:self.model];

  [[NSNotificationCenter defaultCenter]
      addObserverForName:kConfigNewSwitch
                  object:nil
                   queue:nil
              usingBlock:^(NSNotification *note) {
                  NSString *mac = note.userInfo[@"mac"];
                  [self.model addSwitchWithMac:mac];
                  dispatch_async(MAIN_QUEUE, ^{ [self.tableView reloadData]; });
                  //                  self.mac = mac;
                  //                  SDZGSwitch *aSwitch =
                  //                      [SwitchDataCeneter
                  //                      sharedInstance].switchsDict[mac];
                  //                  NSArray *switchs = [[SwitchDataCeneter
                  //                          sharedInstance]
                  //                          switchsWithChangeStatus];
                  //                  if (aSwitch) {
                  //                    aSwitch.networkStatus = SWITCH_NEW;
                  //                    aSwitch.name = NSLocalizedString(@"Smart
                  //                    Switch", nil);
                  //                    self.switchs = switchs;
                  //                    dispatch_async(MAIN_QUEUE,
                  //                                   ^{ [self.tableView
                  //                                   reloadData]; });
                  //                  } else {
                  //
                  //                  }
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
  [self viewAppearOrEnterForeground];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(applicationWillEnterForegroundNotification:)
             name:UIApplicationWillEnterForegroundNotification
           object:nil];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(applicationDidEnterBackgroundNotification:)
             name:UIApplicationDidEnterBackgroundNotification
           object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  [self viewDisappearOrEnterBackground];
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:UIApplicationWillEnterForegroundNotification
              object:nil];
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:UIApplicationDidEnterBackgroundNotification
              object:nil];
}

- (void)viewDisappearOrEnterBackground {
  [self.model stopScanState];
  [self stopUpdateList];
  //  [[NSNotificationCenter defaultCenter]
  //      removeObserver:self
  //                name:UIApplicationWillEnterForegroundNotification
  //              object:nil];
  //  [[NSNotificationCenter defaultCenter]
  //      removeObserver:self
  //                name:UIApplicationDidEnterBackgroundNotification
  //              object:nil];
}

- (void)viewAppearOrEnterForeground {
  NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
  NSArray *switchs = [[SwitchDataCeneter sharedInstance] switchs];
  for (SDZGSwitch *aSwitch in switchs) {
    aSwitch.lastUpdateInterval = current;
  }
  [self.model startScanState];
  // model层修改数据，指定时间后，页面统一修改
  [self startUpdateList];
  //  [[NSNotificationCenter defaultCenter]
  //      addObserver:self
  //         selector:@selector(applicationWillEnterForegroundNotification:)
  //             name:UIApplicationWillEnterForegroundNotification
  //           object:nil];
  //  [[NSNotificationCenter defaultCenter]
  //      addObserver:self
  //         selector:@selector(applicationDidEnterBackgroundNotification:)
  //             name:UIApplicationDidEnterBackgroundNotification
  //           object:nil];
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

- (void)startUpdateList {
  self.timerUpdateList =
      [NSTimer timerWithTimeInterval:REFRESH_DEV_TIME
                              target:self
                            selector:@selector(reloadTableView)
                            userInfo:nil
                             repeats:YES];
  [self.timerUpdateList
      setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.delayInterval]];
  [[NSRunLoop currentRunLoop] addTimer:self.timerUpdateList
                               forMode:NSRunLoopCommonModes];
}

- (void)stopUpdateList {
  [self.timerUpdateList invalidate];
  self.timerUpdateList = nil;
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
    [self stopUpdateList];
  } else {
    if (status == ReachableViaWWAN) {
      BOOL warn = [[[NSUserDefaults standardUserDefaults]
          objectForKey:wwanWarn] boolValue];
      if (warn) {
        [self.view
            makeToast:NSLocalizedString(@"WWAN Message", nil)
             duration:5.f
             position:[NSValue
                          valueWithCGPoint:
                              CGPointMake(self.view.frame.size.width / 2,
                                          self.view.frame.size.height - 40)]];
      }
    }
    if (!self.model.isScanningState) {
      [self.model startScanState];
      [self startUpdateList];
    }
  }
}

- (void)reloadTableView {
  self.switchs = [[SwitchDataCeneter sharedInstance] switchsWithChangeStatus];
  [self.tableView reloadData];
}

- (void)applicationWillEnterForegroundNotification:(NSNotification *)notif {
  [self viewAppearOrEnterForeground];
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notif {
  [self viewDisappearOrEnterBackground];
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
    [self.tableView
        makeToast:NSLocalizedString(
                      @"Device offline, Please check your network", nil)];
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
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                 initWithTitle:NSLocalizedString(
                                   @"Which operation do you want?", nil)
                      delegate:self
             cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
        destructiveButtonTitle:nil
             otherButtonTitles:NSLocalizedString(@"Flash", nil),
                               NSLocalizedString(@"Delete", nil), nil];
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
              initWithTitle:NSLocalizedString(@"Tips", nil)
                    message:NSLocalizedString(@"TipsInfo", nil)
                   delegate:self
          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
          otherButtonTitles:NSLocalizedString(@"Sure", nil), nil];
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
