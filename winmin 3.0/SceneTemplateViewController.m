//
//  SceneTemplateViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-25.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SceneTemplateViewController.h"
#import "SceneDetailViewController.h"

@interface SceneTemplateViewController () <UIActionSheetDelegate,
                                           UINavigationControllerDelegate,
                                           UIImagePickerControllerDelegate>
- (IBAction)close:(id)sender;
- (IBAction)touchImg:(id)sender;
@end

@implementation SceneTemplateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
  return NO;
}

- (IBAction)close:(id)sender {
  [[UIApplication sharedApplication] setStatusBarHidden:NO];
  [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)touchImg:(id)sender {
  UIButton *btn = (UIButton *)sender;
  int imgId = btn.tag - 1900;
  if (imgId != 107) {
    NSString *imgName = [NSString stringWithFormat:@"%d__", imgId];
    NSString *sceneName = [kSceneTemplateDict
        objectForKey:[NSString stringWithFormat:@"%d", imgId]];
    [self passImgName:imgName sceneName:sceneName delay:NO];
  } else {
    //自定义
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                 initWithTitle:NSLocalizedString(@"How to set the Icon?", nil)
                      delegate:self
             cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
        destructiveButtonTitle:nil
             otherButtonTitles:NSLocalizedString(@"Take a picture", nil),
                               NSLocalizedString(@"Choose from album", nil),
                               nil];
    [actionSheet showInView:self.view];
  }
}

- (void)passImgName:(NSString *)imgName
          sceneName:(NSString *)sceneName
              delay:(BOOL)delay {
  if (self.sceneTemplateDelegate &&
      [self.sceneTemplateDelegate
          respondsToSelector:@selector(imgName:sceneName:)]) {
    [self.sceneTemplateDelegate imgName:imgName sceneName:sceneName];
  }
  if (delay) {
    [self performSelector:@selector(close:) withObject:nil afterDelay:1];
  } else {
    [self close:nil];
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
      [self imageWithImageSimple:image scaledToSize:CGSizeMake(168.0, 168.0)];
  NSString *str =
      [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
  NSString *name = [[[str componentsSeparatedByString:@"."] objectAtIndex:0]
      stringByAppendingString:@".png"];
  [self saveImage:theImage withName:name];
  [self dismissViewControllerAnimated:YES completion:nil];
  [self passImgName:name sceneName:nil delay:YES];
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
