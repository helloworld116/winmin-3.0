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
#import "SwitchSyncService.h"

@interface SwitchListViewController () <
    UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate,
    UIAlertViewDelegate, EGORefreshTableHeaderDelegate, MBProgressHUDDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
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
@property (nonatomic, assign)
    BOOL isFirstLoad; //标识是否第一次加载，第一次时不修改最后更新时间
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, assign) BOOL hasBlinkMenu;
//选中设备修改名称或图标延时刷新问题
@property (nonatomic, strong) NSIndexPath *lastSelectedIndexPath;
//判断是不是刚登录，是则刷新设备列表，然后将值设为NO；
@property (nonatomic, assign) BOOL isLogin;
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
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  UILongPressGestureRecognizer *longPressGesture =
      [[UILongPressGestureRecognizer alloc]
          initWithTarget:self
                  action:@selector(handlerLongPress:)];
  longPressGesture.minimumPressDuration = 0.5;
  [self.tableView addGestureRecognizer:longPressGesture];
  self.isFirstLoad = YES;
  self.delayInterval = 1.f;
  self.noDataView = [[UIView alloc]
      initWithSize:self.view.frame.size
           imgName:@"noswitch"
           message:NSLocalizedString(@"You have not configure any device!",
                                     nil)];
  self.noDataView.hidden = YES;
  [self.tableView addSubview:self.noDataView];

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
                  NSString *password = note.userInfo[@"password"];
                  [self.model addSwitchWithMac:mac password:password];
                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                               (int64_t)(1 * NSEC_PER_SEC)),
                                 dispatch_get_main_queue(),
                                 ^{ [self reloadTableView]; });
              }];
  //检查登录后设备变化
  [[NSNotificationCenter defaultCenter]
      addObserverForName:kLoginSuccess
                  object:nil
                   queue:nil
              usingBlock:^(NSNotification *note) { self.isLogin = YES; }];

  //下拉刷新
  self.refreshHeaderView = [[EGORefreshTableHeaderView alloc]
       initWithFrame:CGRectMake(0.0f, 0.0f - self.view.bounds.size.height,
                                self.view.frame.size.width,
                                self.view.bounds.size.height)
      arrowImageName:@"grayArrow"
           textColor:[UIColor grayColor]];
  self.refreshHeaderView.backgroundColor = [UIColor whiteColor];
  self.refreshHeaderView.delegate = self;
  [self.tableView addSubview:self.refreshHeaderView];
  [self.refreshHeaderView refreshLastUpdatedDate];
  BOOL isShowedPulldownGuide = [[[NSUserDefaults standardUserDefaults]
      objectForKey:switchListPulldownRefresh] boolValue];
  if (!isShowedPulldownGuide) {
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{
            UIView *viewForGuide =
                [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            viewForGuide.backgroundColor = [UIColor blackColor];
            viewForGuide.alpha = .5f;
            viewForGuide.tag = switchListPulldownRefreshViewTag;
            UIImageView *imageView = [[UIImageView alloc]
                initWithImage:[UIImage imageNamed:@"pulldown_guide"]];
            imageView.frame = CGRectMake(100, 64, 216.f, 141.f);
            [viewForGuide addSubview:imageView];
            [UIView animateWithDuration:0.3f
                             animations:^{
                                 [[[UIApplication sharedApplication] keyWindow]
                                     addSubview:viewForGuide];
                             }];
        });
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self setup];
  SwitchSyncService *service = [[SwitchSyncService alloc] init];
  [service downloadSwitchs];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  BOOL isShowedLongPressDeleteGuide = [[[NSUserDefaults standardUserDefaults]
      objectForKey:switchListLongPressDelete] boolValue];
  if (!isShowedLongPressDeleteGuide && self.switchs.count) {
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)),
        dispatch_get_main_queue(), ^{
            UIView *viewForGuide =
                [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            viewForGuide.backgroundColor = [UIColor blackColor];
            viewForGuide.alpha = .5f;
            viewForGuide.tag = switchListLongPressDeleteViewTag;
            UIImageView *imageView = [[UIImageView alloc]
                initWithImage:[UIImage imageNamed:@"delete_guide"]];
            imageView.frame = CGRectMake(-5, 58, 96.f, 98.f);
            [viewForGuide addSubview:imageView];
            [UIView animateWithDuration:0.3f
                             animations:^{
                                 [[[UIApplication sharedApplication] keyWindow]
                                     addSubview:viewForGuide];
                             }];
        });
  }
  if (self.isLogin) {
    self.switchs = [[SwitchDataCeneter sharedInstance] switchs];
    if (self.switchs.count) {
      self.noDataView.hidden = YES;
      [self.tableView reloadData];
    }
    self.isLogin = NO;
  }
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
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(netChangedNotification:)
             name:kNetChangedNotification
           object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
  [self viewDisappearOrEnterBackground];
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:UIApplicationWillEnterForegroundNotification
              object:nil];
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:UIApplicationDidEnterBackgroundNotification
              object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:kNetChangedNotification
                                                object:nil];
  [super viewDidDisappear:animated];
}

