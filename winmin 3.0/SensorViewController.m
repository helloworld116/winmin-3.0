//
//  SensorViewController.m
//  winmin 3.0
//
//  Created by sdzg on 15-4-9.
//  Copyright (c) 2015年 itouchco.com. All rights reserved.
//

#import "SensorViewController.h"
#import "SensorModel.h"
#import "UIImageView+LBBlurredImage.h"

static NSString *const defaultBg = @"sensor_bg";
#define kSensorDefaultColor [UIColor whiteColor]
#define kSensorHighlightColor [UIColor colorWithHexString:@"#00FF66"]
@interface SensorViewController () <UIActionSheetDelegate,
                                    UINavigationControllerDelegate,
                                    UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblSensorTemeratureAndHudmidity;
@property (weak, nonatomic) IBOutlet UILabel *lblSensorSmog;
@property (weak, nonatomic) IBOutlet UILabel *lblSensorCo;
@property (weak, nonatomic) IBOutlet UILabel *lblSensorBody;
@property (weak, nonatomic) IBOutlet UILabel *lblSensorLight;
@property (weak, nonatomic)
    IBOutlet UILabel *lblTagSensorTemeratureAndHudmidity;
@property (weak, nonatomic) IBOutlet UILabel *lblTagSensorSmog;
@property (weak, nonatomic) IBOutlet UILabel *lblTagSensorCo;
@property (weak, nonatomic) IBOutlet UILabel *lblTagSensorBody;
@property (weak, nonatomic) IBOutlet UILabel *lblTagSensorLight;
@property (weak, nonatomic) IBOutlet UIImageView *imgVTemeratureAndHudmidity;
@property (weak, nonatomic) IBOutlet UIImageView *imgVSmog;
@property (weak, nonatomic) IBOutlet UIImageView *imgVCo;
@property (weak, nonatomic) IBOutlet UIImageView *imgVBody;
@property (weak, nonatomic) IBOutlet UIImageView *imgVLight;

@property (weak, nonatomic) IBOutlet UILabel *lblCityName;
@property (weak, nonatomic) IBOutlet UILabel *lblCityTemerature;
@property (weak, nonatomic) IBOutlet UILabel *lblCityWind;
@property (weak, nonatomic) IBOutlet UILabel *lblCityWeather;
@property (weak, nonatomic) IBOutlet UILabel *lblCityPm2point5;
@property (weak, nonatomic) IBOutlet UIImageView *imgVBg;

@property (strong, nonatomic) SensorModel *sensorModel;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation SensorViewController

- (void)setup {
  self.navigationItem.title = @"环境监测";
  if (self.aSwitch.sensorBgImage) {
    UIImage *image = [UIImage
        imageWithContentsOfFile:
            [PATH_OF_DOCUMENT
                stringByAppendingPathComponent:self.aSwitch.sensorBgImage]];
    [self.imgVBg setImageToBlur:image
                     blurRadius:50
                completionBlock:^(){
                }];
  } else {
    self.imgVBg.image = [UIImage imageNamed:defaultBg];
  }

  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
      initWithImage:[UIImage imageNamed:@"sensor_rightBar"]
              style:UIBarButtonItemStylePlain
             target:self
             action:@selector(showActionSheet:)];
  self.lblDate.text = [self getDate:[NSDate date]];
  self.lblCityName.text = @"";
  self.lblCityWind.text = @"";
  self.lblCityTemerature.text = @"";
  self.lblCityPm2point5.text = @"";
  self.lblCityWeather.text = @"";
  self.lblSensorCo.text = @"";
  self.lblSensorSmog.text = @"";
  self.lblSensorBody.text = @"";
  self.lblSensorLight.text = @"";
  self.lblSensorTemeratureAndHudmidity.text = @"";
  //设置在列表中获取到的值
  [self setSensorValue:self.aSwitch.sensorInfo];
  self.sensorModel = [[SensorModel alloc] initWithSwitch:self.aSwitch];
  [self.sensorModel queryWeatherInfo:^(CityEnvironment *cityEnviroment) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (cityEnviroment) {
        self.lblCityName.text = cityEnviroment.cityName;
        self.lblCityWind.text = cityEnviroment.wind;
        self.lblCityTemerature.text = cityEnviroment.temperature;
        self.lblCityPm2point5.text =
            [NSString stringWithFormat:@"PM2.5/%@", cityEnviroment.pm2point5];
        self.lblCityWeather.text = cityEnviroment.weather;
      }
    });
  }];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.timer = [NSTimer timerWithTimeInterval:REFRESH_DEV_TIME
                                       target:self
                                     selector:@selector(getSensorInfo:)
                                     userInfo:nil
                                      repeats:YES];
  [self.timer fire];
  [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self.timer invalidate];
  self.timer = nil;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)getSensorInfo:(NSTimer *)timer {
  [self.sensorModel querySensorInfo:^(SensorInfo *sensorInfo) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self setSensorValue:sensorInfo];
    });
  }];
}

