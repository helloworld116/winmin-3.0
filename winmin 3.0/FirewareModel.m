//
//  FirewareModel.m
//  winmin 3.0
//
//  Created by sdzg on 15-1-27.
//  Copyright (c) 2015年 itouchco.com. All rights reserved.
//

#import "FirewareModel.h"
#import "NSData+MD5.h"
static const int successCode = 1;

@interface FirewareModel () <UdpRequestDelegate>
@property (nonatomic, strong) SDZGSwitch *aSwitch;
@property (nonatomic, strong) UdpRequest *request;
@property (nonatomic, strong) UdpRequest *request2; //升级成功后的广播监听
@property (nonatomic, strong) GetSwitchFirewareInfoBlock getFirewareInfoBlock;
@property (nonatomic, strong) UpdateFirewareProgressBlock progressBlock;
//设备本地
@property (nonatomic, strong) NSString *deviceType;         //设备型号
@property (nonatomic, strong) NSString *firmwareVersion;    //固件版本号
@property (nonatomic, assign) NSUInteger firmwareTotalByte; //固件文件总字节
@property (nonatomic, assign) NSUInteger packageCount;      //固件包个数
//服务器
@property (nonatomic, strong) NSString *serverMD5;
@property (nonatomic, strong) NSString *serverFirewareVersion;
@property (nonatomic, strong) NSData *firmwareData; //固件文件
@property (atomic, assign) int lastPackageReciviedCount;
@end

@implementation FirewareModel
- (id)initWithSwitch:(SDZGSwitch *)aSwitch {
  self = [super init];
  if (self) {
    self.aSwitch = aSwitch;
    self.request = [UdpRequest manager];
    self.request.delegate = self;
  }
  return self;
}

- (void)dealloc {
  self.request.delegate = nil;
  self.request = nil;
  self.request2.delegate = nil;
  self.request2 = nil;
}

#pragma mark - 查询
- (void)getSwitchFirewareInfo:(GetSwitchFirewareInfoBlock)block {
  [self.request sendMsg7BWithSwitch:self.aSwitch sendMode:ActiveMode];
  self.getFirewareInfoBlock = block;
}

- (void)getFirewareInfoWithType:(NSString *)deviceType
                     completion:(GetSwitchFirewareInfoBlock)block {
  NSString *requestUrl =
      [NSString stringWithFormat:@"%@deviceVersion/getLastVersion",
                                 BaseURLStringWithNoEncrypt];
  if (deviceType) {
    AFHTTPRequestOperationManager *manager =
        [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableDictionary *parameters = [@{} mutableCopy];
    [parameters setObject:deviceType forKey:@"deviceType"];
    [manager POST:requestUrl
        parameters:parameters
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSString *string =
              [[NSString alloc] initWithData:responseObject
                                    encoding:NSUTF8StringEncoding];
          DDLogDebug(@"response msg is %@", string);
          NSDictionary *responseData = __JSON(string);
          int status = [responseData[@"status"] intValue];
          if (status == successCode) {
            NSDictionary *data = responseData[@"data"];
            NSDictionary *lastVersion = data[@"lastVersion"];
            NSString *serverFirewareVersion = lastVersion[@"softWareVersion"];
            self.serverFirewareVersion = serverFirewareVersion;
            DDLogDebug(@"服务器版本为%@", serverFirewareVersion);
            block(serverFirewareVersion, nil);
          } else {
            block(nil, nil);
          }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          block(nil, nil);
        }];
  } else {
    block(nil, nil);
  }
}

