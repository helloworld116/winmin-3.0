//
//  SceneDetailViewController2.m
//  winmin 3.0
//
//  Created by sdzg on 14-12-17.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SceneDetailViewController2.h"
#import "SceneSwitchListController.h"
#import "SceneTemplateViewController.h"
#import "Scene.h"
#import "SceneDetail.h"
#import "SceneEditAddCell.h"
#import "SceneEditCell2.h"
typedef NS_OPTIONS(NSUInteger, SceneSwitchListOperation){
  Add_After, Add_Before, Modify,
};

@interface SceneDetailViewController2 () <
    UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate,
    UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource,
    SceneSwitchListDelegate, SceneTemplateDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
// default is show
@property (nonatomic, weak) IBOutlet UIView *viewDefault;
// default is hidden
@property (nonatomic, weak) IBOutlet UIView *viewTimeInterval;
@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;
@property (nonatomic, weak) IBOutlet UIView *viewSceneInfo;
@property (strong, nonatomic) IBOutlet UIButton *btnSceneImage;
@property (strong, nonatomic) IBOutlet UITextField *textFieldSceneName;

@property (nonatomic, strong) SDZGSwitch *aSwitch;
@property (strong, nonatomic) NSString *sceneImageName;
@property (assign, nonatomic) BOOL showTemplateController;
@property (assign, nonatomic) int currentEditRow;
@property (assign, nonatomic) SceneSwitchListOperation operationType;
@property (strong, nonatomic) NSMutableArray *pickerData;
@property (assign, nonatomic) float selectedInterval;
@property (strong, nonatomic) UIButton *currentEditIntervalBtn;
@property (strong, nonatomic) UIBarButtonItem *rightButtonItem;
@property (strong, nonatomic)
    SceneSwitchListController *sceneSwitchListController;
- (IBAction)showSwitchList:(id)sender;
@end

@implementation SceneDetailViewController2

- (void)setupStyle {
  self.textFieldSceneName.layer.borderColor = [kThemeColor CGColor];
  self.textFieldSceneName.layer.borderWidth = 2.f;
  self.textFieldSceneName.layer.cornerRadius = 21.f;
  self.viewTimeInterval.layer.borderColor = [UIColor blackColor].CGColor;
  self.viewTimeInterval.layer.borderWidth = 1.f;

  UIView *view = [[UIView alloc] init];
  view.backgroundColor = [UIColor clearColor];
  self.tableView.tableFooterView = view;
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.pickerData = [@[] mutableCopy];
  for (int i = 1; i <= 99; i++) {
    [self.pickerData addObject:@(i)];
  }
  self.pickerView.delegate = self;
  self.pickerView.dataSource = self;

  self.navigationItem.title = NSLocalizedString(@"Scene", nil);
  self.rightButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil)
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(save:)];
}

- (void)setup {
  [self setupStyle];
  self.operationType = Add_After;
  self.textFieldSceneName.delegate = self;
  self.textFieldSceneName.attributedPlaceholder = [[NSAttributedString alloc]
      initWithString:NSLocalizedString(@"Please enter the scene name", nil)
          attributes:@{ NSForegroundColorAttributeName : kThemeColor }];

  if (self.scene) {
    self.scene = [self.scene copy];
    NSString *imgName;
    if (self.scene.imageName.length < 10) {
      imgName = [NSString stringWithFormat:@"%@_", self.scene.imageName];
    } else {
      imgName = self.scene.imageName;
    }
    self.sceneImageName = [imgName substringToIndex:imgName.length - 1];
    [self.btnSceneImage setImage:[Scene imgNameToImage:imgName]
                        forState:UIControlStateNormal];
    self.textFieldSceneName.text = self.scene.name;
    self.viewSceneInfo.hidden = NO;
    self.viewDefault.hidden = YES;
    self.navigationItem.rightBarButtonItem = self.rightButtonItem;
  } else {
    self.row = -1;
    self.viewSceneInfo.hidden = YES;
    self.viewDefault.hidden = NO;
    self.scene = [[Scene alloc] init];
    self.scene.detailList = [@[] mutableCopy];
  }
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
  self.operationType = Add_After;
  [self showSwitchListController];
}

- (void)showSwitchListController {
  if (!self.sceneSwitchListController) {
    self.sceneSwitchListController = [[SceneSwitchListController alloc]
        initWithNibName:@"SceneSwitchListController"
                 bundle:nil];
    self.sceneSwitchListController.delegate = self;
  }
  [self presentPopupViewController:self.sceneSwitchListController
                     animationType:MJPopupViewAnimationFade
               backgroundClickable:YES];
}

