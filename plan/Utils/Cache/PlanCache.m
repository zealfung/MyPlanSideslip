//
//  PlanCache.m
//  plan
//
//  Created by Fengzy on 15/8/29.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "LogIn.h"
#import "PlanCache.h"
#import "BmobQuery.h"
#import "FMDatabase.h"
#import "DataCenter.h"
#import "FMDatabasePool.h"
#import "FMDatabaseQueue.h"
#import <BmobSDK/BmobUser.h>
#import "FMDatabaseAdditions.h"
#import "LocalNotificationManager.h"



#define FMDBQuickCheck(SomeBool, Title, Db) {\
if (!(SomeBool)) { \
NSLog(@"Failure on line %d, %@ error(%d): %@", __LINE__, Title, [Db lastErrorCode], [Db lastErrorMessage]);\
}}


NSString * dbFilePath(NSString * filename) {
    NSArray * documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES);
    NSString * documentDirectory = [documentPaths objectAtIndex:0];
    NSString * pathName = [documentDirectory stringByAppendingPathComponent:@"cache"];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:pathName])
        [fileManager createDirectoryAtPath:pathName withIntermediateDirectories:YES attributes:nil error:nil];
    
    pathName = [pathName stringByAppendingPathComponent:filename];
    
    return pathName;
};

NSData * encodePwd(NSString * pwd) {
    
    NSData * data = [pwd dataUsingEncoding:NSUTF8StringEncoding];
    
    return data;
};

NSString * decodePwd(NSData * data) {
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
};


@implementation PlanCache


static FMDatabase * __db;
static NSString *__currentPath;
static NSString *__currentPlistPath;
static NSString *__offlineMsgPlistPath;
static NSMutableDictionary * __contactsOnlineState;

+ (void)initialize {
    
    NSLog(@"Is SQLite compiled with it's thread safe options turned on? %@!", [FMDatabase isSQLiteThreadSafe] ? @"Yes" : @"No");
    
}

#pragma mark -重置当前用户本地数据库链接
+ (void)resetCurrentLogin {
    
    [__db close];
    __db = nil;
    
    if (__currentPath) {
        __currentPath = nil;
    }
    
    if (__currentPlistPath) {
        __currentPlistPath = nil;
    }
    
    if (__offlineMsgPlistPath) {
        __offlineMsgPlistPath = nil;
    }
}

