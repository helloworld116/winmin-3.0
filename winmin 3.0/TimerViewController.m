//
//  TimerViewController.m
//  SmartSwitch
//
//  Created by sdzg on 14-8-13.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "TimerViewController.h"
#import "TimerCell.h"
#import "TimerEditViewController.h"
#import "SwitchDataCeneter.h"
#import "TimerModel.h"
#define kAddTimer -1

@interface TimerViewController ()<UIActionSheetDelegate>
@property(nonatomic, strong) NSMutableArray *timers;
@property(nonatomic, strong)
    NSIndexPath *editIndexPath;  //正在编辑或删除的indexPath
@property(nonatomic, strong) TimerModel *model;
@property(nonatomic, strong) UIView *noDataView;
@property(nonatomic, strong)
    SDZGTimerTask *timer;  //修改定时任务是否生效时当前的timer
@end

@implementation TimerViewController

- (id)initWithStyle:(UITableViewStyle)style {
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)setupStyle {
  UIView *view = [[UIView alloc] init];
  view.backgroundColor = [UIColor clearColor];
  self.tableView.tableFooterView = view;
}

- (void)setup {
  [self setupStyle];
  self.noDataView =
      [[UIView alloc] initWithSize:self.view.frame.size
                           imgName:@"noswitch"
                           message:@"您暂时还未添加任何定时计划"];
  self.noDataView.hidden = YES;
  [self.tableView addSubview:self.noDataView];
  self.model = [[TimerModel alloc] initWithSwitch:self.aSwitch
                                    socketGroupId:self.socketGroupId];
  [self.model queryTimers];
  self.timers = [@[] mutableCopy];
  SDZGSocket *socket =
      [self.aSwitch.sockets objectAtIndex:self.socketGroupId - 1];
  if (socket.timerList && socket.timerList.count) {
    [self.timers addObjectsFromArray:socket.timerList];
  } else {
    self.noDataView.hidden = NO;
  }
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(addOrEditTimerNotification:)
             name:kAddOrEditTimerNotification
           object:nil];
  //定时任务生效页面改变通知
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(timerEffectiveChanged:)
             name:kTimerEffectiveChanged
           object:nil];

  //查询通知
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(changeTimersList:)
                                               name:kTimerListChanged
                                             object:nil];
  //删除通知
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(timerDeleteNotification:)
             name:kTimerDeleteNotification
           object:nil];
  //修改定时任务生效报文请求后通知
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(timerEffectiveChangedNotifcation:)
             name:kTimerEffectiveChangedNotifcation
           object:nil];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationItem.title = @"定时任务";
  UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
  backButtonItem.title = @"返回";
  self.navigationItem.backBarButtonItem = backButtonItem;
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                           target:self
                           action:@selector(addTimer:)];
  //      [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add"]
  //                                       style:UIBarButtonItemStylePlain
  //                                      target:self
  //                                      action:@selector(addTimer:)];
  [self setup];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:kAddOrEditTimerNotification
              object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:kTimerEffectiveChanged
                                                object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:kTimerListChanged
                                                object:nil];
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:kTimerEffectiveChangedNotifcation
              object:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return self.timers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"TimerCell";
  TimerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId
                                                    forIndexPath:indexPath];

  SDZGTimerTask *task = [self.timers objectAtIndex:indexPath.row];
  [cell setCellInfo:task];
  //增加长按事件
  UILongPressGestureRecognizer *longPressGesture =
      [[UILongPressGestureRecognizer alloc]
          initWithTarget:self
                  action:@selector(handlerLongPress:)];
  longPressGesture.minimumPressDuration = 0.5;
  [cell addGestureRecognizer:longPressGesture];
  return cell;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  SDZGTimerTask *timer = [self.timers objectAtIndex:indexPath.row];
  TimerEditViewController *nextVC = [self.storyboard
      instantiateViewControllerWithIdentifier:@"TimerEditViewController"];
  //  [nextVC setParamSwitch:self.aSwitch
  //                socketId:self.socketGroupId
  //                  timers:self.timers
  //                   timer:timer
  //                   index:indexPath.row];
  [nextVC setTimers:self.timers
              timer:timer
         timerModel:self.model
              index:indexPath.row];
  [self.navigationController pushViewController:nextVC animated:YES];
}

