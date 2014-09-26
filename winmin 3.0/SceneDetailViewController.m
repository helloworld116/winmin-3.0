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

@interface SceneDetailViewController ()<
    UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,
    SceneTemplateDelegate>
@property(strong, nonatomic) IBOutlet UIImageView *imgViewScene;
@property(strong, nonatomic) IBOutlet UITextField *textFieldSceneName;
@property(strong, nonatomic) IBOutlet UITableView *tableView;

@property(strong, nonatomic) NSArray *switchs;
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

  self.navigationItem.title = @"场景";
  self.navigationItem.rightBarButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:@"保存"
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(save:)];
}

- (void)setUp {
  [self setupStyle];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.textFieldSceneName.delegate = self;
  self.textFieldSceneName.attributedPlaceholder = [[NSAttributedString alloc]
      initWithString:@"请输入场景名称"
          attributes:@{NSForegroundColorAttributeName : kThemeColor}];
  self.switchs = [[SwitchDataCeneter sharedInstance] switchs];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self setUp];
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
  //  CATransition *animation = [CATransition animation];
  //  [animation setDuration:0.5];
  //  [animation setType:kCATransitionMoveIn];
  //  [animation setSubtype:kCATransitionFromBottom];
  //  [animation setTimingFunction:
  //                 [CAMediaTimingFunction
  //                     functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
  //  [[self.view layer] addAnimation:animation forKey:@"saveback"];
}

#pragma mark - 模板
- (IBAction)showTemplate:(id)sender {
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
  //在模板内的名称进行替换
  if ([[kSceneTemplateDict allValues]
          containsObject:self.textFieldSceneName.text] ||
      self.textFieldSceneName.text.length == 0) {
    self.textFieldSceneName.text = sceneName;
  }
  //  if (imgName.length > 10) {
  //    CGRect imgViewFrame = self.imgViewScene.frame;
  //    imgViewFrame.origin.x -= 12;
  //    imgViewFrame.origin.y -= 12;
  //    imgViewFrame.size.width += 24;
  //    imgViewFrame.size.height += 24;
  //    self.imgViewScene.frame = imgViewFrame;
  //  }
  self.imgViewScene.image = [SDZGSwitch imgNameToImage:imgName];
}
@end
