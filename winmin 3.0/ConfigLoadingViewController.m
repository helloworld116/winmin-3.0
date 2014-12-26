//
//  ConfigLoadingViewController.m
//  winmin 3.0
//
//  Created by sdzg on 14-9-16.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "ConfigLoadingViewController.h"
#import <DDProgressView.h>

static unsigned char password[6];
@interface ConfigLoadingViewController () <UdpRequestDelegate>
@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UIView *successView;
@property (strong, nonatomic) IBOutlet UIView *timeoutView;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UIButton *btn;
@property (strong, nonatomic) IBOutlet DDProgressView *progressView;
@property (strong, nonatomic) FirstTimeConfig *config;
@property (strong, nonatomic) UdpRequest *request;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) int msg2RecivedCount;

@property (strong, nonatomic) NSString *mac; //配置成功后设备的mac
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
  self.view.layer.masksToBounds = YES;
  self.view.layer.cornerRadius = 5.f;
  self.btn.layer.cornerRadius = 5.f;

  self.progressView.outerColor = [UIColor whiteColor];
  self.progressView.innerColor = kThemeColor;
  self.progressView.emptyColor = [UIColor colorWithHexString:@"#F0EFEF"];
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
  for (int i = 0; i < 6; i++) {
    unsigned char random = (arc4random() % 255);
    password[i] = random;
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)dealloc {
}

- (void)success {
  self.request = nil;
  [self.timer invalidate];
  [self stopAction];
}

- (IBAction)cancel:(id)sender {
  BOOL success = NO;
  if ([self.lblTitle.text
          isEqualToString:NSLocalizedString(@"Config Success", nil)]) {
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kConfigNewSwitch
                      object:self
                    userInfo:@{
                      @"mac" : self.mac,
                      @"password" : [NSString
                          stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                           password[0], password[1],
                                           password[2], password[3],
                                           password[4], password[5]]
                    }];
    success = YES;
  }
  [self success];
  if (self.delegate &&
      [self.delegate
          respondsToSelector:@selector(cancelButtonClicked:success:)]) {
    [self.delegate cancelButtonClicked:self success:success];
  }
}

- (void)changeProgress {
  //默认1分钟
  self.progressView.progress += 1.f / 60;
  //方式1，
  //  if (self.progressView.progress == 1.f) {
  //    self.request = nil;
  //    [self.timer invalidate];
  //    //停止发送
  //    [self stopAction];
  //    CGRect selfFrame = self.view.frame;
  //    CGFloat beginHeight = self.loadingView.frame.size.height;
  //    CGFloat endHeight = self.timeoutView.frame.size.height;
  //    selfFrame.origin.y -= (endHeight - beginHeight) / 2;
  //    selfFrame.size = CGSizeMake(
  //        selfFrame.size.width, selfFrame.size.height + endHeight -
  //        beginHeight);
  //    [UIView animateWithDuration:0.3f
  //                     animations:^{
  //                         self.view.frame = selfFrame;
  //                         self.loadingView.hidden = YES;
  //                         self.timeoutView.hidden = NO;
  //                         self.lblTitle.text =
  //                             NSLocalizedString(@"Config Timeout", nnil);
  //                         [self.btn
  //                             setTitle:NSLocalizedString(@"Config Close",
  //                             nil)
  //                             forState:UIControlStateNormal];
  //                     }];
  //  }
  //方式2，发送10秒，休息10秒
  //  if ((self.progressView.progress > 10.f / 60 &&
  //       self.progressView.progress < 20.f / 60) ||
  //      (self.progressView.progress > 30.f / 60 &&
  //       self.progressView.progress < 40.f / 60) ||
  //      (self.progressView.progress > 50.f / 60 &&
  //       self.progressView.progress < 60.f / 60)) {
  //    if ([self.config isTransmitting]) {
  //      [self stopAction];
  //    }
  //  } else if ((self.progressView.progress > 20.f / 60 &&
  //              self.progressView.progress < 30.f / 60) ||
  //             (self.progressView.progress > 40.f / 60 &&
  //              self.progressView.progress < 50.f / 60)) {
  //    if (![self.config isTransmitting]) {
  //      [self startTransmitting];
  //    }
  //  } else if (self.progressView.progress == 1.f) {
  //    self.request = nil;
  //    [self.timer invalidate];
  //    //停止发送
  //    [self stopAction];
  //    CGRect selfFrame = self.view.frame;
  //    CGFloat beginHeight = self.loadingView.frame.size.height;
  //    CGFloat endHeight = self.timeoutView.frame.size.height;
  //    selfFrame.origin.y -= (endHeight - beginHeight) / 2;
  //    selfFrame.size = CGSizeMake(
  //        selfFrame.size.width, selfFrame.size.height + endHeight -
  //        beginHeight);
  //    [UIView animateWithDuration:0.3f
  //                     animations:^{
  //                         self.view.frame = selfFrame;
  //                         self.loadingView.hidden = YES;
  //                         self.timeoutView.hidden = NO;
  //                         self.lblTitle.text =
  //                             NSLocalizedString(@"Config Timeout", nnil);
  //                         [self.btn
  //                             setTitle:NSLocalizedString(@"Config Close",
  //                             nil)
  //                             forState:UIControlStateNormal];
  //                     }];
  //  }
  //方式3，前30秒默认发送，中间休息15秒
  if ((self.progressView.progress > 30.f / 60 &&
       self.progressView.progress < 45.f / 60)) {
    if ([self.config isTransmitting]) {
      [self stopAction];
    }
  } else if (self.progressView.progress > 45.f / 60 &&
             self.progressView.progress < 60.f / 60) {
    if (![self.config isTransmitting]) {
      [self startTransmitting];
    }
  } else if (self.progressView.progress == 1.f) {
    self.request = nil;
    [self.timer invalidate];
    //停止发送
    [self stopAction];
    CGRect selfFrame = self.view.frame;
    CGFloat beginHeight = self.loadingView.frame.size.height;
    CGFloat endHeight = self.timeoutView.frame.size.height;
    selfFrame.origin.y -= (endHeight - beginHeight) / 2;
    selfFrame.size = CGSizeMake(
        selfFrame.size.width, selfFrame.size.height + endHeight - beginHeight);
    [UIView animateWithDuration:0.3f
                     animations:^{
                         self.view.frame = selfFrame;
                         self.loadingView.hidden = YES;
                         self.timeoutView.hidden = NO;
                         self.lblTitle.text =
                             NSLocalizedString(@"Config Timeout", nnil);
                         [self.btn
                             setTitle:NSLocalizedString(@"Config Close", nil)
                             forState:UIControlStateNormal];
                     }];
  }
}

