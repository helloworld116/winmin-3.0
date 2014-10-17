//
//  TestViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-30.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "TestViewController.h"
//#import "ElecRealTimeView.h"
#import <NCISimpleChartView.h>
#import <NCIZoomGraphView.h>
#import "HistoryElec.h"

@interface TestViewController ()
//@property(nonatomic, strong) IBOutlet ElecRealTimeView *realTimeView;
@property(nonatomic, strong) NCISimpleChartView *chartView;
@property(nonatomic, strong) IBOutlet UIView *containerView;
@end

@implementation TestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.

  //  [self custom];
  //  [self demo];

  self.containerView.layer.masksToBounds = YES;
  self.containerView.layer.cornerRadius = 10;
}

- (void)custom {
    NCISimpleChartView *chart = [[NCISimpleChartView alloc]
                                 initWithFrame:CGRectMake(10, 10, 300, 120)
                                 andOptions:@{
                                              nciGraphRenderer : [NCIZoomGraphView class],
                                              nciIsSmooth : @[ @NO ],
                                              nciIsFill : @[ @YES ],
                                              nciLineColors : @[ [UIColor orangeColor] ],
                                              nciLineWidths : @[ @1 ],
                                              nciHasSelection : @NO,
                                              nciShowPoints : @NO,
                                              nciGridVertical : @{
                                                      nciLineColor : [UIColor purpleColor],
                                                      nciLineDashes : @[],
                                                      nciLineWidth : @1
                                                      },
                                              nciGridHorizontal : @{
                                                      nciLineColor : [UIColor clearColor],
                                                      nciLineDashes : @[ ],
                                                      nciLineWidth : @1
                                                      },
                                              nciGridColor : [[UIColor magentaColor] colorWithAlphaComponent:0.1],
                                              nciGridLeftMargin : @0,
                                              nciGridRightMargin : @20,
                                              nciGridTopMargin : @0,
                                              nciGridBottomMargin : @0,
                                              nciUseDateFormatter :
                                                  @YES,
                                              nciYAxis : @{
                                                      nciLineColor : [UIColor clearColor],
                                                      nciLineDashes : @[],
                                                      nciAxisShift : @260,
                                                      nciLineWidth : @1,
                                                      //                   nciLabelsFont : [UIFont systemFontOfSize:12],
                                                      nciLabelsColor : [UIColor blackColor],
                                                      nciLabelsDistance : @50,
                                                      nciLabelRenderer : ^(double value) {
        return [[NSAttributedString alloc]
                initWithString:[NSString stringWithFormat:@"%.1f$", value]];
}
}
, nciXAxis : @{
               nciLineColor : [UIColor clearColor],
               nciLineWidth : @2,
               nciAxisShift : @120,
               nciLineDashes : @[],
               nciInvertedLabes : @NO,
               nciLabelsDistance : @50,
               nciUseDateFormatter : @YES
             }
}];
[self.view addSubview:chart];

int numOfPoints = 90;
for (int ind = 0; ind < numOfPoints; ind++) {
  [chart addPoint:ind val:@[ @(arc4random() % 5) ]];
}
}

- (void)demo {
    NCISimpleChartView *simpleChart = [[NCISimpleChartView alloc]
                                       initWithFrame:CGRectMake(10, 220, 300, 200)
                                       andOptions: @{
                                                     nciGraphRenderer : [NCIZoomGraphView class],
                                                     nciIsFill: @[@(NO), @(NO)],
                                                     nciIsSmooth: @[@(NO), @(YES)],
                                                     nciLineColors: @[[UIColor orangeColor], [NSNull null]],
                                                     nciLineWidths: @[@2, [NSNull null]],
                                                     nciHasSelection: @NO,
                                                     
nciSelPointSizes :
    @[ @10, [NSNull null] ],

    //                                               nciTapGridAction: ^(double
    //                                               argument, double value,
    //                                               float xInGrid, float
    //                                               yInGrid){
    //
    //    },
    nciShowPoints :
    @YES,
    nciUseDateFormatter :
    @YES,  // nciXLabelRenderer
    nciXAxis :
    @{
      nciLineColor : [UIColor redColor],
      nciLineDashes : @[],
      nciLineWidth : @2,
      nciLabelsFont : [UIFont fontWithName:@"MarkerFelt-Thin" size:12],
      nciLabelsColor : [UIColor blueColor],
      nciLabelsDistance : @120,
      nciUseDateFormatter : @YES
    },
    nciYAxis :
    @{
      nciLineColor : [UIColor blackColor],
      nciLineDashes : @[],
      nciLineWidth : @1,
      nciLabelsFont : [UIFont fontWithName:@"MarkerFelt-Thin" size:12],
      nciLabelsColor : [UIColor brownColor],
      nciLabelsDistance : @30,
      nciLabelRenderer : ^(double value) {NSLog(@"demo value is %.1f", value);
return [[NSAttributedString alloc]
    initWithString:[NSString stringWithFormat:@"%.1f$", value]
        attributes:@{
          NSForegroundColorAttributeName : [UIColor brownColor],
          NSFontAttributeName : [UIFont fontWithName:@"MarkerFelt-Thin" size:12]
        }];
}
}
, nciGridVertical : @{
                      nciLineColor : [UIColor purpleColor],
                      nciLineDashes : @[],
                      nciLineWidth : @1
                    },
                    nciGridColor :
                    [[UIColor magentaColor] colorWithAlphaComponent:0.1],
                    nciGridLeftMargin : @50,
                                        nciGridTopMargin : @50,
                                                           nciGridBottomMargin :
                                                           @40
}];

simpleChart.backgroundColor =
    [[UIColor yellowColor] colorWithAlphaComponent:0.2];

int numOfPoints = 10;
double dataPeriod = 60 * 60 * 24 * 30;
double step = dataPeriod / (numOfPoints - 1);
for (int ind = 0; ind < numOfPoints; ind++) {
  // to use default date formatter for Y axis, provide arguments as
  // timeIntervalSince1970
  // and set nciXLabelRenderer option to YES
  [simpleChart
      addPoint:[[NSDate dateWithTimeIntervalSinceNow:
                            -dataPeriod + step * ind] timeIntervalSince1970]
           val:@[ @(arc4random() % 5), @(arc4random() % 5) ]];
}

[self.view addSubview:simpleChart];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
