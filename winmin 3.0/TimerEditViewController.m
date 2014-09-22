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

@interface TimerEditViewController ()<PassValueDelegate>
@property(strong, nonatomic) IBOutlet UIView *cellView1;
@property(strong, nonatomic) IBOutlet UIView *cellView2;
@property(strong, nonatomic) IBOutlet UIView *cellView3;
@property(strong, nonatomic) IBOutlet UILabel *lblTime;
@property(strong, nonatomic) IBOutlet UILabel *lblRepeatDesc;
@property(strong, nonatomic) IBOutlet UISwitch *_switch;
@property(strong, nonatomic) IBOutlet UIDatePicker *datePicker;
- (IBAction)switchValueChanged:(id)sender;
- (IBAction)showDatePicker:(id)sender;
- (IBAction)changeWeek:(id)sender;
- (IBAction)touchBackground:(id)sender;
- (IBAction)timeValueChanged:(id)sender;

@property(nonatomic, strong) SDZGSwitch *aSwtich;
@property(nonatomic, assign) int socketGroupId;
@property(nonatomic, strong) NSMutableArray *timers;  //所有的定时任务
@property(nonatomic, strong) SDZGTimerTask *timer;  //正在编辑的定时任务
@property(nonatomic, assign)
    int index;  //正在编辑的timer在数组中位置，方便后续编辑操作时replace
@property(strong, nonatomic) NSDateFormatter *dateFormatter;
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
  self.cellView1.layer.borderWidth = 1.0f;
  self.cellView1.layer.borderColor = [UIColor lightGrayColor].CGColor;
  self.cellView1.layer.cornerRadius = 1.5f;
  self.cellView2.layer.borderWidth = 1.0f;
  self.cellView2.layer.borderColor = [UIColor lightGrayColor].CGColor;
  self.cellView2.layer.cornerRadius = 1.5f;
  self.cellView3.layer.borderWidth = 1.0f;
  self.cellView3.layer.borderColor = [UIColor lightGrayColor].CGColor;
  self.cellView3.layer.cornerRadius = 1.5f;
  //设置公用的时间选择器
  self.dateFormatter = [[NSDateFormatter alloc] init];
  [self.dateFormatter setDateFormat:@"HH:mm"];
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
  self._switch.on = self.timer.timerActionType;
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

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - UINavigationBar事件_保存
- (void)save:(id)sender {
  if (self.index == -1) {
    //添加
    [self.timers addObject:self.timer];
  } else {
    [self.timers replaceObjectAtIndex:self.index withObject:self.timer];
  }
  [self.model updateTimers:self.timers];
  //  if (!self.request) {
  //    self.request = [UdpRequest manager];
  //    self.request.delegate = self;
  //  }
  //  dispatch_sync(GLOBAL_QUEUE,
  //                ^{//      [self.request sendMsg1DOr1F:self.aSwtich
  //                  //                         socketId:self.socketId
  //                  //                         timeList:self.timers
  //                  //                         sendMode:ActiveMode];
  //                });
}

#pragma mark -
- (IBAction)showDatePicker:(id)sender {
  [UIView animateWithDuration:0.3
                   animations:^{
                       NSDate *defaultDate = [self.dateFormatter
                           dateFromString:[self.timer actionTimeString]];
                       self.datePicker.date = defaultDate;
                       if (self.datePicker.hidden) {
                         self.datePicker.hidden = NO;
                       } else {
                         self.datePicker.hidden = YES;
                       }
                   }];
}

- (IBAction)changeWeek:(id)sender {
  if (!self.datePicker.hidden) {
    [UIView animateWithDuration:0.3
                     animations:^{ self.datePicker.hidden = YES; }];
  }
  CycleViewController *nextVC = [self.storyboard
      instantiateViewControllerWithIdentifier:@"CycleViewController"];
  nextVC.week = self.timer.week;
  nextVC.delegate = self;
  [self.navigationController pushViewController:nextVC animated:YES];
}

- (IBAction)touchBackground:(id)sender {
  if (!self.datePicker.hidden) {
    [UIView animateWithDuration:0.3
                     animations:^{ self.datePicker.hidden = YES; }];
  }
}

- (IBAction)timeValueChanged:(id)sender {
  //时间选择时，输出格式
  NSString *dateString =
      [self.dateFormatter stringFromDate:self.datePicker.date];
  self.lblTime.text = dateString;
  NSArray *time = [dateString componentsSeparatedByString:@":"];
  self.timer.actionTime = [time[0] intValue] * 3600 + [time[1] intValue] * 60;
}

- (IBAction)switchValueChanged:(id)sender {
  self.timer.timerActionType = self._switch.on;
}

#pragma mark - PassValueDelegate
- (void)passValue:(id)value {
  int week = [value intValue];
  self.timer.week = week;
  self.lblRepeatDesc.text = [self.timer actionWeekString];
}

//#pragma mark - UdpRequestDelegate
//- (void)responseMsg:(CC3xMessage *)message address:(NSData *)address {
//  switch (message.msgId) {
//    //设置定时
//    case 0x1e:
//    case 0x20:
//      [self responseMsg1EOr20:message];
//      break;
//
//    default:
//      break;
//  }
//}
//
//- (void)responseMsg1EOr20:(CC3xMessage *)message {
//  if (message.state == 0) {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSDictionary *userInfo = @{ @"type" : @(self.index) };
//        [[NSNotificationCenter defaultCenter]
//            postNotificationName:kAddOrEditTimerNotification
//                          object:self
//                        userInfo:userInfo];
//        [self.navigationController popViewControllerAnimated:YES];
//    });
//    //更新数据
//    //    [[SwitchDataCeneter sharedInstance] updateTimerList:self.timers
//    //                                                    mac:self.aSwtich.mac
//    //                                               socketId:self.socketId];
//  }
//}
@end