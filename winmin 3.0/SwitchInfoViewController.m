//
//  SwitchInfoViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-22.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SwitchInfoViewController.h"
#import "SwitchInfoModel.h"
#import "ApService.h"
#import <CRToast.h>
static const int maxPower = 2500;
@interface InfoTextField : UITextField

@end

@implementation InfoTextField
//控制文本所在的的位置，左右缩 10
- (CGRect)textRectForBounds:(CGRect)bounds {
  return CGRectInset(bounds, 20, 0);
}

//控制编辑文本时所在的位置，左右缩 10
- (CGRect)editingRectForBounds:(CGRect)bounds {
  return CGRectInset(bounds, 20, 0);
}
@end

@interface SwitchInfoCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UIView *outerView;
@end

@implementation SwitchInfoCell
- (void)awakeFromNib {
  self.outerView.layer.borderColor =
      [UIColor colorWithHexString:@"#c3c3c3"].CGColor;
  self.outerView.layer.borderWidth = .5f;
  self.outerView.layer.cornerRadius = 10.f;
}
@end

@interface SwitchInfoViewController () <
    UIActionSheetDelegate, UITextFieldDelegate, UINavigationControllerDelegate,
    UIImagePickerControllerDelegate>
@property (nonatomic, strong) IBOutlet UIImageView *imgViewSwitch;
@property (nonatomic, strong) IBOutlet UITextField *textFieldName;
@property (nonatomic, strong) IBOutlet UITextField *textFieldAlertUnder;
@property (nonatomic, strong) IBOutlet UITextField *textFieldAlertGreater;
@property (nonatomic, strong) IBOutlet UITextField *textFieldOffUnder;
@property (nonatomic, strong) IBOutlet UITextField *textFieldOffGreater;
@property (nonatomic, strong) IBOutlet UISwitch *_switchLock;
@property (nonatomic, strong) IBOutlet UISwitch *_switchAlertUnder;
@property (nonatomic, strong) IBOutlet UISwitch *_switchAlertGreater;
@property (nonatomic, strong) IBOutlet UISwitch *_switchOffUnder;
@property (nonatomic, strong) IBOutlet UISwitch *_switchOffGreater;
@property (nonatomic, strong) UITextField *currentEditField;

@property (nonatomic, assign) LockStatus lockStatus;
@property (nonatomic, assign) BOOL isAlertUnder;
@property (nonatomic, assign) BOOL isAlertGreater;
@property (nonatomic, assign) BOOL isOffUnder;
@property (nonatomic, assign) BOOL isOffGreater;
@property (nonatomic, assign) short alertUnderValue;
@property (nonatomic, assign) short alertGreaterValue;
@property (nonatomic, assign) short offUnderValue;
@property (nonatomic, assign) short offGreaterValue;
- (IBAction)showActionSheet:(id)sender;
- (IBAction)switchValueChanged:(id)sender;

@property (nonatomic, strong) NSString *imgName; //保存在本地的图片名称
@property (nonatomic, strong) SwitchInfoModel *model;
@property (nonatomic, strong) UIButton *btnDone; //键盘左下角的按钮

@property (nonatomic, assign) BOOL isUpdateNameSuccess;
@property (nonatomic, assign) BOOL isUpdateLockSuccess;
@property (nonatomic, assign) BOOL isUpdatePowerInfoSuccess;
//标识是否进行了修改
@property (nonatomic, assign) BOOL isImgUpdate;
@property (nonatomic, assign) BOOL isNameUpdate;
@property (nonatomic, assign) BOOL isLockUpdate;
@property (nonatomic, assign) BOOL isPowerInfoUpdate;
//保存原有信息
@property (nonatomic, strong)
    NSString *switchName; //保存修改前的名称，对比不一致才提交请求
@property (nonatomic, assign) BOOL originalLock;
@end

