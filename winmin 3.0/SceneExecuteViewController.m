//
//  SceneExecuteViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-26.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SceneExecuteViewController.h"
#import "SceneExcCell.h"
#import "Scene.h"
#import "SceneDetail.h"
#define kSceneExcCellHeight 45.f

@interface SceneExecuteViewController ()<UITableViewDelegate,
                                         UITableViewDataSource>
@property(nonatomic, strong) UILabel *lblStatus;
@property(nonatomic, strong) UIButton *btnCancelOrOk;

@property(nonatomic, strong) NSArray *sceneDetails;
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
  [btnCancelOrOk setTitle:@"取  消" forState:UIControlStateNormal];
  [btnCancelOrOk setTitleColor:kThemeColor forState:UIControlStateNormal];
  [btnCancelOrOk addTarget:self
                    action:@selector(cancelOrOk:)
          forControlEvents:UIControlEventTouchUpInside];
  self.btnCancelOrOk = btnCancelOrOk;
  [self.view addSubview:btnCancelOrOk];

  CGFloat tableViewHeight = self.sceneDetails.count * kSceneExcCellHeight;
  UITableView *tableView = [[UITableView alloc]
      initWithFrame:CGRectMake(0, SCREEN_HEIGHT -
                                      CGRectGetHeight(btnCancelOrOk.frame) -
                                      tableViewHeight,
                               SCREEN_WIDTH, tableViewHeight)
              style:UITableViewStylePlain];
  tableView.bounces = NO;
  tableView.dataSource = self;
  tableView.delegate = self;
  [self.view addSubview:tableView];

  UIView *titleView = [[UIView alloc]
      initWithFrame:CGRectMake(0, SCREEN_HEIGHT -
                                      CGRectGetHeight(btnCancelOrOk.frame) -
                                      tableViewHeight - 56,
                               SCREEN_WIDTH, 56)];
  titleView.backgroundColor = kThemeColor;

  CGSize sceneNameSize =
      [self.scene.name sizeWithFont:[UIFont systemFontOfSize:20]];
  UILabel *lblTitle =
      [[UILabel alloc] initWithFrame:CGRectMake(80, 16, sceneNameSize.width,
                                                sceneNameSize.height)];
  lblTitle.font = [UIFont systemFontOfSize:20];
  lblTitle.textColor = [UIColor whiteColor];
  lblTitle.text = self.scene.name;
  [titleView addSubview:lblTitle];

  NSString *status = @"场景执行中...";
  CGSize statusSize = [status sizeWithFont:[UIFont systemFontOfSize:18]];
  UILabel *lblStatus = [[UILabel alloc]
      initWithFrame:CGRectMake(CGRectGetMaxX(lblTitle.frame) + 15, 17,
                               statusSize.width, statusSize.height)];
  lblStatus.textColor = [UIColor whiteColor];
  lblStatus.font = [UIFont systemFontOfSize:18];
  lblStatus.text = status;
  self.lblStatus = lblStatus;
  [titleView addSubview:lblStatus];
  [self.view addSubview:titleView];

  UIView *shadowView = [[UIView alloc]
      initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,
                               SCREEN_HEIGHT -
                                   CGRectGetHeight(btnCancelOrOk.frame) -
                                   tableViewHeight - 56)];
  shadowView.backgroundColor = [UIColor blackColor];
  shadowView.alpha = .2f;
  [self.view addSubview:shadowView];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  //  [self.view performSelector:@selector(removeFromSuperview)
  //                  withObject:nil
  //                  afterDelay:3.f];
  [self performSelector:@selector(removeWindow) withObject:nil afterDelay:3.f];
  [self setup];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

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
  [self removeWindow];
}

#pragma mark - 清除自定义window
- (void)removeWindow {
  [kSharedAppliction.userWindow resignKeyWindow];
  kSharedAppliction.userWindow = nil;
}
@end
