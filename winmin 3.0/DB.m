//
//  DB.m
//  SmartSwitch
//
//  Created by 文正光 on 14-8-25.
//  Copyright (c) 2014年 itouchco.com. All rights reserved.
//

#import "DB.h"
#import <FMDB/FMDB.h>
#import "Scene.h"
#import "SceneDetail.h"

@interface DBUtil ()
@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, strong) FMDatabaseQueue *queue;
@end

@implementation DBUtil

- (id)init {
  self = [super init];
  if (self) {
    [self createDatabase];
    if (![self isExistTable:@"switch"]) {
      [self createTableSwitch];
    }
    if (![self isExistTable:@"socket"]) {
      [self createTableSocket];
    }
    if (![self isExistTable:@"timertask"]) {
      [self createTableTimerTask];
    }
    if (![self isExistTable:@"scene"]) {
      [self createTableScene];
    }
    if (![self isExistTable:@"scenedetail"]) {
      [self createTableSceneDetail];
    }
    if (![self isExistTable:@"scenedetailtmp"]) {
      [self createTableSceneDetailTmp];
    }
  }
  return self;
}

+ (instancetype)sharedInstance {
  static DBUtil *dbUtil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{ dbUtil = [[DBUtil alloc] init]; });
  return dbUtil;
}

- (void)createDatabase {
  NSString *dbPath =
      [PATH_OF_DOCUMENT stringByAppendingPathComponent:@"smartswitch.db"];
  self.db = [FMDatabase databaseWithPath:dbPath];
  self.queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
}

- (BOOL)createTableSwitch {
  if ([self.db open]) {
    NSString *sql =
        @"create table switch(id integer primary key autoincrement,name "
        @"text,networkstatus integer,mac text,ip text,port integer,lockstatus "
        @"integer,version integer,tag integer,imagename text,password "
        @"text);";
    BOOL success = [self.db executeUpdate:sql];
    if (success) {
      DDLogDebug(@"创建表switch成功");
    } else {
      DDLogDebug(@"创建表switch失败");
    }
    [self.db close];
    return success;
  }
  return NO;
}

- (BOOL)createTableSocket {
  if ([self.db open]) {
    NSString *sql = @"create table socket(id integer primary key  "
        @"autoincrement,mac text,groupid integer,name "
        @"text,delaytime integer,delayaction "
        @"integer,socketstatus integer,socket1image text,socket2image "
        @"text,socket3image text);";
    BOOL success = [self.db executeUpdate:sql];
    if (success) {
      DDLogDebug(@"创建表socket成功");
    } else {
      DDLogDebug(@"创建表socket失败");
    }
    [self.db close];
    return success;
  }
  return NO;
}

- (BOOL)createTableTimerTask {
  if ([self.db open]) {
    NSString *sql = @"create table timertask(id integer primary key "
        @"autoincrement,mac text,groupid integer,week integer,actiontime "
        @"integer,iseffective numeric,actiontype integer);";
    BOOL success = [self.db executeUpdate:sql];
    if (success) {
      DDLogDebug(@"创建表timertask成功");
    } else {
      DDLogDebug(@"创建表timertask失败");
    }
    [self.db close];
    return success;
  }
  return NO;
}

- (BOOL)createTableScene {
  if ([self.db open]) {
    NSString *sql = @"create table scene(id integer primary key "
        @"autoincrement,name text,imagename text);";
    BOOL success = [self.db executeUpdate:sql];
    if (success) {
      DDLogDebug(@"创建表scene成功");
    } else {
      DDLogDebug(@"创建表scene失败");
    }
    [self.db close];
    return success;
  }
  return NO;
}

- (BOOL)createTableSceneDetail {
  if ([self.db open]) {
    NSString *sql = @"create table scenedetail(id integer primary key "
        @"autoincrement,sceneid integer,mac text,action "
        @"integer,groupid integer,interval real);";
    BOOL success = [self.db executeUpdate:sql];
    if (success) {
      DDLogDebug(@"创建表scenedetail成功");
    } else {
      DDLogDebug(@"创建表scenedetail失败");
    }
    [self.db close];
    return success;
  }
  return NO;
}