@implementation SwitchInfoViewController
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)setup {
  self.navigationItem.title = self.aSwitch.name;
  self.navigationItem.rightBarButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil)
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(save:)];

  UIView *tableHeaderView = [[UIView alloc]
      initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 10)];
  tableHeaderView.backgroundColor = [UIColor clearColor];
  self.tableView.tableHeaderView = tableHeaderView;
  self.textFieldName.delegate = self;
  self.textFieldAlertUnder.delegate = self;
  self.textFieldAlertGreater.delegate = self;
  self.textFieldOffUnder.delegate = self;
  self.textFieldOffGreater.delegate = self;

  self.textFieldName.text = self.aSwitch.name;
  self.imgViewSwitch.image = [SDZGSwitch imgNameToImage:self.aSwitch.imageName];
  if (self.aSwitch.lockStatus == LockStatusOn) {
    self._switchLock.on = YES;
  } else {
    self._switchLock.on = NO;
  }
  self.switchName = self.aSwitch.name;
  self.originalLock = self.aSwitch.lockStatus;
  self.model = [[SwitchInfoModel alloc] initWithSwitch:self.aSwitch];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(switchOnOffChanged:)
             name:kSwitchOnOffStateChange
           object:self.model];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(switchNameChanged:)
             name:kSwitchNameChange
           object:self.model];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(noResponseNotification:)
             name:kNoResponseNotification
           object:self.model];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(getElecPowerInfoSuccessNotification:)
             name:kGetElecPowerInfoSuccess
           object:self.model];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(setElecPowerInfoSuccessNotification:)
             name:kSetElecPowerInfoSuccess
           object:self.model];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(keyboardDidShow:)
             name:UIKeyboardDidShowNotification
           object:nil];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(keyboardWillBeHidden:)
             name:UIKeyboardWillHideNotification
           object:nil];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self setup];

  [self.model getElecPowerInfo];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)save:(id)sender {
  if ([self check]) {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (self.isImgUpdate) {
      [self saveImageInfoToDB];
    }
    if (self.isNameUpdate) {
      self.isUpdateNameSuccess = NO;
      [self.model setSwitchName:self.switchName];
    } else {
      self.isUpdateNameSuccess = YES;
    }
    if (self.isLockUpdate) {
      self.isUpdateLockSuccess = NO;
      [self.model changeSwitchLockStatus];
    } else {
      self.isUpdateLockSuccess = YES;
    }

    self.isUpdatePowerInfoSuccess = NO;
    self.isAlertUnder = self._switchAlertUnder.on;
    self.isAlertGreater = self._switchAlertGreater.on;
    self.isOffUnder = self._switchOffUnder.on;
    self.isOffGreater = self._switchOffGreater.on;
    [self.model setElecInfoWithAlertUnder:self.alertUnderValue
                             isAlertUnder:self.isAlertUnder
                             alertGreater:self.alertGreaterValue
                           isAlertGreater:self.isAlertGreater
                             turnOffUnder:self.offUnderValue
                           isTurnOffUnder:self.isOffUnder
                           turnOffGreater:self.offGreaterValue
                         isTurnOffGreater:self.isOffGreater];
  }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)check {
  [self.textFieldName resignFirstResponder];
  [self.textFieldAlertUnder resignFirstResponder];
  [self.textFieldAlertGreater resignFirstResponder];
  [self.textFieldOffUnder resignFirstResponder];
  [self.textFieldOffGreater resignFirstResponder];
  NSCharacterSet *charSet = [NSCharacterSet whitespaceCharacterSet];
  NSString *name =
      [self.textFieldName.text stringByTrimmingCharactersInSet:charSet];
  if ([name isEqualToString:@""]) {
    [CRToastManager
        showNotificationWithMessage:NSLocalizedString(@"Name can't empty", nil)
                    completionBlock:^{}];
    return NO;
  }

  float alertUnder = [[self.textFieldAlertUnder.text
      stringByTrimmingCharactersInSet:charSet] floatValue];
  float alertGreater = [[self.textFieldAlertGreater.text
      stringByTrimmingCharactersInSet:charSet] floatValue];
  float offUnder = [[self.textFieldOffUnder.text
      stringByTrimmingCharactersInSet:charSet] floatValue];
  float offGreater = [[self.textFieldOffGreater.text
      stringByTrimmingCharactersInSet:charSet] floatValue];
  if ((self._switchAlertUnder && (alertUnder <= 0 || alertUnder > maxPower)) ||
      (self._switchAlertGreater &&
       (alertGreater <= 0 || alertGreater > maxPower)) ||
      (self._switchOffUnder && (offUnder <= 0 || offUnder > maxPower)) ||
      (self._switchOffGreater && (offGreater <= 0 || offGreater > maxPower))) {
    [CRToastManager
        showNotificationWithMessage:NSLocalizedString(
                                        @"Power Set Message Error", nil)
                    completionBlock:^{

                    }];
    return NO;
  }
  return YES;
  //  if (alertGreater < 0 || alertGreater > maxPower) {
  //  }
  //  if (offUnder < 0 || offUnder > maxPower) {
  //  }
  //  if (offGreater < 0 || offGreater > maxPower) {
  //  }
}

