//
//  SceneExecuteViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-26.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SceneExecuteViewController.h"
#import "SceneExcCell.h"
#import "SceneExcTitleView.h"
#import "Scene.h"
#import "SceneDetail.h"
#import "SceneExecuteModel.h"
#define kSceneExcCellHeight 45.f

@interface SceneExecuteViewController () <UITableViewDelegate,
                                          UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *lblStatus;
@property (nonatomic, strong) UIButton *btnCancelOrOk;

@property (nonatomic, strong) NSArray *sceneDetails;
@property (nonatomic, strong) SceneExecuteModel *model;
@end

@implementation SceneExecuteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)setup {
  //  self.lblSceneName.text = self.scene.name;
  self.sceneDetails = self.scene.detailList;

  UIButton *btnCancelOrOk = [UIButton buttonWithType:UIButtonTypeSystem];
  btnCancelOrOk.backgroundColor = [UIColor whiteColor];
  btnCancelOrOk.frame = CGRectMake(0, SCREEN_HEIGHT - 45, SCREEN_WIDTH, 45);
  [btnCancelOrOk setTitle:NSLocalizedString(@"Cancel", nil)
                 forState:UIControlStateNormal];
  [btnCancelOrOk setTitleColor:kThemeColor forState:UIControlStateNormal];
  [btnCancelOrOk addTarget:self
                    action:@selector(cancelOrOk:)
          forControlEvents:UIControlEventTouchUpInside];
  self.btnCancelOrOk = btnCancelOrOk;
  [self.view addSubview:btnCancelOrOk];

  CGFloat tableViewHeight = self.sceneDetails.count * kSceneExcCellHeight;
  if (tableViewHeight > SCREEN_HEIGHT * 0.5) {
    tableViewHeight = SCREEN_HEIGHT * 0.5;
  }
  UITableView *tableView = [[UITableView alloc]
      initWithFrame:CGRectMake(0, SCREEN_HEIGHT -
                                      CGRectGetHeight(btnCancelOrOk.frame) -
                                      tableViewHeight,
                               SCREEN_WIDTH, tableViewHeight)
              style:UITableViewStylePlain];
  tableView.bounces = NO;
  tableView.showsVerticalScrollIndicator = NO;
  tableView.dataSource = self;
  tableView.delegate = self;
  self.tableView = tableView;
  [self.view addSubview:tableView];

  //  UIView *titleView = [[UIView alloc]
  //      initWithFrame:CGRectMake(0, SCREEN_HEIGHT -
  //                                      CGRectGetHeight(btnCancelOrOk.frame) -
  //                                      tableViewHeight - 56,
  //                               SCREEN_WIDTH, 56)];
  //  titleView.backgroundColor = kThemeColor;
  //
  //  CGSize sceneNameSize =
  //      [self.scene.name sizeWithFont:[UIFont systemFontOfSize:20]];
  //  UILabel *lblTitle =
  //      [[UILabel alloc] initWithFrame:CGRectMake(80, 16, sceneNameSize.width,
  //                                                sceneNameSize.height)];
  //  lblTitle.font = [UIFont systemFontOfSize:20];
  //  lblTitle.textColor = [UIColor whiteColor];
  //  lblTitle.text = self.scene.name;
  //  [titleView addSubview:lblTitle];
  //
  //  NSString *status = NSLocalizedString(@"is executing", nil);
  //  CGSize statusSize = [status sizeWithFont:[UIFont systemFontOfSize:18]];
  //  UILabel *lblStatus = [[UILabel alloc]
  //      initWithFrame:CGRectMake(CGRectGetMaxX(lblTitle.frame) + 15, 17,
  //                               statusSize.width + 10, statusSize.height)];
  //  lblStatus.textColor = [UIColor whiteColor];
  //  lblStatus.font = [UIFont systemFontOfSize:18];
  //  lblStatus.text = status;
  //  self.lblStatus = lblStatus;
  //  [titleView addSubview:lblStatus];
  //  [self.view addSubview:titleView];
  SceneExcTitleView *titleView =
      [[[NSBundle mainBundle] loadNibNamed:@"SceneExcTitleView"
                                     owner:self
                                   options:nil] objectAtIndex:0];
  titleView.frame =
      CGRectMake(0, SCREEN_HEIGHT - CGRectGetHeight(btnCancelOrOk.frame) -
                        tableViewHeight - 56,
                 SCREEN_WIDTH, 56);
  titleView.lblName.text = self.scene.name;
  self.lblStatus = titleView.lblStatus;
  self.lblStatus.text = NSLocalizedString(@"is executing", nil);
  [self.view addSubview:titleView];

  UIView *shadowView = [[UIView alloc]
      initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,
                               SCREEN_HEIGHT -
                                   CGRectGetHeight(btnCancelOrOk.frame) -
                                   tableViewHeight - 56)];
  shadowView.backgroundColor = [UIColor blackColor];
  shadowView.alpha = .2f;
  [self.view addSubview:shadowView];

  self.model = [[SceneExecuteModel alloc] init];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(sceneExecuteResult:)
             name:kSceneExecuteResultNotification
           object:self.model];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(sceneExecuteFinished:)
             name:kSceneExecuteFinishedNotification
           object:self.model];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  //  [self performSelector:@selector(removeWindow) withObject:nil
  //  afterDelay:3.f];
  [self setup];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self.model executeSceneDetails:self.sceneDetails];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - begin iOS8下cell分割线处理
