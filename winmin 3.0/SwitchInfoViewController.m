//
//  SwitchInfoViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-22.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SwitchInfoViewController.h"
#import "SwitchInfoModel.h"
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
@property(nonatomic, strong) IBOutlet UIView *outerView;
@end

@implementation SwitchInfoCell
- (void)awakeFromNib {
  self.outerView.layer.borderColor =
      [UIColor colorWithHexString:@"#c3c3c3"].CGColor;
  self.outerView.layer.borderWidth = .5f;
  self.outerView.layer.cornerRadius = 10.f;
}
@end

@interface SwitchInfoViewController ()<
    UIActionSheetDelegate, UITextFieldDelegate, UINavigationControllerDelegate,
    UIImagePickerControllerDelegate>
@property(nonatomic, strong) IBOutlet UIImageView *imgViewSwitch;
@property(nonatomic, strong) IBOutlet UITextField *textFieldName;
@property(nonatomic, strong) IBOutlet UISwitch *_switch;
@property(nonatomic, strong)
    NSString *switchName;  //保存修改前的名称，对比不一致才提交请求
@property(nonatomic, assign) LockStatus lockStatus;
- (IBAction)showActionSheet:(id)sender;
- (IBAction)switchValueChanged:(id)sender;

@property(nonatomic, strong) NSString *imgName;  //保存在本地的图片名称
@property(nonatomic, strong) SwitchInfoModel *model;
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
  UIView *tableHeaderView = [[UIView alloc]
      initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 10)];
  tableHeaderView.backgroundColor = [UIColor clearColor];
  self.tableView.tableHeaderView = tableHeaderView;
  self.textFieldName.delegate = self;
  self.textFieldName.text = self.aSwitch.name;
  self.switchName = self.aSwitch.name;
  self.imgViewSwitch.image = [SDZGSwitch imgNameToImage:self.aSwitch.imageName];
  if (self.aSwitch.lockStatus == LockStatusOn) {
    self._switch.on = YES;
  } else {
    self._switch.on = NO;
  }
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

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
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
- (IBAction)showActionSheet:(id)sender {
  [self.textFieldName resignFirstResponder];
  UIActionSheet *actionSheet = [[UIActionSheet alloc]
               initWithTitle:@"自定义电器"
                    delegate:self
           cancelButtonTitle:@"取消"
      destructiveButtonTitle:nil
           otherButtonTitles:@"拍照", @"从手机相册中选择", nil];
  [actionSheet showInView:self.view];
}

- (IBAction)switchValueChanged:(id)sender {
  [self.textFieldName resignFirstResponder];
  if (self._switch.on) {
    self.lockStatus = LockStatusOn;
  } else {
    self.lockStatus = LockStatusOff;
  }
  [self.model changeSwitchLockStatus];
}

#pragma mark - UITextField协议
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  NSString *switchName = textField.text;
  if (switchName.length && ![self.switchName isEqualToString:switchName]) {
    self.switchName = switchName;
    [self.model setSwitchName:switchName];
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
- (void)switchNameChanged:(NSNotification *)notification {
  debugLog(@"########switch name changed");
  [[SwitchDataCeneter sharedInstance] updateSwitchName:self.switchName
                                           socketNames:nil
                                                   mac:self.aSwitch.mac];
  dispatch_async(MAIN_QUEUE, ^{ self.navigationItem.title = self.switchName; });
}

- (void)switchOnOffChanged:(NSNotification *)notification {
  [[SwitchDataCeneter sharedInstance] updateSwitchLockStaus:self.lockStatus
                                                        mac:self.aSwitch.mac];
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

- (BOOL)saveImage:(NSString *)imgName {
  BOOL result =
      [[DBUtil sharedInstance] updateSwitch:self.aSwitch imageName:imgName];
  [[SwitchDataCeneter sharedInstance] updateSwitchImageName:imgName
                                                        mac:self.aSwitch.mac];
  return result;
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
  [self saveImage:theImage withName:name];
  [self dismissViewControllerAnimated:YES completion:nil];
  self.imgName = name;
  self.imgViewSwitch.image = [SDZGSwitch imgNameToImage:name];
  if (![self saveImage:name]) {
    // TOOD:提示修改失败
  }
}

#pragma mark 保存图片到document
- (void)saveImage:(UIImage *)tempImage withName:(NSString *)imageName {
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