- (BOOL)createTableSceneDetailTmp {
  if ([self.db open]) {
    NSString *createTableSql =
        @"create table scenedetailtmp(id integer primary key autoincrement,mac "
        @"text,groupid integer,onoff integer);";
    BOOL success = [self.db executeUpdate:createTableSql];
    if (success) {
      DDLogDebug(@"创建表sceneeetailtmp成功");
    } else {
      DDLogDebug(@"创建表scenedetailtmp失败");
    }
    [self.db close];
    return success;
  }
  return NO;
}

- (BOOL)isExistTable:(NSString *)tableName {
  NSString *name = nil;
  BOOL isExistTable = NO;
  FMDatabase *db = self.db;
  if ([db open]) {
    NSString *sql =
        [NSString stringWithFormat:@"select name from sqlite_master where "
                                   @"type = 'table' and name = '%@'",
                                   tableName];
    FMResultSet *rs = [db executeQuery:sql];
    while ([rs next]) {
      name = [rs stringForColumn:@"name"];

      if ([name isEqualToString:tableName]) {
        isExistTable = YES;
      }
    }
    [db close];
  }
  return isExistTable;
}

- (void)saveSwitch:(SDZGSwitch *)aSwitch {
  if (aSwitch && [aSwitch.sockets count] == 2) {
    [self.queue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
          NSString *sql = @"select count(id) as sid from switch where mac=?";
          FMResultSet *switchResult = [db executeQuery:sql, aSwitch.mac];
          if ([switchResult next]) {
            int sid = [switchResult intForColumn:@"sid"];
            if (sid) {
              NSString *sql = @"update switch set "
                  @"name=?,networkstatus=?,lockstatus=?,version=?,tag=?,"
                  @"imagename=?,password=?,ip=? where mac=?";
              [db executeUpdate:sql, aSwitch.name, @(aSwitch.networkStatus),
                                @(aSwitch.lockStatus), @(aSwitch.version), @(0),
                                aSwitch.imageName, aSwitch.password, aSwitch.ip,
                                aSwitch.mac];
            } else {
              NSString *sql = @"insert into "
                  @"switch(name,networkstatus,mac,ip,port,lockstatus,version,"
                  @"tag," @"imagename,password) values(?,?,?,?,?,?,?,?,?,?)";
              [db executeUpdate:sql, aSwitch.name, @(aSwitch.networkStatus),
                                aSwitch.mac, aSwitch.ip, @(aSwitch.port),
                                @(aSwitch.lockStatus), @(aSwitch.version), @(0),
                                aSwitch.imageName, aSwitch.password];
            }
          }

          sql = @"select count(id) as socketcount from socket where mac=?";
          FMResultSet *socketResult = [db executeQuery:sql, aSwitch.mac];
          if ([socketResult next]) {
            int socketcount = [socketResult intForColumn:@"socketcount"];
            if (socketcount && socketcount == 2) {
              sql = @"update socket set "
                  @"delaytime=?,delayaction=?,socketstatus=? where mac=? "
                  @"and groupid=?";
              for (SDZGSocket *socket in aSwitch.sockets) {
                [db executeUpdate:sql, @(socket.delayTime),
                                  @(socket.delayAction), @(socket.socketStatus),
                                  aSwitch.mac, @(socket.groupId)];
              }
            } else {
              sql = @"insert into "
                  @"socket(mac,groupid,name,delaytime,delayaction,socketstatus,"
                  @"socket1image,socket2image,socket3image) "
                  @"values(?,?,?,?,?,?,?,?,?)";
              for (SDZGSocket *socket in aSwitch.sockets) {
                [db executeUpdate:sql, aSwitch.mac, @(socket.groupId),
                                  socket.name, @(socket.delayTime),
                                  @(socket.delayAction), @(socket.socketStatus),
                                  socket.imageNames[0], socket.imageNames[1],
                                  socket.imageNames[2]];
              }
            }
          }
          sql = @"delete from timertask where mac=?";
          [db executeUpdate:sql, aSwitch.mac];
          for (SDZGSocket *socket in aSwitch.sockets) {
            for (SDZGTimerTask *timer in socket.timerList) {
              sql = @"insert into timertask(mac,groupid,week,actiontime,"
                  @"actiontype,iseffective) values(?,?,?,?,?,?)";
              [db executeUpdate:sql, aSwitch.mac, @(socket.groupId),
                                @(timer.week), @(timer.actionTime),
                                @(timer.timerActionType), @(timer.isEffective)];
            }
          }
          [db close];
        }
    }];
  }
}