- (void)checkFirewareWithDeviceType:(NSString *)deviceType
                         completion:(UpdateFirewareProgressBlock)block {
  NSString *requestUrl =
      [NSString stringWithFormat:@"%@deviceVersion/getLastVersion",
                                 BaseURLStringWithNoEncrypt];
  if (deviceType) {
    AFHTTPRequestOperationManager *manager =
        [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableDictionary *parameters = [@{} mutableCopy];
    [parameters setObject:deviceType forKey:@"deviceType"];
    [manager POST:requestUrl
        parameters:parameters
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSString *string =
              [[NSString alloc] initWithData:responseObject
                                    encoding:NSUTF8StringEncoding];
          //          DDLogDebug(@"response msg is %@",string);
          NSDictionary *responseData = __JSON(string);
          int status = [responseData[@"status"] intValue];
          if (status == successCode) {
            NSDictionary *data = responseData[@"data"];
            NSDictionary *lastVersion = data[@"lastVersion"];
            NSString *serverFirewareVersion = lastVersion[@"softWareVersion"];
            self.serverFirewareVersion = serverFirewareVersion;
            DDLogDebug(@"服务器版本为%@", serverFirewareVersion);
            if ([self.firmwareVersion isEqualToString:serverFirewareVersion]) {
              block(NO, YES, @"已是最新版本");
            } else {
              self.serverMD5 = lastVersion[@"md5Check"];
              NSString *downloadUrl = lastVersion[@"pathUrl"];
              self.progressBlock = block;
              block(YES, NO, @"正在下载固件文件");
              [self downloadFile:downloadUrl];
            }
          } else {
            block(NO, NO, @"服务器错误，请稍后再试");
          }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          block(NO, NO, @"网络错误，请稍后再试");
        }];
  } else {
    block(NO, NO, @"未知设备");
  }
}

- (void)downloadFile:(NSString *)urlString {
  NSURL *url = [NSURL URLWithString:urlString];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  AFHTTPRequestOperation *operation =
      [[AFHTTPRequestOperation alloc] initWithRequest:request];
  NSString *fullPath = [NSTemporaryDirectory()
      stringByAppendingPathComponent:
          [NSString
              stringWithFormat:@"%ld",
                               (long)[[NSDate date] timeIntervalSince1970]]];
  [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:fullPath
                                                               append:NO]];
  [operation
      setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead,
                                 long long totalBytesExpectedToRead){
      }];
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation,
                                             id responseObject) {
    self.firmwareData = [NSData dataWithContentsOfFile:fullPath];
    self.progressBlock(YES, NO, @"文件下载成功，验证MD5");
    [self checkDownloadFileMD5];
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    DDLogDebug(@"ERR: %@", [error description]);
    self.progressBlock(NO, NO, @"文件下载出错");
  }];
  [operation start];
}

- (void)checkDownloadFileMD5 {
  if (self.firmwareData) {
    NSString *localMD5 = [self.firmwareData MD5];
    DDLogDebug(@"local md5 is %@", localMD5);
    DDLogDebug(@"server md5 is %@", self.serverMD5);
    if ([self.serverMD5 isEqualToString:localMD5]) {
      DDLogDebug(@"MD5验证成功");
      self.progressBlock(YES, NO, @"正在更新固件");
      [self verifyFireware];
    } else {
      self.progressBlock(NO, NO, @"MD5验证出错");
    }
  } else {
    self.progressBlock(NO, NO, @"MD5文件读取出错");
  }
}

- (void)verifyFireware {
  //  NSURL *imgPath = [[NSBundle mainBundle] URLForResource:@"WG1300_Demo"
  //                                           withExtension:@"bin"];
  //  NSString *stringPath = [imgPath absoluteString]; // this is correct
  //  self.firmwareData =
  //      [NSData dataWithContentsOfURL:[NSURL URLWithString:stringPath]];
  self.firmwareTotalByte = self.firmwareData.length;
  DDLogDebug(@"文件总大小为:%d", self.firmwareTotalByte);
  int mod = self.firmwareTotalByte % 512;
  int count = self.firmwareTotalByte / 512;
  if (mod) {
    count += 1;
  }
  self.packageCount = count;
  [self.request sendMsg7DWithSwitch:self.aSwitch
                            version:self.serverFirewareVersion
                          totalByte:self.firmwareData.length
                           sendMode:ActiveMode];
  //  [self sendFirewareDataWithPackageNum:1];
}

