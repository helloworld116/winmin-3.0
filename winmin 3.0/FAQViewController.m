//
//  FAQViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-10-23.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "FAQViewController.h"

@interface FAQViewController ()
@property (nonatomic, strong) NSArray *faqs;
@property (nonatomic, strong) NSDictionary *attributes;
@property (nonatomic, assign) CGFloat titleHeight;
@property (nonatomic, assign) CGFloat contentHeight;
@end

@implementation FAQViewController

- (void)setup {
  self.navigationItem.title = @"常见问题";
  self.attributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:18] };
  NSString *path =
      [[NSBundle mainBundle] pathForResource:@"faq" ofType:@"plist"];
  NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
  self.faqs = dict[@"faqs"];
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

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  // Return the number of rows in the section.
  return self.faqs.count;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  CGFloat height = 0;
  CGRect rect = [self.faqs[indexPath.row][@"q"]
      boundingRectWithSize:CGSizeMake(265, CGFLOAT_MAX)
                   options:NSStringDrawingUsesLineFragmentOrigin
                attributes:self.attributes
                   context:nil];
  //  debugLog(@"",)
  self.titleHeight = rect.size.height + 20;
  debugLog(@"titleHeight is %f", self.titleHeight);
  height += rect.size.height + 20;
  rect = [self.faqs[indexPath.row][@"a"]
      boundingRectWithSize:CGSizeMake(265, CGFLOAT_MAX)
                   options:NSStringDrawingUsesLineFragmentOrigin
                attributes:self.attributes
                   context:nil];
  self.contentHeight = rect.size.height + 20;
  debugLog(@"contentHeight is %f", self.contentHeight);
  height += rect.size.height + 20;
  return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"FAQCell";
  UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:cellId
                                      forIndexPath:indexPath];
  return cell;
}

@end
