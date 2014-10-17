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
@property(nonatomic, strong) NSMutableArray *scenes;

@property(nonatomic, strong) UIView *noDataView;
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
  self.noDataView =
      [[UIView alloc] initWithSize:self.view.frame.size
                           imgName:@"noscene"
                           message:@"您暂时还未添加任何场景"];
  self.noDataView.hidden = YES;
  [self.view addSubview:self.noDataView];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(addOrUpdateScene:)
             name:kSceneAddOrUpdateNotification
           object:nil];
  [[NSNotificationCenter defaultCenter]
      addObserverForName:kSwitchDeleteSceneNotification
                  object:nil
                   queue:nil
              usingBlock:^(NSNotification *note) {
                  self.scenes = [[[DBUtil sharedInstance] scenes] mutableCopy];
                  [self.collectionView reloadData];
                  if (!self.scenes || self.scenes.count == 0) {
                    self.noDataView.hidden = NO;
                  }
              }];
  self.scenes = [[[DBUtil sharedInstance] scenes] mutableCopy];
  if (!self.scenes || self.scenes.count == 0) {
    self.noDataView.hidden = NO;
  }
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
#pragma mark - UICollectionViewDatasource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"SceneCell";
  SceneCell *cell =
      [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier
                                                forIndexPath:indexPath];
  Scene *scene = self.scenes[indexPath.row];
  [cell setCellInfo:scene];
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
  return self.scenes.count;
}

#pragma mark - UICollectionViewDelegate
// UICollectionView被选中时调用的方法
- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  [collectionView deselectItemAtIndexPath:indexPath animated:YES];
  SceneExecuteViewController *executeViewController =
      [[SceneExecuteViewController alloc] init];
  Scene *scene = self.scenes[indexPath.row];
  executeViewController.scene = scene;
  UIWindow *window =
      [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  kSharedAppliction.userWindow = window;
  window.rootViewController = executeViewController;
  window.windowLevel = UIWindowLevelAlert;
  [window makeKeyAndVisible];
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
  Scene *scene = self.scenes[self.longPressIndexPath.row];
  switch (buttonIndex) {
    case 0:
      //编辑
      {
        SceneDetailViewController *nextViewController =
            [self.storyboard instantiateViewControllerWithIdentifier:
                                 @"SceneDetailViewController"];
        nextViewController.scene = scene;
        nextViewController.row = self.longPressIndexPath.row;
        [self.navigationController pushViewController:nextViewController
                                             animated:YES];
      }

      break;
    case 1:
      //删除
      {
        [[DBUtil sharedInstance] removeScene:scene];
        //删除后提示页面
        NSArray *indexPaths = @[ self.longPressIndexPath ];
        [self.collectionView performBatchUpdates:^{
            [self.scenes removeObjectAtIndex:self.longPressIndexPath.row];
            [self.collectionView deleteItemsAtIndexPaths:indexPaths];
        } completion:^(BOOL finished) {
            if (finished) {
              if (self.scenes.count == 0) {
                [UIView animateWithDuration:0.3
                                 animations:^{ self.noDataView.hidden = NO; }];
              }
            }
        }];
      }
      break;
    default:
      break;
  }
}

#pragma mark - 添加修改scene后通知
- (void)addOrUpdateScene:(NSNotification *)notification {
  NSDictionary *userInfo = notification.userInfo;
  int row = [userInfo[@"row"] intValue];
  Scene *scene = userInfo[@"scene"];
  if (row == -1) {
    if (!self.noDataView.hidden) {
      self.noDataView.hidden = YES;
    }
    //添加
    [self.collectionView performBatchUpdates:^{
        [self.scenes addObject:scene];
        NSIndexPath *indexPath =
            [NSIndexPath indexPathForRow:self.scenes.count - 1 inSection:0];
        [self.collectionView insertItemsAtIndexPaths:@[ indexPath ]];
    } completion:^(BOOL finished) {}];
  } else {
    //修改
    [self.collectionView performBatchUpdates:^{
        [self.scenes replaceObjectAtIndex:row withObject:scene];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.collectionView reloadItemsAtIndexPaths:@[ indexPath ]];
    } completion:^(BOOL finished) {}];
  }
}
@end