- (void)saveSwitchs:(NSArray *)switchs {
  if (switchs && switchs.count) {
    for (SDZGSwitch *aSwitch in switchs) {
      [self saveSwitch:aSwitch];
    }
  }
}

- (BOOL)updateSwitch:(SDZGSwitch *)aSwitch imageName:(NSString *)imageName {
  BOOL result = NO;
  NSString *sql = @"update switch set imagename=? where mac =?";
  if ([self.db open]) {
    result = [self.db executeUpdate:sql, imageName, aSwitch.mac];
    [self.db close];
  }
  return result;
}

- (NSArray *)getSwitchs {
  NSMutableArray *switchs = [@[] mutableCopy];
  NSString *switchSql = @"select * from switch order by networkstatus,mac";
  if ([self.db open]) {
    FMResultSet *switchResult = [self.db executeQuery:switchSql];
    while (switchResult.next) {
      SDZGSwitch *aSwitch = [[SDZGSwitch alloc] init];
      aSwitch.name = [switchResult stringForColumn:@"name"];
      aSwitch.ip = [switchResult stringForColumn:@"ip"];
      aSwitch.mac = [switchResult stringForColumn:@"mac"];
      aSwitch.imageName = [switchResult stringForColumn:@"imagename"];
      aSwitch.password = [switchResult stringForColumn:@"password"];
      aSwitch.port = [switchResult intForColumn:@"port"];
      aSwitch.networkStatus = [switchResult intForColumn:@"networkstatus"];
      //      aSwitch.networkStatus = SWITCH_OFFLINE;
      aSwitch.lockStatus = [switchResult intForColumn:@"lockstatus"];
      aSwitch.version = [switchResult intForColumn:@"version"];
      aSwitch.tag = [switchResult intForColumn:@"tag"];
      aSwitch.sockets = [@[] mutableCopy];

      NSString *socketSql = @"select * from socket where mac = ?";
      FMResultSet *socketResult = [self.db executeQuery:socketSql, aSwitch.mac];
      while (socketResult.next) {
        SDZGSocket *socket = [[SDZGSocket alloc] init];
        socket.groupId = [socketResult intForColumn:@"groupid"];
        socket.name = [socketResult stringForColumn:@"name"];
        NSString *socket1image = [socketResult stringForColumn:@"socket1image"];
        NSString *socket2image = [socketResult stringForColumn:@"socket2image"];
        NSString *socket3image = [socketResult stringForColumn:@"socket3image"];
        if (!socket1image) {
          socket1image = socket_default_image;
        }
        if (!socket2image) {
          socket2image = socket_default_image;
        }
        if (!socket3image) {
          socket3image = socket_default_image;
        }
        socket.imageNames = @[ socket1image, socket2image, socket3image ];
        //        socket.delayTime = [socketResult intForColumn:@"delaytime"];
        //        socket.delayAction = [socketResult
        //        intForColumn:@"delayaction"];
        //        socket.socketStatus = [socketResult
        //        intForColumn:@"socketstatus"];
        socket.socketStatus = SocketStatusOff;
        socket.timerList = [@[] mutableCopy];

        NSString *timertaskSql =
            @"select * from timertask where mac =? and groupid=?";
        FMResultSet *timertaskResult =
            [self.db executeQuery:timertaskSql, aSwitch.mac, @(socket.groupId)];
        while (timertaskResult.next) {
          SDZGTimerTask *timerTask = [[SDZGTimerTask alloc] init];
          timerTask.week = [timertaskResult intForColumn:@"week"];
          timerTask.actionTime = [timertaskResult intForColumn:@"actiontime"];
          timerTask.isEffective =
              [timertaskResult boolForColumn:@"iseffective"];
          timerTask.timerActionType =
              [timertaskResult intForColumn:@"actiontype"];
          [socket.timerList addObject:timerTask];
        }
        [aSwitch.sockets addObject:socket];
      }
      if (!aSwitch.sockets || [aSwitch.sockets count] != 2) {
        aSwitch.sockets = [@[] mutableCopy];
        SDZGSocket *socket1 = [[SDZGSocket alloc] init];
        socket1.groupId = 1;
        socket1.socketStatus = SocketStatusOff;
        socket1.imageNames = @[
          socket_default_image,
          socket_default_image,
          socket_default_image
        ];
        [aSwitch.sockets addObject:socket1];
        SDZGSocket *socket2 = [[SDZGSocket alloc] init];
        socket2.groupId = 2;
        socket2.socketStatus = SocketStatusOff;
        socket2.imageNames = @[
          socket_default_image,
          socket_default_image,
          socket_default_image
        ];
        [aSwitch.sockets addObject:socket2];
      }
      [switchs addObject:aSwitch];
    }
    [self.db close];
  }
  return switchs;
}