#pragma mark -打开当前用户本地数据库链接
+ (void)openDBWithAccount:(NSString *)account {
    
    [PlanCache resetCurrentLogin];
    
    if (!account)
        return;
    
    NSString * fileName = dbFilePath([NSString stringWithFormat:@"data_%@.db", account]);
    
    __currentPath = [fileName copy];
    __db = [FMDatabase databaseWithPath:fileName];
    
    if (![__db open]) {
        NSLog(@"Could not open db:%@", fileName);
        
        return;
    }
    
    [__db setShouldCacheStatements:YES];
    
    // 个人设置
    if (![__db tableExists:str_TableName_Settings]) {
        NSString *sqlString = [NSString stringWithFormat:@"CREATE TABLE %@ (objectId TEXT, account TEXT, nickname TEXT, birthday TEXT, email TEXT, gender TEXT, lifespan TEXT, syntime TEXT, avatar BLOB, avatarURL TEXT, centerTop BLOB, centerTopURL TEXT, isAutoSync TEXT, isUseGestureLock TEXT, isShowGestureTrack TEXT, gesturePasswod TEXT, updatetime TEXT, createtime TEXT)", str_TableName_Settings];
        
        BOOL b = [__db executeUpdate:sqlString];
        
        FMDBQuickCheck(b, sqlString, __db);
        
    } else {//新增字段
        //新增objectId字段2015-12-30
        NSString *objectId = @"objectId";
        if (![__db columnExists:objectId inTableWithName:str_TableName_Settings]) {
            
            NSString *sqlString = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",str_TableName_Settings, objectId];
            
            BOOL b = [__db executeUpdate:sqlString];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        //新增创建时间字段2015-12-3
        NSString *createtime = @"createtime";
        if (![__db columnExists:createtime inTableWithName:str_TableName_Settings]) {
            
            NSString *sqlString = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",str_TableName_Settings, createtime];
            
            BOOL b = [__db executeUpdate:sqlString];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        //是否启用手势密码字段2015-11-27
        NSString *isUseGestureLock = @"isUseGestureLock";
        if (![__db columnExists:isUseGestureLock inTableWithName:str_TableName_Settings]) {
            
            NSString *sqlString = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",str_TableName_Settings, isUseGestureLock];
            
            BOOL b = [__db executeUpdate:sqlString];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        //是否显示手势轨迹字段2015-11-27
        NSString *isShowGestureTrack = @"isShowGestureTrack";
        if (![__db columnExists:isShowGestureTrack inTableWithName:str_TableName_Settings]) {
            
            NSString *sqlString = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",str_TableName_Settings, isShowGestureTrack];
            
            BOOL b = [__db executeUpdate:sqlString];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        //手势密码字段2015-11-27
        NSString *gesturePasswod = @"gesturePasswod";
        if (![__db columnExists:gesturePasswod inTableWithName:str_TableName_Settings]) {
            
            NSString *sqlString = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",str_TableName_Settings, gesturePasswod];
            
            BOOL b = [__db executeUpdate:sqlString];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        //是否自动同步字段2015-11-25
        NSString *isAutoSync = @"isAutoSync";
        if (![__db columnExists:isAutoSync inTableWithName:str_TableName_Settings]) {
            
            NSString *sqlString = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",str_TableName_Settings, isAutoSync];
            
            BOOL b = [__db executeUpdate:sqlString];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
    }
    
    // 计划
    if (![__db tableExists:str_TableName_Plan]) {
        
        NSString *sqlString = [NSString stringWithFormat:@"CREATE TABLE %@ (account TEXT, planid TEXT, content TEXT, createtime TEXT, completetime TEXT, updatetime TEXT, iscompleted TEXT, isnotify TEXT, notifytime TEXT, plantype TEXT, isdeleted TEXT)", str_TableName_Plan];
        
        BOOL b = [__db executeUpdate:sqlString];
        
        FMDBQuickCheck(b, sqlString, __db);
        
    }
    
    //相册
    if (![__db tableExists:str_TableName_Photo]) {
        
        NSString *sqlString = [NSString stringWithFormat:@"CREATE TABLE %@ (account TEXT, photoid TEXT, content TEXT, createtime TEXT, phototime TEXT, updatetime TEXT, location TEXT, photo1 BLOB, photo2 BLOB, photo3 BLOB, photo4 BLOB, photo5 BLOB, photo6 BLOB, photo7 BLOB, photo8 BLOB, photo9 BLOB, photo1URL TEXT, photo2URL TEXT, photo3URL TEXT, photo4URL TEXT, photo5URL TEXT, photo6URL TEXT, photo7URL TEXT, photo8URL TEXT, photo9URL TEXT, isdeleted TEXT)", str_TableName_Photo];
        
        BOOL b = [__db executeUpdate:sqlString];
        
        FMDBQuickCheck(b, sqlString, __db);
        
    } else { //新增字段
        //图片URL字段2015-12-3
        NSString *photo1URL = @"photo1URL";
        if (![__db columnExists:photo1URL inTableWithName:str_TableName_Photo]) {
            
            NSString *sqlString = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",str_TableName_Photo, photo1URL];
            
            BOOL b = [__db executeUpdate:sqlString];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        //图片URL字段2015-12-3
        NSString *photo2URL = @"photo2URL";
        if (![__db columnExists:photo2URL inTableWithName:str_TableName_Photo]) {
            
            NSString *sqlString = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",str_TableName_Photo, photo2URL];
            
            BOOL b = [__db executeUpdate:sqlString];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        //图片URL字段2015-12-3
        NSString *photo3URL = @"photo3URL";
        if (![__db columnExists:photo3URL inTableWithName:str_TableName_Photo]) {
            
            NSString *sqlString = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",str_TableName_Photo, photo3URL];
            
            BOOL b = [__db executeUpdate:sqlString];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        //图片URL字段2015-12-3
        NSString *photo4URL = @"photo4URL";
        if (![__db columnExists:photo4URL inTableWithName:str_TableName_Photo]) {
            
            NSString *sqlString = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",str_TableName_Photo, photo4URL];
            
            BOOL b = [__db executeUpdate:sqlString];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        //图片URL字段2015-12-3
        NSString *photo5URL = @"photo5URL";
        if (![__db columnExists:photo5URL inTableWithName:str_TableName_Photo]) {
            
            NSString *sqlString = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",str_TableName_Photo, photo5URL];
            
            BOOL b = [__db executeUpdate:sqlString];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        //图片URL字段2015-12-3
        NSString *photo6URL = @"photo6URL";
        if (![__db columnExists:photo6URL inTableWithName:str_TableName_Photo]) {
            
            NSString *sqlString = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",str_TableName_Photo, photo6URL];
            
            BOOL b = [__db executeUpdate:sqlString];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        //图片URL字段2015-12-3
        NSString *photo7URL = @"photo7URL";
        if (![__db columnExists:photo7URL inTableWithName:str_TableName_Photo]) {
            
            NSString *sqlString = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",str_TableName_Photo, photo7URL];
            
            BOOL b = [__db executeUpdate:sqlString];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        //图片URL字段2015-12-3
        NSString *photo8URL = @"photo8URL";
        if (![__db columnExists:photo8URL inTableWithName:str_TableName_Photo]) {
            
            NSString *sqlString = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",str_TableName_Photo, photo8URL];
            
            BOOL b = [__db executeUpdate:sqlString];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        //图片URL字段2015-12-3
        NSString *photo9URL = @"photo9URL";
        if (![__db columnExists:photo9URL inTableWithName:str_TableName_Photo]) {
            
            NSString *sqlString = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",str_TableName_Photo, photo9URL];
            
            BOOL b = [__db executeUpdate:sqlString];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
    }
    
    //统计
    if (![__db tableExists:str_TableName_Statistics]) {
        
        NSString *sqlString = [NSString stringWithFormat:@"CREATE TABLE %@ (account TEXT, recentMax TEXT, recentMaxBeginDate TEXT, recentMaxEndDate TEXT, recordMax TEXT, recordMaxBeginDate TEXT, recordMaxEndDate TEXT, updatetime TEXT)", str_TableName_Statistics];
        
        BOOL b = [__db executeUpdate:sqlString];
        
        FMDBQuickCheck(b, sqlString, __db);
    } else { //新增字段
        NSString *updateTime = @"updatetime";
        if (![__db columnExists:updateTime inTableWithName:str_TableName_Statistics]) {
            
            NSString *sqlString = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",str_TableName_Statistics, updateTime];
            
            BOOL b = [__db executeUpdate:sqlString];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
    }
    
    //任务
    if (![__db tableExists:str_TableName_Task]) {
        
        NSString *sqlString = [NSString stringWithFormat:@"CREATE TABLE %@ (account TEXT, taskId TEXT, content TEXT, totalCount TEXT, completionDate TEXT, createTime TEXT, updateTime TEXT, isNotify TEXT, notifyTime TEXT, isDeleted TEXT)", str_TableName_Task];
        
        BOOL b = [__db executeUpdate:sqlString];
        
        FMDBQuickCheck(b, sqlString, __db);
    }

    //任务记录
    if (![__db tableExists:str_TableName_TaskRecord]) {
        
        NSString *sqlString = [NSString stringWithFormat:@"CREATE TABLE %@ (recordId TEXT, createTime TEXT)", str_TableName_TaskRecord];
        
        BOOL b = [__db executeUpdate:sqlString];
        
        FMDBQuickCheck(b, sqlString, __db);
    }
    
    //系统消息
    if (![__db tableExists:str_TableName_Messages]) {
        
        NSString *sqlString = [NSString stringWithFormat:@"CREATE TABLE %@ (account TEXT, messageId TEXT, title TEXT, content TEXT, detailURL TEXT, imgURLArray BLOB, hasRead TEXT, canShare TEXT, createTime TEXT)", str_TableName_Messages];
        
        BOOL b = [__db executeUpdate:sqlString];
        
        FMDBQuickCheck(b, sqlString, __db);
    } else {
        //新增图片URL数组字段2016-01-16
        NSString *imgURLArray = @"imgURLArray";
        if (![__db columnExists:imgURLArray inTableWithName:str_TableName_Messages]) {
            
            NSString *sqlString = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",str_TableName_Messages, imgURLArray];
            
            BOOL b = [__db executeUpdate:sqlString];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        //新增是否可分享字段2016-01-16
        NSString *canShare = @"canShare";
        if (![__db columnExists:canShare inTableWithName:str_TableName_Messages]) {
            
            NSString *sqlString = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",str_TableName_Messages, canShare];
            
            BOOL b = [__db executeUpdate:sqlString];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
    }
}

+ (void)storePersonalSettings:(Settings *)settings {
    
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return ;
            }
        }
        
        if ([LogIn isLogin]) {
            BmobUser *user = [BmobUser getCurrentUser];
            settings.account = user.objectId;
        } else {
            settings.account = @"";
        }
        if (!settings.objectId) {
            settings.objectId = @"";
        }
        if (!settings.nickname) {
            settings.nickname = @"";
        }
        if (!settings.birthday) {
            settings.birthday = @"";
        }
        if (!settings.email) {
            settings.email = @"";
        }
        if (!settings.gender) {
            settings.gender = @"0";
        }
        if (!settings.lifespan) {
            settings.lifespan = @"";
        }
        if (!settings.password) {
            settings.password = @"";
        }
        if (!settings.avatarURL) {
            settings.avatarURL = @"";
        }
        if (!settings.centerTopURL) {
            settings.centerTopURL = @"";
        }
        if (!settings.isAutoSync) {
            settings.isAutoSync = @"0";
        }
        if (!settings.isUseGestureLock) {
            settings.isUseGestureLock = @"0";
        }
        if (!settings.isShowGestureTrack) {
            settings.isShowGestureTrack = @"1";
        }
        if (!settings.gesturePasswod) {
            settings.gesturePasswod = @"";
        }
        if (!settings.syntime || settings.syntime.length == 0) {
            settings.syntime = @"2015-09-01 09:09:09";
        }
        NSString *timeNow = [CommonFunction getTimeNowString];
        if (!settings.createtime || settings.createtime.length == 0) {
            settings.createtime = timeNow;
        }
        settings.updatetime = timeNow;
        
        NSData *avatarData = [NSData data];
        if (settings.avatar) {
            avatarData = UIImageJPEGRepresentation(settings.avatar, 1.0);
        }
        NSData *centerTopData = [NSData data];
        if (settings.centerTop) {
            centerTopData = UIImageJPEGRepresentation(settings.centerTop, 1.0);
        }
        
        BOOL hasRec = NO;
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE account=?", str_TableName_Settings];
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[settings.account]];
        hasRec = [rs next];
        [rs close];
        if (hasRec) {
            
            sqlString = [NSString stringWithFormat:@"UPDATE %@ SET objectId=?, nickname=?, birthday=?, email=?, gender=?, lifespan=?, avatar=?, avatarURL=?, centerTop=?, centerTopURL=?, isAutoSync=?, isUseGestureLock=?, isShowGestureTrack=?, gesturePasswod=?, createtime=?, updatetime=?, syntime=? WHERE account=?", str_TableName_Settings];
            
            BOOL b = [__db executeUpdate:sqlString withArgumentsInArray:@[settings.objectId, settings.nickname, settings.birthday, settings.email, settings.gender, settings.lifespan, avatarData, settings.avatarURL, centerTopData, settings.centerTopURL, settings.isAutoSync, settings.isUseGestureLock, settings.isShowGestureTrack, settings.gesturePasswod, settings.createtime, settings.updatetime, settings.syntime, settings.account]];
            
            FMDBQuickCheck(b, sqlString, __db);
            
        } else {
            
            sqlString = [NSString stringWithFormat:@"INSERT INTO %@(objectId, account, nickname, birthday, email, gender, lifespan, avatar, avatarURL, centerTop, centerTopURL, isAutoSync, isUseGestureLock, isShowGestureTrack, gesturePasswod, createtime, updatetime, syntime) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", str_TableName_Settings];
            
            BOOL b = [__db executeUpdate:sqlString withArgumentsInArray:@[settings.objectId, settings.account, settings.nickname, settings.birthday, settings.email, settings.gender, settings.lifespan, avatarData, settings.avatarURL, centerTopData, settings.centerTopURL, settings.isAutoSync, settings.isUseGestureLock, settings.isShowGestureTrack, settings.gesturePasswod, settings.createtime, settings.updatetime, settings.syntime]];

            FMDBQuickCheck(b, sqlString, __db);
        }
        
        [NotificationCenter postNotificationName:Notify_Settings_Save object:nil];
        [NotificationCenter postNotificationName:Notify_Photo_RefreshOnly object:nil];
    }
}

+ (void)updateSettingsUpdatedTime {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return ;
            }
        }
        
        NSString *account = @"";
        if ([LogIn isLogin]) {
            BmobUser *user = [BmobUser getCurrentUser];
            account = user.objectId;
        }
        NSString *timeNow = [CommonFunction getTimeNowString];

        BOOL hasRec = NO;
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE account=?", str_TableName_Settings];
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account]];
        hasRec = [rs next];
        [rs close];
        if (hasRec) {
            sqlString = [NSString stringWithFormat:@"UPDATE %@ SET updatetime=? WHERE account=?", str_TableName_Settings];
            BOOL b = [__db executeUpdate:sqlString withArgumentsInArray:@[timeNow, account]];
            FMDBQuickCheck(b, sqlString, __db);
        }
    }
}

+ (BOOL)storePlan:(Plan *)plan {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return NO;
            }
        }
        
        if (!plan.planid || !plan.content || !plan.createtime)
            return NO;
        
        if ([LogIn isLogin]) {
            BmobUser *user = [BmobUser getCurrentUser];
            plan.account = user.objectId;
        } else {
            plan.account = @"";
        }
        if (!plan.completetime) {
            plan.completetime = @"";
        }
        if (!plan.updatetime) {
            plan.updatetime = plan.createtime;
        }
        if (!plan.iscompleted) {
            plan.iscompleted = @"0";
        }
        if (!plan.plantype) {
            plan.plantype = @"";
        }
        if (!plan.notifytime) {
            plan.notifytime = @"";
        }
        if (!plan.isdeleted) {
            plan.isdeleted = @"0";
        }
        
        BOOL hasRec = NO;
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE planid=? AND account=?", str_TableName_Plan];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[plan.planid, plan.account]];
        hasRec = [rs next];
        [rs close];
        BOOL b = NO;
        if (hasRec) {
            
            sqlString = [NSString stringWithFormat:@"UPDATE %@ SET content=?, createtime=?, completetime=?, updatetime=?, iscompleted=?, isnotify=?, notifytime=?, plantype=?, isdeleted=? WHERE planid=? AND account=?", str_TableName_Plan];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[plan.content, plan.createtime, plan.completetime, plan.updatetime, plan.iscompleted, plan.isnotify, plan.notifytime, plan.plantype, plan.isdeleted, plan.planid, plan.account]];
            
            FMDBQuickCheck(b, sqlString, __db);
            
            //更新提醒
            if (b && [plan.isnotify isEqualToString:@"1"]) {
                
                [self updateLocalNotification:plan];
                
            } else {
                
                [self cancelLocalNotification:plan.planid];
            }
        } else {
            
            sqlString = [NSString stringWithFormat:@"INSERT INTO %@(account, planid, content, createtime, completetime, updatetime, iscompleted, isnotify, notifytime, plantype, isdeleted) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", str_TableName_Plan];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[plan.account, plan.planid, plan.content, plan.createtime, plan.completetime, plan.updatetime, plan.iscompleted, plan.isnotify, plan.notifytime, plan.plantype, plan.isdeleted]];
            
            FMDBQuickCheck(b, sqlString, __db);
            
            //添加提醒
            if (b && [plan.isnotify isEqualToString:@"1"]) {
                
                [self addLocalNotification:plan];
            }
            //更新5天没有新建计划的提醒时间
            [self setFiveDayNotification];
        }
        if (b) {
            [NotificationCenter postNotificationName:Notify_Plan_Save object:nil];
            [self updateSettingsUpdatedTime];
        }
        return b;
    }
}

+ (BOOL)storePhoto:(Photo *)photo {
    
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return NO;
            }
        }
        
        if (!photo.photoid || !photo.createtime)
            return NO;
        
        if ([LogIn isLogin]) {
            BmobUser *user = [BmobUser getCurrentUser];
            photo.account = user.objectId;
        } else {
            photo.account = @"";
        }
        if (!photo.content) {
            photo.content = @"";
        }
        if (!photo.phototime) {
            photo.phototime = @"";
        }
        if (!photo.updatetime) {
            photo.updatetime = photo.createtime;
        }
        if (!photo.location) {
            photo.location = @"";
        }
        NSMutableArray *photoDataArray = [NSMutableArray arrayWithCapacity:9];
        for (NSInteger i = 0; i < 9; i++) {
            
            if (i < photo.photoArray.count) {
                
                UIImage *image = photo.photoArray[i];
                NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
                [photoDataArray addObject:imageData];
                
            } else {
                
                [photoDataArray addObject:[NSData data]];
            }
        }

        BOOL hasRec = NO;
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE photoid=? AND account=?", str_TableName_Photo];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[photo.photoid, photo.account]];
        hasRec = [rs next];
        [rs close];
        BOOL b = NO;
        if (hasRec) {
            
            sqlString = [NSString stringWithFormat:@"UPDATE %@ SET content=?, createtime=?, phototime=?, updatetime=?, location=?, photo1=?, photo2=?, photo3=?, photo4=?, photo5=?, photo6=?, photo7=?, photo8=?, photo9=?, photo1URL=?, photo2URL=?, photo3URL=?, photo4URL=?, photo5URL=?, photo6URL=?, photo7URL=?, photo8URL=?, photo9URL=? WHERE photoid=? AND account=?", str_TableName_Photo];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[photo.content, photo.createtime, photo.phototime, photo.updatetime, photo.location, photoDataArray[0], photoDataArray[1], photoDataArray[2], photoDataArray[3], photoDataArray[4], photoDataArray[5], photoDataArray[6], photoDataArray[7], photoDataArray[8], photo.photoURLArray[0], photo.photoURLArray[1], photo.photoURLArray[2], photo.photoURLArray[3], photo.photoURLArray[4], photo.photoURLArray[5], photo.photoURLArray[6], photo.photoURLArray[7], photo.photoURLArray[8], photo.photoid, photo.account]];
            
            FMDBQuickCheck(b, sqlString, __db);

        } else {
            
            sqlString = [NSString stringWithFormat:@"INSERT INTO %@(account, photoid, content, createtime, phototime, updatetime, location, photo1, photo2, photo3, photo4, photo5, photo6, photo7, photo8, photo9, photo1URL, photo2URL, photo3URL, photo4URL, photo5URL, photo6URL, photo7URL, photo8URL, photo9URL, isdeleted) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", str_TableName_Photo];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[photo.account, photo.photoid, photo.content, photo.createtime, photo.phototime, photo.updatetime, photo.location, photoDataArray[0], photoDataArray[1], photoDataArray[2], photoDataArray[3], photoDataArray[4], photoDataArray[5], photoDataArray[6], photoDataArray[7], photoDataArray[8], photo.photoURLArray[0], photo.photoURLArray[1], photo.photoURLArray[2], photo.photoURLArray[3], photo.photoURLArray[4], photo.photoURLArray[5], photo.photoURLArray[6], photo.photoURLArray[7], photo.photoURLArray[8], @"0"]];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        if (b) {
            [NotificationCenter postNotificationName:Notify_Photo_Save object:nil];
            [self updateSettingsUpdatedTime];
        }
        return b;
    }
}