- (void)save:(id)sender {
  NSMutableArray *details = self.scene.detailList;
  NSString *sceneName = self.textFieldSceneName.text;
  if (sceneName.length == 0) {
    [self.view
        makeToast:NSLocalizedString(@"Please enter the scene name", nil)];
    return;
  }
  if (details.count) {
    self.scene.name = sceneName;
    if (!self.sceneImageName) {
      self.sceneImageName = @"sdef_";
    }
    self.scene.imageName = self.sceneImageName;
    self.scene.detailList = details;
    [[DBUtil sharedInstance] saveScene:self.scene];
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kSceneAddOrUpdateNotification
                      object:self
                    userInfo:@{
                      @"row" : @(self.row),
                      @"scene" : self.scene
                    }];
  } else {
    [self.view makeToast:NSLocalizedString(@"Please add one operation", nil)];
  }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  int scenedetailCount = self.scene.detailList.count;
  return scenedetailCount + 1;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row < self.scene.detailList.count) {
    return 120.f;
  } else {
    return 44.f;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *leftCell = @"SceneEditLeftCell";
  static NSString *rightCell = @"SceneEditRightCell";
  static NSString *addCell = @"SceneEditAddCell";
  UITableViewCell *cell;
  if (indexPath.row < self.scene.detailList.count) {
    if (indexPath.row % 2 == 0) {
      cell = [tableView dequeueReusableCellWithIdentifier:leftCell
                                             forIndexPath:indexPath];
    } else {
      cell = [tableView dequeueReusableCellWithIdentifier:rightCell
                                             forIndexPath:indexPath];
    }
    SceneEditCell2 *editCell = (SceneEditCell2 *)cell;
    SceneDetail *sceneDetail = self.scene.detailList[indexPath.row];
    [editCell setSceneDetail:sceneDetail];
  } else {
    cell = [tableView dequeueReusableCellWithIdentifier:addCell
                                           forIndexPath:indexPath];
  }
  return cell;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - SceneSwitchListDelegate
- (void)touchSceneCallbackSwitch:(SDZGSwitch *)aSwitch {
  DDLogDebug(@"%s", __FUNCTION__);
  if (aSwitch) {
    //
    self.aSwitch = aSwitch;
    NSString *title =
        [NSString stringWithFormat:NSLocalizedString(
                                       @"Set command %@ will be executed", nil),
                                   aSwitch.name];
    UIActionSheet *sheet = [[UIActionSheet alloc]
                 initWithTitle:title
                      delegate:self
             cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
        destructiveButtonTitle:nil
             otherButtonTitles:NSLocalizedString(@"Open Switch I", nil),
                               NSLocalizedString(@"Close Switch I", nil),
                               NSLocalizedString(@"Open Switch II", nil),
                               NSLocalizedString(@"Close Switch II", nil), nil];

    sheet.tag = 98981;
    [sheet showInView:self.view];
  } else {
  }
  [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (actionSheet.tag == 98981) {
    int socketGroupId = 0;
    BOOL isOn = NO;
    switch (buttonIndex) {
      case 0:
        socketGroupId = 1;
        isOn = YES;
        break;
      case 1:
        socketGroupId = 1;
        isOn = NO;
        break;
      case 2:
        socketGroupId = 2;
        isOn = YES;
        break;
      case 3:
        socketGroupId = 2;
        isOn = NO;
        break;
      case 4:
        DDLogDebug(@"cancel");
        break;
      default:
        break;
    }
    if (buttonIndex != 4) {
      SceneDetail *detail = [[SceneDetail alloc] initWithMac:self.aSwitch.mac
                                                     groupId:socketGroupId
                                                     onOrOff:isOn];
      switch (self.operationType) {
        case Add_After:
          [self.scene.detailList addObject:detail];
          break;
        case Add_Before:
          [self.scene.detailList insertObject:detail
                                      atIndex:self.currentEditRow];
          break;
        case Modify:
          [self.scene.detailList replaceObjectAtIndex:self.currentEditRow
                                           withObject:detail];
          break;
        default:
          break;
      }
    }
    if (self.scene.detailList.count) {
      self.viewDefault.hidden = YES;
      self.viewSceneInfo.hidden = NO;
      self.navigationItem.rightBarButtonItem = self.rightButtonItem;
      [self.tableView reloadData];
      //      [self.tableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)
      //                              animated:YES];
      CGFloat yOffset = 0;
      if (self.tableView.contentSize.height >
          self.tableView.bounds.size.height) {
        yOffset = self.tableView.contentSize.height -
                  self.tableView.bounds.size.height;
      }
      [self.tableView setContentOffset:CGPointMake(0, yOffset) animated:NO];
    }
  } else if (actionSheet.tag == 98982) {
    switch (buttonIndex) {
      case 0:
        self.operationType = Add_Before;
        [self showSwitchListController];
        break;
      case 1:
        self.operationType = Modify;
        [self showSwitchListController];
        break;
      case 2:
        [self.scene.detailList removeObjectAtIndex:self.currentEditRow];
        [self.tableView reloadData];
        break;
      case 3:
        DDLogDebug(@"cancel");
        break;
      default:
        break;
    }
  }
}

//[[DBUtil sharedInstance] updateDetailTmpWithSwitchMac:self.mac
//                                              groupId:self.groupId
//                                          onOffStatus:self.btnOnOff.selected];
//[[DBUtil sharedInstance] addDetailTmpWithSwitchMac:self.mac
//                                           groupId:self.groupId];
//[[DBUtil sharedInstance] removeDetailTmpWithSwitchMac:self.mac
//                                              groupId:self.groupId];

- (IBAction)showTimeInterval:(id)sender {
  self.currentEditIntervalBtn = (UIButton *)sender;
  CGPoint buttonPosition =
      [sender convertPoint:CGPointZero toView:self.tableView];
  NSIndexPath *indexPath =
      [self.tableView indexPathForRowAtPoint:buttonPosition];
  DDLogDebug(@"row is %d", indexPath.row);
  self.currentEditRow = indexPath.row;
  self.viewTimeInterval.hidden = NO;
  int currentValue = [[self.currentEditIntervalBtn currentTitle] intValue];
  DDLogDebug(@"current is %d", currentValue);
  [self.pickerView selectRow:currentValue - 1 inComponent:0 animated:YES];
  [self.viewSceneInfo bringSubviewToFront:self.viewTimeInterval];
}

- (IBAction)showEditMenu:(id)sender {
  CGPoint buttonPosition =
      [sender convertPoint:CGPointZero toView:self.tableView];
  NSIndexPath *indexPath =
      [self.tableView indexPathForRowAtPoint:buttonPosition];
  DDLogDebug(@"row is %d", indexPath.row);
  self.currentEditRow = indexPath.row;
  UIActionSheet *sheet = [[UIActionSheet alloc]
               initWithTitle:
                   NSLocalizedString(
                       @"You want to do this kind of operation command?", nil)
                    delegate:self
           cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
      destructiveButtonTitle:nil
           otherButtonTitles:NSLocalizedString(@"Insert", nil),
                             NSLocalizedString(@"Reset", nil),
                             NSLocalizedString(@"Delete", nil), nil];
  sheet.tag = 98982;
  [sheet showInView:self.view];
}
#pragma mark - 模板
- (IBAction)showTemplate:(id)sender {
  self.showTemplateController = YES;
  [[UIApplication sharedApplication] setStatusBarHidden:YES];
  SceneTemplateViewController *templateController = [self.storyboard
      instantiateViewControllerWithIdentifier:@"SceneTemplateViewController"];
  templateController.sceneTemplateDelegate = self;
  CATransition *animation = [CATransition animation];
  [animation setDuration:0.5];
  [animation setType:kCATransitionFade];
  [animation setSubtype:kCATransitionFromBottom];
  [animation setTimingFunction:
                 [CAMediaTimingFunction
                     functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
  [[templateController.view layer] addAnimation:animation
                                         forKey:@"SceneTemplate"];
  [self presentViewController:templateController animated:NO completion:^{}];
}

#pragma mark - SceneTemplateDelegate
- (void)imgName:(NSString *)imgName sceneName:(NSString *)sceneName {
  self.showTemplateController = NO;
  //在模板内的名称进行替换
  if (([[kSceneTemplateDict allValues]
           containsObject:self.textFieldSceneName.text] ||
       self.textFieldSceneName.text.length == 0) &&
      sceneName) {
    self.textFieldSceneName.text = sceneName;
  }
  [self.btnSceneImage setImage:[Scene imgNameToImage:imgName]
                      forState:UIControlStateNormal];
  if (imgName.length < 10) {
    imgName = [imgName substringToIndex:imgName.length - 1];
  }
  self.sceneImageName = imgName;
}

#pragma mark - UITextField协议
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self.textFieldSceneName resignFirstResponder];
  return YES;
}

- (IBAction)keyBoardBack:(id)sender {
  [self.textFieldSceneName resignFirstResponder];
}

#pragma mark - UIPickeView Datasouce
// pickerView 列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 1;
}

// pickerView 每列个数
- (NSInteger)pickerView:(UIPickerView *)pickerView
    numberOfRowsInComponent:(NSInteger)component {
  return self.pickerData.count;
}

// 每列宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView
    widthForComponent:(NSInteger)component {
  return SCREEN_WIDTH;
}
// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
  //  if (component == 0) {
  //    _proNameStr = [_proTitleList objectAtIndex:row];
  //  } else {
  //    _proTimeStr = [_proTimeList objectAtIndex:row];
  //  }
  self.selectedInterval = [self.pickerData[row] floatValue];
}

//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
  //  int i = row % [self.pickerData count];
  //  DDLogDebug(@"i is %d", i);
  return [NSString
      stringWithFormat:@"%.1f 秒",
                       [self.pickerData[row %
                                        [self.pickerData count]] floatValue]];
}

- (IBAction)cancelTimeInterval:(id)sender {
  self.viewTimeInterval.hidden = YES;
}

- (IBAction)sureTimeInterval:(id)sender {
  self.viewTimeInterval.hidden = YES;
  SceneDetail *detail = self.scene.detailList[self.currentEditRow];
  detail.interval = self.selectedInterval;
  [self.currentEditIntervalBtn
      setTitle:[NSString stringWithFormat:@"%.1fs", self.selectedInterval]
      forState:UIControlStateNormal]; //默认1秒
}
@end