- (IBAction)showActionSheet:(id)sender {
  [self.textFieldName resignFirstResponder];
  UIActionSheet *actionSheet = [[UIActionSheet alloc]
               initWithTitle:NSLocalizedString(@"How to set the Icon?", nil)
                    delegate:self
           cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
      destructiveButtonTitle:nil
           otherButtonTitles:NSLocalizedString(@"Take a picture", nil),
                             NSLocalizedString(@"Choose from album", nil), nil];

  [actionSheet showInView:self.view];
}

- (IBAction)switchValueChanged:(id)sender {
  NSCharacterSet *charSet = [NSCharacterSet whitespaceCharacterSet];
  [self.textFieldName resignFirstResponder];
  [self.textFieldAlertUnder resignFirstResponder];
  [self.textFieldAlertGreater resignFirstResponder];
  [self.textFieldOffUnder resignFirstResponder];
  [self.textFieldOffGreater resignFirstResponder];

  UISwitch *_switch = (UISwitch *)sender;
  if (_switch == self._switchLock) {
    if (self._switchLock.on) {
      self.lockStatus = LockStatusOn;
    } else {
      self.lockStatus = LockStatusOff;
    }
    if (self._switchLock.on == self.lockStatus) {
      self.isLockUpdate = YES;
    } else {
      self.isLockUpdate = NO;
    }
  } else if (_switch == self._switchAlertUnder) {
    NSString *alertUnder =
        [self.textFieldAlertUnder.text stringByTrimmingCharactersInSet:charSet];
    if (_switch.on) {
      if ([alertUnder isEqualToString:@""] ||
          [alertUnder isEqualToString:@"0"]) {
        self.textFieldAlertUnder.text = @"20";
        self.alertUnderValue = 20;
      }
    }
  } else if (_switch == self._switchAlertGreater) {
    NSString *alertGreater = [self.textFieldAlertGreater.text
        stringByTrimmingCharactersInSet:charSet];
    if (_switch.on) {
      if ([alertGreater isEqualToString:@""] ||
          [alertGreater isEqualToString:@"0"]) {
        self.textFieldAlertGreater.text =
            [NSString stringWithFormat:@"%.0f", maxPower * 0.9];
        self.alertGreaterValue = maxPower * 0.9;
      }
    }
  } else if (_switch == self._switchOffUnder) {
    NSString *offUnder =
        [self.textFieldOffUnder.text stringByTrimmingCharactersInSet:charSet];
    if (_switch.on) {
      if ([offUnder isEqualToString:@""] || [offUnder isEqualToString:@"0"]) {
        self.textFieldOffUnder.text = @"5";
        self.offUnderValue = 5;
      }
    }
  } else if (_switch == self._switchOffGreater) {
    NSString *offGreater =
        [self.textFieldOffGreater.text stringByTrimmingCharactersInSet:charSet];
    if (_switch.on) {
      if ([offGreater isEqualToString:@""] ||
          [offGreater isEqualToString:@"0"]) {
        self.textFieldOffGreater.text =
            [NSString stringWithFormat:@"%.0f", maxPower * 0.99];
        self.offGreaterValue = maxPower * 0.99;
      }
    }
  }
}

#pragma mark - UITextField协议
- (void)textFieldDidBeginEditing:(UITextField *)textField {
  self.currentEditField = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  if (textField == self.textFieldName) {
    NSString *switchName = textField.text;
    if (switchName.length && ![self.switchName isEqualToString:switchName]) {
      self.switchName = switchName;
      self.isNameUpdate = YES;
    }
  } else if (textField == self.textFieldAlertUnder) {
    self.alertUnderValue = [textField.text floatValue];
  } else if (textField == self.textFieldAlertGreater) {
    self.alertGreaterValue = [textField.text floatValue];
  } else if (textField == self.textFieldOffUnder) {
    self.offUnderValue = [textField.text floatValue];
  } else if (textField == self.textFieldOffGreater) {
    self.offGreaterValue = [textField.text floatValue];
  }
}