+ (BOOL)storeStatistics:(Statistics *)statistics {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return NO;
            }
        }
        
        if ([LogIn isLogin]) {
            BmobUser *user = [BmobUser getCurrentUser];
            statistics.account = user.objectId;
        } else {
            return NO;
        }
        if (!statistics.recentMax) {
            statistics.recentMax = @"0";
        }
        if (!statistics.recentMaxBeginDate) {
            statistics.recentMaxBeginDate = @"";
        }
        if (!statistics.recentMaxEndDate) {
            statistics.recentMaxEndDate = @"";
        }
        if (!statistics.recordMax) {
            statistics.recordMax = @"0";
        }
        if (!statistics.recordMaxBeginDate) {
            statistics.recordMaxBeginDate = @"";
        }
        if (!statistics.recordMaxEndDate) {
            statistics.recordMaxEndDate = @"";
        }
        if (!statistics.updatetime) {
            statistics.updatetime = @"";
        }
        
        BOOL hasRec = NO;
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE account=?", str_TableName_Statistics];
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[statistics.account]];
        hasRec = [rs next];
        [rs close];
        BOOL b = NO;
        if (hasRec) {
            
            sqlString = [NSString stringWithFormat:@"UPDATE %@ SET recentMax=?, recentMaxBeginDate=?, recentMaxEndDate=?, recordMax=?, recordMaxBeginDate=?, recordMaxEndDate=?, updatetime=? WHERE account=?", str_TableName_Statistics];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[statistics.recentMax, statistics.recentMaxBeginDate, statistics.recentMaxEndDate, statistics.recordMax, statistics.recordMaxBeginDate, statistics.recordMaxEndDate, statistics.updatetime, statistics.account]];
            
            FMDBQuickCheck(b, sqlString, __db);
            
        } else {
            
            sqlString = [NSString stringWithFormat:@"INSERT INTO %@(account, recentMax, recentMaxBeginDate, recentMaxEndDate, recordMax, recordMaxBeginDate, recordMaxEndDate, updatetime) values(?, ?, ?, ?, ?, ?, ?, ?)", str_TableName_Statistics];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[statistics.account, statistics.recentMax, statistics.recentMaxBeginDate, statistics.recentMaxEndDate, statistics.recordMax, statistics.recordMaxBeginDate, statistics.recordMaxEndDate, statistics.updatetime]];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        [NotificationCenter postNotificationName:Notify_Settings_Save object:nil];
        return b;
    }
}