- (void)deleteSwitch:(NSString *)mac {
  if ([self.db open]) {
    NSString *sql = @"delete from switch where mac =?";
    [self.db executeUpdate:sql, mac];

    sql = @"delete from socket where mac = ?";
    [self.db executeUpdate:sql, mac];

    sql = @"delete from timertask where mac = ?";
    [self.db executeUpdate:sql, mac];
    [self.db close];
  }
}

- (BOOL)updateSocketImage:(NSString *)imageName
                  groupId:(int)groupId
                 socketId:(int)socketId
              whichSwitch:(id)aSwitch {
  NSString *socketImage;
  switch (socketId) {
    case 1:
      socketImage = @"socket1image";
      break;
    case 2:
      socketImage = @"socket2image";
      break;
    case 3:
      socketImage = @"socket3image";
      break;
  }
  NSString *sql = [NSString
      stringWithFormat:@"update socket set %@=? where mac=? and groupid=?",
                       socketImage];
  if ([self.db open]) {
    BOOL result = [self.db
        executeUpdate:sql, imageName, ((SDZGSwitch *)aSwitch).mac, @(groupId)];
    [self.db close];
    return result;
  } else {
    return NO;
  }
}

- (NSArray *)scenes {
  NSMutableArray *scenes = [@[] mutableCopy];
  if ([self.db open]) {
    NSString *sql = @"select * from scene order by id asc";
    FMResultSet *sceneResultSet = [self.db executeQuery:sql];
    while (sceneResultSet.next) {
      Scene *scene = [[Scene alloc] init];
      scene.indentifier = [sceneResultSet intForColumn:@"id"];
      scene.name = [sceneResultSet stringForColumn:@"name"];
      scene.imageName = [sceneResultSet stringForColumn:@"imagename"];
      sql = @"select mac,action,groupid,interval from scenedetail where "
          @"sceneid=?";
      NSMutableArray *sceneDetails = [@[] mutableCopy];
      FMResultSet *sceneDetailResultSet =
          [self.db executeQuery:sql, @(scene.indentifier)];
      while (sceneDetailResultSet.next) {
        NSString *mac = [sceneDetailResultSet stringForColumn:@"mac"];
        int groupId = [sceneDetailResultSet intForColumn:@"groupid"];
        BOOL onOrOff = [sceneDetailResultSet boolForColumn:@"action"];
        SceneDetail *detail = [[SceneDetail alloc] initWithMac:mac
                                                       groupId:groupId
                                                       onOrOff:onOrOff];
        detail.interval = [sceneDetailResultSet doubleForColumn:@"interval"];
        [sceneDetails addObject:detail];
      }
      scene.detailList = sceneDetails;
      [scenes addObject:scene];
    }
    [self.db close];
  }
  return scenes;
}

- (BOOL)saveScene:(id)object {
  BOOL result = YES;
  Scene *scene = (Scene *)object;
  if ([self.db open]) {
    //先查询，如果存在进行修改操作，否则执行添加操作
    int sceneId;
    if (scene.indentifier) {
      sceneId = scene.indentifier;
      NSString *sql = @"update scene set name=?,imagename=? where id = ?";
      [self.db
          executeUpdate:sql, scene.name, scene.imageName, @(scene.indentifier)];
      sql = @"delete from scenedetail where sceneid = ?";
      [self.db executeUpdate:sql, @(scene.indentifier)];
    } else {
      NSString *sql = @"insert into scene(name,imagename) values (?,?)";
      [self.db executeUpdate:sql, scene.name, scene.imageName];
      sceneId = (int)[self.db lastInsertRowId];
      scene.indentifier = sceneId; //添加后设置标识符便于后续删除
    }
    for (SceneDetail *detail in scene.detailList) {
      NSString *sql =
          @"insert into scenedetail(sceneid,mac,action,groupid,interval) "
          @"values(?,?,?,?,?)";
      [self.db executeUpdate:sql, @(sceneId), detail.mac, @(detail.onOrOff),
                             @(detail.groupId), @(detail.interval)];
    }
    [self.db close];
  }
  return result;
}

