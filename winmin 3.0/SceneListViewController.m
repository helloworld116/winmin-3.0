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
#import "ScenePreExcDailogViewController.h"
#import "SceneCell.h"
#import "Scene.h"
#import "ShakeWindow.h"
typedef NS_ENUM(NSInteger, ShakeType) {
  ShakeType_Cancel,
  ShakeType_Set,
};

@interface SceneListViewController () <UIActionSheetDelegate,
                                       ScenePreExcDailogControllerDelegate>
@property (nonatomic, strong) NSIndexPath *operationIndexPath;
@property (nonatomic, strong) NSMutableArray *scenes;
@property (nonatomic, assign) ShakeType shakeType; //长按时设置摇一摇的动作类型
@property (nonatomic, assign) NSInteger shakeId; //摇一摇的指定场景id
@property (nonatomic, strong)
    NSIndexPath *lastShakeIndexPath; //修改摇一摇之前的indexPath
@property (nonatomic, strong) UIView *noDataView;
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
  self.navigationItem.title = NSLocalizedString(@"Scene", nil);
  UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
  backButtonItem.title = NSLocalizedString(@"Back", nil);
  self.navigationItem.backBarButtonItem = backButtonItem;
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                           target:self
                           action:@selector(addScene:)];
  self.noDataView = [[UIView alloc]
      initWithSize:self.view.frame.size
           imgName:@"noscene"
           message:NSLocalizedString(@"You have not add any scene!", nil)];
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
  [[NSNotificationCenter defaultCenter]
      addObserverForName:kSceneFinishedWindowViewRemoveNotification
                  object:nil
                   queue:nil
              usingBlock:^(NSNotification *note) {
                  [self.collectionView
                      deselectItemAtIndexPath:self.operationIndexPath
                                     animated:YES];
              }];
  self.scenes = [[[DBUtil sharedInstance] scenes] mutableCopy];
  if (!self.scenes || self.scenes.count == 0) {
    self.noDataView.hidden = NO;
  }
  self.shakeId = [[[NSUserDefaults standardUserDefaults]
      objectForKey:@"shakeId"] integerValue];
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
  BOOL isShowShake;
  if (scene.indentifier == self.shakeId) {
    self.lastShakeIndexPath = indexPath;
    isShowShake = YES;
  } else {
    isShowShake = NO;
  }
  [cell setCellInfo:scene isShowShake:isShowShake];
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
  self.operationIndexPath = indexPath;

  ScenePreExcDailogViewController *viewController =
      [[ScenePreExcDailogViewController alloc]
          initWithNibName:@"ScenePreExcDailogViewController"
                   bundle:nil];
  viewController.delegate = self;
  [self presentPopupViewController:viewController
                     animationType:MJPopupViewAnimationFade
               backgroundClickable:NO];
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