#pragma mark - UINavigationBar
- (void)addTimer:(id)sender {
  TimerEditViewController *nextVC = [self.storyboard
      instantiateViewControllerWithIdentifier:@"TimerEditViewController"];
  //  [nextVC setParamSwitch:self.aSwitch
  //                socketId:self.socketGroupId
  //                  timers:self.timers
  //                   timer:nil
  //                   index:kAddTimer];
  [nextVC setTimers:self.timers
              timer:nil
         timerModel:self.model
              index:kAddTimer];
  [self.navigationController pushViewController:nextVC animated:YES];
}

#pragma mark - SceneListCellHandler
- (void)handlerLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
  CGPoint p = [gestureRecognizer locationInView:self.view];
  NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
  if (indexPath && gestureRecognizer.state == UIGestureRecognizerStateBegan) {
    self.editIndexPath = indexPath;
    UIActionSheet *actionSheet =
        [[UIActionSheet alloc] initWithTitle:@"确定删除该定时记录"
                                    delegate:self
                           cancelButtonTitle:@"取消"
                      destructiveButtonTitle:nil
                           otherButtonTitles:@"删除", nil];
    [actionSheet showInView:self.view];
  }
}

- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0) {
    //删除
    NSMutableArray *timers = [NSMutableArray arrayWithArray:self.timers];
    [timers removeObjectAtIndex:self.editIndexPath.row];
    [self.model updateTimers:timers type:3];
  }
}

#pragma mark - AddOrEditTimerNotification
- (void)addOrEditTimerNotification:(NSNotification *)notification {
  NSDictionary *userIofo = [notification userInfo];
  int type = [[userIofo objectForKey:@"type"] intValue];
  NSIndexPath *indexPath;
  NSString *message;
  switch (type) {
    case kAddTimer:
      message = @"添加成功";
      indexPath =
          [NSIndexPath indexPathForRow:self.timers.count - 1 inSection:0];
      [self.tableView beginUpdates];
      [self.tableView insertRowsAtIndexPaths:@[ indexPath ]
                            withRowAnimation:UITableViewRowAnimationRight];
      [self.tableView endUpdates];
      [self updateViewWithReloadData:NO];
      break;
    default:
      message = @"修改成功";
      indexPath = [NSIndexPath indexPathForRow:type inSection:0];
      [self.tableView reloadRowsAtIndexPaths:@[ indexPath ]
                            withRowAnimation:UITableViewRowAnimationAutomatic];
      break;
  }
  [self.view
      makeToast:message
       duration:1.f
       position:[NSValue
                    valueWithCGPoint:CGPointMake(
                                         self.view.frame.size.width / 2,
                                         self.view.frame.size.height - 40)]];
}

- (void)changeTimersList:(NSNotification *)notification {
  NSDictionary *userInfo = notification.userInfo;
  self.timers = [userInfo objectForKey:@"timers"];
  dispatch_async(MAIN_QUEUE, ^{ [self updateViewWithReloadData:YES]; });
  [self updateMemorySwitch];
}

- (void)timerDeleteNotification:(NSNotification *)notification {
  [self.timers removeObjectAtIndex:self.editIndexPath.row];
  dispatch_async(MAIN_QUEUE, ^{
      [self.tableView beginUpdates];
      [self.tableView deleteRowsAtIndexPaths:@[ self.editIndexPath ]
                            withRowAnimation:UITableViewRowAnimationLeft];
      [self.tableView endUpdates];
      [self updateViewWithReloadData:NO];
  });
  [self updateMemorySwitch];
}

//定时任务生效改变
- (void)timerEffectiveChanged:(NSNotification *)notification {
  TimerCell *cell = (TimerCell *)notification.object;
  NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
  self.editIndexPath = indexPath;
  BOOL effective =
      [[notification.userInfo objectForKey:@"effective"] boolValue];
  NSMutableArray *timers = [NSMutableArray arrayWithArray:self.timers];
  self.timer = [timers objectAtIndex:indexPath.row];
  self.timer.isEffective = effective;
  [timers replaceObjectAtIndex:indexPath.row withObject:self.timer];
  [self.model updateTimers:timers type:4];
}

- (void)timerEffectiveChangedNotifcation:(NSNotification *)notification {
  [self.timers replaceObjectAtIndex:self.editIndexPath.row
                         withObject:self.timer];
}

- (void)updateMemorySwitch {
  [[SwitchDataCeneter sharedInstance] updateTimerList:self.timers
                                                  mac:self.aSwitch.mac
                                        socketGroupId:self.socketGroupId];
}

- (void)updateViewWithReloadData:(BOOL)reloadData {
  if (self.timers && self.timers.count) {
    self.noDataView.hidden = YES;
    if (reloadData) {
      [self.tableView reloadData];
    }
  } else {
    self.noDataView.hidden = NO;
  }
}
@end
