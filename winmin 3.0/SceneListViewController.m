//
//  SceneListViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-25.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SceneListViewController.h"
#import "SceneDetailViewController.h"
#import "SceneExecuteViewController.h"
#import "SceneCell.h"

@interface SceneListViewController ()<UIActionSheetDelegate>
@property(nonatomic, strong) NSIndexPath *longPressIndexPath;
@end

@implementation SceneListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)setup {
  self.navigationItem.title = @"场景";
  UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
  backButtonItem.title = @"返回";
  self.navigationItem.backBarButtonItem = backButtonItem;
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                           target:self
                           action:@selector(addScene:)];
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
#pragma mark - UICollectionViewDatasource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"SceneCell";
  UICollectionViewCell *cell =
      [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier
                                                forIndexPath:indexPath];
  //  cell.backgroundColor = [UIColor grayColor];
  UILongPressGestureRecognizer *longPressGesture =
      [[UILongPressGestureRecognizer alloc]
          initWithTarget:self
                  action:@selector(handlerLongPress:)];
  longPressGesture.minimumPressDuration = 0.5;
  [cell addGestureRecognizer:longPressGesture];
  return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return 5;
}

#pragma mark - UICollectionViewDelegate
// UICollectionView被选中时调用的方法
- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  [collectionView deselectItemAtIndexPath:indexPath animated:YES];
  //  SceneCell *cell =
  //      (SceneCell *)[collectionView cellForItemAtIndexPath:indexPath];
  //  cell.backgroundColor = [UIColor whiteColor];
  //  SceneExecuteViewController *executeViewController = [self.storyboard
  //      instantiateViewControllerWithIdentifier:@"SceneExecuteViewController"];
  SceneExecuteViewController *executeViewController =
      [[SceneExecuteViewController alloc] init];

  UIWindow *window =
      [[[UIApplication sharedApplication] windows] objectAtIndex:0];
  [window addSubview:executeViewController.view];
  //  [self.navigationController pushViewController:executeViewController
  //                                       animated:YES];
}

//返回这个UICollectionView是否可以被选择
- (BOOL)collectionView:(UICollectionView *)collectionView
    shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}

#pragma mark - UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  return CGSizeMake(140, 140);
}

//定义每个UICollectionView 的 margin
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
  return UIEdgeInsetsMake(10, 10, 10, 10);
}

#pragma mark -
- (void)addScene:(id)sender {
  SceneDetailViewController *nextViewController = [self.storyboard
      instantiateViewControllerWithIdentifier:@"SceneDetailViewController"];
  [self.navigationController pushViewController:nextViewController
                                       animated:YES];
}

#pragma mark - 长按处理
- (void)handlerLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
  CGPoint p = [gestureRecognizer locationInView:self.collectionView];
  NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
  if (indexPath && gestureRecognizer.state == UIGestureRecognizerStateBegan) {
    self.longPressIndexPath = indexPath;
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                 initWithTitle:@"您希望对这个场景执行怎样的操作"
                      delegate:self
             cancelButtonTitle:@"取消"
        destructiveButtonTitle:nil
             otherButtonTitles:@"编辑", @"删除", nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
  }
}

- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  //  SDZGSwitch *aSwitch =
  //      [self.switchs objectAtIndex:self.longPressIndexPath.row];
  switch (buttonIndex) {
    case 0:
      //编辑
      //      [self.model blinkSwitch:aSwitch];
      break;
    case 1:
      //删除
      //      [[SwitchDataCeneter sharedInstance] removeSwitch:aSwitch];
      break;
    default:
      break;
  }
}

@end
