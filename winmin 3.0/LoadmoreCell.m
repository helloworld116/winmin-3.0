//
//  LoadmoreCell.m
//  winmin 3.0
//
//  Created by sdzg on 14-12-10.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "LoadmoreCell.h"

@implementation LoadmoreCell

- (void)awakeFromNib {
  // Initialization code
  self.activityIndicator.hidden = YES;
  self.btnLoadmore.layer.borderWidth = 0.5f;
  self.btnLoadmore.layer.cornerRadius = 2.0f;
  self.btnLoadmore.layer.borderColor =
      [UIColor colorWithHexString:@"#F0EFEF"].CGColor;
  [self.btnLoadmore addTarget:self
                       action:@selector(loadMore:)
             forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

- (void)firstLoad {
  [self loadMore:nil];
}

- (void)noMoreData {
  [self.btnLoadmore setTitle:NSLocalizedString(@"Message_No_More", nil)
                    forState:UIControlStateNormal];
  self.btnLoadmore.enabled = NO;
}

- (void)loadMore:(id)sender {
  self.activityIndicator.hidden = NO;
  [self.activityIndicator startAnimating];
  [self.btnLoadmore setTitle:NSLocalizedString(@"Message_Loading", nil)
                    forState:UIControlStateNormal];
  self.btnLoadmore.enabled = NO;
  [self.delegate beginLoad:^(BOOL result) {
    if (result) {
      [self success];
    } else {
      [self faiure];
    }
  }];
}

- (void)success {
  self.activityIndicator.hidden = YES;
  [self.activityIndicator stopAnimating];
  self.btnLoadmore.enabled = YES;
  [self.btnLoadmore setTitle:NSLocalizedString(@"Message_Show_Next", nil)
                    forState:UIControlStateNormal];
}

- (void)faiure {
  self.activityIndicator.hidden = YES;
  [self.activityIndicator stopAnimating];
  self.btnLoadmore.enabled = YES;
  [self.btnLoadmore setTitle:NSLocalizedString(@"Message_Load_Failure", nil)
                    forState:UIControlStateNormal];
}
@end