- (BOOL)removeScene:(id)object {
  BOOL result = NO;
  Scene *scene = (Scene *)object;
  if ([self.db open]) {
    NSString *sql = @"delete from scene where id=?";
    result = [self.db executeUpdate:sql, @(scene.indentifier)];
    sql = @"delete from scenedetail where sceneid = ?";
    [self.db executeUpdate:sql, @(scene.indentifier)];
    [self.db close];
  }
  return result;
}

- (BOOL)removeSceneBySwitch:(SDZGSwitch *)aSwitch {
  if ([self.db open]) {
    NSString *sql = @"select sceneid from scenedetail where mac = ?";
    FMResultSet *sceneDetailResultSet = [self.db executeQuery:sql, aSwitch.mac];
    while ([sceneDetailResultSet next]) {
      int sceneId = [sceneDetailResultSet intForColumn:@"sceneid"];
      sql = @"delete from scene where id = ?";
      [self.db executeUpdate:sql, @(sceneId)];
    }
    sql = @"delete from scenedetail where mac = ?";
    [self.db executeUpdate:sql, aSwitch.mac];
    [self.db close];
    return YES;
  }
  return NO;
}

#pragma mark - 操作时的临时保存场景数据
- (void)addSceneToSceneDetailTmp:(id)object {
  Scene *scene = (Scene *)object;
  if ([self.db open]) {
    if (scene) {
      static NSString *sql =
          @"insert into scenedetailtmp (mac,groupid,onoff) values (?,?,?)";
      for (SceneDetail *detail in scene.detailList) {
        [self.db executeUpdate:sql, detail.mac, @(detail.groupId),
                               @(detail.onOrOff)];
      }
    }
    [self.db close];
  }
}

- (void)addDetailTmpWithSwitchMac:(NSString *)mac groupId:(int)groupid {
  if ([self.db open]) {
    static NSString *sql =
        @"insert into scenedetailtmp (mac,groupid,onoff) values (?,?,?)";
    [self.db executeUpdate:sql, mac, @(groupid), @(1)];
    [self.db close];
  }
}

- (void)removeDetailTmpWithSwitchMac:(NSString *)mac groupId:(int)groupid {
  if ([self.db open]) {
    static NSString *sql =
        @"delete from scenedetailtmp where mac=? and groupid=?";
    [self.db executeUpdate:sql, mac, @(groupid)];
  }
  [self.db close];
}

- (void)updateDetailTmpWithSwitchMac:(NSString *)mac
                             groupId:(int)groupid
                         onOffStatus:(BOOL)onOffStatus {
  if ([self.db open]) {
    static NSString *sql =
        @"update scenedetailtmp set onoff=? where mac=? and groupid=?";
    [self.db executeUpdate:sql, @(onOffStatus), mac, @(groupid)];
  }
  [self.db close];
}

- (NSArray *)allSceneDetailsTmp {
  NSMutableArray *details = [@[] mutableCopy];
  static NSString *sql = @"select mac,groupid,onoff from scenedetailtmp";
  if ([self.db open]) {
    FMResultSet *resultSet = [self.db executeQuery:sql];
    while ([resultSet next]) {
      NSString *mac = [resultSet stringForColumn:@"mac"];
      int groupId = [resultSet intForColumn:@"groupid"];
      BOOL onOff = [resultSet boolForColumn:@"onoff"];
      SceneDetail *detail =
          [[SceneDetail alloc] initWithMac:mac groupId:groupId onOrOff:onOff];
      [details addObject:detail];
    }
    [self.db close];
  }
  return details;
}

- (void)removeAllSceneDetailTmp {
  if ([self.db open]) {
    static NSString *sql = @"delete from scenedetailtmp;";
    [self.db executeUpdate:sql];
    [self.db close];
  }
}
@end
