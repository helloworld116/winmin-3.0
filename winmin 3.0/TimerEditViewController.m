//
//  TimerEditViewController.m
//  SmartSwitch
//
//  Created by sdzg on 14-8-14.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "TimerEditViewController.h"
#import "CycleViewController.h"
#import <NSDate+Calendar.h>
#import "SwitchDataCeneter.h"
#import "DatePickerViewController.h"
static const int maxCount = 20;

@interface TimerCellInfo : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *info;
- (id)initWithTitle:(NSString *)title info:(NSString *)info;
@end

@implementation TimerCellInfo
- (id)initWithTitle:(NSString *)title info:(NSString *)info {
  self = [super init];
  if (self) {
    self.title = title;
    self.info = info;
  }
  return self;
}
@end

@interface TimerEditCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblInfo;
- (void)setContent:(NSDictionary *)content;
@end
@implementation TimerEditCell
- (void)setContent:(TimerCellInfo *)timerCellInfo {
  self.lblTitle.text = timerCellInfo.title;
  self.lblInfo.text = timerCellInfo.info;
}
@end

@interface TimerEditViewController () <UITableViewDelegate,
                                       UITableViewDataSource,
                                       UIActionSheetDelegate, PassValueDelegate>
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSMutableArray *timers; //所有的定时任务
@property (nonatomic, strong) SDZGTimerTask *timer; //正在编辑的定时任务
@property (nonatomic, assign)
    int index; //正在编辑的timer在数组中位置，方便后续编辑操作时replace
@property (nonatomic, assign) TimerOperationType action;
@property (strong, nonatomic) TimerModel *model;
@property (strong, nonatomic) NSMutableArray *menus;
@property (strong, nonatomic) NSIndexPath *currentEditIndexPath;
@end

@implementation TimerEditViewController

- (void)setTimers:(NSMutableArray *)timers
            timer:(SDZGTimerTask *)timer
       timerModel:(TimerModel *)model
           action:(TimerOperationType)action
            index:(int)index {
  self.model = model;
  self.timers = timers;
  self.timer = timer;
  self.action = action;
  self.index = index;
}

- (void)setup {
  UIView *view = [[UIView alloc] init];
  view.backgroundColor = [UIColor clearColor];
  self.tableView.tableFooterView = view;
  self.menus = [@[] mutableCopy];
  if (!self.timer) {
    // timer不存在，则表明正在进行添加操作
    self.timer = [[SDZGTimerTask alloc] init];
    self.timer.timerActionType = TimerActionTypeOn; //默认开
    self.timer.isEffective = YES;                   //默认生效
    NSDate *tenMinituesLater =
        [NSDate dateWithTimeIntervalSinceNow:10 * 60]; //默认10分钟后
    int hour = [tenMinituesLater hour];
    int min = [tenMinituesLater minute];
    //获取当前时间离本周一0点开始的秒数
    NSInteger tenMinituesLaterTime = hour * 3600 + min * 60;
    self.timer.actionTime = tenMinituesLaterTime;
  }
  self.dateFormatter = [[NSDateFormatter alloc] init];
  [self.dateFormatter setDateFormat:@"HH:mm"];
  NSDate *defaultDate =
      [self.dateFormatter dateFromString:[self.timer actionTimeString]];
  self.datePicker.date = defaultDate;
  NSString *actionType;
  if (self.timer.timerActionType) {
    actionType = NSLocalizedString(@"ON", nil);
  } else {
    actionType = NSLocalizedString(@"OFF", nil);
  }

  [self.menus
      addObject:[[TimerCellInfo alloc]
                    initWithTitle:NSLocalizedString(@"Switch Action", nil)
                             info:actionType]];

  [self.menus addObject:[[TimerCellInfo alloc]
                            initWithTitle:NSLocalizedString(@"Repeat", nil)
                                     info:[self.timer actionWeekString]]];
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(timerAddNotification:)
             name:kTimerAddNotification
           object:nil];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  NSString *operationType;
  if (self.action == TimerOperationAdd) {
    operationType = NSLocalizedString(@"AddWithBlank", nil);
  } else {
    operationType = NSLocalizedString(@"EditWithBlank", nil);
  }
  self.navigationItem.title =
      [NSString stringWithFormat:@"%@%@", operationType,
                                 NSLocalizedString(@"Timer Task", nil)];
  UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
  backButtonItem.title = NSLocalizedString(@"Back", nil);
  self.navigationItem.backBarButtonItem = backButtonItem;
  self.navigationItem.rightBarButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil)
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(save:)];
  [self setup];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(timerUpdateNotification:)
             name:kTimerUpdateNotification
           object:nil];
  //无响应通知
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(noResponseNotification:)
             name:kNoResponseNotification
           object:self.model];
  [self.tableView
      deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow]
                    animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:kTimerUpdateNotification
                                                object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:kNoResponseNotification
                                                object:nil];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)timeValueChanged:(id)sender {
  //时间选择时，输出格式
  NSString *dateString =
      [self.dateFormatter stringFromDate:self.datePicker.date];
  NSArray *time = [dateString componentsSeparatedByString:@":"];
  self.timer.actionTime = [time[0] intValue] * 3600 + [time[1] intValue] * 60;
}