+ (BOOL)storeTask:(Task *)task {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return NO;
            }
        }
        
        if (!task.taskId || !task.createTime)
            return NO;
        
        if ([LogIn isLogin]) {
            BmobUser *user = [BmobUser getCurrentUser];
            task.account = user.objectId;
        } else {
            task.account = @"";
        }
        if (!task.content) {
            task.content = @"";
        }
        if (!task.totalCount) {
            task.totalCount = @"0";
        }
        if (!task.completionDate) {
            task.completionDate = @"";
        }
        if (!task.updateTime) {
            task.updateTime = @"";
        }
        if (!task.isNotify) {
            task.isNotify = @"0";
        }
        if (!task.notifyTime) {
            task.notifyTime = @"";
        }
        if (!task.isDeleted) {
            task.isDeleted = @"0";
        }
        
        BOOL hasRec = NO;
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE taskId=? AND account=?", str_TableName_Task];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[task.taskId, task.account]];
        hasRec = [rs next];
        [rs close];
        BOOL b = NO;
        if (hasRec) {
            
            sqlString = [NSString stringWithFormat:@"UPDATE %@ SET content=?, totalCount=?, completionDate=?, updateTime=?, isNotify=?, notifyTime=? WHERE taskId=? AND account=?", str_TableName_Task];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[task.content, task.totalCount, task.completionDate, task.updateTime, task.isNotify, task.notifyTime, task.taskId, task.account]];
            
            FMDBQuickCheck(b, sqlString, __db);
            
        } else {
            
            sqlString = [NSString stringWithFormat:@"INSERT INTO %@(account, taskId, content, totalCount, completionDate, createTime, updateTime, isNotify, notifyTime, isDeleted) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", str_TableName_Task];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[task.account, task.taskId, task.content, task.totalCount, task.completionDate, task.createTime, task.updateTime, task.isNotify, task.notifyTime, @"0"]];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        if (b) {
            [NotificationCenter postNotificationName:Notify_Task_Save object:nil];
            [self updateSettingsUpdatedTime];
        }
        return b;
    }
}

+ (BOOL)storeTaskRecord:(TaskRecord *)taskRecord {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return NO;
            }
        }
        
        if (!taskRecord.recordId || !taskRecord.createTime)
            return NO;

        NSString *sqlString = [NSString stringWithFormat:@"INSERT INTO %@(recordId, createTime) values(?, ?)", str_TableName_TaskRecord];
 
        BOOL b = [__db executeUpdate:sqlString withArgumentsInArray:@[taskRecord.recordId, taskRecord.createTime]];
        
        FMDBQuickCheck(b, sqlString, __db);
        
        if (b) {
            [NotificationCenter postNotificationName:Notify_TaskRecord_Save object:nil];
            [self updateSettingsUpdatedTime];
        }
        return b;
    }
}

+ (BOOL)storeMessages:(Messages *)message {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return NO;
            }
        }
        
        if (!message.messageId)
            return NO;
        
        NSString *account = @"";
        if ([LogIn isLogin]) {
            BmobUser *user = [BmobUser getCurrentUser];
            account = user.objectId;
        }
        if (!message.title) {
            message.title = @"";
        }
        if (!message.content) {
            message.content = @"";
        }
        if (!message.detailURL) {
            message.detailURL = @"";
        }
        if (!message.imgURLArray) {
            message.imgURLArray = [NSArray array];
        }
        if (!message.canShare) {
            message.canShare = @"0";
        }
        if (!message.createTime) {
            message.createTime = [CommonFunction getTimeNowString];
        }
        
        NSData *imgURLArrayData = [NSKeyedArchiver archivedDataWithRootObject:message.imgURLArray];
        
        BOOL hasRec = NO;
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE messageId=? AND account=?", str_TableName_Messages];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[message.messageId, account]];
        hasRec = [rs next];
        [rs close];
        BOOL b = NO;
        if (!hasRec) {
            
            sqlString = [NSString stringWithFormat:@"INSERT INTO %@(account, messageId, title, content, detailURL, imgURLArray, hasRead, canShare, createTime) values(?, ?, ?, ?, ?, ?, ?, ?, ?)", str_TableName_Messages];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[account, message.messageId, message.title, message.content, message.detailURL, imgURLArrayData, @"0", message.canShare, message.createTime]];
            
            FMDBQuickCheck(b, sqlString, __db);
            
            [NotificationCenter postNotificationName:Notify_Messages_Save object:nil];
        }
        return b;
    }
}

+ (BOOL)setMessagesRead:(Messages *)message {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return NO;
            }
        }
        
        if (!message.messageId)
            return NO;
        
        NSString *account = @"";
        if ([LogIn isLogin]) {
            BmobUser *user = [BmobUser getCurrentUser];
            account = user.objectId;
        }
        
        BOOL hasRec = NO;
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE messageId=? AND account=?", str_TableName_Messages];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[message.messageId, account]];
        hasRec = [rs next];
        [rs close];
        BOOL b = NO;
        if (hasRec) {
            
            sqlString = [NSString stringWithFormat:@"UPDATE %@ SET hasRead=1 WHERE messageId=? AND account=?", str_TableName_Messages];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[message.messageId, account]];
            
            FMDBQuickCheck(b, sqlString, __db);
            
            [NotificationCenter postNotificationName:Notify_Messages_Save object:nil];
        }
        return b;
    }
}

+ (BOOL)deletePlan:(Plan *)plan {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return NO;
            }
        }
        
        if ([LogIn isLogin]) {
            BmobUser *user = [BmobUser getCurrentUser];
            plan.account = user.objectId;
        } else {
            plan.account = @"";
        }
        plan.updatetime = [CommonFunction getTimeNowString];
        
        BOOL hasRec = NO;
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE planid=? AND account=?", str_TableName_Plan];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[plan.planid, plan.account]];
        hasRec = [rs next];
        [rs close];
        BOOL b = NO;
        if (hasRec) {

            sqlString = [NSString stringWithFormat:@"UPDATE %@ SET isdeleted=1, updatetime=?  WHERE planid=? AND account=?", str_TableName_Plan];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[plan.updatetime, plan.planid, plan.account]];
            
            FMDBQuickCheck(b, sqlString, __db);
            
            //取消提醒
            if (b && [plan.isnotify isEqualToString:@"1"]) {
                
                [self cancelLocalNotification:plan.planid];
            }
        }
        if (b) {
            [NotificationCenter postNotificationName:Notify_Plan_Save object:nil];
            [self updateSettingsUpdatedTime];
        }
        return b;
    }
}

+ (BOOL)deletePhoto:(Photo *)photo {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return NO;
            }
        }
        
        if ([LogIn isLogin]) {
            BmobUser *user = [BmobUser getCurrentUser];
            photo.account = user.objectId;
        } else {
            photo.account = @"";
        }
        photo.updatetime = [CommonFunction getTimeNowString];
        
        BOOL hasRec = NO;
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE photoid=? AND account=?", str_TableName_Photo];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[photo.photoid, photo.account]];
        hasRec = [rs next];
        [rs close];
        BOOL b = NO;
        if (hasRec) {
            
            sqlString = [NSString stringWithFormat:@"UPDATE %@ SET isdeleted=1, updatetime=? WHERE photoid=? AND account=?", str_TableName_Photo];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[photo.updatetime, photo.photoid, photo.account]];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        if (b) {
            [NotificationCenter postNotificationName:Notify_Photo_Save object:nil];
            [self updateSettingsUpdatedTime];
        }
        return b;
    }
}

+ (BOOL)deleteTask:(Task *)task {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return NO;
            }
        }
        
        if ([LogIn isLogin]) {
            BmobUser *user = [BmobUser getCurrentUser];
            task.account = user.objectId;
        } else {
            task.account = @"";
        }
        task.updateTime = [CommonFunction getTimeNowString];
        
        BOOL hasRec = NO;
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE taskId=? AND account=?", str_TableName_Task];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[task.taskId, task.account]];
        hasRec = [rs next];
        [rs close];
        BOOL b = NO;
        if (hasRec) {
            
            sqlString = [NSString stringWithFormat:@"UPDATE %@ SET isdeleted=1, updateTime=?  WHERE taskId=? AND account=?", str_TableName_Task];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[task.updateTime, task.taskId, task.account]];
            
            FMDBQuickCheck(b, sqlString, __db);
            
//            //取消提醒
//            if (b && [task.isNotify isEqualToString:@"1"]) {
//                
//                [self cancelLocalNotification:task.taskId];
//            }
        }
        if (b) {
            [NotificationCenter postNotificationName:Notify_Task_Save object:nil];
            [self updateSettingsUpdatedTime];
        }
        return b;
    }
}

+ (BOOL)cleanHasReadMessages {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return NO;
            }
        }
        
        NSString *account = @"";
        if ([LogIn isLogin]) {
            BmobUser *user = [BmobUser getCurrentUser];
            account = user.objectId;
        }
        
        NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM %@ WHERE hasRead=1 AND account=?", str_TableName_Messages];
        BOOL b = [__db executeUpdate:sqlString withArgumentsInArray:@[account]];
        
        FMDBQuickCheck(b, sqlString, __db);
        
        [NotificationCenter postNotificationName:Notify_Messages_Save object:nil];

        return b;
    }
}

