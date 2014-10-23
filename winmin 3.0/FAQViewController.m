//
//  FAQViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-10-23.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "FAQViewController.h"
#import "FaqCell.h"
// static const CGFloat kContentWidth = 265.f;

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
      boundingRectWithSize:CGSizeMake(kContentWidth, CGFLOAT_MAX)
                   options:NSStringDrawingUsesLineFragmentOrigin
                attributes:self.attributes
                   context:nil];
  self.titleHeight = ceil(rect.size.height) + 5;
  height += self.titleHeight;
  rect = [self.faqs[indexPath.row][@"a"]
      boundingRectWithSize:CGSizeMake(kContentWidth, CGFLOAT_MAX)
                   options:NSStringDrawingUsesLineFragmentOrigin
                attributes:self.attributes
                   context:nil];
  self.contentHeight = ceil(rect.size.height) + 10;
  height += self.contentHeight;
  debugLog(@"hegiht is %d", indexPath.row);
  debugLog(@"indexPath row is %d height is %f", indexPath.row, height);
  return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"FaqCell";
  //  FaqCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId
  //                                                  forIndexPath:indexPath];
  //  FaqCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
  FaqCell *cell =
      [[[NSBundle mainBundle] loadNibNamed:cellId owner:nil options:nil]
          objectAtIndex:0];
  NSDictionary *questionAndAnswer = self.faqs[indexPath.row];
  [cell setQuestion:questionAndAnswer[@"q"]
      questionHeight:self.titleHeight
              answer:questionAndAnswer[@"a"]
        answerHeight:self.contentHeight
           indexPath:indexPath];
  return cell;
}

@end
