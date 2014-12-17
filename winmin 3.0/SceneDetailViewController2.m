//
//  SceneDetailViewController2.m
//  winmin 3.0
//
//  Created by sdzg on 14-12-17.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SceneDetailViewController2.h"
#import "SceneSwitchListController.h"
#import "Scene.h"

@interface SceneDetailViewController2 () <
    UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate,
    SceneSwitchListDelegate>
// default is hidden
@property (nonatomic, weak) IBOutlet UITableView *tableView;
// default is show
@property (nonatomic, weak) IBOutlet UIView *viewDefault;

- (IBAction)showSwitchList:(id)sender;
@end

@implementation SceneDetailViewController2

- (void)setupStyle {
  //  self.textFieldSceneName.layer.borderColor = [kThemeColor CGColor];
  //  self.textFieldSceneName.layer.borderWidth = 2.f;
  //  self.textFieldSceneName.layer.cornerRadius = 21.f;

  UIView *view = [[UIView alloc] init];
  view.backgroundColor = [UIColor clearColor];
  self.tableView.tableFooterView = view;

  self.navigationItem.title = NSLocalizedString(@"Scene", nil);
  self.navigationItem.rightBarButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil)
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(save:)];
}

- (void)setup {
  [self setupStyle];
  //  self.tableView.delegate = self;
  //  self.tableView.dataSource = self;
  //  self.textFieldSceneName.delegate = self;
  //  self.textFieldSceneName.attributedPlaceholder = [[NSAttributedString
  //  alloc]
  //      initWithString:NSLocalizedString(@"Please enter the scene name", nil)
  //          attributes:@{ NSForegroundColorAttributeName : kThemeColor }];
  //  self.switchs = [[SwitchDataCeneter sharedInstance] switchs];
  //
  //  //修改时添加场景数据到数据库临时表中
  //  if (self.scene) {
  //    [[DBUtil sharedInstance] addSceneToSceneDetailTmp:self.scene];
  //    NSString *imgName;
  //    if (self.scene.imageName.length < 10) {
  //      imgName = [NSString stringWithFormat:@"%@_", self.scene.imageName];
  //    } else {
  //      imgName = self.scene.imageName;
  //    }
  //    self.sceneImageName = [imgName substringToIndex:imgName.length - 1];
  //    [self.btnSceneImage setImage:[Scene imgNameToImage:imgName]
  //                        forState:UIControlStateNormal];
  //    self.textFieldSceneName.text = self.scene.name;
  //  } else {
  //    self.row = -1;
  //  }
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
- (IBAction)showSwitchList:(id)sender {
  SceneSwitchListController *viewController = [[SceneSwitchListController alloc]
      initWithNibName:@"SceneSwitchListController"
               bundle:nil];
  viewController.delegate = self;
  [self presentPopupViewController:viewController
                     animationType:MJPopupViewAnimationFade
               backgroundClickable:YES];
}

- (void)save:(id)sender {
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"SceneEditCell";
  return nil;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - SceneSwitchListDelegate
- (void)touchScene:(SceneSwitchListController *)sceneSwitchListController
           aSwitch:(SDZGSwitch *)aSwitch {
  [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
  if (aSwitch) {
    //
  } else {
  }
}
@end