+ (BOOL)hasUnreadMessages {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return NO ;
            }
        }
        
        NSString *account = @"";
        if ([LogIn isLogin]) {
            BmobUser *user = [BmobUser getCurrentUser];
            account = user.objectId;
        }

        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE account=? AND hasRead=0", str_TableName_Messages];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account]];
        
        BOOL b = NO;
        while ([rs next]) {
            
            b = YES;
            break;
        }
        [rs close];
        
        return b;
    }
}

+ (Settings *)getPersonalSettings {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return nil;
            }
        }

        Settings *settings = [[Settings alloc] init];
        if ([LogIn isLogin]) {
            BmobUser *user = [BmobUser getCurrentUser];
            settings.account = user.objectId;
        } else {
            settings.account = @"";
        }

        NSString *sqlString = [NSString stringWithFormat:@"SELECT objectId, nickname, birthday, email, gender, lifespan, avatar, avatarURL, centerTop, centerTopURL, isAutoSync, isUseGestureLock, isShowGestureTrack, gesturePasswod, createtime, updatetime, syntime FROM %@ WHERE account=?", str_TableName_Settings];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[settings.account]];
        while ([rs next]) {
            settings.objectId = [rs stringForColumn:@"objectId"];
            settings.nickname = [rs stringForColumn:@"nickname"];
            settings.birthday = [rs stringForColumn:@"birthday"];
            settings.email = [rs stringForColumn:@"email"];
            settings.gender = [rs stringForColumn:@"gender"];
            settings.lifespan = [rs stringForColumn:@"lifespan"];
            NSData *imageData = [rs dataForColumn:@"avatar"];
            if (imageData) {
                
                settings.avatar = [UIImage imageWithData:imageData];
            }
            settings.avatarURL = [rs stringForColumn:@"avatarURL"];
            imageData = [rs dataForColumn:@"centerTop"];
            if (imageData) {
                
                settings.centerTop = [UIImage imageWithData:imageData];
            }
            settings.centerTopURL = [rs stringForColumn:@"centerTopURL"];
            settings.isAutoSync = [rs stringForColumn:@"isAutoSync"];
            settings.isUseGestureLock = [rs stringForColumn:@"isUseGestureLock"];
            settings.isShowGestureTrack = [rs stringForColumn:@"isShowGestureTrack"];
            settings.gesturePasswod = [rs stringForColumn:@"gesturePasswod"];
            settings.createtime = [rs stringForColumn:@"createtime"];
            settings.updatetime = [rs stringForColumn:@"updatetime"];
            settings.syntime = [rs stringForColumn:@"syntime"];
            if (!settings.isAutoSync) {
                settings.isAutoSync = @"0";
            }
            if (!settings.isUseGestureLock) {
                settings.isUseGestureLock = @"0";
            }
            if (!settings.isShowGestureTrack) {
                settings.isShowGestureTrack = @"1";
            }
            
            if (!settings.objectId || settings.objectId.length ==0) {
                [self getUserSettingsObjectId];
            }
        }
        [rs close];
        
        return settings;
    }
}

+ (NSArray *)getPlanByPlantype:(NSString *)plantype startIndex:(NSInteger)startIndex {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return nil ;
            }
        }
        
        NSString *account = @"";
        if ([LogIn isLogin]) {
            BmobUser *user = [BmobUser getCurrentUser];
            account = user.objectId;
        }
        
        NSMutableArray *array = [NSMutableArray array];
        NSString *sqlString = [NSString stringWithFormat:@"SELECT planid, content, createtime, completetime, updatetime, iscompleted, isnotify, notifytime, plantype, isdeleted FROM %@ WHERE plantype=? AND account=? AND isdeleted=0 ORDER BY iscompleted, createtime DESC Limit ? Offset ?", str_TableName_Plan];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[plantype, account, @(kPlanLoadMax), @(startIndex)]];
        
        while ([rs next]) {
            
            Plan *plan = [[Plan alloc] init];
            plan.account = account;
            plan.planid = [rs stringForColumn:@"planid"];
            plan.content = [rs stringForColumn:@"content"];
            plan.createtime = [rs stringForColumn:@"createtime"];
            plan.completetime = [rs stringForColumn:@"completetime"];
            plan.updatetime = [rs stringForColumn:@"updatetime"];
            plan.iscompleted = [rs stringForColumn:@"iscompleted"];
            plan.isnotify = [rs stringForColumn:@"isnotify"];
            plan.notifytime = [rs stringForColumn:@"notifytime"];
            plan.plantype = [rs stringForColumn:@"plantype"];
            plan.isdeleted = [rs stringForColumn:@"isdeleted"];
            
            [array addObject:plan];
        }
        [rs close];
        
        return array;
    }
}

+ (NSArray *)getPhoto:(NSInteger)startIndex {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return nil ;
            }
        }
        
        NSString *account = @"";
        if ([LogIn isLogin]) {
            BmobUser *user = [BmobUser getCurrentUser];
            account = user.objectId;
        }
        
        NSMutableArray *array = [NSMutableArray array];
        NSString *sqlString = [NSString stringWithFormat:@"SELECT photoid, content, createtime, phototime, updatetime, location, photo1, photo2, photo3, photo4, photo5, photo6, photo7, photo8, photo9, photo1URL, photo2URL, photo3URL, photo4URL, photo5URL, photo6URL, photo7URL, photo8URL, photo9URL FROM %@ WHERE account=? AND isdeleted=0 ORDER BY phototime DESC, createtime DESC Limit ? Offset ?", str_TableName_Photo];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account, @(kPhotoLoadMax), @(startIndex)]];
        
        while ([rs next]) {
            
            Photo *photo = [[Photo alloc] init];
            photo.account = account;
            photo.photoid = [rs stringForColumn:@"photoid"];
            photo.content = [rs stringForColumn:@"content"];
            photo.createtime = [rs stringForColumn:@"createtime"];
            photo.phototime = [rs stringForColumn:@"phototime"];
            photo.updatetime = [rs stringForColumn:@"updatetime"];
            photo.location = [rs stringForColumn:@"location"];
            photo.photoURLArray = [NSMutableArray arrayWithCapacity:9];
            for (NSInteger n = 0; n < 9; n++) {
                NSString *url = [NSString stringWithFormat:@"photo%ldURL", (long)(n + 1)];
                if ([rs stringForColumn:url]) {
                    photo.photoURLArray[n] = [rs stringForColumn:url];
                } else {
                    photo.photoURLArray[n] = @"";
                }
                
            }
            photo.photoArray = [NSMutableArray arrayWithCapacity:9];
            for (NSInteger m = 0; m < 9; m++) {
                NSString *photoName = [NSString stringWithFormat:@"photo%ld", (long)(m + 1)];
                NSData *imageData = [rs dataForColumn:photoName];
                if (imageData) {
                    photo.photoArray[m] = [UIImage imageWithData:imageData];
                }
            }
            
            [array addObject:photo];
        }
        [rs close];
        
        return array;
    }
}

+ (Photo *)getPhotoById:(NSString *)photoid {
    @synchronized(__db) {
        
        Photo *photo = [[Photo alloc] init];
        
        if (!__db.open) {
            if (![__db open]) {
                return photo ;
            }
        }
        
        NSString *account = @"";
        if ([LogIn isLogin]) {
            BmobUser *user = [BmobUser getCurrentUser];
            account = user.objectId;
        }
        
        NSString *sqlString = [NSString stringWithFormat:@"SELECT photoid, content, createtime, phototime, updatetime, location, photo1, photo2, photo3, photo4, photo5, photo6, photo7, photo8, photo9, photo1URL, photo2URL, photo3URL, photo4URL, photo5URL, photo6URL, photo7URL, photo8URL, photo9URL FROM %@ WHERE account=? AND photoid=?", str_TableName_Photo];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account, photoid]];
        
        while ([rs next]) {
            
            photo.account = account;
            photo.photoid = [rs stringForColumn:@"photoid"];
            photo.content = [rs stringForColumn:@"content"];
            photo.createtime = [rs stringForColumn:@"createtime"];
            photo.phototime = [rs stringForColumn:@"phototime"];
            photo.updatetime = [rs stringForColumn:@"updatetime"];
            photo.location = [rs stringForColumn:@"location"];
            photo.isdeleted = @"0";
            photo.photoURLArray = [NSMutableArray arrayWithCapacity:9];
            for (NSInteger n = 0; n < 9; n++) {
                NSString *url = [NSString stringWithFormat:@"photo%ldURL", (long)(n + 1)];
                if ([rs stringForColumn:url]) {
                    photo.photoURLArray[n] = [rs stringForColumn:url];
                } else {
                    photo.photoURLArray[n] = @"";
                }
            }
            photo.photoArray = [NSMutableArray arrayWithCapacity:9];
            for (NSInteger i = 0; i < 9; i++) {
                NSString *photoName = [NSString stringWithFormat:@"photo%ld", (long)(i + 1)];
                NSData *imageData = [rs dataForColumn:photoName];
                if (imageData) {
                    photo.photoArray[i] = [UIImage imageWithData:imageData];
                }
            }
        }
        [rs close];
        
        return photo;
    }
}