- (void)viewDisappearOrEnterBackground {
  [self.model stopScanState];
  [self stopUpdateList];
}

- (void)viewAppearOrEnterForeground {
  if (kSharedAppliction.networkStatus != NotReachable) {
    //    if (!self.isFirstLoad) {
    //      self.delayInterval = 1.f;
    //      NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
    //      NSArray *switchs = [[SwitchDataCeneter sharedInstance] switchs];
    //      for (SDZGSwitch *aSwitch in switchs) {
    //        aSwitch.lastUpdateInterval = current + 1.5 * REFRESH_DEV_TIME;
    //      }
    //    } else {
    //      self.delayInterval = 3.1f;
    //      self.isFirstLoad = NO;
    //    }
    if (self.lastSelectedIndexPath) {
      NSArray *indexPaths = @[ self.lastSelectedIndexPath ];
      [self.tableView reloadRowsAtIndexPaths:indexPaths
                            withRowAnimation:UITableViewRowAnimationAutomatic];
      self.lastSelectedIndexPath = nil;
    }

    self.delayInterval = REFRESH_DEV_TIME;
    [self.model startScanState];
    // model层修改数据，指定时间后，页面统一修改
    [self startUpdateList];
  } else {
    [[SwitchDataCeneter sharedInstance] updateAllSwitchStautsToOffLine];
    [self.tableView reloadData];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)startUpdateList {
  [self stopUpdateList];
  self.timerUpdateList =
      [NSTimer timerWithTimeInterval:REFRESH_DEV_TIME
                              target:self
                            selector:@selector(reloadTableView)
                            userInfo:nil
                             repeats:YES];
  [self.timerUpdateList
      setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.delayInterval]];
  [[NSRunLoop currentRunLoop] addTimer:self.timerUpdateList
                               forMode:NSDefaultRunLoopMode];
}

- (void)stopUpdateList {
  if (self.timerUpdateList) {
    [self.timerUpdateList invalidate];
    self.timerUpdateList = nil;
  }
}

- (void)pauseUpdateList {
  if (![self.timerUpdateList isValid]) {
    return;
  }
  [self.timerUpdateList setFireDate:[NSDate distantFuture]];
}

- (void)resumeUpdateList {
  if (![self.timerUpdateList isValid]) {
    return;
  }
  [self.timerUpdateList
      setFireDate:[NSDate dateWithTimeIntervalSinceNow:REFRESH_DEV_TIME]];
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
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
      NetworkStatus status = kSharedAppliction.networkStatus;
      if (status == NotReachable) {
        //网络不可用时修改所有设备状态为离线并停止扫描
        [self.model stopScanState];
        [[SwitchDataCeneter sharedInstance] updateAllSwitchStautsToOffLine];
        [self.tableView reloadData];
        [self stopUpdateList];

        //        self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
        //        self.tableView.contentOffset = CGPointMake(0, -20);
      } else {
        //        self.tableView.contentInset = UIEdgeInsetsZero;
        //        self.tableView.contentOffset = CGPointZero;
        if (status == ReachableViaWWAN) {
          BOOL warn = [[[NSUserDefaults standardUserDefaults]
              objectForKey:wwanWarn] boolValue];
          if (warn) {
            [self.view
                makeToast:NSLocalizedString(@"WWAN Message", nil)
                 duration:5.f
                 position:[NSValue valueWithCGPoint:
                                       CGPointMake(
                                           self.view.frame.size.width / 2,
                                           self.view.frame.size.height - 40)]];
          }
        }
        if (!self.model.isScanningState) {
          [self.model startScanState];
          [self startUpdateList];
        }
      }
  });
}

- (void)reloadTableView {
  DDLogDebug(@"***************%s****************", __FUNCTION__);
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
  //  UILongPressGestureRecognizer *longPressGesture =
  //      [[UILongPressGestureRecognizer alloc]
  //          initWithTarget:self
  //                  action:@selector(handlerLongPress:)];
  //  longPressGesture.minimumPressDuration = 0.5;
  //  [cell addGestureRecognizer:longPressGesture];
  UIView *myBackView = [[UIView alloc] initWithFrame:cell.frame];
  myBackView.backgroundColor = [UIColor colorWithHexString:@"#F6F4F4"];
  cell.selectedBackgroundView = myBackView;
  return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self pauseUpdateList];
  self.HUD = [[MBProgressHUD alloc] initWithWindow:kSharedAppliction.window];
  [self.view.window addSubview:self.HUD];
  self.HUD.delegate = self;
  [self.HUD show:YES];
  SDZGSwitch *aSwitch = [self.switchs objectAtIndex:indexPath.row];
  if (aSwitch.networkStatus == SWITCH_NEW) {
    aSwitch.networkStatus = SWITCH_LOCAL;
    NSArray *indexPaths = @[ indexPath ];
    [self.tableView reloadRowsAtIndexPaths:indexPaths
                          withRowAnimation:UITableViewRowAnimationAutomatic];
  }
  [self.model scanSwitchState:aSwitch
                     complete:^(int status) {
                         [self switchStatusRecivied:aSwitch
                                             status:status
                                          indexPath:indexPath];
                     }];
}