//- (BOOL)textField:(UITextField *)textField
//    shouldChangeCharactersInRange:(NSRange)range
//                replacementString:(NSString *)string {
//  if (range.location == textField.text.length &&
//      [string isEqualToString:@" "]) {
//    // ignore replacement string and add your own
//    textField.text = [textField.text stringByAppendingString:@"\u00a0"];
//    return NO;
//  }
//  // for all other cases, proceed with replacement
//  return YES;
//}

#pragma mark - 通知
- (void)getElecPowerInfoSuccessNotification:(NSNotification *)notification {
  CC3xMessage *message = notification.userInfo[@"message"];
  if (message.alertUnder == 0) {
    message.alertUnder = 20;
  }
  self.alertUnderValue = message.alertUnder;
  if (message.alertGreater == 0) {
    message.alertGreater = maxPower * 0.9f;
  }
  self.alertGreaterValue = message.alertGreater;
  if (message.turnOffUnder == 0) {
    message.turnOffUnder = 5;
  }
  self.offUnderValue = message.turnOffUnder;
  if (message.turnOffGreater == 0) {
    message.turnOffGreater = maxPower * .99f;
  }
  self.offGreaterValue = message.turnOffGreater;
  self._switchAlertUnder.on = message.isAlertUnderOn;
  self._switchAlertGreater.on = message.isAlertGreaterOn;
  self._switchOffUnder.on = message.isTurnOffUnderOn;
  self._switchOffGreater.on = message.isTurnOffGreaterOn;
  dispatch_async(MAIN_QUEUE, ^{
      self.textFieldAlertUnder.text =
          [NSString stringWithFormat:@"%d", message.alertUnder];
      self.textFieldAlertGreater.text =
          [NSString stringWithFormat:@"%d", message.alertGreater];
      self.textFieldOffUnder.text =
          [NSString stringWithFormat:@"%d", message.turnOffUnder];
      self.textFieldOffGreater.text =
          [NSString stringWithFormat:@"%d", message.turnOffGreater];
  });
}

- (void)setElecPowerInfoSuccessNotification:(NSNotification *)notification {
  self.isUpdatePowerInfoSuccess = YES;
  dispatch_async(MAIN_QUEUE, ^{ [self allResuestSuccess]; });
}

- (void)switchNameChanged:(NSNotification *)notification {
  self.isUpdateNameSuccess = YES;
  self.isNameUpdate = NO;
  debugLog(@"########switch name changed");
  [[SwitchDataCeneter sharedInstance] updateSwitchName:self.switchName
                                           socketNames:nil
                                                   mac:self.aSwitch.mac];
  dispatch_async(MAIN_QUEUE, ^{
      [self allResuestSuccess];
      self.navigationItem.title = self.switchName;
      int count = [[self.navigationController viewControllers] count];
      UIViewController *popViewController =
          [[self.navigationController viewControllers] objectAtIndex:count - 2];
      popViewController.navigationItem.title = self.switchName;

  });
}

- (void)switchOnOffChanged:(NSNotification *)notification {
  self.isUpdateLockSuccess = YES;
  self.isLockUpdate = NO;
  [[SwitchDataCeneter sharedInstance] updateSwitchLockStaus:self.lockStatus
                                                        mac:self.aSwitch.mac];
  dispatch_async(MAIN_QUEUE, ^{ [self allResuestSuccess]; });
}

- (void)allResuestSuccess {
  if (self.isUpdateNameSuccess && self.isUpdateLockSuccess &&
      self.isUpdatePowerInfoSuccess) {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [CRToastManager
        showNotificationWithMessage:NSLocalizedString(@"Save Success", nil)
                    completionBlock:^{}];
    [self.navigationController popViewControllerAnimated:YES];
  }
}

- (void)noResponseNotification:(NSNotification *)notif {
  dispatch_async(MAIN_QUEUE, ^{
      [MBProgressHUD hideHUDForView:self.view animated:YES];
      NSDictionary *userInfo = notif.userInfo;
      long tag = [userInfo[@"tag"] longValue];
      switch (tag) {
        case P2D_DEV_LOCK_REQ_47:
        case P2S_DEV_LOCK_REQ_49:
          //锁定状态还原
          self._switchLock.on = !self._switchLock.on;
          [self.view makeToast:NSLocalizedString(@"No UDP Response Msg", nil)];
          break;
        case P2D_SET_NAME_REQ_3F:
        case P2S_SET_NAME_REQ_41:
          //名字还原
          self.textFieldName.text = self.aSwitch.name;
          [self.view makeToast:NSLocalizedString(@"No UDP Response Msg", nil)];
          break;
      }
  });
}