+ (Statistics *)getStatistics {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return nil;
            }
        }
        
        Statistics *statistics = [[Statistics alloc] init];
        if ([LogIn isLogin]) {
            BmobUser *user = [BmobUser getCurrentUser];
            statistics.account = user.objectId;
        } else {
            statistics.account = @"";
        }
        
        NSString *sqlString = [NSString stringWithFormat:@"SELECT recentMax, recentMaxBeginDate, recentMaxEndDate, recordMax, recordMaxBeginDate, recordMaxEndDate, updatetime FROM %@ WHERE account=?", str_TableName_Statistics];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[statistics.account]];
        while ([rs next]) {
            
            statistics.recentMax = [rs stringForColumn:@"recentMax"];
            statistics.recentMaxBeginDate = [rs stringForColumn:@"recentMaxBeginDate"];
            statistics.recentMaxEndDate = [rs stringForColumn:@"recentMaxEndDate"];
            statistics.recordMax = [rs stringForColumn:@"recordMax"];
            statistics.recordMaxBeginDate = [rs stringForColumn:@"recordMaxBeginDate"];
            statistics.recordMaxEndDate = [rs stringForColumn:@"recordMaxEndDate"];
            statistics.updatetime = [rs stringForColumn:@"updatetime"];
        }
        [rs close];
        if (!statistics.recentMax) {
            statistics.recentMax = @"0";
        }
        if (!statistics.recordMax) {
            statistics.recordMax = @"0";
        }
        return statistics;
    }
}

+ (NSArray *)getTeask {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return nil ;
            }
        }
        
        NSString *account = @"";
        if ([LogIn isLogin]) {
            BmobUser *user = [BmobUser getCurrentUser];
            account = user.objectId;
        }

        NSMutableArray *array = [NSMutableArray array];
        NSString *sqlString = [NSString stringWithFormat:@"SELECT taskId, content, totalCount, completionDate, createTime, updateTime, isNotify, notifyTime FROM %@ WHERE account=? AND isDeleted=0 ORDER BY createTime DESC", str_TableName_Task];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account]];
        
        while ([rs next]) {
            
            Task *task = [[Task alloc] init];
            task.account = account;
            task.taskId = [rs stringForColumn:@"taskId"];
            task.content = [rs stringForColumn:@"content"];
            task.totalCount = [rs stringForColumn:@"totalCount"];
            task.completionDate = [rs stringForColumn:@"completionDate"];
            task.createTime = [rs stringForColumn:@"createTime"];
            task.updateTime = [rs stringForColumn:@"updateTime"];
            task.isNotify = [rs stringForColumn:@"isNotify"];
            task.notifyTime = [rs stringForColumn:@"notifyTime"];
            task.isDeleted = @"0";
            
            [array addObject:task];
        }
        [rs close];
        
        return array;
    }
}

+ (NSArray *)getTeaskRecord:(NSString *)recordId {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return nil ;
            }
        }
        
        NSMutableArray *array = [NSMutableArray array];
        NSString *sqlString = [NSString stringWithFormat:@"SELECT recordId, createTime FROM %@ WHERE recordId=? ORDER BY createTime DESC", str_TableName_TaskRecord];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[recordId]];
        
        while ([rs next]) {
            
            TaskRecord *taskRecord = [[TaskRecord alloc] init];
            taskRecord.recordId = recordId;
            taskRecord.createTime = [rs stringForColumn:@"createTime"];
            
            [array addObject:taskRecord];
        }
        [rs close];
        
        return array;
    }
}

+ (NSArray *)getMessages {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return nil ;
            }
        }
        
        NSString *account = @"";
        if ([LogIn isLogin]) {
            BmobUser *user = [BmobUser getCurrentUser];
            account = user.objectId;
        }
        
        NSMutableArray *array = [NSMutableArray array];
        NSString *sqlString = [NSString stringWithFormat:@"SELECT messageId, title, content, detailURL, imgURLArray, hasRead, canShare, createTime FROM %@ WHERE account=? ORDER BY createTime DESC", str_TableName_Messages];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account]];
        
        while ([rs next]) {
            
            Messages *message = [[Messages alloc] init];
            message.messageId = [rs stringForColumn:@"messageId"];
            message.title = [rs stringForColumn:@"title"];
            message.content = [rs stringForColumn:@"content"];
            message.detailURL = [rs stringForColumn:@"detailURL"];
            message.hasRead = [rs stringForColumn:@"hasRead"];
            message.canShare = [rs stringForColumn:@"canShare"];
            message.createTime = [rs stringForColumn:@"createTime"];
            NSData *imgURLArrayData = [rs dataForColumn:@"imgURLArray"];
            message.imgURLArray = [NSKeyedUnarchiver unarchiveObjectWithData:imgURLArrayData];
            
            [array addObject:message];
        }
        [rs close];
        
        return array;
    }
}

+ (NSString *)getPlanTotalCountByPlantype:(NSString *)plantype {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return nil ;
            }
        }
        
        NSString *account = @"";
        if ([LogIn isLogin]) {
            BmobUser *user = [BmobUser getCurrentUser];
            account = user.objectId;
        }
        
        NSString *total = @"0";
        NSString *sqlString = [NSString stringWithFormat:@"SELECT COUNT(*) as total FROM %@ WHERE plantype=? AND account=? AND isdeleted=0", str_TableName_Plan];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[plantype, account]];
        
        if([rs next]) {
            
            total = [rs stringForColumn:@"total"];
        }
        [rs close];
        
        return total;
    }
}

+ (NSString *)getPlanCompletedCountByPlantype:(NSString *)plantype {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return nil ;
            }
        }
        
        NSString *account = @"";
        if ([LogIn isLogin]) {
            BmobUser *user = [BmobUser getCurrentUser];
            account = user.objectId;
        }
        
        NSString *completed = @"0";
        NSString *sqlString = [NSString stringWithFormat:@"SELECT COUNT(*) as completed FROM %@ WHERE plantype=? AND account=? AND iscompleted=1 AND isdeleted=0", str_TableName_Plan];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[plantype, account]];
        
        if([rs next]) {
            
            completed = [rs stringForColumn:@"completed"];
        }
        [rs close];
        
        return completed;
    }
}

+ (NSString *)getPhotoTotalCount {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return nil ;
            }
        }
        
        NSString *account = @"";
        if ([LogIn isLogin]) {
            BmobUser *user = [BmobUser getCurrentUser];
            account = user.objectId;
        }
        
        NSString *total = @"0";
        NSString *sqlString = [NSString stringWithFormat:@"SELECT COUNT(*) as total FROM %@ WHERE account=? AND isdeleted=0", str_TableName_Photo];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account]];
        
        if([rs next]) {
            
            total = [rs stringForColumn:@"total"];
        }
        [rs close];
        
        return total;
    }
}

+ (NSString *)getTaskTotalCount {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return nil ;
            }
        }
        
        NSString *account = @"";
        if ([LogIn isLogin]) {
            BmobUser *user = [BmobUser getCurrentUser];
            account = user.objectId;
        }
        
        NSString *total = @"0";
        NSString *sqlString = [NSString stringWithFormat:@"SELECT COUNT(*) as total FROM %@ WHERE account=? AND isDeleted=0", str_TableName_Task];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account]];
        
        if([rs next]) {
            
            total = [rs stringForColumn:@"total"];
        }
        [rs close];
        
        return total;
    }
}

+ (void)addLocalNotification:(Plan *)plan {
    //时间格式：yyyy-MM-dd HH:mm
    NSDate *date = [CommonFunction NSStringDateToNSDate:plan.notifytime formatter:str_DateFormatter_yyyy_MM_dd_HHmm];
    
    if (!date) return;
    
    NSMutableDictionary *destDic = [NSMutableDictionary dictionary];
    [destDic setObject:plan.planid forKey:@"tag"];
    [destDic setObject:@([date timeIntervalSince1970]) forKey:@"time"];
    [destDic setObject:@(NotificationTypePlan) forKey:@"type"];
    [destDic setObject:plan.createtime forKey:@"createtime"];
    [destDic setObject:plan.plantype forKey:@"plantype"];
    [destDic setObject:plan.iscompleted forKey:@"iscompleted"];
    [destDic setObject:plan.completetime forKey:@"completetime"];
    [destDic setObject:plan.content forKey:@"content"];
    [destDic setObject:plan.notifytime forKey:@"notifytime"];
    [LocalNotificationManager createLocalNotification:date userInfo:destDic alertBody:plan.content];
}

+ (void)updateLocalNotification:(Plan *)plan {
    //首先取消该计划的本地所有通知
    [self cancelLocalNotification:plan.planid];
    //重新添加新的通知
    [self addLocalNotification:plan];
}

+ (void)cancelLocalNotification:(NSString*)planid {
    //取消该计划的本地所有通知
    NSArray *array = [LocalNotificationManager getNotificationWithTag:planid type:NotificationTypePlan];
    for (UILocalNotification *item in array) {
        [LocalNotificationManager cancelNotification:item];
    }
}