#pragma mark - PopViewControllerDelegate
- (void)closePopViewController:(UIViewController *)controller
                passExecutable:(BOOL)excute {
  [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
  if (excute) {
    SceneExecuteViewController *executeViewController =
        [[SceneExecuteViewController alloc] init];
    Scene *scene = self.scenes[self.operationIndexPath.row];
    executeViewController.scene = scene;
    UIWindow *window =
        [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    kSharedAppliction.userWindow = window;
    window.rootViewController = executeViewController;
    window.windowLevel = UIWindowLevelAlert;
    [window makeKeyAndVisible];
  } else {
    [self.collectionView deselectItemAtIndexPath:self.operationIndexPath
                                        animated:YES];
  }
}

#pragma mark -
- (void)addScene:(id)sender {
  SceneDetailViewController *nextViewController = [self.storyboard
      instantiateViewControllerWithIdentifier:@"SceneDetailViewController2"];
  [self.navigationController pushViewController:nextViewController
                                       animated:YES];
}

#pragma mark - 长按处理
- (void)handlerLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
  CGPoint p = [gestureRecognizer locationInView:self.collectionView];
  NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
  if (indexPath && gestureRecognizer.state == UIGestureRecognizerStateBegan) {
    self.operationIndexPath = indexPath;
    Scene *scene = self.scenes[self.operationIndexPath.row];
    NSString *shakeName;
    if (self.shakeId != scene.indentifier) {
      shakeName = @"设置摇一摇";
      self.shakeType = ShakeType_Set;
    } else {
      shakeName = @"取消摇一摇";
      self.shakeType = ShakeType_Cancel;
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                 initWithTitle:
                     NSLocalizedString(
                         @"How do you want to perform operations on the scene",
                         nil)
                      delegate:self
             cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
        destructiveButtonTitle:nil
             otherButtonTitles:shakeName, NSLocalizedString(@"Edit", nil),
                               NSLocalizedString(@"Delete", nil), nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
  }
}

- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  Scene *scene = self.scenes[self.operationIndexPath.row];
  switch (buttonIndex) {
    case 0: {
      NSArray *reloadItemsAtIndexPaths;
      NSInteger shakeId;
      if (self.shakeType == ShakeType_Set) {
        shakeId = scene.indentifier;
        if (self.lastShakeIndexPath &&
            self.lastShakeIndexPath != self.operationIndexPath) {
          reloadItemsAtIndexPaths =
              @[ self.lastShakeIndexPath, self.operationIndexPath ];
        } else {
          reloadItemsAtIndexPaths = @[ self.operationIndexPath ];
        }
      } else if (self.shakeType == ShakeType_Cancel) {
        shakeId = 0;
        self.lastShakeIndexPath = nil;
        reloadItemsAtIndexPaths = @[ self.operationIndexPath ];
      }
      NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
      [userDefaults setObject:@(shakeId) forKey:@"shakeId"];
      [self.collectionView performBatchUpdates:^{
          self.shakeId = shakeId;
          [self.collectionView reloadItemsAtIndexPaths:reloadItemsAtIndexPaths];
          //          [self.collectionView reloadSections:[NSIndexSet
          //          indexSetWithIndex:0]];
      } completion:^(BOOL finished) {
          if (finished) {
            ShakeWindow *shakeWindow = (ShakeWindow *)kSharedAppliction.window;
            if (self.shakeType == ShakeType_Set) {
              [shakeWindow setShakeScene:scene];
            } else {
              [shakeWindow setShakeScene:nil];
            }
          }
      }];
    } break;
    case 1:
      //编辑
      {
        SceneDetailViewController *nextViewController =
            [self.storyboard instantiateViewControllerWithIdentifier:
                                 @"SceneDetailViewController2"];
        nextViewController.scene = scene;
        nextViewController.row = self.operationIndexPath.row;
        [self.navigationController pushViewController:nextViewController
                                             animated:YES];
      }
      break;
    case 2:
      //删除
      {
        //摇一摇
        if (scene.indentifier == self.shakeId) {
          NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
          [userDefaults setObject:@(0) forKey:@"shakeId"];
          ShakeWindow *shakeWindow = (ShakeWindow *)kSharedAppliction.window;
          [shakeWindow setShakeScene:nil];
        }
        //
        [[DBUtil sharedInstance] removeScene:scene];
        //删除后提示页面
        NSArray *indexPaths = @[ self.operationIndexPath ];
        [self.collectionView performBatchUpdates:^{
            [self.scenes removeObjectAtIndex:self.operationIndexPath.row];
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
    } completion:^(BOOL finished){}];
  } else {
    //修改
    [self.collectionView performBatchUpdates:^{
        [self.scenes replaceObjectAtIndex:row withObject:scene];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.collectionView reloadItemsAtIndexPaths:@[ indexPath ]];
    } completion:^(BOOL finished) {
        if (finished) {
          if (scene.indentifier == self.shakeId) {
            ShakeWindow *shakeWindow = (ShakeWindow *)kSharedAppliction.window;
            [shakeWindow setShakeScene:scene];
          }
        }
    }];
  }
}
@end
