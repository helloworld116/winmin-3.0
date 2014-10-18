//
//  MoreViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-17.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "MoreViewController.h"
#import "MoreCellTypeFirst.h"
#import "MoreCellTypeSecond.h"
#import "MoreCellTypeThird.h"
#import "UserInfo.h"

@interface MoreViewController ()
@property(nonatomic, strong) NSArray *titles;
@property(nonatomic, strong) NSArray *icons;
@property(nonatomic, assign) BOOL isLogin;
@end

@implementation MoreViewController

- (id)initWithStyle:(UITableViewStyle)style {
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)setupStyle {
  UIView *view = [[UIView alloc] init];
  view.backgroundColor = [UIColor clearColor];
  self.tableView.tableFooterView = view;

  UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
  backButtonItem.title = @"返回";
  self.navigationItem.backBarButtonItem = backButtonItem;
}

- (void)setup {
  [self setupStyle];
  self.titles = @[ @"关于我们", @"安全警告", @"常见问题" ];
  self.icons = @[ @"about_us", @"security", @"question", ];
  [[NSNotificationCenter defaultCenter]
      addObserverForName:kLoginSuccess
                  object:nil
                   queue:nil
              usingBlock:^(NSNotification *note) {
                  self.isLogin = YES;
                  dispatch_async(MAIN_QUEUE, ^{
                      NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
                      [self.tableView
                            reloadSections:indexSet
                          withRowAnimation:UITableViewRowAnimationNone];
                  });
              }];
  [[NSNotificationCenter defaultCenter]
      addObserverForName:kLoginOut
                  object:nil
                   queue:nil
              usingBlock:^(NSNotification *note) {
                  self.isLogin = NO;
                  [UserInfo userLoginout];
                  NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
                  [self.tableView reloadSections:indexSet
                                withRowAnimation:UITableViewRowAnimationNone];
              }];
  self.isLogin = [UserInfo userInfoInDisk];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setup];
}

#pragma mark - begin iOS8下cell分割线处理
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
#pragma mark - end iOS8下cell分割线处理

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // Return the number of sections.
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  // Return the number of rows in the section.
  if (section == 0) {
    return 1;
  } else {
    return self.titles.count;
  }
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    return 80.f;
  } else {
    return 48.f;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellType1Identifier = @"MoreCellTypeFirst";
  static NSString *cellType2Identifier = @"MoreCellTypeSecond";
  static NSString *cellType3Identifier = @"MoreCellTypeThird";
  UITableViewCell *cell;
  if (indexPath.section == 0) {
    if (self.isLogin) {
      cell = [tableView dequeueReusableCellWithIdentifier:cellType3Identifier
                                             forIndexPath:indexPath];
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
      ((MoreCellTypeThird *)cell).lblUsername.text =
          [defaults objectForKey:@"nickname"];
    } else {
      cell = [tableView dequeueReusableCellWithIdentifier:cellType1Identifier
                                             forIndexPath:indexPath];
    }
  } else {
    cell = [tableView dequeueReusableCellWithIdentifier:cellType2Identifier
                                           forIndexPath:indexPath];
    NSString *title = [self.titles objectAtIndex:indexPath.row];
    NSString *icon = [self.icons objectAtIndex:indexPath.row];
    [((MoreCellTypeSecond *)cell)setTitle:title icon:icon];
  }
  UIView *myBackView = [[UIView alloc] initWithFrame:cell.frame];
  myBackView.backgroundColor = [UIColor colorWithHexString:@"#F6F4F4"];
  cell.selectedBackgroundView = myBackView;
  return cell;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 1) {
    UIViewController *nextController;
    switch (indexPath.row) {
      case 0:
        nextController = [self.storyboard
            instantiateViewControllerWithIdentifier:@"AboutUsViewController"];
        break;
      case 1:
        nextController =
            [self.storyboard instantiateViewControllerWithIdentifier:
                                 @"SecurityWarnViewController"];
        break;
      case 2:
        nextController = [self.storyboard
            instantiateViewControllerWithIdentifier:@"TestViewController"];

        break;
      default:
        break;
    }
    [self.navigationController pushViewController:nextController animated:YES];
  }
}
@end
