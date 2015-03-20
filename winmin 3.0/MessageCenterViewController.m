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
    UITableViewDelegate, UITableViewDataSource, LoadmoreDelegate,
    UIAlertViewDelegate>
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
    dispatch_async(dispatch_get_main_queue(), ^{
      [iSelf.tableView reloadData];
    });
  } else {
    iSelf.noDataView.hidden = NO;
  }
};

- (void)setup {
  self.navigationItem.title = NSLocalizedString(@"Message Center", nil);
  //  self.navigationItem.rightBarButtonItem = self.editButtonItem;
  self.navigationItem.rightBarButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:@"清空"
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(clear:)];
  self.noDataView =
      [[UIView alloc] initWithSize:self.view.frame.size
                           imgName:@"no_message"
                           message:NSLocalizedString(@"No Message!", nil)];
  self.noDataView.hidden = YES;
  [self.tableView addSubview:self.noDataView];
  self.tableView.dataSource = self;
  self.tableView.delegate = self;

  self.model = [[MessageCenterModel alloc] init];
  self.messages = [@[] mutableCopy];
  //  dispatch_async(dispatch_get_global_queue(0, 0), ^{
  //
  //                 });
  //  NSArray *messages =
  //      [[DBUtil sharedInstance] getHistoryMessagesWithCount:20 offset:0];
  //  DDLogDebug(@"messages is %@", messages);
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self setup];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
  [super setEditing:editing animated:animated];
  [self.tableView setEditing:editing animated:animated];
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

#pragma mark - UITableView Edit
- (BOOL)tableView:(UITableView *)tableView
    canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
  return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.messages removeObjectAtIndex:indexPath.row];
  self.totalCount--;
  self.currentCount--;
  [tableView deleteRowsAtIndexPaths:@[ indexPath ]
                   withRowAnimation:UITableViewRowAnimationFade];
}

- (void)clear:(id)sender {
  UIAlertView *alertView =
      [[UIAlertView alloc] initWithTitle:@""
                                 message:@"确定清空历史消息吗？"
                                delegate:self
                       cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                       otherButtonTitles:NSLocalizedString(@"Sure", nil), nil];
  [alertView show];
}

- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  switch (buttonIndex) {
    case 0:
      break;
    case 1: {
      HistoryMessage *message = [self.messages firstObject];
      [[NSUserDefaults standardUserDefaults] setObject:@(message._id)
                                                forKey:kHistoryMessageId];
      [self.messages removeAllObjects];
      self.totalCount = 0;
      self.currentCount = 0;
      //      [[DBUtil sharedInstance] removeAllHistoryMessages];
      [self.tableView reloadData];
    } break;
    default:
      break;
  }
}
@end