#pragma mark - UINavigationBar事件_保存
- (void)save:(id)sender {
  int type = 0;
  if (self.action == TimerOperationAdd) {
    //添加
    type = TimerOperationAdd;
    [self.timers addObject:self.timer];
  } else {
    type = TimerOperationEdit;
    [self.timers replaceObjectAtIndex:self.index withObject:self.timer];
  }
  if (self.timers.count > maxCount) {
    [self.view makeToast:NSLocalizedString(@"maximum count is 20", nil)];
  } else {
    [self.model updateTimers:self.timers type:type];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //确保在保存操作时，按钮重复点击
    self.navigationItem.rightBarButtonItem.enabled = NO;
  }
}

#pragma mark -
- (void)changeWeek {
  CycleViewController *nextVC = [self.storyboard
      instantiateViewControllerWithIdentifier:@"CycleViewController"];
  nextVC.week = self.timer.week;
  nextVC.delegate = self;
  [self.navigationController pushViewController:nextVC animated:YES];
}

#pragma mark - PassValueDelegate
- (void)passValue:(id)value {
  [self.tableView deselectRowAtIndexPath:self.currentEditIndexPath
                                animated:YES];
  int week = [value intValue];
  self.timer.week = week;
  TimerCellInfo *cellInfo = self.menus[self.currentEditIndexPath.row];
  cellInfo.info = [self.timer actionWeekString];
  NSArray *indexPaths = @[ self.currentEditIndexPath ];
  [self.tableView reloadRowsAtIndexPaths:indexPaths
                        withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - 通知
- (void)timerAddNotification:(NSNotification *)notification {
  DDLogDebug(@"add success");
  dispatch_async(MAIN_QUEUE, ^{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSDictionary *userInfo = @{
      @"index" : @(self.index),
      @"action" : @(self.action)
    };
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kAddOrEditTimerNotification
                      object:self
                    userInfo:userInfo];
    [self.navigationController popViewControllerAnimated:YES];
  });
}

- (void)timerUpdateNotification:(NSNotification *)notification {
  dispatch_async(MAIN_QUEUE, ^{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSDictionary *userInfo = @{
      @"index" : @(self.index),
      @"action" : @(self.action)
    };
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kAddOrEditTimerNotification
                      object:self
                    userInfo:userInfo];
    [self.navigationController popViewControllerAnimated:YES];
  });
}

- (void)noResponseNotification:(NSNotification *)notif {
  dispatch_async(MAIN_QUEUE, ^{
    if (self.index == -1) {
      //未添加成功则从数组中删除，避免下次继续保存出错
      //只在添加情况下执行删除操作，修改不从集合中删除
      [self.timers removeObject:self.timer];
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    NSDictionary *userInfo = notif.userInfo;
    long tag = [userInfo[@"tag"] longValue];
    switch (tag) {
      case P2D_GET_TIMER_REQ_17:
      case P2S_GET_TIMER_REQ_19:
        [self.view makeToast:NSLocalizedString(@"No UDP Response Msg", nil)];
        break;
      case P2D_SET_TIMER_REQ_1D:
      case P2S_SET_TIMER_REQ_1F:
        [self.view makeToast:NSLocalizedString(@"No UDP Response Msg", nil)];
        break;
    }
  });
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 44.f;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return [self.menus count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellID = @"TimerEditCell";
  NSDictionary *content = self.menus[indexPath.row];
  TimerEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID
                                                        forIndexPath:indexPath];
  [cell setContent:content];
  return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  self.currentEditIndexPath = indexPath;
  switch (indexPath.row) {
    case 0: {
      UIActionSheet *actionSheet = [[UIActionSheet alloc]
                   initWithTitle:NSLocalizedString(
                                     @"Please choose whether to open the task",
                                     nil)
                        delegate:self
               cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
          destructiveButtonTitle:nil
               otherButtonTitles:NSLocalizedString(@"ON", nil),
                                 NSLocalizedString(@"OFF", nil), nil];
      [actionSheet showInView:self.view];
    } break;
    case 1:
      [self changeWeek];
      break;
    default:
      break;
  }
}

- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  [self.tableView deselectRowAtIndexPath:self.currentEditIndexPath
                                animated:YES];
  TimerCellInfo *cellInfo = self.menus[self.currentEditIndexPath.row];
  NSString *type;
  switch (buttonIndex) {
    case 0:
      type = NSLocalizedString(@"ON", nil);
      self.timer.timerActionType = TimerActionTypeOn;
      break;
    case 1:
      type = NSLocalizedString(@"OFF", nil);
      self.timer.timerActionType = TimerActionTypeOff;
      break;
    default:
      type = cellInfo.info;
      self.timer.timerActionType = self.timer.timerActionType;
      break;
  }
  cellInfo.info = type;
  NSArray *indexPaths = @[ self.currentEditIndexPath ];
  [self.tableView reloadRowsAtIndexPaths:indexPaths
                        withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end