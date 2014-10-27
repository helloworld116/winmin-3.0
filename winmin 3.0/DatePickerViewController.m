//
//  DatePickerViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-24.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "DatePickerViewController.h"

@interface DatePickerViewController ()
@property (strong, nonatomic) IBOutlet UIButton *btnOK;
@property (strong, nonatomic) IBOutlet UIButton *btnCancel;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (strong, nonatomic) NSString *dateString;
@property (assign, nonatomic) int seconds;

- (IBAction)ok:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)timeValueChanged:(id)sender;
@end

@implementation DatePickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)setupStyle {
  self.btnOK.layer.cornerRadius = 5.f;
  self.btnCancel.layer.cornerRadius = 5.f;
}

- (void)setup {
  [self setupStyle];
  //设置公用的时间选择器
  self.dateFormatter = [[NSDateFormatter alloc] init];
  [self.dateFormatter setDateFormat:@"HH:mm"];

  self.dateString = self.actionTimeString;
  NSDate *defaultDate =
      [self.dateFormatter dateFromString:self.actionTimeString];
  self.datePicker.date = defaultDate;
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

- (IBAction)ok:(id)sender {
  if (self.delegate &&
      [self.delegate
          respondsToSelector:@selector(okBtnClicked:passSeconds:dateString:)]) {
    [self.delegate okBtnClicked:self
                    passSeconds:self.seconds
                     dateString:self.dateString];
  }
}
- (IBAction)cancel:(id)sender {
  if (self.delegate &&
      [self.delegate respondsToSelector:@selector(cancelBtnClicked:)]) {
    [self.delegate cancelBtnClicked:self];
  }
}

- (IBAction)timeValueChanged:(id)sender {
  //时间选择时，输出格式
  self.dateString = [self.dateFormatter stringFromDate:self.datePicker.date];
  NSArray *time = [self.dateString componentsSeparatedByString:@":"];
  self.seconds = [time[0] intValue] * 3600 + [time[1] intValue] * 60;
}
@end