- (void)setSensorValue:(SensorInfo *)sensorInfo {
  if (sensorInfo) {
    if (sensorInfo.hasSensorHumidity && sensorInfo.hasSensorTemperature) {
      self.imgVTemeratureAndHudmidity.highlighted = YES;
      self.lblSensorTemeratureAndHudmidity.textColor = kSensorHighlightColor;
      self.lblTagSensorTemeratureAndHudmidity.textColor = kSensorHighlightColor;
      self.lblSensorTemeratureAndHudmidity.text =
          [NSString stringWithFormat:@"%.1f°C %d%%", sensorInfo.temperature,
                                     sensorInfo.humidity];
    } else {
      self.imgVTemeratureAndHudmidity.highlighted = NO;
      self.lblSensorTemeratureAndHudmidity.textColor = kSensorDefaultColor;
      self.lblTagSensorTemeratureAndHudmidity.textColor = kSensorDefaultColor;
      self.lblSensorTemeratureAndHudmidity.text = @"";
    }
    if (sensorInfo.hasSensorCo) {
      self.imgVCo.highlighted = YES;
      self.lblSensorCo.textColor = kSensorHighlightColor;
      self.lblTagSensorCo.textColor = kSensorHighlightColor;
      self.lblSensorCo.text = sensorInfo.coStatus;
    } else {
      self.imgVCo.highlighted = NO;
      self.lblSensorCo.textColor = kSensorDefaultColor;
      self.lblTagSensorCo.textColor = kSensorDefaultColor;
      self.lblSensorCo.text = @"";
    }
    if (sensorInfo.hasSensorSmog) {
      self.imgVSmog.highlighted = YES;
      self.lblSensorSmog.textColor = kSensorHighlightColor;
      self.lblTagSensorSmog.textColor = kSensorHighlightColor;
      self.lblSensorSmog.text = sensorInfo.smogStatus;
    } else {
      self.imgVSmog.highlighted = NO;
      self.lblSensorSmog.textColor = kSensorDefaultColor;
      self.lblTagSensorSmog.textColor = kSensorDefaultColor;
      self.lblSensorSmog.text = @"";
    }
    if (sensorInfo.hasSensorInfaredFlag) {
      self.imgVBody.highlighted = YES;
      self.lblSensorBody.textColor = kSensorHighlightColor;
      self.lblTagSensorBody.textColor = kSensorHighlightColor;
      self.lblSensorBody.text = sensorInfo.infaredStatus;
    } else {
      self.imgVBody.highlighted = NO;
      self.lblSensorBody.textColor = kSensorDefaultColor;
      self.lblTagSensorBody.textColor = kSensorDefaultColor;
      self.lblSensorBody.text = @"";
    }
    if (sensorInfo.hasSensorLight) {
      self.imgVLight.highlighted = YES;
      self.lblSensorLight.textColor = kSensorHighlightColor;
      self.lblTagSensorLight.textColor = kSensorHighlightColor;
      self.lblSensorLight.text = sensorInfo.lightStatus;
      //              [NSString stringWithFormat:@"%d", sensorInfo.light];
    } else {
      self.imgVLight.highlighted = NO;
      self.lblSensorLight.textColor = kSensorDefaultColor;
      self.lblTagSensorLight.textColor = kSensorDefaultColor;
      self.lblSensorLight.text = @"";
    }
  }
}