+ (void)setFiveDayNotification {
    
    BOOL hasFiveDayNotification = NO;
    
    NSArray *arry = [LocalNotificationManager getAllLocalNotification];
    //查询是否已经添加过5天未新建计划的提醒
    for (UILocalNotification *item in arry) {
        NSDictionary *sourceN = item.userInfo;
        NSString *tag = [sourceN objectForKey:@"tag"];
        if ([tag longLongValue] == [Notify_FiveDay_Tag longLongValue]) {
            
            hasFiveDayNotification = YES;
            break;
        }
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:str_DateFormatter_yyyy_MM_dd_HHmm];
    NSString *fiveDayLater = [dateFormatter stringFromDate:[[NSDate date] dateByAddingTimeInterval:5 * 24 * 3600]];
    
    Plan *fiveDayPlan = [[Plan alloc] init];
    fiveDayPlan.planid = Notify_FiveDay_Tag;
    fiveDayPlan.createtime = Notify_FiveDay_Time;
    fiveDayPlan.plantype = @"2";
    fiveDayPlan.iscompleted = @"0";
    fiveDayPlan.completetime = Notify_FiveDay_Time;
    fiveDayPlan.content = str_Notify_Tips2;
    fiveDayPlan.notifytime = fiveDayLater;
    
    if (hasFiveDayNotification) {//更新提醒时间
        
        [self updateLocalNotification:fiveDayPlan];
    } else {//新建提醒
        
        [self addLocalNotification:fiveDayPlan];
    }
}

+ (void)linkedLocalDataToAccount {
    
    BmobUser *user = [BmobUser getCurrentUser];
    if (!user) return;
    
    [Config shareInstance].settings = [PlanCache getPersonalSettings];
    if (![Config shareInstance].settings.createtime) {
        
        BmobQuery *bquery = [BmobQuery queryWithClassName:@"UserSettings"];
        [bquery whereKey:@"userObjectId" equalTo:user.objectId];
        [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            if (array.count > 0) {
                BmobObject *obj = array[0];
                [DataCenter syncServerToLocalForSettings:obj];
            } else {
                /*
                 *说明：只要在本地没有已登录账号的设置数据时才关联
                 *     如果本地已经有已登录账号的设置数据，则不关联
                 *     防止同一个账号在本地有两份设置数据
                 */
                //设置
                NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE account=?", str_TableName_Settings];
                FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[@""]];
                BOOL hasRec = [rs next];
                [rs close];
                if (hasRec) {
                    
                    NSString *sqlString = [NSString stringWithFormat:@"UPDATE %@ SET account=? WHERE account=?", str_TableName_Settings];
                    
                    BOOL b = [__db executeUpdate:sqlString withArgumentsInArray:@[user.objectId, @""]];
                    
                    FMDBQuickCheck(b, sqlString, __db);
                }
                [NotificationCenter postNotificationName:Notify_Settings_Save object:nil];
                //同时自动将本地设置同步到服务器
                [DataCenter addSettingsToServer];
            }
        }];
    }
    
    //计划
    BOOL hasRec = NO;
    NSString *sqlString = [NSString stringWithFormat:@"SELECT planid FROM %@ WHERE account=?", str_TableName_Plan];
    FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[@""]];
    hasRec = [rs next];
    [rs close];
    if (hasRec) {
        
        sqlString = [NSString stringWithFormat:@"UPDATE %@ SET account=? WHERE account=?", str_TableName_Plan];
        
        BOOL b = [__db executeUpdate:sqlString withArgumentsInArray:@[user.objectId, @""]];
        
        FMDBQuickCheck(b, sqlString, __db);
    }
    [NotificationCenter postNotificationName:Notify_Plan_Save object:nil];
    //影像
    hasRec = NO;
    sqlString = [NSString stringWithFormat:@"SELECT photoid FROM %@ WHERE account=?", str_TableName_Photo];
    rs = [__db executeQuery:sqlString withArgumentsInArray:@[@""]];
    hasRec = [rs next];
    [rs close];
    if (hasRec) {
        
        sqlString = [NSString stringWithFormat:@"UPDATE %@ SET account=? WHERE account=?", str_TableName_Photo];
        
        BOOL b = [__db executeUpdate:sqlString withArgumentsInArray:@[user.objectId, @""]];
        
        FMDBQuickCheck(b, sqlString, __db);
    }
    [NotificationCenter postNotificationName:Notify_Photo_Save object:nil];
    //任务
    hasRec = NO;
    sqlString = [NSString stringWithFormat:@"SELECT taskId FROM %@ WHERE account=?", str_TableName_Task];
    rs = [__db executeQuery:sqlString withArgumentsInArray:@[@""]];
    hasRec = [rs next];
    [rs close];
    if (hasRec) {
        
        sqlString = [NSString stringWithFormat:@"UPDATE %@ SET account=? WHERE account=?", str_TableName_Task];
        
        BOOL b = [__db executeUpdate:sqlString withArgumentsInArray:@[user.objectId, @""]];
        
        FMDBQuickCheck(b, sqlString, __db);
    }
    [NotificationCenter postNotificationName:Notify_Task_Save object:nil];
}

+ (NSArray *)getPlanForSync:(NSString *)syntime {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return nil ;
            }
        }
        
        NSMutableArray *array = [NSMutableArray array];
        
        NSString *account = @"";
        if ([LogIn isLogin]) {
            BmobUser *user = [BmobUser getCurrentUser];
            account = user.objectId;
        } else {
            return array;
        }
        
        NSString *sqlString = @"";
        if (syntime) {
            sqlString = [NSString stringWithFormat:@"SELECT planid, content, createtime, completetime, updatetime, iscompleted, isnotify, notifytime, plantype, isdeleted FROM %@ WHERE account=? AND updatetime >=?", str_TableName_Plan];
        } else {
            sqlString = [NSString stringWithFormat:@"SELECT planid, content, createtime, completetime, updatetime, iscompleted, isnotify, notifytime, plantype, isdeleted FROM %@ WHERE account=?", str_TableName_Plan];
        }
        
        FMResultSet *rs = syntime == nil ? [__db executeQuery:sqlString withArgumentsInArray:@[account]] : [__db executeQuery:sqlString withArgumentsInArray:@[account, syntime]];
        
        while ([rs next]) {
            
            Plan *plan = [[Plan alloc] init];
            plan.account = account;
            plan.planid = [rs stringForColumn:@"planid"];
            plan.content = [rs stringForColumn:@"content"];
            plan.createtime = [rs stringForColumn:@"createtime"];
            plan.completetime = [rs stringForColumn:@"completetime"] ? [rs stringForColumn:@"completetime"] : @"";
            plan.updatetime = [rs stringForColumn:@"updatetime"] ? [rs stringForColumn:@"updatetime"] : [rs stringForColumn:@"createtime"];
            plan.iscompleted = [rs stringForColumn:@"iscompleted"] ? [rs stringForColumn:@"iscompleted"] : @"0";
            plan.isnotify = [rs stringForColumn:@"isnotify"] ? [rs stringForColumn:@"isnotify"] : @"0";
            plan.notifytime = [rs stringForColumn:@"notifytime"] ? [rs stringForColumn:@"notifytime"] : @"";
            plan.plantype = [rs stringForColumn:@"plantype"];
            plan.isdeleted = [rs stringForColumn:@"isdeleted"];
            
            [array addObject:plan];
        }
        [rs close];
        
        return array;
    }
}

+ (Plan *)findPlan:(NSString *)account planid:(NSString *)planid {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return nil ;
            }
        }
        
        NSString *sqlString = [NSString stringWithFormat:@"SELECT planid, content, createtime, completetime, updatetime, iscompleted, isnotify, notifytime, plantype, isdeleted FROM %@ WHERE account=? AND planid =?", str_TableName_Plan];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account, planid]];
        
        Plan *plan = [[Plan alloc] init];
        while ([rs next]) {
            
            plan.account = account;
            plan.planid = [rs stringForColumn:@"planid"];
            plan.content = [rs stringForColumn:@"content"];
            plan.createtime = [rs stringForColumn:@"createtime"];
            plan.completetime = [rs stringForColumn:@"completetime"];
            plan.updatetime = [rs stringForColumn:@"updatetime"];
            plan.iscompleted = [rs stringForColumn:@"iscompleted"];
            plan.isnotify = [rs stringForColumn:@"isnotify"];
            plan.notifytime = [rs stringForColumn:@"notifytime"];
            plan.plantype = [rs stringForColumn:@"plantype"];
            plan.isdeleted = [rs stringForColumn:@"isdeleted"];
            
        }
        [rs close];
        
        return plan;
    }
}

