//
//  ConfigLoadingViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-16.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "ConfigLoadingViewController.h"

@interface ConfigLoadingViewController ()<UdpRequestDelegate>
@property(strong, nonatomic) IBOutlet UIButton *btn;
@property(strong, nonatomic) IBOutlet UIProgressView *progressView;
@property(strong, nonatomic) FirstTimeConfig *config;
@property(strong, nonatomic) UdpRequest *request;
@property(strong, nonatomic) NSTimer *timer;
- (IBAction)cancel:(id)sender;
@end

@implementation ConfigLoadingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)setupStyle {
  self.view.layer.cornerRadius = 5.f;
  self.btn.layer.cornerRadius = 5.f;
}

- (void)setup {
  [self setupStyle];
  [self startTransmitting];
  self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                target:self
                                              selector:@selector(changeProgress)
                                              userInfo:nil
                                               repeats:YES];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self setup];
  self.request = [UdpRequest managerConfig];
  self.request.delegate = self;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
  self.request = nil;
  [self.timer invalidate];
  [self stopAction];
  if (self.delegate &&
      [self.delegate respondsToSelector:@selector(cancelButtonClicked:)]) {
    [self.delegate cancelButtonClicked:self];
  }
}

- (void)changeProgress {
  self.progressView.progress += 1.f / 60;  //默认1分钟
  if (self.progressView.progress == 1.f) {
    [self.timer invalidate];
    //停止发送
    [self stopAction];
  }
}

#pragma mark - CC3000
//网络连接完好，进行udp传输
- (void)startTransmitting {
#if defined(TARGET_IPHONE_SIMULATOR) && TARGET_IPHONE_SIMULATOR
#else
  @try {
    self.config = nil;
    if ([self.password length]) {
      self.config = [[FirstTimeConfig alloc] initWithKey:self.password];
    } else {
      self.config = [[FirstTimeConfig alloc] init];
    }
    [self sendAction];
  }
  @catch (NSException *exception) {
    debugLog(@"%s exception == %@", __FUNCTION__, [exception description]);
  }
  @finally {
  }
#endif
}

- (void)sendAction {
  @try {
    debugLog(@"begin");
    [self.config transmitSettings];
    debugLog(@"end");
  }
  @catch (NSException *exception) {
    debugLog(@"exception === %@", [exception description]);
  }
  @finally {
  }
}

- (void)stopAction {
  debugLog(@"%s begin", __PRETTY_FUNCTION__);
  @try {
    [self.config stopTransmitting];
  }
  @catch (NSException *exception) {
    debugLog(@"%s exception == %@", __FUNCTION__, [exception description]);
  }
  @finally {
  }
  debugLog(@"%s end", __PRETTY_FUNCTION__);
}

#pragma mark - UdpRequestDelegate
- (void)responseMsg:(CC3xMessage *)message address:(NSData *)address {
  switch (message.msgId) {
    case 0x2:
      debugLog(@"mac is %@ ip is %@ and port is %d", message.mac, message.ip,
               message.port);
      [self.request sendMsg05:message.ip port:message.port mode:ActiveMode];
      break;
    case 0x6:
      if (message.state == 0) {
        // TODO:配置成功
        //保存wifi信息
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:self.password forKey:self.ssid];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self cancel:nil];
            //            [self.view
            //                makeToast:@"添加成功"
            //                 duration:1.f
            //                 position:[NSValue valueWithCGPoint:
            //                                       CGPointMake(
            //                                           self.view.frame.size.width
            //                                           / 2,
            //                                           self.view.frame.size.height
            //                                           - 40)]];
            //            [self performSelector:@selector(back:)
            //            withObject:nil afterDelay:1];
        });
      }
      debugLog(@"mac is %@ state is %d", message.mac, message.state);
      break;
    default:
      break;
  }
}

@end
