//
//  SocketImgTemplateViewController.m
//  winmin 3.0
//  插孔选择模板图片
//  Created by sdzg on 14-9-18.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SocketImgTemplateViewController.h"
#define kRowHeight 80.f
#define kMargin 80.f

@interface SocketImgTemplateViewController ()<UINavigationControllerDelegate,
                                              UIImagePickerControllerDelegate,
                                              UIActionSheetDelegate>
@property(strong, nonatomic) IBOutlet UIView *backgroundView;
- (IBAction)close:(id)sender;
- (IBAction)touchImg:(id)sender;
@end

@implementation SocketImgTemplateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)setup {
  //  NSString *path =
  //      [[NSBundle mainBundle] pathForResource:@"image" ofType:@"plist"];
  //  NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
  //  NSArray *templates = [dict objectForKey:@"socket_template"];
  //  int count = templates.count;
  //  int rows = count % 4;
  //  if (count % 4 != 0) {
  //    rows += 1;
  //  }
  //  self.backgroundView.frame =
  //      CGRectMake(0, 0, SCREEN_WIDTH, rows * kRowHeight + 2 * kMargin);
  //  for (int i = 0; i < rows; i++) {
  //    UIView *rowView =
  //        [[UIView alloc] initWithFrame:CGRectMake(0, kRowHeight * (i + 1),
  //                                                 SCREEN_WIDTH, kRowHeight)];
  //    for (int j = 0; j < 4; j++) {
  //      UIView *contentView = [[UIView alloc]
  //          initWithFrame:CGRectMake(kRowHeight * j, 0, kRowHeight,
  //          kRowHeight)];
  //    }
  //  }
  //
  //  [self setModalPresentationCapturesStatusBarAppearance:NO];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self setup];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
    [self prefersStatusBarHidden];
    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
  return NO;
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
- (IBAction)close:(id)sender {
  [[UIApplication sharedApplication] setStatusBarHidden:NO];
  [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)touchImg:(id)sender {
  UIButton *btn = (UIButton *)sender;
  int imgId = btn.tag - 1000;
  if (imgId != 11) {
    NSString *imgName;
    if (imgId >= 10) {
      imgName = [NSString stringWithFormat:@"0%d_", imgId];
    } else {
      imgName = [NSString stringWithFormat:@"00%d_", imgId];
    }
    if ([self saveImage:imgName]) {
      if (self.delegate &&
          [self.delegate
              respondsToSelector:@selector(socketView:socketId:imgName:)]) {
        [self.delegate socketView:self.socketView
                         socketId:self.socketId
                          imgName:imgName];
      }
      [self close:nil];
    } else {
      // TODO:保存图片信息失败后提示信息
    }
  } else {
    //自定义
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                 initWithTitle:@"自定义电器"
                      delegate:self
             cancelButtonTitle:@"取消"
        destructiveButtonTitle:nil
             otherButtonTitles:@"拍照", @"从手机相册中选择", nil];
    [actionSheet showInView:self.view];
  }
}

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
  //保存到数据库
  BOOL saveToDBResult =
      [[DBUtil sharedInstance] updateSocketImage:imgName
                                         groupId:self.socketView.groupId
                                        socketId:self.socketId
                                     whichSwitch:self.aSwitch];
  //修改内存中的备份
  [[SwitchDataCeneter sharedInstance] updateSocketImage:imgName
                                                groupId:self.socketView.groupId
                                               socketId:self.socketId
                                            whichSwitch:self.aSwitch];
  return saveToDBResult;
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

  if ([self saveImage:name]) {
    if (self.delegate &&
        [self.delegate
            respondsToSelector:@selector(socketView:socketId:imgName:)]) {
      [self.delegate socketView:self.socketView
                       socketId:self.socketId
                        imgName:name];
    }
    [self performSelector:@selector(close:) withObject:nil afterDelay:1];
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

@end
