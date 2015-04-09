//
//  SensorViewController.m
//  winmin 3.0
//
//  Created by sdzg on 15-4-9.
//  Copyright (c) 2015年 itouchco.com. All rights reserved.
//

#import "SensorViewController.h"

@interface SensorViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblSensorTemeratureAndHudmidity;
@property (weak, nonatomic) IBOutlet UILabel *lblSensorSmog;
@property (weak, nonatomic) IBOutlet UILabel *lblSensorCo;
@property (weak, nonatomic) IBOutlet UILabel *lblCityName;
@property (weak, nonatomic) IBOutlet UILabel *lblCityTemerature;
@property (weak, nonatomic) IBOutlet UILabel *lblCityWind;
@property (weak, nonatomic) IBOutlet UILabel *lblCityWeather;
@property (weak, nonatomic) IBOutlet UILabel *lblCityPm2point5;
@end

@implementation SensorViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
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

@end