- (void)switchStatusRecivied:(SDZGSwitch *)aSwitch
                      status:(int)status
                   indexPath:(NSIndexPath *)indexPath {
  dispatch_async(MAIN_QUEUE, ^{
      [self.HUD hide:YES];
      DDLogDebug(@"result is %d", status);
      [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
      if (status == -1) {
        if (aSwitch.networkStatus != SWITCH_OFFLINE) {
          aSwitch.networkStatus = SWITCH_OFFLINE;
          NSArray *indexPaths = @[ indexPath ];
          [self.tableView
              reloadRowsAtIndexPaths:indexPaths
                    withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [self.view
            makeToast:NSLocalizedString(
                          @"Device offline, Please check your network", nil)];
        [self resumeUpdateList];
      } else if (status == kUdpResponsePasswordErrorCode) {
        if (aSwitch.networkStatus != SWITCH_OFFLINE) {
          aSwitch.networkStatus = SWITCH_OFFLINE;
          NSArray *indexPaths = @[ indexPath ];
          [self.tableView
              reloadRowsAtIndexPaths:indexPaths
                    withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        UIAlertView *alertView = [[UIAlertView alloc]
                initWithTitle:nil
                      message:NSLocalizedString(@"Auth Error", nil)
                     delegate:self
            cancelButtonTitle:NSLocalizedString(@"Sure", nil)
            otherButtonTitles:nil, nil];
        [alertView show];
        [self resumeUpdateList];
      } else {
        self.lastSelectedIndexPath = indexPath;
        aSwitch.networkStatus = status;
        SwitchDetailViewController *detailViewController =
            [self.storyboard instantiateViewControllerWithIdentifier:
                                 @"SwitchDetailViewController"];
        detailViewController.aSwitch = aSwitch;
        [self.navigationController pushViewController:detailViewController
                                             animated:YES];
      }
  });
}

#pragma mark - 长按处理
- (void)handlerLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
  CGPoint p = [gestureRecognizer locationInView:self.tableView];
  NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
  SDZGSwitch *aSwitch = [self.switchs objectAtIndex:indexPath.row];
  self.operationSwitch = aSwitch;
  if (indexPath && gestureRecognizer.state == UIGestureRecognizerStateBegan) {
    [self pauseUpdateList];
    self.longPressIndexPath = indexPath;
    UIActionSheet *actionSheet;
    if (aSwitch.networkStatus == SWITCH_OFFLINE) {
      self.hasBlinkMenu = NO;
      actionSheet = [[UIActionSheet alloc]
                   initWithTitle:NSLocalizedString(
                                     @"Which operation do you want?", nil)
                        delegate:self
               cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
          destructiveButtonTitle:nil
               otherButtonTitles:NSLocalizedString(@"Delete", nil), nil];
    } else {
      self.hasBlinkMenu = YES;
      actionSheet = [[UIActionSheet alloc]
                   initWithTitle:NSLocalizedString(
                                     @"Which operation do you want?", nil)
                        delegate:self
               cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
          destructiveButtonTitle:nil
               otherButtonTitles:NSLocalizedString(@"Flash", nil),
                                 NSLocalizedString(@"Delete", nil), nil];
    }
    //    [actionSheet showInView:self.view];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
  }
}

- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  [self resumeUpdateList];
  switch (buttonIndex) {
    case 0:
      //闪烁
      if (self.hasBlinkMenu) {
        [self.model blinkSwitch:self.operationSwitch];
      } else {
        UIAlertView *alertView = [[UIAlertView alloc]
                initWithTitle:NSLocalizedString(@"Tips", nil)
                      message:NSLocalizedString(@"TipsInfo", nil)
                     delegate:self
            cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
            otherButtonTitles:NSLocalizedString(@"Sure", nil), nil];
        [alertView show];
      }
      break;
    case 1:
      if (self.hasBlinkMenu) {
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
      [self.tableView reloadData];
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

//- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:
//            (UIScrollView *)scrollView {
//  [self.tableView reloadData];
//}

#pragma mark - MBProgressHud
- (void)hudWasHidden {
  // Remove HUD from screen
  [self.HUD removeFromSuperview];

  // add here the code you may need
}
@end
