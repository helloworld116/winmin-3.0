//
//  UserSettingViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-11-18.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "UserSettingViewController.h"
NSString *const keyShake = @"KeyShake";
NSString *const showMac = @"ShowMac";
NSString *const wwanWarn = @"WWANWarn";

@interface UserSettingCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIView *viewOfCellContent;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UISwitch *_switch;
@property (strong, nonatomic) NSString *name;
@end
@implementation UserSettingCell
- (void)awakeFromNib {
  self.viewOfCellContent.layer.borderWidth = .5f;
  self.viewOfCellContent.layer.borderColor =
      [UIColor colorWithHexString:@"#c3c3c3"].CGColor;
  self.viewOfCellContent.layer.cornerRadius = 10.f;
}

- (void)setCellInfo:(NSString *)name {
  self.name = name;
  self.lblName.text = NSLocalizedString(name, nil);
  self._switch.on =
      [[[NSUserDefaults standardUserDefaults] objectForKey:name] boolValue];
}

- (IBAction)switchValueChanged:(id)sender {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:@(self._switch.on) forKey:self.name];
  [defaults synchronize];
}
@end

@interface UserSettingViewController ()
@property (nonatomic, strong) NSArray *settings;
@end

@implementation UserSettingViewController

- (void)setupStyle {
  UIView *view = [[UIView alloc] init];
  view.backgroundColor = [UIColor clearColor];
  self.tableView.tableFooterView = view;

  self.navigationItem.title = NSLocalizedString(@"User Setting", nil);
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setupStyle];
  self.settings = @[ keyShake, showMac, wwanWarn ];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return self.settings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"UserSettingCell";
  UserSettingCell *cell =
      [tableView dequeueReusableCellWithIdentifier:cellId
                                      forIndexPath:indexPath];
  NSString *name = self.settings[indexPath.row];
  [cell setCellInfo:name];
  return cell;
}

@end
