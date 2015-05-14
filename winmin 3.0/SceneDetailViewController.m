//
//  SceneDetailViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-25.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "SceneDetailViewController.h"
#import "SceneTemplateViewController.h"
#import "SceneEditCell.h"
#import "Scene.h"

@interface SceneTextField : UITextField

@end

@implementation SceneTextField

//控制文本所在的的位置，左右缩 10
- (CGRect)textRectForBounds:(CGRect)bounds {
  return CGRectInset(bounds, 15, 0);
}

//控制编辑文本时所在的位置，左右缩 10
- (CGRect)editingRectForBounds:(CGRect)bounds {
  return CGRectInset(bounds, 15, 0);
}

@end

@interface SceneDetailViewController () <
    UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,
    SceneTemplateDelegate>
@property (strong, nonatomic) IBOutlet UIButton *btnSceneImage;
@property (strong, nonatomic) IBOutlet UITextField *textFieldSceneName;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *switchs;
@property (strong, nonatomic) NSString *sceneImageName;
@property (assign, nonatomic) BOOL showTemplateController;
- (IBAction)showTemplate:(id)sender;
@end

@implementation SceneDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)setupStyle {
  self.textFieldSceneName.layer.borderColor = [kThemeColor CGColor];
  self.textFieldSceneName.layer.borderWidth = 2.f;
  self.textFieldSceneName.layer.cornerRadius = 21.f;

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
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.textFieldSceneName.delegate = self;
  self.textFieldSceneName.attributedPlaceholder = [[NSAttributedString alloc]
      initWithString:NSLocalizedString(@"Please enter the scene name", nil)
          attributes:@{ NSForegroundColorAttributeName : kThemeColor }];
  self.switchs = [[SwitchDataCeneter sharedInstance] switchs];

  //修改时添加场景数据到数据库临时表中
  if (self.scene) {
    [[DBUtil sharedInstance] addSceneToSceneDetailTmp:self.scene];
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
  } else {
    self.row = -1;
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self setup];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  if (!self.showTemplateController) {
    //保存后删除临时表中的数据
    [[DBUtil sharedInstance] removeAllSceneDetailTmp];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return self.switchs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"SceneEditCell";
  SceneEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId
                                                        forIndexPath:indexPath];
  SDZGSwitch *aSwtich = self.switchs[indexPath.row];
  [cell setSwitchInfo:aSwtich row:indexPath.row];
  return cell;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - UITextField协议
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self.textFieldSceneName resignFirstResponder];
  return YES;
}

#pragma mark - 保存
- (void)save:(id)sender {
  NSArray *details = [[DBUtil sharedInstance] allSceneDetailsTmp];
  NSString *sceneName = self.textFieldSceneName.text;
  if (sceneName.length == 0) {
    [self.view
        makeToast:NSLocalizedString(@"Please enter the scene name", nil)];
    return;
  }
  if (details && details.count) {
    Scene *scene;
    if (self.scene) {
      scene = self.scene;
    } else {
      scene = [[Scene alloc] init];
    }
    scene.name = sceneName;
    if (!self.sceneImageName) {
      self.sceneImageName = @"sdef_";
    }
    scene.imageName = self.sceneImageName;
    scene.detailList = [details mutableCopy];
    [[DBUtil sharedInstance] saveScene:scene];
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kSceneAddOrUpdateNotification
                      object:self
                    userInfo:@{
                      @"row" : @(self.row),
                      @"scene" : scene
                    }];
  } else {
    [self.view makeToast:NSLocalizedString(@"Please add one operation", nil)];
  }
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
  [self presentViewController:templateController
                     animated:NO
                   completion:^{
                   }];
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
@end