#pragma mark - CC3000
//网络连接完好，进行udp传输
- (void)startTransmitting {
#if !TARGET_IPHONE_SIMULATOR
  @try {
    self.config = nil;
    if ([self.password length]) {
      self.config = [[FirstTimeConfig alloc] initWithKey:self.password];
    } else {
      self.config = [[FirstTimeConfig alloc] init];
    }
    [self sendAction];
    [NSThread detachNewThreadSelector:@selector(waitForAckThread:)
                             toTarget:self
                           withObject:nil];
  }
  @catch (NSException *exception) {
    DDLogDebug(@"%s exception == %@", __FUNCTION__, [exception description]);
  }
  @finally {
  }
#endif
}

- (void)sendAction {
  [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
  @try {
    DDLogDebug(@"begin");
    [self.config transmitSettings];
    DDLogDebug(@"end");
  }
  @catch (NSException *exception) {
    DDLogDebug(@"exception === %@", [exception description]);
  }
  @finally {
  }
}

- (void)waitForAckThread:(id)sender {
  @try {
    DDLogDebug(@"%s begin", __PRETTY_FUNCTION__);
    Boolean val = [self.config waitForAck];
    DDLogDebug(@"Bool value == %d", val);
    if (val) {
      [self stopAction];
    }
  }
  @catch (NSException *exception) {
    DDLogDebug(@"%s exception == %@", __FUNCTION__, [exception description]);
    /// stop here
  }
  @finally {
  }
}

- (void)stopAction {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
      [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
  });
  DDLogDebug(@"%s begin", __PRETTY_FUNCTION__);
  @try {
    [self.config stopTransmitting];
  }
  @catch (NSException *exception) {
    DDLogDebug(@"%s exception == %@", __FUNCTION__, [exception description]);
  }
  @finally {
  }
  DDLogDebug(@"%s end", __PRETTY_FUNCTION__);
}

#pragma mark - UdpRequestDelegate
- (void)udpRequest:(UdpRequest *)request
     didReceiveMsg:(CC3xMessage *)message
           address:(NSData *)address {
  switch (message.msgId) {
    case 0x2:
      if (self.msg2RecivedCount % 5 == 0) {
        [self.request sendMsg05:message.ip
                           port:message.port
                       password:password
                           mode:ActiveMode];
      }
      self.msg2RecivedCount++;
      DDLogDebug(
          @"mac is %@ ip is %@ and port is %d and recivedMsgId2 count is %d",
          message.mac, message.ip, message.port, self.msg2RecivedCount);
      break;
    case 0x6:
      if (message.state == kUdpResponseSuccessCode) {
        // TODO:配置成功
        //保存wifi信息
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:self.password forKey:self.ssid];
        self.mac = message.mac;
        dispatch_async(MAIN_QUEUE, ^{
            [self success];
            [UIView animateWithDuration:0.3f
                             animations:^{
                                 self.successView.hidden = NO;
                                 self.loadingView.hidden = YES;
                                 self.lblTitle.text =
                                     NSLocalizedString(@"Config Success", nil);
                                 [self.btn setTitle:NSLocalizedString(
                                                        @"Config Close", nil)
                                           forState:UIControlStateNormal];
                             }];
        });
      }
      DDLogDebug(@"mac is %@ state is %d", message.mac, message.state);
      break;
    default:
      break;
  }
}

@end
