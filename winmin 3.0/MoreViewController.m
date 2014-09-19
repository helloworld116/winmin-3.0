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

@interface MoreViewController ()
@property(nonatomic, strong) NSArray *titles;
@property(nonatomic, strong) NSArray *icons;
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
}

- (void)setup {
  [self setupStyle];
  self.titles = @[ @"关于我们", @"更新版本", @"常见问题" ];
  self.icons = @[
    @"switch_default_online",
    @"switch_default_online",
    @"switch_default_online",
  ];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setup];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
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
  UITableViewCell *cell;
  if (indexPath.section == 0) {
    cell = [tableView dequeueReusableCellWithIdentifier:cellType1Identifier
                                           forIndexPath:indexPath];
  } else {
    cell = [tableView dequeueReusableCellWithIdentifier:cellType2Identifier
                                           forIndexPath:indexPath];
    NSString *title = [self.titles objectAtIndex:indexPath.row];
    NSString *icon = [self.icons objectAtIndex:indexPath.row];
    [((MoreCellTypeSecond *)cell)setTitle:title icon:icon];
  }
  return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath
*)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath]
withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the
array, and add a new row to the table view
    }
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath
*)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath
*)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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

@end
