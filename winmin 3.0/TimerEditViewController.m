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

@interface TimerEditCell : UITableViewCell
@property(strong, nonatomic) IBOutlet UIView *viewOfCellContent;
@end
@implementation TimerEditCell
- (void)awakeFromNib {
  self.viewOfCellContent.layer.borderWidth = .5f;
  self.viewOfCellContent.layer.borderColor =
      [UIColor colorWithHexString:@"#c3c3c3"].CGColor;
  self.viewOfCellContent.layer.cornerRadius = 10.f;
}
@end

@interface TimerEditViewController ()<PassValueDelegate,
                                      DatePickerControllerDelegate>
@property(strong, nonatomic) IBOutlet UILabel *lblTime;
@property(strong, nonatomic) IBOutlet UILabel *lblRepeatDesc;
@property(strong, nonatomic) IBOutlet UIButton *btnOnOff;
- (IBAction)onOffChanged:(id)sender;
- (IBAction)showDatePicker:(id)sender;
- (IBAction)changeWeek:(id)sender;

//@property(nonatomic, strong) SDZGSwitch *aSwtich;
//@property(nonatomic, assign) int socketGroupId;
@property(nonatomic, strong) NSMutableArray *timers;  //所有的定时任务
@property(nonatomic, strong) SDZGTimerTask *timer;  //正在编辑的定时任务
@property(nonatomic, assign)
    int index;  //正在编辑的timer在数组中位置，方便后续编辑操作时replace
@property(strong, nonatomic) TimerModel *model;
@end

@implementation TimerEditViewController

//- (void)setParamSwitch:(SDZGSwitch *)aSwtich
//         socketGroupId:(int)socketGroupId
//            timerModel:(TimerModel *)model
//                timers:(NSMutableArray *)timers
//                 timer:(SDZGTimerTask *)timer
//                 index:(int)index {
//  self.aSwtich = aSwtich;
//  self.socketGroupId = socketGroupId;
//  self.model = model;
//  self.timers = timers;
//  self.timer = timer;
//  self.index = index;
//}

- (void)setTimers:(NSMutableArray *)timers
            timer:(SDZGTimerTask *)timer
       timerModel:(TimerModel *)model
            index:(int)index {
  self.model = model;
  self.timers = timers;
  self.timer = timer;
  self.index = index;
}

- (void)setup {
  UIView *tableHeaderView = [[UIView alloc]
      initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 15)];
  tableHeaderView.backgroundColor = [UIColor clearColor];
  self.tableView.tableHeaderView = tableHeaderView;
  if (!self.timer) {
    // timer不存在，则表明正在进行添加操作
    self.timer = [[SDZGTimerTask alloc] init];
    self.timer.timerActionType = TimerActionTypeOn;  //默认开
    self.timer.isEffective = YES;                    //默认生效
    NSDate *tenMinituesLater =
        [NSDate dateWithTimeIntervalSinceNow:10 * 60];  //默认10分钟后
    int hour = [tenMinituesLater hour];
    int min = [tenMinituesLater minute];
    //获取当前时间离本周一0点开始的秒数
    NSInteger tenMinituesLaterTime = hour * 3600 + min * 60;
    self.timer.actionTime = tenMinituesLaterTime;
  }
  self.lblTime.text = [self.timer actionTimeString];
  self.lblRepeatDesc.text = [self.timer actionWeekString];
  self.btnOnOff.selected = self.timer.timerActionType;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationItem.title = @"定时任务";
  UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
  backButtonItem.title = @"返回";
  self.navigationItem.backBarButtonItem = backButtonItem;
  self.navigationItem.rightBarButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:@"保存"
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(save:)];
  [self setup];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(timerAddNotification:)
             name:kTimerAddNotification
           object:nil];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(timerUpdateNotification:)
             name:kTimerUpdateNotification
           object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:kTimerAddNotification
                                                object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:kTimerUpdateNotification
                                                object:nil];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - UINavigationBar事件_保存
- (void)save:(id)sender {
  int type = 0;
  if (self.index == -1) {
    //添加
    type = 1;
    [self.timers addObject:self.timer];
  } else {
    type = 2;
    [self.timers replaceObjectAtIndex:self.index withObject:self.timer];
  }
  [self.model updateTimers:self.timers type:type];
}

#pragma mark -
- (IBAction)showDatePicker:(id)sender {
  DatePickerViewController *popupViewController =
      [[DatePickerViewController alloc]
          initWithNibName:@"DatePickerViewController"
                   bundle:nil];
  popupViewController.delegate = self;
  popupViewController.actionTimeString = [self.timer actionTimeString];
  [self presentPopupViewController:popupViewController
                     animationType:MJPopupViewAnimationFade
               backgroundClickable:YES];
}

- (IBAction)changeWeek:(id)sender {
  CycleViewController *nextVC = [self.storyboard
      instantiateViewControllerWithIdentifier:@"CycleViewController"];
  nextVC.week = self.timer.week;
  nextVC.delegate = self;
  [self.navigationController pushViewController:nextVC animated:YES];
}

- (IBAction)onOffChanged:(id)sender {
  [UIView animateWithDuration:0.3
                   animations:^{
                       self.btnOnOff.selected = !self.btnOnOff.selected;
                   }];
  self.timer.timerActionType = self.btnOnOff.selected;
}

#pragma mark - PassValueDelegate
- (void)passValue:(id)value {
  int week = [value intValue];
  self.timer.week = week;
  self.lblRepeatDesc.text = [self.timer actionWeekString];
}

#pragma mark - DatePickerControllerDelegate
- (void)okBtnClicked:(UIViewController *)viewController
         passSeconds:(int)seconds
          dateString:(NSString *)dateString {
  self.lblTime.text = dateString;
  self.timer.actionTime = seconds;
  [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}

- (void)cancelBtnClicked:(UIViewController *)viewController {
  [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}

#pragma mark - 通知
- (void)timerAddNotification:(NSNotification *)notification {
  dispatch_async(MAIN_QUEUE, ^{
      NSDictionary *userInfo = @{ @"type" : @(self.index) };
      [[NSNotificationCenter defaultCenter]
          postNotificationName:kAddOrEditTimerNotification
                        object:self
                      userInfo:userInfo];
      [self.navigationController popViewControllerAnimated:YES];
  });
}

- (void)timerUpdateNotification:(NSNotification *)notification {
  dispatch_async(MAIN_QUEUE, ^{
      NSDictionary *userInfo = @{ @"type" : @(self.index) };
      [[NSNotificationCenter defaultCenter]
          postNotificationName:kAddOrEditTimerNotification
                        object:self
                      userInfo:userInfo];
      [self.navigationController popViewControllerAnimated:YES];
  });
}

@end