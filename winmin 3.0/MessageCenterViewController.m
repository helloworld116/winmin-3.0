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
#import "LoadmoreCell.h"

@interface MessageCenterViewController () <
    UITableViewDelegate, UITableViewDataSource, LoadmoreDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, assign) int totalCount;
@property (nonatomic, assign) int currentCount;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) MessageCenterModel *model;
@property (nonatomic, strong) UIView *noDataView;
@end

@implementation MessageCenterViewController

void (^loadCompletion)(MessageCenterViewController *iSelf, int status,
                       NSArray *messages,
                       int totalCount) = ^(MessageCenterViewController *iSelf,
                                           int status, NSArray *messages,
                                           int totalCount) {
    if (status == successCode) {
      iSelf.totalCount = totalCount;
      [iSelf.messages addObjectsFromArray:messages];
      iSelf.currentCount = [iSelf.messages count];
    }
    if (iSelf.currentCount) {
      dispatch_async(dispatch_get_main_queue(),
                     ^{ [iSelf.tableView reloadData]; });
    } else {
      iSelf.noDataView.hidden = NO;
    }
};

- (void)setup {
  self.navigationItem.title = NSLocalizedString(@"Message Center", nil);
  self.noDataView = [[UIView alloc]
      initWithSize:self.view.frame.size
           imgName:@"noswitch"
           message:NSLocalizedString(@"You have not configure any device!",
                                     nil)];
  self.noDataView.hidden = YES;
  [self.tableView addSubview:self.noDataView];
  self.tableView.dataSource = self;
  self.tableView.delegate = self;

  self.model = [[MessageCenterModel alloc] init];
  self.messages = [@[] mutableCopy];
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
  return self.currentCount + 1;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row < self.currentCount) {
    return 80.f;
  } else {
    return 50.f;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellTypeIdentifier = @"MessageCell";
  static NSString *cellTypeIdentifier2 = @"LoadmoreCell";
  UITableViewCell *cell;
  if (indexPath.row < self.currentCount) {
    MessageCell *messageCell =
        [self.tableView dequeueReusableCellWithIdentifier:cellTypeIdentifier
                                             forIndexPath:indexPath];
    HistoryMessage *message = self.messages[indexPath.row];
    [messageCell setInfo:message];
    cell = messageCell;
  } else {
    LoadmoreCell *moreCell =
        [self.tableView dequeueReusableCellWithIdentifier:cellTypeIdentifier2
                                             forIndexPath:indexPath];
    moreCell.delegate = self;
    cell = moreCell;
    if (self.currentCount == 0) {
      [moreCell firstLoad];
    }
    if (self.totalCount == self.currentCount && self.currentCount != 0) {
      [moreCell noMoreData];
    }
  }
  return cell;
}

#pragma mark - 加载更多
- (void)beginLoad:(void (^)(BOOL))result {
  dispatch_async(GLOBAL_QUEUE, ^{
      HistoryMessage *message = [self.messages lastObject];
      [self.model
          requestWithStartId:message._id
                  completion:^(int status, NSArray *msgs, int totalCount) {
                      loadCompletion(self, status, msgs, totalCount);
                      if (status == successCode) {
                        result(YES);
                      } else {
                        result(NO);
                      }
                  }];
  });
}
@end