+ (NSArray *)getPhotoForSync:(NSString *)syntime {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return nil ;
            }
        }
        
        NSMutableArray *array = [NSMutableArray array];
        
        NSString *account = @"";
        if ([LogIn isLogin]) {
            BmobUser *user = [BmobUser getCurrentUser];
            account = user.objectId;
        } else {
            return array;
        }
        
        NSString *sqlString = @"";
        if (syntime) {
            sqlString = [NSString stringWithFormat:@"SELECT photoid, content, createtime, phototime, updatetime, location, photo1, photo2, photo3, photo4, photo5, photo6, photo7, photo8, photo9, photo1URL, photo2URL, photo3URL, photo4URL, photo5URL, photo6URL, photo7URL, photo8URL, photo9URL, isdeleted FROM %@ WHERE account=? AND updatetime >=?", str_TableName_Photo];
        } else {
            sqlString = [NSString stringWithFormat:@"SELECT photoid, content, createtime, phototime, updatetime, location, photo1, photo2, photo3, photo4, photo5, photo6, photo7, photo8, photo9, photo1URL, photo2URL, photo3URL, photo4URL, photo5URL, photo6URL, photo7URL, photo8URL, photo9URL, isdeleted FROM %@ WHERE account=?", str_TableName_Photo];
        }
        
        FMResultSet *rs = syntime == nil ? [__db executeQuery:sqlString withArgumentsInArray:@[account]] : [__db executeQuery:sqlString withArgumentsInArray:@[account, syntime]];
        
        while ([rs next]) {
            Photo *photo = [[Photo alloc] init];
            photo.account = account;
            photo.photoid = [rs stringForColumn:@"photoid"];
            photo.content = [rs stringForColumn:@"content"];
            photo.createtime = [rs stringForColumn:@"createtime"];
            photo.phototime = [rs stringForColumn:@"phototime"];
            photo.updatetime = [rs stringForColumn:@"updatetime"];
            photo.location = [rs stringForColumn:@"location"];
            photo.isdeleted = [rs stringForColumn:@"isdeleted"];
            photo.photoURLArray = [NSMutableArray arrayWithCapacity:9];
            for (NSInteger n = 0; n < 9; n++) {
                NSString *url = [NSString stringWithFormat:@"photo%ldURL", (long)(n + 1)];
                if ([rs stringForColumn:url]) {
                    photo.photoURLArray[n] = [rs stringForColumn:url];
                } else {
                    photo.photoURLArray[n] = @"";
                }
            }
            photo.photoArray = [NSMutableArray arrayWithCapacity:9];
            for (NSInteger m = 0; m < 9; m++) {
                NSString *photoName = [NSString stringWithFormat:@"photo%ld", (long)(m + 1)];
                NSData *imageData = [rs dataForColumn:photoName];
                if (imageData) {
                    photo.photoArray[m] = [UIImage imageWithData:imageData];
                }
            }
            if (!photo.content) {
                photo.content = @"";
            }
            if (!photo.location) {
                photo.location = @"";
            }
            [array addObject:photo];
        }
        [rs close];
        
        return array;
    }
}

//time : yyyy-MM-dd HH:mm:ss
+ (NSArray *)getPlanDateForStatisticsByTime:(NSString *)time {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return nil ;
            }
        }
        
        NSString *account = @"";
        if ([LogIn isLogin]) {
            BmobUser *user = [BmobUser getCurrentUser];
            account = user.objectId;
        }
        
        NSMutableArray *array = [NSMutableArray array];
        NSString *sqlString = @"";
        FMResultSet *rs;
        if (time) {
            
            sqlString = [NSString stringWithFormat:@"SELECT createtime FROM %@ WHERE account=? AND createtime >? ORDER BY createtime", str_TableName_Plan];
            rs = [__db executeQuery:sqlString withArgumentsInArray:@[account, time]];
            
        } else {
            
            sqlString = [NSString stringWithFormat:@"SELECT createtime FROM %@ WHERE account=? ORDER BY createtime", str_TableName_Plan];
            rs = [__db executeQuery:sqlString withArgumentsInArray:@[account]];
        }

        while ([rs next]) {

            NSString *time = [rs stringForColumn:@"createtime"];
            NSString *date = [[time componentsSeparatedByString:@" "] objectAtIndex:0];
            if (![array containsObject:date]) {
                [array addObject:date];
            }
        }
        [rs close];
        
        return array;
    }
    
}

+ (NSArray *)getTaskForSync:(NSString *)syntime {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return nil ;
            }
        }
        
        NSString *account = @"";
        if ([LogIn isLogin]) {
            BmobUser *user = [BmobUser getCurrentUser];
            account = user.objectId;
        }
        
        NSMutableArray *array = [NSMutableArray array];
        
        NSString *sqlString = @"";
        if (syntime) {
            sqlString = [NSString stringWithFormat:@"SELECT taskId, content, totalCount, completionDate, createTime, updateTime, isNotify, notifyTime, isDeleted FROM %@ WHERE account=? AND updatetime >=?", str_TableName_Task];
        } else {
            sqlString = [NSString stringWithFormat:@"SELECT taskId, content, totalCount, completionDate, createTime, updateTime, isNotify, notifyTime, isDeleted FROM %@ WHERE account=?", str_TableName_Task];
        }
        
        FMResultSet *rs = syntime == nil ? [__db executeQuery:sqlString withArgumentsInArray:@[account]] : [__db executeQuery:sqlString withArgumentsInArray:@[account, syntime]];

        while ([rs next]) {
            
            Task *task = [[Task alloc] init];
            task.account = account;
            task.taskId = [rs stringForColumn:@"taskId"];
            task.content = [rs stringForColumn:@"content"];
            task.totalCount = [rs stringForColumn:@"totalCount"];
            task.completionDate = [rs stringForColumn:@"completionDate"];
            task.createTime = [rs stringForColumn:@"createTime"];
            task.updateTime = [rs stringForColumn:@"updateTime"];
            task.isNotify = [rs stringForColumn:@"isNotify"];
            task.notifyTime = [rs stringForColumn:@"notifyTime"];
            task.isDeleted = [rs stringForColumn:@"isDeleted"];
            if (!task.completionDate) {
                task.completionDate = @"";
            }
            if (!task.isNotify) {
                task.isNotify = @"";
            }
            if (!task.notifyTime) {
                task.notifyTime = @"";
            }
            [array addObject:task];
        }
        [rs close];
        
        return array;
    }
}

+ (NSArray *)getTeaskRecordForSyncByTaskId:(NSString *)taskId syntime:(NSString *)syntime {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return nil ;
            }
        }
        
        NSMutableArray *array = [NSMutableArray array];
        
        NSString *sqlString = @"";
        if (syntime) {
            sqlString = [NSString stringWithFormat:@"SELECT recordId, createTime FROM %@ WHERE recordId=? AND createTime >=?", str_TableName_TaskRecord];
        } else {
            sqlString = [NSString stringWithFormat:@"SELECT recordId, createTime FROM %@ WHERE recordId=?", str_TableName_TaskRecord];
        }
        
        FMResultSet *rs = syntime == nil ? [__db executeQuery:sqlString withArgumentsInArray:@[taskId]] : [__db executeQuery:sqlString withArgumentsInArray:@[taskId, syntime]];
        
        while ([rs next]) {
            
            TaskRecord *taskRecord = [[TaskRecord alloc] init];
            taskRecord.recordId = taskId;
            taskRecord.createTime = [rs stringForColumn:@"createTime"];
            
            [array addObject:taskRecord];
        }
        [rs close];
        
        return array;
    }
}

+ (Task *)findTask:(NSString *)account taskId:(NSString *)taskId {
    @synchronized(__db) {
        
        if (!__db.open) {
            if (![__db open]) {
                return nil ;
            }
        }
        
        NSString *sqlString = [NSString stringWithFormat:@"SELECT taskId, content, totalCount, completionDate, createTime, updateTime, isNotify, notifyTime, isDeleted FROM %@ WHERE account=? AND taskId =?", str_TableName_Task];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account, taskId]];
        
        Task *task = [[Task alloc] init];
        while ([rs next]) {
            task.account = account;
            task.taskId = taskId;
            task.content = [rs stringForColumn:@"content"];
            task.totalCount = [rs stringForColumn:@"totalCount"];
            task.completionDate = [rs stringForColumn:@"completionDate"];
            task.createTime = [rs stringForColumn:@"createTime"];
            task.updateTime = [rs stringForColumn:@"updateTime"];
            task.isNotify = [rs stringForColumn:@"isNotify"];
            task.notifyTime = [rs stringForColumn:@"notifyTime"];
            task.isDeleted = [rs stringForColumn:@"isDeleted"];
            if (!task.completionDate) {
                task.completionDate = @"";
            }
            if (!task.isNotify) {
                task.isNotify = @"";
            }
            if (!task.notifyTime) {
                task.notifyTime = @"";
            }
        }
        [rs close];
        
        return task;
    }
}

+ (void)getUserSettingsObjectId {
    BmobUser *user = [BmobUser getCurrentUser];
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"UserSettings"];
    [bquery whereKey:@"userObjectId" equalTo:user.objectId];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {

        if (!error && array.count == 1) {
            BmobObject *settings = array[0];
            [Config shareInstance].settings.objectId = settings.objectId;
            [PlanCache storePersonalSettings:[Config shareInstance].settings];
        }
    }];
}

@end