#ifdef __IPHONE_8_0
- (void)viewDidLayoutSubviews {
  if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
  }

  if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
  }
}

- (void)tableView:(UITableView *)tableView
      willDisplayCell:(UITableViewCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
    [cell setSeparatorInset:UIEdgeInsetsZero];
  }

  if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
    [cell setLayoutMargins:UIEdgeInsetsZero];
  }
}
#endif
#pragma mark - end iOS8下cell分割线处理

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return kSceneExcCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return self.sceneDetails.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellId = @"SceneExcCell";
  SceneExcCell *cell =
      [[[NSBundle mainBundle] loadNibNamed:CellId owner:self options:nil]
          objectAtIndex:0];
  SceneDetail *detail = self.sceneDetails[indexPath.row];
  [cell setSceneDetail:detail row:indexPath.row + 1];
  return cell;
}

#pragma mark -
- (void)cancelOrOk:(id)sender {
  [self.model cancelExecute];
  [self removeWindow];
}

#pragma mark - 清除自定义window
- (void)removeWindow {
  [kSharedAppliction.userWindow resignKeyWindow];
  kSharedAppliction.userWindow = nil;
  [[NSNotificationCenter defaultCenter]
      postNotificationName:kSceneFinishedWindowViewRemoveNotification
                    object:nil];
}

#pragma mark - 场景执行通知
- (void)sceneExecuteResult:(NSNotification *)notification {
  NSDictionary *userInfo = notification.userInfo;
  int row = [userInfo[@"row"] intValue];
  BOOL resultType = [userInfo[@"resultType"] boolValue];
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
  SceneExcCell *cell =
      (SceneExcCell *)[self.tableView cellForRowAtIndexPath:indexPath];
  dispatch_async(MAIN_QUEUE, ^{
      if (indexPath.row < self.sceneDetails.count - 1) {
        NSIndexPath *scollIndexPath =
            [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:scollIndexPath
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:YES];
      }
      [cell updatePage:resultType];
  });
}

- (void)sceneExecuteFinished:(NSNotification *)notification {
  dispatch_async(MAIN_QUEUE, ^{
      self.lblStatus.text = NSLocalizedString(@"execute finished", nil);
  });
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),
                 MAIN_QUEUE, ^{ [self removeWindow]; });
}
@end