- (NSString *)getDate:(NSDate *)date {
  NSInteger localMonth, localDay;
  NSInteger month, day, week;
  NSString *weekStr = nil;
  NSArray *chineseMonths = [NSArray
      arrayWithObjects:@"正月", @"二月", @"三月", @"四月", @"五月",
                       @"六月", @"七月", @"八月", @"九月", @"十月",
                       @"冬月", @"腊月", nil];
  NSArray *chineseDays = [NSArray
      arrayWithObjects:@"初一", @"初二", @"初三", @"初四", @"初五",
                       @"初六", @"初七", @"初八", @"初九", @"初十",
                       @"十一", @"十二", @"十三", @"十四", @"十五",
                       @"十六", @"十七", @"十八", @"十九", @"二十",
                       @"廿一", @"廿二", @"廿三", @"廿四", @"廿五",
                       @"廿六", @"廿七", @"廿八", @"廿九", @"三十",
                       nil];
  NSCalendar *localeCalendar =
      [[NSCalendar alloc] initWithCalendarIdentifier:NSChineseCalendar];
  unsigned localUnitFlags = NSMonthCalendarUnit | NSDayCalendarUnit;
  NSDateComponents *localeComp =
      [localeCalendar components:localUnitFlags fromDate:date];
  localMonth = [localeComp month];
  localDay = [localeComp day];
  NSString *m_str = [chineseMonths objectAtIndex:localMonth - 1];
  NSString *d_str = [chineseDays objectAtIndex:localDay - 1];

  NSCalendar *gregorianGalendar =
      [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  unsigned gregorianUnitFlags =
      NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit;
  NSDateComponents *gregorianComp =
      [gregorianGalendar components:gregorianUnitFlags fromDate:date];
  month = [gregorianComp month];
  day = [gregorianComp day];
  week = [gregorianComp weekday];
  if (week == 1) {
    weekStr = NSLocalizedString(@"Sun", nil);
  } else if (week == 2) {
    weekStr = NSLocalizedString(@"Mon", nil);
  } else if (week == 3) {
    weekStr = NSLocalizedString(@"Tues", nil);
  } else if (week == 4) {
    weekStr = NSLocalizedString(@"Wed", nil);
  } else if (week == 5) {
    weekStr = NSLocalizedString(@"Thurs", nil);
  } else if (week == 6) {
    weekStr = NSLocalizedString(@"Fri", nil);
  } else if (week == 7) {
    weekStr = NSLocalizedString(@"Sat", nil);
  } else {
    DDLogDebug(@"error!");
  }
  NSString *dateString =
      [NSString stringWithFormat:@"%d月%d日  %@  %@%@", month, day, weekStr,
                                 m_str, d_str];
  return dateString;
}

- (void)showActionSheet:(id)sender {
  UIActionSheet *actionSheet = [[UIActionSheet alloc]
               initWithTitle:NSLocalizedString(@"How to set the Icon?", nil)
                    delegate:self
           cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
      destructiveButtonTitle:nil
           otherButtonTitles:NSLocalizedString(@"Default", nil),
                             NSLocalizedString(@"Take a picture", nil),
                             NSLocalizedString(@"Choose from album", nil), nil];

  [actionSheet showInView:self.view];
}

#pragma mark---------- ActionSheetDelegate----
- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == actionSheet.cancelButtonIndex) {
    return;
  }
  switch (buttonIndex) {
    case 0:
      self.imgVBg.image = [UIImage imageNamed:defaultBg];
      self.aSwitch.sensorBgImage = nil;
      [[DBUtil sharedInstance] updateSwitch:self.aSwitch sensorBgImage:nil];
      break;
    case 1:
      //调用相机
      [self takePhoto];
      break;
    case 2:
      //调用本地相册
      [self localPhoto];
      break;
  }
}

#pragma mark---获取图片
- (void)takePhoto {
  UIImagePickerControllerSourceType sourceType =
      UIImagePickerControllerSourceTypeCamera;
  if ([UIImagePickerController
          isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    //设置拍照后的图片可被编辑
    picker.allowsEditing = YES;
    picker.sourceType = sourceType;
    [self presentViewController:picker animated:YES completion:nil];
  } else {
    UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"连接到图片库错误"
                                   message:@""
                                  delegate:nil
                         cancelButtonTitle:@"确定"
                         otherButtonTitles:nil];
    [alert show];
  }
}

- (void)localPhoto {
  if ([UIImagePickerController
          isSourceTypeAvailable:
              UIImagePickerControllerSourceTypePhotoLibrary]) {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
  } else {
    UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"连接到图片库错误"
                                   message:@""
                                  delegate:nil
                         cancelButtonTitle:@"确定"
                         otherButtonTitles:nil];
    [alert show];
  }
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker
    didFinishPickingMediaWithInfo:(NSDictionary *)info {
  UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
  if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
  }

  UIImage *theImage =
      [self imageWithImageSimple:image
                    scaledToSize:[UIScreen mainScreen].bounds.size];
  NSString *str =
      [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
  NSString *name = [[[str componentsSeparatedByString:@"."] objectAtIndex:0]
      stringByAppendingString:@".png"];
  [self saveImageFileToDisk:theImage withName:name];
  self.aSwitch.sensorBgImage = name;
  [[DBUtil sharedInstance] updateSwitch:self.aSwitch sensorBgImage:name];
  [self dismissViewControllerAnimated:YES
                           completion:^{
                             [self.imgVBg
                                  setImageToBlur:theImage
                                      blurRadius:50
                                 completionBlock:^() {
                                   DDLogDebug(
                                       @"The blurred image has been set");
                                 }];
                           }];
}

#pragma mark 保存图片到document
- (void)saveImageFileToDisk:(UIImage *)tempImage
                   withName:(NSString *)imageName {
  NSData *imageData = UIImagePNGRepresentation(tempImage);
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                       NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  // Now we get the full path to the file
  NSString *fullPathToFile =
      [documentsDirectory stringByAppendingPathComponent:imageName];
  // and then we write it out
  [imageData writeToFile:fullPathToFile atomically:NO];
}

#pragma mark 压缩图片
- (UIImage *)imageWithImageSimple:(UIImage *)image
                     scaledToSize:(CGSize)newSize {
  // Create a graphics image context
  UIGraphicsBeginImageContext(newSize);

  // Tell the old image to draw in this new context, with the desired
  // new size
  [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];

  // Get the new image from the context
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

  // End the context
  UIGraphicsEndImageContext();

  // Return the new image.
  return newImage;
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
  // bug fixes: UIIMagePickerController使用中偷换StatusBar颜色的问题
  if ([navigationController isKindOfClass:[UIImagePickerController class]] &&
      ((UIImagePickerController *)navigationController).sourceType ==
          UIImagePickerControllerSourceTypePhotoLibrary) {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication]
        setStatusBarStyle:UIStatusBarStyleLightContent
                 animated:NO];
  }
}
@end