#pragma mark - 键盘通知
- (void)keyboardDidShow:(NSNotification *)notification {
  if (self.currentEditField == self.textFieldOffUnder ||
      self.currentEditField == self.textFieldOffGreater ||
      self.currentEditField == self.textFieldAlertUnder ||
      self.currentEditField == self.textFieldAlertGreater) {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize =
        [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat width = kbSize.width / 3;
    CGFloat height = kbSize.height / 4;
    if (self.btnDone == nil) {
      self.btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
      self.btnDone.frame = CGRectMake(0, SCREEN_HEIGHT - height, width, height);
      [self.btnDone setTitle:NSLocalizedString(@"Keyboard return", nil)
                    forState:UIControlStateNormal];
      [self.btnDone setTitleColor:[UIColor blackColor]
                         forState:UIControlStateNormal];
      [self.btnDone addTarget:self
                       action:@selector(finishAction:)
             forControlEvents:UIControlEventTouchUpInside];
    }

    // locate keyboard view
    UIWindow *tempWindow =
        [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    if (self.btnDone.superview == nil) {
      [tempWindow addSubview:self.btnDone]; // 注意这里直接加到window上
    }

    CGRect selfFrame = self.view.frame;
    selfFrame.origin.y -= 90;
    [UIView animateWithDuration:0.3
                     animations:^{ self.view.frame = selfFrame; }];
  }
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
  if (self.currentEditField == self.textFieldOffUnder ||
      self.currentEditField == self.textFieldOffGreater ||
      self.currentEditField == self.textFieldAlertUnder ||
      self.currentEditField == self.textFieldAlertGreater) {
    CGRect selfFrame = self.view.frame;
    selfFrame.origin.y += 90;
    [UIView animateWithDuration:0.3
                     animations:^{ self.view.frame = selfFrame; }];
    if (self.btnDone.superview) {
      [self.btnDone removeFromSuperview];
      self.btnDone = nil;
    }
  }
}

//#pragma mark - 键盘通知
//- (void)keyboardDidShow:(NSNotification *)notification {
//    NSDictionary *info = [notification userInfo];
//    CGRect kbRect =
//    [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
//    kbRect = [self.view convertRect:kbRect fromView:nil];
//
//    UIEdgeInsets contentInsets =
//    UIEdgeInsetsMake(0.0, 0.0, kbRect.size.height, 0.0);
//    self.scrollView.contentInset = contentInsets;
//    self.scrollView.scrollIndicatorInsets = contentInsets;
//
//    CGRect aRect = self.view.frame;
//    aRect.size.height -= kbRect.size.height;
//    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin)) {
//        [self.scrollView scrollRectToVisible:self.activeField.frame
//        animated:YES];
//    }
//}
//
//- (void)keyboardWillBeHidden:(NSNotification *)notification {
//    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
//    self.scrollView.contentInset = contentInsets;
//    self.scrollView.scrollIndicatorInsets = contentInsets;
//}

- (void)finishAction:(id)sender {
  //  [self.textField resignFirstResponder];
  //  self.actionMinitues = [self.textField.text intValue];
  [self.currentEditField resignFirstResponder];
}

#pragma mark - 选择图片
#pragma mark---------- ActionSheetDelegate----
- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == actionSheet.cancelButtonIndex) {
    return;
  }
  switch (buttonIndex) {
    case 0:
      //调用相机
      [self takePhoto];
      break;
    case 1:
      //调用本地相册
      [self localPhoto];
      break;
  }
}

- (BOOL)saveImageInfoToDB {
  if (self.isImgUpdate) {
    [[DBUtil sharedInstance] updateSwitch:self.aSwitch imageName:self.imgName];
    [[SwitchDataCeneter sharedInstance] updateSwitchImageName:self.imgName
                                                          mac:self.aSwitch.mac];
  }
  return YES;
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
      [self imageWithImageSimple:image scaledToSize:CGSizeMake(112.0, 112.0)];
  NSString *str =
      [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
  NSString *name = [[[str componentsSeparatedByString:@"."] objectAtIndex:0]
      stringByAppendingString:@".png"];
  [self saveImageFileToDisk:theImage withName:name];
  [self dismissViewControllerAnimated:YES completion:nil];
  self.imgName = name;
  self.imgViewSwitch.image = [SDZGSwitch imgNameToImage:name];
  self.isImgUpdate = YES;
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
#pragma mark -
@end