+ (NSData *)dataFromHexString:(NSString *)hexString {
  NSString *cleanString = hexString;
  NSMutableData *result = [[NSMutableData alloc] init];
  int i = 0;
  for (i = 0; i + 2 <= cleanString.length; i += 2) {
    NSRange range = NSMakeRange(i, 2);
    NSString *hexStr = [cleanString substringWithRange:range];
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    unsigned int intValue;
    [scanner scanHexInt:&intValue];
    unsigned char uc = (unsigned char)intValue;
    [result appendBytes:&uc length:1];
  }
  NSData *data = [NSData dataWithData:result];
  return data;
}

#pragma mark - 发送固件包
/**
 *
 *
 *  @param num 从1开始
 */
- (void)sendFirewareDataWithPackageNum:(int)num {
  char pakage[512];
  NSRange range;
  if (num < self.packageCount) {
    range = NSMakeRange((num - 1) * 512, 512);
  } else {
    range =
        NSMakeRange((num - 1) * 512, self.firmwareTotalByte - (num - 1) * 512);
  }
  [self.firmwareData getBytes:pakage range:range];
  NSData *subData = [NSData dataWithBytes:pakage length:range.length];
  if (num == self.packageCount) {
    DDLogDebug(@"last data is %@", subData);
  }
  [self.request sendMsg7FWithSwitch:self.aSwitch
                            content:subData
                                num:num
                           sendMode:ActiveMode];
}

#pragma mark - UdpRequest代理
- (void)udpRequest:(UdpRequest *)request
     didReceiveMsg:(CC3xMessage *)message
           address:(NSData *)address {
  switch (message.msgId) {
    case 0x7c:
      [self responseMsg7C:message];
      break;
    case 0x7e:
      [self responseMsg7E:message];
      break;
    case 0x80:
      [self responseMsg80:message];
      break;
    case 0x81:
      [self responseMsg81:message];
      break;
    default:
      break;
  }
}

- (void)udpRequest:(UdpRequest *)request
    didNotReceiveMsgTag:(long)tag
          socketGroupId:(int)socketGroupId {
}

- (void)responseMsg7C:(CC3xMessage *)message {
  self.firmwareVersion = message.firmwareVersion;
  self.deviceType = message.deviceType;
  self.getFirewareInfoBlock(message.firmwareVersion, message.deviceType);
}

- (void)responseMsg7E:(CC3xMessage *)message {
  DDLogDebug(@"state is %d", message.state);
  if (message.state == kUdpResponseSuccessCode &&
      message.totalBytes == self.firmwareTotalByte) {
    DDLogDebug(@"开始发送固件包");
    [self sendFirewareDataWithPackageNum:1];
  } else {
    self.progressBlock(NO, NO, @"字节包大小效验出错");
  }
}

- (void)responseMsg80:(CC3xMessage *)message {
  DDLogDebug(@"state is %d and package num is %d", message.state,
             message.packageNum);
  if (message.packageNum <= self.packageCount) {
    if (message.state == kUdpResponseSuccessCode) {
      if (message.packageNum < self.packageCount) {
        [self sendFirewareDataWithPackageNum:message.packageNum + 1];
      }
    } else {
      //重新发送，丢包等情况
      [self sendFirewareDataWithPackageNum:message.packageNum];
    }
    if (message.packageNum == self.packageCount &&
        self.lastPackageReciviedCount == 0 &&
        message.state == kUdpResponseSuccessCode) {
      self.lastPackageReciviedCount++;
      if (!self.request2) {
        self.request2 = [UdpRequest managerConfig];
        self.request2.delegate = self;
      }
    }
  }
}

- (void)responseMsg81:(CC3xMessage *)message {
  DDLogDebug(@"固件升级成功，最新版本是：%@", message.firmwareVersion);
  if ([self.aSwitch.mac isEqualToString:message.mac]) {
    self.firmwareVersion = message.firmwareVersion;
    self.progressBlock(NO, YES, @"固件升级成功");
    self.request2.delegate = nil;
    self.request2 = nil;
  }
}
@end
