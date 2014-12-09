//
//  MessageCenterViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-12-9.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "MessageCenterViewController.h"
#import "MessageCell.h"
#import "MessageCenterModel.h"

@interface MessageCenterViewController () <
    UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, assign) int totalCount;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) MessageCenterModel *model;
@property (nonatomic, strong) MBProgressHUD *HUD;
@end

@implementation MessageCenterViewController

- (void)setup {
  self.navigationItem.title = NSLocalizedString(@"Message Center", nil);
  self.tableView.dataSource = self;

  self.model = [[MessageCenterModel alloc] init];
  self.messages = [@[] mutableCopy];
  self.HUD = [[MBProgressHUD alloc] initWithWindow:kSharedAppliction.window];
  [self.view.window addSubview:self.HUD];
  self.HUD.delegate = self;
  [self.HUD show:YES];

  dispatch_async(GLOBAL_QUEUE, ^{
      [self.model
          requestWithStartId:0
                  completion:^(int status, NSArray *msgs, int totalCount) {
                      if (status == 1) {
                        self.totalCount = totalCount;
                        [self.messages addObjectsFromArray:msgs];
                      }
                      dispatch_async(dispatch_get_main_queue(),
                                     ^{ [self.tableView reloadData]; });
                  }];

  });
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  // Return the number of rows in the section.
  return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellTypeIdentifier = @"MessageCell";
  MessageCell *messageCell =
      [self.tableView dequeueReusableCellWithIdentifier:cellTypeIdentifier
                                           forIndexPath:indexPath];
  HistoryMessage *message = self.messages[indexPath.row];
  [messageCell setInfo:message];
  return messageCell;
}

@end
