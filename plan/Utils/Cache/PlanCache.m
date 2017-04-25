//
//  PlanCache.m
//  plan
//
//  Created by Fengzy on 15/8/29.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "LogIn.h"
#import "PlanCache.h"
#import "FMDatabase.h"
#import "DataCenter.h"
#import "TaskStatistics.h"
#import "FMDatabasePool.h"
#import "FMDatabaseQueue.h"
#import <BmobSDK/BmobQuery.h>
#import <BmobSDK/BmobUser.h>
#import "FMDatabaseAdditions.h"
#import "LocalNotificationManager.h"

#define FMDBQuickCheck(SomeBool, Title, Db) {\
if (!(SomeBool)) { \
NSLog(@"Failure on line %d, %@ error(%d): %@", __LINE__, Title, [Db lastErrorCode], [Db lastErrorMessage]);\
}}


NSString *dbFilePath(NSString *filename) {
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES);
    NSString *documentDirectory = [documentPaths objectAtIndex:0];
    NSString *pathName = [documentDirectory stringByAppendingPathComponent:@"cache"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:pathName])
        [fileManager createDirectoryAtPath:pathName withIntermediateDirectories:YES attributes:nil error:nil];
    pathName = [pathName stringByAppendingPathComponent:filename];
    return pathName;
};

NSData *encodePwd(NSString *pwd) {
    NSData *data = [pwd dataUsingEncoding:NSUTF8StringEncoding];
    return data;
};

NSString *decodePwd(NSData *data) {
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
};


@implementation PlanCache

static FMDatabase *__db;
static NSString *__currentPath;
static NSString *__currentPlistPath;
static NSString *__offlineMsgPlistPath;
static NSMutableDictionary *__contactsOnlineState;

+ (void)initialize
{
    NSLog(@"Is SQLite compiled with it's thread safe options turned on? %@!", [FMDatabase isSQLiteThreadSafe] ? @"Yes" : @"No");
}

#pragma mark -重置当前用户本地数据库链接
+ (void)resetCurrentLogin
{
    [__db close];
    __db = nil;
    
    if (__currentPath)
    {
        __currentPath = nil;
    }
    
    if (__currentPlistPath)
    {
        __currentPlistPath = nil;
    }
    
    if (__offlineMsgPlistPath)
    {
        __offlineMsgPlistPath = nil;
    }
}

#pragma mark -打开当前用户本地数据库链接
+ (void)openDBWithAccount:(NSString *)account
{
    
    [PlanCache resetCurrentLogin];
    
    if (!account)
        return;
    
    NSString *fileName = dbFilePath([NSString stringWithFormat:@"data_%@.db", account]);
    
    __currentPath = [fileName copy];
    __db = [FMDatabase databaseWithPath:fileName];
    
    if (![__db open])
    {
        NSLog(@"Could not open db:%@", fileName);
        __db = nil;
        return;
    }
    
    [__db setShouldCacheStatements:YES];
    
    // 个人设置
    if (![__db tableExists:STRTableName1])
    {
        NSString *sqlString = [NSString stringWithFormat:@"CREATE TABLE %@ (objectId TEXT, account TEXT, nickname TEXT, birthday TEXT, email TEXT, gender TEXT, lifespan TEXT, syntime TEXT, avatar BLOB, avatarURL TEXT, centerTop BLOB, centerTopURL TEXT, isAutoSync TEXT, isUseGestureLock TEXT, isShowGestureTrack TEXT, gesturePasswod TEXT, updatetime TEXT, createtime TEXT, countdownType TEXT, dayOrMonth TEXT, autoDelayUndonePlan TEXT, signature TEXT)", STRTableName1];
        
        BOOL b = [__db executeUpdate:sqlString];
        
        FMDBQuickCheck(b, sqlString, __db);
    }
    else
    {//新增字段
        //新增未完计划设置字段2016-06-30
//        NSString *autoDelayUndonePlan = @"autoDelayUndonePlan";
//        if (![__db columnExists:autoDelayUndonePlan inTableWithName:str_TableName_Settings]) {
//            
//            NSString *sqlString = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",str_TableName_Settings, autoDelayUndonePlan];
//            
//            BOOL b = [__db executeUpdate:sqlString];
//            
//            FMDBQuickCheck(b, sqlString, __db);
//        }
    }
    
    // 计划
    if (![__db tableExists:STRTableName2])
    {
        NSString *sqlString = [NSString stringWithFormat:@"CREATE TABLE %@ (account TEXT, planid TEXT, content TEXT, createtime TEXT, completetime TEXT, updatetime TEXT, iscompleted TEXT, isnotify TEXT, notifytime TEXT, beginDate TEXT, isdeleted TEXT)", STRTableName2];
        
        BOOL b = [__db executeUpdate:sqlString];
        
        FMDBQuickCheck(b, sqlString, __db);
    }
    else
    { //新增字段
        //新增每日重复字段2017-1-12
        NSString *isRepeat = @"isRepeat";
        if (![__db columnExists:isRepeat inTableWithName:STRTableName2])
        {
            NSString *sqlString = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",STRTableName2, isRepeat];
            
            BOOL b = [__db executeUpdate:sqlString];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        //新增备注字段2017-1-12
        NSString *remark = @"remark";
        if (![__db columnExists:remark inTableWithName:STRTableName2])
        {
            NSString *sqlString = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",STRTableName2, remark];
            
            BOOL b = [__db executeUpdate:sqlString];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
    }
    
    //相册
    if (![__db tableExists:STRTableName3])
    {
        NSString *sqlString = [NSString stringWithFormat:@"CREATE TABLE %@ (account TEXT, photoid TEXT, content TEXT, createtime TEXT, phototime TEXT, updatetime TEXT, location TEXT, photo1 BLOB, photo2 BLOB, photo3 BLOB, photo4 BLOB, photo5 BLOB, photo6 BLOB, photo7 BLOB, photo8 BLOB, photo9 BLOB, photo1URL TEXT, photo2URL TEXT, photo3URL TEXT, photo4URL TEXT, photo5URL TEXT, photo6URL TEXT, photo7URL TEXT, photo8URL TEXT, photo9URL TEXT, isdeleted TEXT)", STRTableName3];
        
        BOOL b = [__db executeUpdate:sqlString];
        
        FMDBQuickCheck(b, sqlString, __db);
    }
    else
    { //新增字段
 
    }
    
    //统计
    if (![__db tableExists:STRTableName4])
    {
        NSString *sqlString = [NSString stringWithFormat:@"CREATE TABLE %@ (account TEXT, recentMax TEXT, recentMaxBeginDate TEXT, recentMaxEndDate TEXT, recordMax TEXT, recordMaxBeginDate TEXT, recordMaxEndDate TEXT, updatetime TEXT)", STRTableName4];
        
        BOOL b = [__db executeUpdate:sqlString];
        
        FMDBQuickCheck(b, sqlString, __db);
    }
    else
    { //新增字段

    }
    
    //任务
    if (![__db tableExists:STRTableName5])
    {
        NSString *sqlString = [NSString stringWithFormat:@"CREATE TABLE %@ (account TEXT, taskId TEXT, content TEXT, totalCount TEXT, completionDate TEXT, createTime TEXT, updateTime TEXT, isNotify TEXT, notifyTime TEXT, isTomato TEXT, tomatoMinute TEXT, isRepeat TEXT, repeatType TEXT, taskOrder TEXT, isDeleted TEXT)", STRTableName5];
        
        BOOL b = [__db executeUpdate:sqlString];
        
        FMDBQuickCheck(b, sqlString, __db);
    }
    else
    { //新增字段
        
    }

    //任务记录
    if (![__db tableExists:STRTableName6])
    {
        NSString *sqlString = [NSString stringWithFormat:@"CREATE TABLE %@ (recordId TEXT, createTime TEXT)", STRTableName6];
        
        BOOL b = [__db executeUpdate:sqlString];
        
        FMDBQuickCheck(b, sqlString, __db);
    }
    
    //系统消息
    if (![__db tableExists:STRTableName7])
    {
        NSString *sqlString = [NSString stringWithFormat:@"CREATE TABLE %@ (account TEXT, messageId TEXT, title TEXT, content TEXT, detailURL TEXT, imgURLArray BLOB, hasRead TEXT, canShare TEXT, messageType TEXT, createTime TEXT)", STRTableName7];
        
        BOOL b = [__db executeUpdate:sqlString];
        
        FMDBQuickCheck(b, sqlString, __db);
    }
    else
    {
        
    }
}

+ (void)storePersonalSettings:(Settings *)settings isNotify:(BOOL)isNotify
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return ;
        }
        
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            settings.account = user.objectId;
        }
        else
        {
            settings.account = @"";
        }
        if (!settings.objectId)
        {
            settings.objectId = @"";
        }
        if (!settings.nickname)
        {
            settings.nickname = @"";
        }
        if (!settings.birthday)
        {
            settings.birthday = @"";
        }
        if (!settings.email)
        {
            settings.email = @"";
        }
        if (!settings.gender) {
            settings.gender = @"0";
        }
        if (!settings.lifespan)
        {
            settings.lifespan = @"";
        }
        if (!settings.password)
        {
            settings.password = @"";
        }
        if (!settings.avatar)
        {
            settings.avatar = [NSData data];
        }
        if (!settings.avatarURL)
        {
            settings.avatarURL = @"";
        }
        if (!settings.centerTop)
        {
            settings.centerTop = [NSData data];
        }
        if (!settings.centerTopURL)
        {
            settings.centerTopURL = @"";
        }
        if (!settings.isAutoSync)
        {
            settings.isAutoSync = @"0";
        }
        if (!settings.isUseGestureLock)
        {
            settings.isUseGestureLock = @"0";
        }
        if (!settings.isShowGestureTrack)
        {
            settings.isShowGestureTrack = @"1";
        }
        if (!settings.gesturePasswod)
        {
            settings.gesturePasswod = @"";
        }
        if (!settings.countdownType)
        {
            settings.countdownType = @"0";
        }
        if (!settings.dayOrMonth)
        {
            settings.dayOrMonth = @"0";
        }
        if (!settings.autoDelayUndonePlan)
        {
            settings.autoDelayUndonePlan = @"0";
        }
        if (!settings.signature)
        {
            settings.signature = @"";
        }
        if (!settings.syntime || settings.syntime.length == 0)
        {
            settings.syntime = @"2015-09-01 09:09:09";
        }
        NSString *timeNow = [CommonFunction getTimeNowString];
        if (!settings.createtime || settings.createtime.length == 0)
        {
            settings.createtime = timeNow;
        }
        settings.updatetime = timeNow;

        BOOL hasRec = NO;
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE account=?", STRTableName1];
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[settings.account]];
        hasRec = [rs next];
        [rs close];
        if (hasRec)
        {
            sqlString = [NSString stringWithFormat:@"UPDATE %@ SET objectId=?, nickname=?, birthday=?, email=?, gender=?, lifespan=?, avatar=?, avatarURL=?, centerTop=?, centerTopURL=?, isAutoSync=?, isUseGestureLock=?, isShowGestureTrack=?, gesturePasswod=?, createtime=?, updatetime=?, syntime=?, countdownType=?, dayOrMonth=?, autoDelayUndonePlan=?, signature=?  WHERE account=?", STRTableName1];
            
            BOOL b = [__db executeUpdate:sqlString withArgumentsInArray:@[settings.objectId, settings.nickname, settings.birthday, settings.email, settings.gender, settings.lifespan, settings.avatar, settings.avatarURL, settings.centerTop, settings.centerTopURL, settings.isAutoSync, settings.isUseGestureLock, settings.isShowGestureTrack, settings.gesturePasswod, settings.createtime, settings.updatetime, settings.syntime, settings.countdownType, settings.dayOrMonth, settings.autoDelayUndonePlan, settings.signature, settings.account]];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        else
        {
            sqlString = [NSString stringWithFormat:@"INSERT INTO %@(objectId, account, nickname, birthday, email, gender, lifespan, avatar, avatarURL, centerTop, centerTopURL, isAutoSync, isUseGestureLock, isShowGestureTrack, gesturePasswod, createtime, updatetime, syntime, countdownType, dayOrMonth, autoDelayUndonePlan, signature) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", STRTableName1];
            
            BOOL b = [__db executeUpdate:sqlString withArgumentsInArray:@[settings.objectId, settings.account, settings.nickname, settings.birthday, settings.email, settings.gender, settings.lifespan, settings.avatar, settings.avatarURL, settings.centerTop, settings.centerTopURL, settings.isAutoSync, settings.isUseGestureLock, settings.isShowGestureTrack, settings.gesturePasswod, settings.createtime, settings.updatetime, settings.syntime, settings.countdownType, settings.dayOrMonth, settings.autoDelayUndonePlan, settings.signature]];

            FMDBQuickCheck(b, sqlString, __db);
        }
        
        if (isNotify)
        {
            [NotificationCenter postNotificationName:NTFSettingsSave object:nil];
            [NotificationCenter postNotificationName:NTFPhotoRefreshOnly object:nil];
        }
    }
}

+ (BOOL)storePlan:(Plan *)plan
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return NO;
        }
        
        if (!plan.planid || !plan.content || !plan.createtime)
        {
            return NO;
        }
        
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            plan.account = user.objectId;
        }
        else
        {
            plan.account = @"";
        }
        if (!plan.completetime)
        {
            plan.completetime = @"";
        }
        if (!plan.updatetime)
        {
            plan.updatetime = plan.createtime;
        }
        if (!plan.iscompleted)
        {
            plan.iscompleted = @"0";
        }
        if (!plan.beginDate)
        {
            plan.beginDate = [[plan.createtime componentsSeparatedByString:@" "] objectAtIndex:0];
        }
        if (!plan.notifytime)
        {
            plan.notifytime = @"";
        }
        if (!plan.isdeleted)
        {
            plan.isdeleted = @"0";
        }
        if (!plan.isRepeat)
        {
            plan.isRepeat = @"0";
        }
        if (!plan.remark)
        {
            plan.remark = @"";
        }
        
        BOOL hasRec = NO;
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE planid=? AND account=?", STRTableName2];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[plan.planid, plan.account]];
        hasRec = [rs next];
        [rs close];
        BOOL b = NO;
        if (hasRec)
        {
            sqlString = [NSString stringWithFormat:@"UPDATE %@ SET content=?, createtime=?, completetime=?, updatetime=?, iscompleted=?, isnotify=?, notifytime=?, beginDate=?, isdeleted=?, isRepeat=?, remark=? WHERE planid=? AND account=?", STRTableName2];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[plan.content, plan.createtime, plan.completetime, plan.updatetime, plan.iscompleted, plan.isnotify, plan.notifytime, plan.beginDate, plan.isdeleted, plan.isRepeat, plan.remark, plan.planid, plan.account]];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        else
        {
            sqlString = [NSString stringWithFormat:@"INSERT INTO %@(account, planid, content, createtime, completetime, updatetime, iscompleted, isnotify, notifytime, beginDate, isdeleted, isRepeat) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", STRTableName2];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[plan.account, plan.planid, plan.content, plan.createtime, plan.completetime, plan.updatetime, plan.iscompleted, plan.isnotify, plan.notifytime, plan.beginDate, plan.isdeleted, plan.isRepeat]];
            
            FMDBQuickCheck(b, sqlString, __db);

            //更新5天没有新建计划的提醒时间
            [self setFiveDayNotification];
        }
        if (b)
        {
            NSString *flag = [UserDefaults objectForKey:STRBeginDateFlag];
            if (!flag || ![flag isEqualToString:@"1"])
            {

            }
            else
            {
                [NotificationCenter postNotificationName:NTFPlanSave object:nil];
            }
        }
        return b;
    }
}

+ (BOOL)updatePlanState:(Plan *)plan
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return NO;
        }
        
        if (!plan.planid)
            return NO;
        
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            plan.account = user.objectId;
        }
        else
        {
            plan.account = @"";
        }
        if (!plan.completetime)
        {
            plan.completetime = @"";
        }
        if (!plan.updatetime)
        {
            plan.updatetime = plan.createtime;
        }
        if (!plan.iscompleted)
        {
            plan.iscompleted = @"0";
        }
        if (!plan.isRepeat)
        {
            plan.isRepeat = @"0";
        }
        if (!plan.remark)
        {
            plan.remark = @"";
        }
        
        BOOL hasRec = NO;
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE planid=? AND account=?", STRTableName2];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[plan.planid, plan.account]];
        hasRec = [rs next];
        [rs close];
        BOOL b = NO;
        if (hasRec)
        {
            sqlString = [NSString stringWithFormat:@"UPDATE %@ SET beginDate=?, completetime=?, updatetime=?, iscompleted=?, isRepeat=?, remark=? WHERE planid=? AND account=?", STRTableName2];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[plan.beginDate, plan.completetime, plan.updatetime, plan.iscompleted, plan.isRepeat, plan.remark, plan.planid, plan.account]];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        if (b)
        {
            [NotificationCenter postNotificationName:NTFPlanSave object:nil];
        }
        return b;
    }
}

+ (BOOL)storePhoto:(Photo *)photo
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return NO;
        }
        
        if (!photo.photoid || !photo.createtime)
            return NO;
        
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            photo.account = user.objectId;
        }
        else
        {
            photo.account = @"";
        }
        if (!photo.content)
        {
            photo.content = @"";
        }
        if (!photo.phototime)
        {
            photo.phototime = @"";
        }
        if (!photo.updatetime)
        {
            photo.updatetime = photo.createtime;
        }
        if (!photo.location)
        {
            photo.location = @"";
        }
        NSMutableArray *photoDataArray = [NSMutableArray arrayWithCapacity:9];
        for (NSInteger i = 0; i < 9; i++)
        {
            if (i < photo.photoArray.count)
            {
                [photoDataArray addObject:photo.photoArray[i]];
            }
            else
            {
                [photoDataArray addObject:[NSData data]];
            }
        }

        BOOL hasRec = NO;
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE photoid=? AND account=?", STRTableName3];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[photo.photoid, photo.account]];
        hasRec = [rs next];
        [rs close];
        BOOL b = NO;
        if (hasRec)
        {
            sqlString = [NSString stringWithFormat:@"UPDATE %@ SET content=?, createtime=?, phototime=?, updatetime=?, location=?, photo1=?, photo2=?, photo3=?, photo4=?, photo5=?, photo6=?, photo7=?, photo8=?, photo9=?, photo1URL=?, photo2URL=?, photo3URL=?, photo4URL=?, photo5URL=?, photo6URL=?, photo7URL=?, photo8URL=?, photo9URL=? WHERE photoid=? AND account=?", STRTableName3];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[photo.content, photo.createtime, photo.phototime, photo.updatetime, photo.location, photoDataArray[0], photoDataArray[1], photoDataArray[2], photoDataArray[3], photoDataArray[4], photoDataArray[5], photoDataArray[6], photoDataArray[7], photoDataArray[8], photo.photoURLArray[0], photo.photoURLArray[1], photo.photoURLArray[2], photo.photoURLArray[3], photo.photoURLArray[4], photo.photoURLArray[5], photo.photoURLArray[6], photo.photoURLArray[7], photo.photoURLArray[8], photo.photoid, photo.account]];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        else
        {
            sqlString = [NSString stringWithFormat:@"INSERT INTO %@(account, photoid, content, createtime, phototime, updatetime, location, photo1, photo2, photo3, photo4, photo5, photo6, photo7, photo8, photo9, photo1URL, photo2URL, photo3URL, photo4URL, photo5URL, photo6URL, photo7URL, photo8URL, photo9URL, isdeleted) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", STRTableName3];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[photo.account, photo.photoid, photo.content, photo.createtime, photo.phototime, photo.updatetime, photo.location, photoDataArray[0], photoDataArray[1], photoDataArray[2], photoDataArray[3], photoDataArray[4], photoDataArray[5], photoDataArray[6], photoDataArray[7], photoDataArray[8], photo.photoURLArray[0], photo.photoURLArray[1], photo.photoURLArray[2], photo.photoURLArray[3], photo.photoURLArray[4], photo.photoURLArray[5], photo.photoURLArray[6], photo.photoURLArray[7], photo.photoURLArray[8], @"0"]];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        if (b)
        {
            [NotificationCenter postNotificationName:NTFPhotoSave object:nil];
        }
        return b;
    }
}

+ (BOOL)storeStatistics:(Statistics *)statistics
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return NO;
        }
        
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            statistics.account = user.objectId;
        }
        else
        {
            return NO;
        }
        if (!statistics.recentMax)
        {
            statistics.recentMax = @"0";
        }
        if (!statistics.recentMaxBeginDate)
        {
            statistics.recentMaxBeginDate = @"";
        }
        if (!statistics.recentMaxEndDate)
        {
            statistics.recentMaxEndDate = @"";
        }
        if (!statistics.recordMax)
        {
            statistics.recordMax = @"0";
        }
        if (!statistics.recordMaxBeginDate)
        {
            statistics.recordMaxBeginDate = @"";
        }
        if (!statistics.recordMaxEndDate)
        {
            statistics.recordMaxEndDate = @"";
        }
        if (!statistics.updatetime)
        {
            statistics.updatetime = @"";
        }
        
        BOOL hasRec = NO;
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE account=?", STRTableName4];
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[statistics.account]];
        hasRec = [rs next];
        [rs close];
        BOOL b = NO;
        if (hasRec)
        {
            sqlString = [NSString stringWithFormat:@"UPDATE %@ SET recentMax=?, recentMaxBeginDate=?, recentMaxEndDate=?, recordMax=?, recordMaxBeginDate=?, recordMaxEndDate=?, updatetime=? WHERE account=?", STRTableName4];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[statistics.recentMax, statistics.recentMaxBeginDate, statistics.recentMaxEndDate, statistics.recordMax, statistics.recordMaxBeginDate, statistics.recordMaxEndDate, statistics.updatetime, statistics.account]];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        else
        {
            sqlString = [NSString stringWithFormat:@"INSERT INTO %@(account, recentMax, recentMaxBeginDate, recentMaxEndDate, recordMax, recordMaxBeginDate, recordMaxEndDate, updatetime) values(?, ?, ?, ?, ?, ?, ?, ?)", STRTableName4];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[statistics.account, statistics.recentMax, statistics.recentMaxBeginDate, statistics.recentMaxEndDate, statistics.recordMax, statistics.recordMaxBeginDate, statistics.recordMaxEndDate, statistics.updatetime]];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        [NotificationCenter postNotificationName:NTFSettingsSave object:nil];
        return b;
    }
}

+ (BOOL)storeTask:(Task *)task updateNotify:(BOOL)updateNotify
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return NO;
        }
        
        if (!task.taskId || !task.createTime)
            return NO;
        
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            task.account = user.objectId;
        }
        else
        {
            task.account = @"";
        }
        if (!task.content)
        {
            task.content = @"";
        }
        if (!task.totalCount)
        {
            task.totalCount = @"0";
        }
        if (!task.completionDate)
        {
            task.completionDate = @"";
        }
        if (!task.updateTime)
        {
            task.updateTime = @"";
        }
        if (!task.isNotify)
        {
            task.isNotify = @"0";
        }
        if (!task.notifyTime)
        {
            task.notifyTime = @"";
        }
        if (!task.isDeleted)
        {
            task.isDeleted = @"0";
        }
        if (!task.isRepeat)
        {
            task.isRepeat = @"0";
        }
        if (!task.repeatType)
        {
            task.repeatType = @"4";
        }
        if (!task.taskOrder)
        {
            task.taskOrder = @"";
        }
        
        BOOL hasRec = NO;
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE taskId=? AND account=?", STRTableName5];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[task.taskId, task.account]];
        hasRec = [rs next];
        [rs close];
        BOOL b = NO;
        if (hasRec) {
            sqlString = [NSString stringWithFormat:@"UPDATE %@ SET content=?, totalCount=?, completionDate=?, updateTime=?, isNotify=?, notifyTime=?, isRepeat=?, repeatType=?, taskOrder=? WHERE taskId=? AND account=?", STRTableName5];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[task.content, task.totalCount, task.completionDate, task.updateTime, task.isNotify, task.notifyTime, task.isRepeat, task.repeatType, task.taskOrder, task.taskId, task.account]];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        else
        {
            
            sqlString = [NSString stringWithFormat:@"INSERT INTO %@(account, taskId, content, totalCount, completionDate, createTime, updateTime, isNotify, notifyTime, isRepeat, repeatType, taskOrder, isDeleted) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", STRTableName5];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[task.account, task.taskId, task.content, task.totalCount, task.completionDate, task.createTime, task.updateTime, task.isNotify, task.notifyTime, task.isRepeat, task.repeatType, task.taskOrder, @"0"]];
            
            FMDBQuickCheck(b, sqlString, __db);
            
            //更新5天没有新建计划的提醒时间
            [self setFiveDayNotification];
        }
        if (b)
        {
            [NotificationCenter postNotificationName:NTFTaskSave object:nil];
        }
        return b;
    }
}

+ (BOOL)updateTaskCount:(Task *)task
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return NO;
        }
        
        if (!task.taskId || !task.createTime)
            return NO;
        
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            task.account = user.objectId;
        }
        else
        {
            task.account = @"";
        }
        if (!task.totalCount)
        {
            task.totalCount = @"0";
        }
        if (!task.completionDate)
        {
            task.completionDate = @"";
        }
        if (!task.updateTime)
        {
            task.updateTime = @"";
        }
        
        BOOL hasRec = NO;
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE taskId=? AND account=?", STRTableName5];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[task.taskId, task.account]];
        hasRec = [rs next];
        [rs close];
        BOOL b = NO;
        if (hasRec)
        {
            sqlString = [NSString stringWithFormat:@"UPDATE %@ SET totalCount=?, completionDate=?, updateTime=? WHERE taskId=? AND account=?", STRTableName5];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[task.totalCount, task.completionDate, task.updateTime, task.taskId, task.account]];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        if (b)
        {
            [NotificationCenter postNotificationName:NTFTaskSave object:nil];
        }
        return b;
    }
}

+ (void)updateTaskOrder:(Task *)task
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return;
        }
        
        if (!task.taskId || !task.createTime)
            return;
        
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            task.account = user.objectId;
        }
        else
        {
            task.account = @"";
        }
        if (!task.taskOrder)
        {
            task.taskOrder = @"";
        }
        if (!task.updateTime)
        {
            task.updateTime = @"";
        }
        
        BOOL hasRec = NO;
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE taskId=? AND account=?", STRTableName5];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[task.taskId, task.account]];
        hasRec = [rs next];
        [rs close];
        BOOL b = NO;
        if (hasRec)
        {
            sqlString = [NSString stringWithFormat:@"UPDATE %@ SET taskOrder=?, updateTime=? WHERE taskId=? AND account=?", STRTableName5];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[task.taskOrder, task.updateTime, task.taskId, task.account]];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        if (b)
        {
            [NotificationCenter postNotificationName:NTFTaskSave object:nil];
        }
    }
}

+ (BOOL)storeTaskRecord:(TaskRecord *)taskRecord
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return NO;
        }
        
        if (!taskRecord.recordId || !taskRecord.createTime)
            return NO;

        NSString *sqlString = [NSString stringWithFormat:@"INSERT INTO %@(recordId, createTime) values(?, ?)", STRTableName6];
 
        BOOL b = [__db executeUpdate:sqlString withArgumentsInArray:@[taskRecord.recordId, taskRecord.createTime]];
        
        FMDBQuickCheck(b, sqlString, __db);
        
        if (b)
        {
            [NotificationCenter postNotificationName:NTFTaskRecordSave object:nil];
        }
        return b;
    }
}

+ (BOOL)storeMessages:(Messages *)message
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return NO;
        }
        
        if (!message.messageId)
            return NO;
        
        NSString *account = @"";
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            account = user.objectId;
        }
        if (!message.title)
        {
            message.title = @"";
        }
        if (!message.content)
        {
            message.content = @"";
        }
        if (!message.detailURL)
        {
            message.detailURL = @"";
        }
        if (!message.imgURLArray)
        {
            message.imgURLArray = [NSArray array];
        }
        if (!message.canShare)
        {
            message.canShare = @"0";
        }
        if (!message.messageType)
        {
            message.messageType = @"1";
        }
        if (!message.createTime)
        {
            message.createTime = [CommonFunction getTimeNowString];
        }
        
        NSData *imgURLArrayData = [NSKeyedArchiver archivedDataWithRootObject:message.imgURLArray];
        
        BOOL hasRec = NO;
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE messageId=? AND account=?", STRTableName7];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[message.messageId, account]];
        hasRec = [rs next];
        [rs close];
        BOOL b = NO;
        if (!hasRec)
        {
            sqlString = [NSString stringWithFormat:@"INSERT INTO %@(account, messageId, title, content, detailURL, imgURLArray, hasRead, canShare, messageType, createTime) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", STRTableName7];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[account, message.messageId, message.title, message.content, message.detailURL, imgURLArrayData, @"0", message.canShare, message.messageType, message.createTime]];
            
            FMDBQuickCheck(b, sqlString, __db);
            
            [NotificationCenter postNotificationName:NTFMessagesSave object:nil];
        }
        return b;
    }
}

+ (BOOL)setMessagesRead:(Messages *)message
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return NO;
        }
        
        if (!message.messageId)
            return NO;
        
        NSString *account = @"";
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            account = user.objectId;
        }
        
        BOOL hasRec = NO;
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE messageId=? AND account=?", STRTableName7];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[message.messageId, account]];
        hasRec = [rs next];
        [rs close];
        BOOL b = NO;
        if (hasRec)
        {
            sqlString = [NSString stringWithFormat:@"UPDATE %@ SET hasRead=1 WHERE messageId=? AND account=?", STRTableName7];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[message.messageId, account]];
            
            FMDBQuickCheck(b, sqlString, __db);
            
            [NotificationCenter postNotificationName:NTFMessagesSave object:nil];
        }
        return b;
    }
}

+ (BOOL)deletePlan:(Plan *)plan
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return NO;
        }
        
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            plan.account = user.objectId;
        }
        else
        {
            plan.account = @"";
        }
        plan.updatetime = [CommonFunction getTimeNowString];
        
        BOOL hasRec = NO;
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE planid=? AND account=?", STRTableName2];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[plan.planid, plan.account]];
        hasRec = [rs next];
        [rs close];
        BOOL b = NO;
        if (hasRec)
        {
            sqlString = [NSString stringWithFormat:@"UPDATE %@ SET isdeleted=1, updatetime=?  WHERE planid=? AND account=?", STRTableName2];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[plan.updatetime, plan.planid, plan.account]];
            
            FMDBQuickCheck(b, sqlString, __db);
            
            //取消提醒
            if (b && [plan.isnotify isEqualToString:@"1"])
            {
                [CommonFunction cancelPlanNotification:plan.planid];
            }
        }
        if (b)
        {
            [NotificationCenter postNotificationName:NTFPlanSave object:nil];
        }
        return b;
    }
}

+ (void)cleanPlan:(Plan *)plan
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return;
        }
        
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            plan.account = user.objectId;
        }
        else
        {
            return;
        }

        BOOL hasRec = NO;
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE planid=? AND account=?", STRTableName2];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[plan.planid, plan.account]];
        hasRec = [rs next];
        [rs close];
        BOOL b = NO;
        if (hasRec)
        {
            sqlString = [NSString stringWithFormat:@"DELETE FROM %@ WHERE planid=? AND account=?", STRTableName2];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[plan.planid, plan.account]];
            
            //取消提醒
            if (b && [plan.isnotify isEqualToString:@"1"])
            {
                [CommonFunction cancelPlanNotification:plan.planid];
            }
            
            if (b)
            {
                NSLog(@"删除本地计划成功");
            }
            else
            {
                NSLog(@"删除本地计划失败");
            }
        }
    }
}

+ (BOOL)deletePhoto:(Photo *)photo
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return NO;
        }
        
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            photo.account = user.objectId;
        }
        else
        {
            photo.account = @"";
        }
        photo.updatetime = [CommonFunction getTimeNowString];
        
        BOOL hasRec = NO;
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE photoid=? AND account=?", STRTableName3];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[photo.photoid, photo.account]];
        hasRec = [rs next];
        [rs close];
        BOOL b = NO;
        if (hasRec)
        {
            sqlString = [NSString stringWithFormat:@"UPDATE %@ SET isdeleted=1, updatetime=? WHERE photoid=? AND account=?", STRTableName3];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[photo.updatetime, photo.photoid, photo.account]];
            
            FMDBQuickCheck(b, sqlString, __db);
        }
        if (b)
        {
            [NotificationCenter postNotificationName:NTFPhotoSave object:nil];
        }
        return b;
    }
}

+ (void)cleanPhoto:(Photo *)photo
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return;
        }
        
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            photo.account = user.objectId;
        }
        else
        {
            return;
        }

        BOOL hasRec = NO;
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE photoid=? AND account=?", STRTableName3];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[photo.photoid, photo.account]];
        hasRec = [rs next];
        [rs close];
        BOOL b = NO;
        if (hasRec)
        {
            sqlString = [NSString stringWithFormat:@"DELETE FROM %@ WHERE photoid=? AND account=?", STRTableName3];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[photo.photoid, photo.account]];
            
            if (b)
            {
                NSLog(@"删除本地岁月影像成功");
            }
            else
            {
                NSLog(@"删除本地岁月影像失败");
            }
        }
    }
}

+ (BOOL)deleteTask:(Task *)task
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return NO;
        }
        
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            task.account = user.objectId;
        }
        else
        {
            task.account = @"";
        }
        task.updateTime = [CommonFunction getTimeNowString];
        
        BOOL hasRec = NO;
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE taskId=? AND account=?", STRTableName5];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[task.taskId, task.account]];
        hasRec = [rs next];
        [rs close];
        BOOL b = NO;
        if (hasRec)
        {
            sqlString = [NSString stringWithFormat:@"UPDATE %@ SET isdeleted=1, updateTime=?  WHERE taskId=? AND account=?", STRTableName5];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[task.updateTime, task.taskId, task.account]];
            
            FMDBQuickCheck(b, sqlString, __db);
            
            //取消提醒
            if (b && [task.isNotify isEqualToString:@"1"])
            {
                [self cancelTaskNotification:task.taskId];
            }
        }
        if (b)
        {
            [NotificationCenter postNotificationName:NTFTaskSave object:nil];
        }
        return b;
    }
}

+ (void)cleanTask:(Task *)task
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return;
        }
        
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            task.account = user.objectId;
        }
        else
        {
            return;
        }
        
        BOOL hasRec = NO;
        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE taskId=? AND account=?", STRTableName5];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[task.taskId, task.account]];
        hasRec = [rs next];
        [rs close];
        BOOL b = NO;
        if (hasRec)
        {
            sqlString = [NSString stringWithFormat:@"DELETE FROM %@ WHERE taskId=? AND account=?", STRTableName5];
            
            b = [__db executeUpdate:sqlString withArgumentsInArray:@[task.taskId, task.account]];
            
            //取消提醒
            if (b && [task.isNotify isEqualToString:@"1"])
            {
                [self cancelTaskNotification:task.taskId];
            }
            
            if (b)
            {
                NSLog(@"删除本地任务成功");
            }
            else
            {
                NSLog(@"删除本地任务失败");
            }
        }
    }
}

+ (BOOL)cleanHasReadMessages
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return NO;
        }
        
        NSString *account = @"";
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            account = user.objectId;
        }
        
        NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM %@ WHERE hasRead=1 AND account=?", STRTableName7];
        BOOL b = [__db executeUpdate:sqlString withArgumentsInArray:@[account]];
        
        FMDBQuickCheck(b, sqlString, __db);
        
        [NotificationCenter postNotificationName:NTFMessagesSave object:nil];

        return b;
    }
}

+ (BOOL)hasUnreadMessages
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return NO;
        }
        
        NSString *account = @"";
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            account = user.objectId;
        }

        NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE account=? AND hasRead=0", STRTableName7];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account]];
        
        BOOL b = NO;
        while ([rs next])
        {
            b = YES;
            break;
        }
        [rs close];
        
        return b;
    }
}

+ (Settings *)getPersonalSettings
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return nil;
        }

        Settings *settings = [[Settings alloc] init];
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            settings.account = user.objectId;
        }
        else
        {
            settings.account = @"";
        }

        NSString *sqlString = [NSString stringWithFormat:@"SELECT objectId, nickname, birthday, email, gender, lifespan, avatar, avatarURL, centerTop, centerTopURL, isAutoSync, isUseGestureLock, isShowGestureTrack, gesturePasswod, createtime, updatetime, syntime, countdownType, dayOrMonth, autoDelayUndonePlan, signature FROM %@ WHERE account=?", STRTableName1];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[settings.account]];
        while ([rs next])
        {
            settings.objectId = [rs stringForColumn:@"objectId"];
            settings.nickname = [rs stringForColumn:@"nickname"];
            settings.birthday = [rs stringForColumn:@"birthday"];
            settings.email = [rs stringForColumn:@"email"];
            settings.gender = [rs stringForColumn:@"gender"];
            settings.lifespan = [rs stringForColumn:@"lifespan"];
            settings.avatar = [rs dataForColumn:@"avatar"];
            if (!settings.avatar)
            {
                settings.avatar = UIImageJPEGRepresentation([UIImage imageNamed:png_AvatarDefault], 1);
            }
            settings.avatarURL = [rs stringForColumn:@"avatarURL"];
            settings.centerTop = [rs dataForColumn:@"centerTop"];
            if (!settings.centerTop)
            {
                settings.centerTop = UIImageJPEGRepresentation([UIImage imageNamed:png_Bg_SideTop], 1);
            }
            settings.centerTopURL = [rs stringForColumn:@"centerTopURL"];
            settings.isAutoSync = [rs stringForColumn:@"isAutoSync"];
            settings.isUseGestureLock = [rs stringForColumn:@"isUseGestureLock"];
            settings.isShowGestureTrack = [rs stringForColumn:@"isShowGestureTrack"];
            settings.gesturePasswod = [rs stringForColumn:@"gesturePasswod"];
            settings.createtime = [rs stringForColumn:@"createtime"];
            settings.updatetime = [rs stringForColumn:@"updatetime"];
            settings.syntime = [rs stringForColumn:@"syntime"];
            settings.countdownType = [rs stringForColumn:@"countdownType"];
            settings.dayOrMonth = [rs stringForColumn:@"dayOrMonth"];
            settings.autoDelayUndonePlan = [rs stringForColumn:@"autoDelayUndonePlan"];
            settings.signature = [rs stringForColumn:@"signature"];
            if (!settings.isAutoSync)
            {
                settings.isAutoSync = @"0";
            }
            if (!settings.isUseGestureLock)
            {
                settings.isUseGestureLock = @"0";
            }
            if (!settings.isShowGestureTrack)
            {
                settings.isShowGestureTrack = @"1";
            }
            if (!settings.objectId)
            {
                settings.objectId = @"";
            }
            if (!settings.countdownType)
            {
                settings.countdownType = @"0";
            }
            if (!settings.dayOrMonth)
            {
                settings.dayOrMonth = @"0";
            }
            if (!settings.autoDelayUndonePlan)
            {
                settings.autoDelayUndonePlan = @"0";
            }
            if (!settings.signature)
            {
                settings.signature = @"";
            }
        }
        [rs close];
        
        return settings;
    }
}

+ (NSArray *)getPlan:(BOOL)isEverydayPlan startIndex:(NSInteger)startIndex
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return nil;
        }
        
        NSString *account = @"";
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            account = user.objectId;
            //处理上次升级后本地数据显示不全的问题
            NSString *tmp = [UserDefaults objectForKey:STRCleanCacheFlag];
            if (!tmp || ![tmp isEqualToString:@"1"])
            {
                //计划
                NSString *sqlString = [NSString stringWithFormat:@"UPDATE %@ SET account=?", STRTableName2];
                BOOL b1 = [__db executeUpdate:sqlString withArgumentsInArray:@[user.objectId]];
                FMDBQuickCheck(b1, sqlString, __db);
                //影像
                sqlString = [NSString stringWithFormat:@"UPDATE %@ SET account=?", STRTableName3];
                BOOL b2 = [__db executeUpdate:sqlString withArgumentsInArray:@[user.objectId]];
                FMDBQuickCheck(b2, sqlString, __db);
                //任务
                sqlString = [NSString stringWithFormat:@"UPDATE %@ SET account=?", STRTableName5];
                BOOL b3 = [__db executeUpdate:sqlString withArgumentsInArray:@[user.objectId]];
                FMDBQuickCheck(b3, sqlString, __db);
                
                if (b1 && b2 && b3)
                {
                    [UserDefaults setObject:@"1" forKey:STRCleanCacheFlag];
                    [UserDefaults synchronize];
                }
            }
        }
        
        NSString *condition = @"";
        NSString *order = @"";
        if (isEverydayPlan)
        {
            condition = [NSString stringWithFormat:@"datetime(beginDate)<=datetime('%@')", [CommonFunction NSDateToNSString:[NSDate date] formatter:STRDateFormatterType4]];
            order = @"DESC";
        }
        else
        {
            condition = [NSString stringWithFormat:@"datetime(beginDate)>datetime('%@')", [CommonFunction NSDateToNSString:[NSDate date] formatter:STRDateFormatterType4]];
            order = @"ASC";
        }
        
        NSMutableArray *array = [NSMutableArray array];
        NSString *sqlString = [NSString stringWithFormat:@"SELECT planid, content, createtime, completetime, updatetime, iscompleted, isnotify, notifytime, beginDate, isdeleted, isRepeat, remark FROM %@ WHERE %@ AND account=? AND isdeleted=0 ORDER BY iscompleted, beginDate %@ Limit ? Offset ?", STRTableName2, condition, order];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account, @(kPlanLoadMax), @(startIndex)]];
        
        while ([rs next])
        {
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
            plan.beginDate = [rs stringForColumn:@"beginDate"];
            plan.isdeleted = [rs stringForColumn:@"isdeleted"];
            plan.isRepeat = [rs stringForColumn:@"isRepeat"];
            plan.remark = [rs stringForColumn:@"remark"];
            
            if (!plan.beginDate
                || plan.beginDate.length == 0)
            {
                NSDate *date = [CommonFunction NSStringDateToNSDate:plan.createtime formatter:STRDateFormatterType1];
                plan.beginDate = [CommonFunction NSDateToNSString:date formatter:STRDateFormatterType4];
            }
            
            [array addObject:plan];
        }
        [rs close];
        
        return array;
    }
}

+ (NSArray *)getUndonePlan
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return nil;
        }
        
        NSString *account = @"";
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            account = user.objectId;
        }

        NSString *order = @"DESC";
        
        NSMutableArray *array = [NSMutableArray array];
        NSString *sqlString = [NSString stringWithFormat:@"SELECT planid, content, createtime, completetime, updatetime, iscompleted, isnotify, notifytime, beginDate, isdeleted FROM %@ WHERE account=? AND isdeleted=0 AND iscompleted=0 ORDER BY beginDate %@", STRTableName2, order];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account]];
        
        while ([rs next])
        {
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
            plan.beginDate = [rs stringForColumn:@"beginDate"];
            plan.isdeleted = [rs stringForColumn:@"isdeleted"];
            plan.isRepeat = [rs stringForColumn:@"isRepeat"];
            plan.remark = [rs stringForColumn:@"remark"];
            
            if (!plan.beginDate || plan.beginDate.length == 0)
            {
                NSDate *date = [CommonFunction NSStringDateToNSDate:plan.createtime formatter:STRDateFormatterType1];
                plan.beginDate = [CommonFunction NSDateToNSString:date formatter:STRDateFormatterType4];
            }
            
            [array addObject:plan];
        }
        [rs close];
        
        return array;
    }
}

+ (void)setRepeatPlan
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return;
        }
        
        NSString *account = @"";
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            account = user.objectId;
        }
        
        NSString *condition = @"";
        NSString *order = @"";

        condition = [NSString stringWithFormat:@"datetime(beginDate)<=datetime('%@')", [CommonFunction NSDateToNSString:[NSDate date] formatter:STRDateFormatterType4]];
        order = @"DESC";

        NSMutableArray *array = [NSMutableArray array];
        NSString *sqlString = [NSString stringWithFormat:@"SELECT planid, content, createtime, completetime, updatetime, iscompleted, isnotify, notifytime, beginDate, isdeleted, isRepeat, remark FROM %@ WHERE %@ AND account=? AND isdeleted=0 ORDER BY beginDate %@ Limit ?", STRTableName2, condition, order];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account, @(kPlanLoadMax)]];
        
        NSString *beginDate = @"";//记录最近一次有计划的日期
        
        while ([rs next])
        {
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
            plan.beginDate = [rs stringForColumn:@"beginDate"];
            plan.isdeleted = [rs stringForColumn:@"isdeleted"];
            plan.isRepeat = [rs stringForColumn:@"isRepeat"];
            plan.remark = [rs stringForColumn:@"remark"];
            
            if (!plan.beginDate || plan.beginDate.length == 0)
            {
                NSDate *date = [CommonFunction NSStringDateToNSDate:plan.createtime formatter:STRDateFormatterType1];
                plan.beginDate = [CommonFunction NSDateToNSString:date formatter:STRDateFormatterType4];
            }
            
            if (beginDate.length == 0)
            {
                beginDate = plan.beginDate;
            }
            
            if ([beginDate isEqualToString:plan.beginDate])
            {
                if ([plan.isRepeat isEqualToString:@"1"])
                {
                    [array addObject:plan];
                }
            }
            else
            {
                break;
            }
        }
        [rs close];
        
        if (array.count)//这就是所有需要每日重复的计划
        {
            for (Plan *item in array)
            {
                [PlanCache addRepeatPlan:item];
            }
        }
    }
}

+ (void)addRepeatPlan:(Plan *)plan
{
    NSString *today = [CommonFunction NSDateToNSString:[NSDate date] formatter:STRDateFormatterType4];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:STRDateFormatterType4];
    
    if (![plan.beginDate isEqualToString:today])
    {
        NSDate *inputDate = [dateFormatter dateFromString:plan.beginDate];
        NSDate *nextDate = [NSDate dateWithTimeInterval:24*60*60 sinceDate:inputDate];
        
        NSString *timeNow = [CommonFunction getTimeNowString];
        NSString *planid = [CommonFunction NSDateToNSString:[NSDate date] formatter:STRDateFormatterType5];
        
        Plan *planRepeat = [[Plan alloc]init];
        planRepeat.planid = planid;
        planRepeat.beginDate = [CommonFunction NSDateToNSString:nextDate formatter:STRDateFormatterType4];
        planRepeat.createtime = timeNow;
        planRepeat.updatetime = timeNow;
        planRepeat.iscompleted = @"0";
        planRepeat.isdeleted = @"0";
        planRepeat.isRepeat = @"1";
        planRepeat.content = plan.content;
        
        if ([planRepeat.beginDate isEqualToString:today]
            && [plan.isnotify isEqualToString:@"1"])
        {
            planRepeat.isnotify = @"1";
            planRepeat.notifytime = plan.notifytime;
        }
        else
        {
            planRepeat.isnotify = @"0";
            planRepeat.notifytime = @"";
        }
        
        [PlanCache storePlan:planRepeat];
        //递归直到今天
        [PlanCache addRepeatPlan:planRepeat];
    }
}

+ (NSArray *)searchPlan:(NSString *)key
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return nil;
        }
        
        NSString *account = @"";
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            account = user.objectId;
        }
        
        NSString *condition = [NSString stringWithFormat:@"content LIKE '%%%@%%'", key];
        NSString *order = @"DESC";
        
        NSMutableArray *array = [NSMutableArray array];
        NSString *sqlString = [NSString stringWithFormat:@"SELECT planid, content, createtime, completetime, updatetime, iscompleted, isnotify, notifytime, beginDate, isdeleted FROM %@ WHERE %@ AND account=? AND isdeleted=0 ORDER BY iscompleted, beginDate %@", STRTableName2, condition, order];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account]];
        
        while ([rs next])
        {
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
            plan.beginDate = [rs stringForColumn:@"beginDate"];
            plan.isdeleted = [rs stringForColumn:@"isdeleted"];
            
            if (!plan.beginDate
                || plan.beginDate.length == 0)
            {
                NSDate *date = [CommonFunction NSStringDateToNSDate:plan.createtime formatter:STRDateFormatterType1];
                plan.beginDate = [CommonFunction NSDateToNSString:date formatter:STRDateFormatterType4];
            }
            
            [array addObject:plan];
        }
        [rs close];
        
        return array;
    }
}

+ (NSArray *)getPhoto:(NSInteger)startIndex
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return nil;
        }
        
        NSString *account = @"";
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            account = user.objectId;
        }
        
        NSMutableArray *array = [NSMutableArray array];
        NSString *sqlString = [NSString stringWithFormat:@"SELECT photoid, content, createtime, phototime, updatetime, location, photo1, photo2, photo3, photo4, photo5, photo6, photo7, photo8, photo9, photo1URL, photo2URL, photo3URL, photo4URL, photo5URL, photo6URL, photo7URL, photo8URL, photo9URL FROM %@ WHERE account=? AND isdeleted=0 ORDER BY phototime DESC, createtime DESC Limit ? Offset ?", STRTableName3];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account, @(kPhotoLoadMax), @(startIndex)]];
        
        while ([rs next])
        {
            Photo *photo = [[Photo alloc] init];
            photo.account = account;
            photo.photoid = [rs stringForColumn:@"photoid"];
            photo.content = [rs stringForColumn:@"content"];
            photo.createtime = [rs stringForColumn:@"createtime"];
            photo.phototime = [rs stringForColumn:@"phototime"];
            photo.updatetime = [rs stringForColumn:@"updatetime"];
            photo.location = [rs stringForColumn:@"location"];
            photo.photoURLArray = [NSMutableArray arrayWithCapacity:9];
            for (NSInteger n = 0; n < 9; n++)
            {
                NSString *url = [NSString stringWithFormat:@"photo%ldURL", (long)(n + 1)];
                if ([rs stringForColumn:url])
                {
                    photo.photoURLArray[n] = [rs stringForColumn:url];
                }
                else
                {
                    photo.photoURLArray[n] = @"";
                }
            }
            photo.photoArray = [NSMutableArray arrayWithCapacity:9];
            for (NSInteger m = 0; m < 9; m++)
            {
                NSString *photoName = [NSString stringWithFormat:@"photo%ld", (long)(m + 1)];
                NSData *imageData = [rs dataForColumn:photoName];
                if (imageData)
                {
                    photo.photoArray[m] = imageData;
                }
            }
            [array addObject:photo];
        }
        [rs close];
        
        return array;
    }
}

+ (Photo *)getPhotoById:(NSString *)photoid
{
    @synchronized(__db)
    {
        Photo *photo = [[Photo alloc] init];
        
        if (![__db open])
        {
            __db = nil;
            return photo;
        }
        
        NSString *account = @"";
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            account = user.objectId;
        }
        
        NSString *sqlString = [NSString stringWithFormat:@"SELECT photoid, content, createtime, phototime, updatetime, location, photo1, photo2, photo3, photo4, photo5, photo6, photo7, photo8, photo9, photo1URL, photo2URL, photo3URL, photo4URL, photo5URL, photo6URL, photo7URL, photo8URL, photo9URL FROM %@ WHERE account=? AND photoid=?", STRTableName3];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account, photoid]];
        
        while ([rs next])
        {
            photo.account = account;
            photo.photoid = [rs stringForColumn:@"photoid"];
            photo.content = [rs stringForColumn:@"content"];
            photo.createtime = [rs stringForColumn:@"createtime"];
            photo.phototime = [rs stringForColumn:@"phototime"];
            photo.updatetime = [rs stringForColumn:@"updatetime"];
            photo.location = [rs stringForColumn:@"location"];
            photo.isdeleted = @"0";
            photo.photoURLArray = [NSMutableArray arrayWithCapacity:9];
            for (NSInteger n = 0; n < 9; n++)
            {
                NSString *url = [NSString stringWithFormat:@"photo%ldURL", (long)(n + 1)];
                if ([rs stringForColumn:url])
                {
                    photo.photoURLArray[n] = [rs stringForColumn:url];
                }
                else
                {
                    photo.photoURLArray[n] = @"";
                }
            }
            photo.photoArray = [NSMutableArray arrayWithCapacity:9];
            for (NSInteger i = 0; i < 9; i++)
            {
                NSString *photoName = [NSString stringWithFormat:@"photo%ld", (long)(i + 1)];
                NSData *imageData = [rs dataForColumn:photoName];
                if (imageData)
                {
                    photo.photoArray[i] = imageData;
                }
            }
        }
        [rs close];
        
        return photo;
    }
}

+ (Statistics *)getStatistics
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return nil;
        }
        
        Statistics *statistics = [[Statistics alloc] init];
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            statistics.account = user.objectId;
        }
        else
        {
            statistics.account = @"";
        }
        
        NSString *sqlString = [NSString stringWithFormat:@"SELECT recentMax, recentMaxBeginDate, recentMaxEndDate, recordMax, recordMaxBeginDate, recordMaxEndDate, updatetime FROM %@ WHERE account=?", STRTableName4];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[statistics.account]];
        while ([rs next])
        {
            statistics.recentMax = [rs stringForColumn:@"recentMax"];
            statistics.recentMaxBeginDate = [rs stringForColumn:@"recentMaxBeginDate"];
            statistics.recentMaxEndDate = [rs stringForColumn:@"recentMaxEndDate"];
            statistics.recordMax = [rs stringForColumn:@"recordMax"];
            statistics.recordMaxBeginDate = [rs stringForColumn:@"recordMaxBeginDate"];
            statistics.recordMaxEndDate = [rs stringForColumn:@"recordMaxEndDate"];
            statistics.updatetime = [rs stringForColumn:@"updatetime"];
        }
        [rs close];
        if (!statistics.recentMax)
        {
            statistics.recentMax = @"0";
        }
        if (!statistics.recordMax)
        {
            statistics.recordMax = @"0";
        }
        return statistics;
    }
}

+ (NSMutableArray *)getTask
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return nil;
        }
        
        NSString *account = @"";
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            account = user.objectId;
        }

        NSMutableArray *array = [NSMutableArray array];
        NSString *sqlString = [NSString stringWithFormat:@"SELECT taskId, content, totalCount, completionDate, createTime, updateTime, isNotify, notifyTime, isTomato, tomatoMinute, isRepeat, repeatType, taskOrder FROM %@ WHERE account=? AND isDeleted=0 ORDER BY cast(taskOrder as integer) ASC", STRTableName5];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account]];
        
        while ([rs next])
        {
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
            task.isTomato = [rs stringForColumn:@"isTomato"];
            task.tomatoMinute = [rs stringForColumn:@"tomatoMinute"];
            task.isRepeat = [rs stringForColumn:@"isRepeat"];
            task.repeatType = [rs stringForColumn:@"repeatType"];
            task.taskOrder = [rs stringForColumn:@"taskOrder"];
            task.isDeleted = @"0";
            
            if (!task.isTomato)
            {
                task.isTomato = @"0";
            }
            if (!task.tomatoMinute)
            {
                task.tomatoMinute = @"";
            }
            if (!task.isRepeat)
            {
                task.isRepeat = @"0";
            }
            if (!task.repeatType)
            {
                task.repeatType = @"4";
            }
            [array addObject:task];
        }
        [rs close];
        
        return array;
    }
}

+ (Task *)getTaskById:(NSString *)taskId
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return nil;
        }
        
        NSString *account = @"";
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            account = user.objectId;
        }

        NSString *sqlString = [NSString stringWithFormat:@"SELECT taskId, content, totalCount, completionDate, createTime, updateTime, isNotify, notifyTime, isTomato, tomatoMinute, isRepeat, repeatType, taskOrder FROM %@ WHERE account=? AND taskId=? ORDER BY cast(taskOrder as integer) ASC, createTime DESC", STRTableName5];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account, taskId]];
        
        Task *task = [[Task alloc] init];
        
        while ([rs next])
        {
            task.account = account;
            task.taskId = [rs stringForColumn:@"taskId"];
            task.content = [rs stringForColumn:@"content"];
            task.totalCount = [rs stringForColumn:@"totalCount"];
            task.completionDate = [rs stringForColumn:@"completionDate"];
            task.createTime = [rs stringForColumn:@"createTime"];
            task.updateTime = [rs stringForColumn:@"updateTime"];
            task.isNotify = [rs stringForColumn:@"isNotify"];
            task.notifyTime = [rs stringForColumn:@"notifyTime"];
            task.isTomato = [rs stringForColumn:@"isTomato"];
            task.tomatoMinute = [rs stringForColumn:@"tomatoMinute"];
            task.isRepeat = [rs stringForColumn:@"isRepeat"];
            task.repeatType = [rs stringForColumn:@"repeatType"];
            task.taskOrder = [rs stringForColumn:@"taskOrder"];
            task.isDeleted = @"0";
            
            if (!task.isTomato)
            {
                task.isTomato = @"0";
            }
            if (!task.tomatoMinute)
            {
                task.tomatoMinute = @"";
            }
            if (!task.isRepeat)
            {
                task.isRepeat = @"0";
            }
            if (!task.repeatType)
            {
                task.repeatType = @"4";
            }
            return task;
        }
        [rs close];
        
        return task;
    }
}

+ (NSArray *)getTaskRecord:(NSString *)recordId
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return nil;
        }
        
        NSMutableArray *array = [NSMutableArray array];
        NSString *sqlString = [NSString stringWithFormat:@"SELECT recordId, createTime FROM %@ WHERE recordId=? ORDER BY createTime DESC", STRTableName6];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[recordId]];
        
        while ([rs next])
        {
            TaskRecord *taskRecord = [[TaskRecord alloc] init];
            taskRecord.recordId = recordId;
            taskRecord.createTime = [rs stringForColumn:@"createTime"];
            
            [array addObject:taskRecord];
        }
        [rs close];
        
        return array;
    }
}

+ (NSArray *)getMessages
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return nil;
        }
        
        NSString *account = @"";
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            account = user.objectId;
        }
        
        NSMutableArray *array = [NSMutableArray array];
        NSString *sqlString = [NSString stringWithFormat:@"SELECT messageId, title, content, detailURL, imgURLArray, hasRead, canShare, messageType, createTime FROM %@ WHERE account=? ORDER BY hasRead ASC, createTime DESC", STRTableName7];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account]];
        
        while ([rs next])
        {
            Messages *message = [[Messages alloc] init];
            message.messageId = [rs stringForColumn:@"messageId"];
            message.title = [rs stringForColumn:@"title"];
            message.content = [rs stringForColumn:@"content"];
            message.detailURL = [rs stringForColumn:@"detailURL"];
            message.hasRead = [rs stringForColumn:@"hasRead"];
            message.canShare = [rs stringForColumn:@"canShare"];
            message.messageType = [rs stringForColumn:@"messageType"];
            message.createTime = [rs stringForColumn:@"createTime"];
            NSData *imgURLArrayData = [rs dataForColumn:@"imgURLArray"];
            message.imgURLArray = [NSKeyedUnarchiver unarchiveObjectWithData:imgURLArrayData];
            
            [array addObject:message];
        }
        [rs close];
        
        return array;
    }
}

+ (NSString *)getPlanTotalCount:(NSString*)type
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return nil;
        }
        
        NSString *account = @"";
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            account = user.objectId;
        }
        
        NSString *total = @"0";
        NSString *sqlString = @"";
        if ([type isEqualToString:@"DAY"])
        {
            NSString *condition = [NSString stringWithFormat:@"datetime(beginDate)<=datetime('%@')", [CommonFunction NSDateToNSString:[NSDate date] formatter:STRDateFormatterType4]];
            sqlString = [NSString stringWithFormat:@"SELECT COUNT(*) as total FROM %@ WHERE %@ AND account=? AND isdeleted=0", STRTableName2, condition];
            
        }
        else if ([type isEqualToString:@"FUTURE"])
        {
            NSString *condition = [NSString stringWithFormat:@"datetime(beginDate)>datetime('%@')", [CommonFunction NSDateToNSString:[NSDate date] formatter:STRDateFormatterType4]];
            sqlString = [NSString stringWithFormat:@"SELECT COUNT(*) as total FROM %@ WHERE %@ AND account=? AND isdeleted=0", STRTableName2, condition];

        }
        else
        {
            sqlString = [NSString stringWithFormat:@"SELECT COUNT(*) as total FROM %@ WHERE account=? AND isdeleted=0", STRTableName2];
        }
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account]];
        
        if([rs next])
        {
            total = [rs stringForColumn:@"total"];
        }
        [rs close];
        
        return total;
    }
}

+ (NSString *)getPlanCompletedCount
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return nil;
        }
        
        NSString *account = @"";
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            account = user.objectId;
        }
        
        NSString *completed = @"0";
        NSString *sqlString = [NSString stringWithFormat:@"SELECT COUNT(*) as completed FROM %@ WHERE account=? AND iscompleted=1 AND isdeleted=0", STRTableName2];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account]];
        
        if([rs next])
        {
            completed = [rs stringForColumn:@"completed"];
        }
        [rs close];
        
        return completed;
    }
}

+ (NSString *)getPhotoTotalCount
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return nil;
        }
        
        NSString *account = @"";
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            account = user.objectId;
        }
        
        NSString *total = @"0";
        NSString *sqlString = [NSString stringWithFormat:@"SELECT COUNT(*) as total FROM %@ WHERE account=? AND isdeleted=0", STRTableName3];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account]];
        
        if([rs next])
        {
            total = [rs stringForColumn:@"total"];
        }
        [rs close];
        
        return total;
    }
}

+ (NSString *)getTaskTotalCount
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return nil;
        }
        
        NSString *account = @"";
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            account = user.objectId;
        }
        
        NSString *total = @"0";
        NSString *sqlString = [NSString stringWithFormat:@"SELECT COUNT(*) as total FROM %@ WHERE account=? AND isDeleted=0", STRTableName5];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account]];
        
        if([rs next])
        {
            total = [rs stringForColumn:@"total"];
        }
        [rs close];
        
        return total;
    }
}

+ (NSArray *)getTaskStatisticsByStartDate:(NSString *)startDate endDate:(NSString *)endDate
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return nil;
        }
        
        NSString *account = @"";
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            account = user.objectId;
        }

        NSString *condition = [NSString stringWithFormat:@"datetime(b.createTime)>=datetime('%@') AND datetime(b.createTime)<=datetime('%@')", startDate, endDate];
        
        NSMutableArray *array = [NSMutableArray array];
        NSString *sqlString = [NSString stringWithFormat:@"SELECT b.recordId, a.content as title, count(b.recordId) as statistics FROM %@ as a, %@ as b WHERE %@ AND a.account=? AND a.isDeleted=0 AND a.taskId = b.recordId GROUP BY b.recordId ORDER BY statistics DESC", STRTableName5, STRTableName6, condition];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account]];
        
        while ([rs next])
        {
            TaskStatistics *taskStatistics = [[TaskStatistics alloc] init];
            taskStatistics.account = account;
            taskStatistics.taskContent = [rs stringForColumn:@"title"];
            taskStatistics.taskCount = [rs intForColumn:@"statistics"];
            
            [array addObject:taskStatistics];
        }
        [rs close];
        
        return array;
    }
}

+ (void)cancelTaskNotification:(NSString*)taskId
{
    //取消该任务的本地所有通知
    NSArray *array = [LocalNotificationManager getNotificationWithTag:taskId type:NotificationTypeTask];
    for (UILocalNotification *item in array)
    {
        [LocalNotificationManager cancelNotification:item];
    }
}
+ (void)setFiveDayNotification
{
    BOOL hasFiveDayNotification = NO;
    
    NSArray *arry = [LocalNotificationManager getAllLocalNotification];
    //查询是否已经添加过5天未新建计划的提醒
    for (UILocalNotification *item in arry)
    {
        NSDictionary *sourceN = item.userInfo;
        NSString *tag = [sourceN objectForKey:@"tag"];
        if ([tag longLongValue] == [STRFiveDayFlag1 longLongValue])
        {
            hasFiveDayNotification = YES;
            break;
        }
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:STRDateFormatterType3];
    NSString *fiveDayLater = [dateFormatter stringFromDate:[[NSDate date] dateByAddingTimeInterval:5 * 24 * 3600]];
    BmobUser *user = [BmobUser currentUser];
    NSString *account = @"";
    if (user)
    {
        account = user.objectId;
    }
    Plan *fiveDayPlan = [[Plan alloc] init];
    fiveDayPlan.account = account;
    fiveDayPlan.planid = STRFiveDayFlag1;
    fiveDayPlan.createtime = STRFiveDayFlag2;
    [dateFormatter setDateFormat:STRDateFormatterType4];
    fiveDayPlan.beginDate = [dateFormatter stringFromDate:[[NSDate date] dateByAddingTimeInterval:5 * 24 * 3600]];
    fiveDayPlan.iscompleted = @"0";
    fiveDayPlan.completetime = STRFiveDayFlag2;
    fiveDayPlan.content = STRViewTips106;
    fiveDayPlan.notifytime = fiveDayLater;
    
    if (hasFiveDayNotification)
    {//更新提醒时间
        [CommonFunction updatePlanNotification:fiveDayPlan];
    }
    else
    {//新建提醒
        [CommonFunction addPlanNotification:fiveDayPlan];
    }
}

+ (void)linkedLocalDataToAccount
{
    BmobUser *user = [BmobUser currentUser];
    if (!user) return;
    
    NSLog(@"开始关联本地数据");
    
    [Config shareInstance].settings = [PlanCache getPersonalSettings];
    if (![Config shareInstance].settings.createtime)
    {
        BmobQuery *bquery = [BmobQuery queryWithClassName:@"UserSettings"];
        [bquery whereKey:@"userObjectId" equalTo:user.objectId];
        [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
        {
            if (array.count == 0)
            {
                /*
                 *说明：只要在本地没有已登录账号的设置数据时才关联
                 *     如果本地已经有已登录账号的设置数据，则不关联
                 *     防止同一个账号在本地有两份设置数据
                 */
                //设置
                NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE account=?", STRTableName1];
                FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[@""]];
                BOOL hasRec = [rs next];
                [rs close];
                if (hasRec)
                {
                    NSString *sqlString = [NSString stringWithFormat:@"UPDATE %@ SET account=? WHERE account=?", STRTableName1];
                    
                    [__db executeUpdate:sqlString withArgumentsInArray:@[user.objectId, @""]];
                }
            }
        }];
    }
    
    //计划
    BOOL hasRec = NO;
    NSString *sqlString = [NSString stringWithFormat:@"SELECT planid FROM %@ WHERE account=?", STRTableName2];
    FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[@""]];
    hasRec = [rs next];
    [rs close];
    if (hasRec)
    {
        sqlString = [NSString stringWithFormat:@"UPDATE %@ SET account=? WHERE account=?", STRTableName2];
        
        [__db executeUpdate:sqlString withArgumentsInArray:@[user.objectId, @""]];
    }
    //影像
    hasRec = NO;
    sqlString = [NSString stringWithFormat:@"SELECT photoid FROM %@ WHERE account=?", STRTableName3];
    rs = [__db executeQuery:sqlString withArgumentsInArray:@[@""]];
    hasRec = [rs next];
    [rs close];
    if (hasRec)
    {
        sqlString = [NSString stringWithFormat:@"UPDATE %@ SET account=? WHERE account=?", STRTableName3];
        
        [__db executeUpdate:sqlString withArgumentsInArray:@[user.objectId, @""]];
    }
    //任务
    hasRec = NO;
    sqlString = [NSString stringWithFormat:@"SELECT taskId FROM %@ WHERE account=?", STRTableName5];
    rs = [__db executeQuery:sqlString withArgumentsInArray:@[@""]];
    hasRec = [rs next];
    [rs close];
    if (hasRec)
    {
        sqlString = [NSString stringWithFormat:@"UPDATE %@ SET account=? WHERE account=?", STRTableName5];
        
        [__db executeUpdate:sqlString withArgumentsInArray:@[user.objectId, @""]];
    }
}

+ (NSArray *)getPlanForSync:(NSString *)syntime
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return nil;
        }
        
        NSMutableArray *array = [NSMutableArray array];
        
        NSString *account = @"";
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            account = user.objectId;
        }
        else
        {
            return array;
        }
        
        NSString *sqlString = @"";
        if (syntime)
        {
            NSString *condition = [NSString stringWithFormat:@"datetime(updatetime)>=datetime('%@')", syntime];
            sqlString = [NSString stringWithFormat:@"SELECT planid, content, createtime, completetime, updatetime, iscompleted, isnotify, notifytime, beginDate, isdeleted, remark, isRepeat FROM %@ WHERE account=? AND %@", STRTableName2, condition];
        }
        else
        {
            sqlString = [NSString stringWithFormat:@"SELECT planid, content, createtime, completetime, updatetime, iscompleted, isnotify, notifytime, beginDate, isdeleted, remark, isRepeat FROM %@ WHERE account=?", STRTableName2];
        }
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account]];
        
        while ([rs next])
        {
            Plan *plan = [[Plan alloc] init];
            plan.account = account;
            plan.planid = [rs stringForColumn:@"planid"];
            plan.content = [rs stringForColumn:@"content"];
            plan.createtime = [rs stringForColumn:@"createtime"];
            plan.completetime = [rs stringForColumn:@"completetime"] ? : @"";
            plan.updatetime = [rs stringForColumn:@"updatetime"] ? : [rs stringForColumn:@"createtime"];
            plan.iscompleted = [rs stringForColumn:@"iscompleted"] ? : @"0";
            plan.isnotify = [rs stringForColumn:@"isnotify"] ? : @"0";
            plan.notifytime = [rs stringForColumn:@"notifytime"] ? : @"";
            plan.beginDate = [rs stringForColumn:@"beginDate"];
            plan.isRepeat = [rs stringForColumn:@"isRepeat"] ? : @"";
            plan.remark = [rs stringForColumn:@"remark"] ? : @"";
            plan.isdeleted = [rs stringForColumn:@"isdeleted"];
            
            if (!plan.beginDate
                || plan.beginDate.length == 0)
            {
                NSDate *date = [CommonFunction NSStringDateToNSDate:plan.createtime formatter:STRDateFormatterType1];
                plan.beginDate = [CommonFunction NSDateToNSString:date formatter:STRDateFormatterType4];
            }
            
            [array addObject:plan];
        }
        [rs close];
        
        return array;
    }
}

+ (Plan *)findPlan:(NSString *)account planid:(NSString *)planid
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return nil;
        }
        
        NSString *sqlString = [NSString stringWithFormat:@"SELECT planid, content, createtime, completetime, updatetime, iscompleted, isnotify, notifytime, beginDate, isdeleted FROM %@ WHERE account=? AND planid =?", STRTableName2];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account, planid]];
        
        Plan *plan = [[Plan alloc] init];
        while ([rs next])
        {
            plan.account = account;
            plan.planid = [rs stringForColumn:@"planid"];
            plan.content = [rs stringForColumn:@"content"];
            plan.createtime = [rs stringForColumn:@"createtime"];
            plan.completetime = [rs stringForColumn:@"completetime"];
            plan.updatetime = [rs stringForColumn:@"updatetime"];
            plan.iscompleted = [rs stringForColumn:@"iscompleted"];
            plan.isnotify = [rs stringForColumn:@"isnotify"];
            plan.notifytime = [rs stringForColumn:@"notifytime"];
            plan.beginDate = [rs stringForColumn:@"beginDate"];
            plan.isdeleted = [rs stringForColumn:@"isdeleted"];
            
            if (!plan.beginDate
                || plan.beginDate.length == 0)
            {
                NSDate *date = [CommonFunction NSStringDateToNSDate:plan.createtime formatter:STRDateFormatterType1];
                plan.beginDate = [CommonFunction NSDateToNSString:date formatter:STRDateFormatterType4];
            }
        }
        [rs close];
        
        return plan;
    }
}

+ (NSArray *)getPhotoForSync:(NSString *)syntime
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return nil;
        }
        
        NSMutableArray *array = [NSMutableArray array];
        
        NSString *account = @"";
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            account = user.objectId;
        }
        else
        {
            return array;
        }
        
        NSString *sqlString = @"";
        if (syntime)
        {
            NSString *condition = [NSString stringWithFormat:@"datetime(updatetime)>=datetime('%@')", syntime];
            sqlString = [NSString stringWithFormat:@"SELECT photoid, content, createtime, phototime, updatetime, location, photo1, photo2, photo3, photo4, photo5, photo6, photo7, photo8, photo9, photo1URL, photo2URL, photo3URL, photo4URL, photo5URL, photo6URL, photo7URL, photo8URL, photo9URL, isdeleted FROM %@ WHERE account=? AND %@", STRTableName3, condition];
        }
        else
        {
            sqlString = [NSString stringWithFormat:@"SELECT photoid, content, createtime, phototime, updatetime, location, photo1, photo2, photo3, photo4, photo5, photo6, photo7, photo8, photo9, photo1URL, photo2URL, photo3URL, photo4URL, photo5URL, photo6URL, photo7URL, photo8URL, photo9URL, isdeleted FROM %@ WHERE account=?", STRTableName3];
        }
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account]];
        
        while ([rs next])
        {
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
            for (NSInteger n = 0; n < 9; n++)
            {
                NSString *url = [NSString stringWithFormat:@"photo%ldURL", (long)(n + 1)];
                if ([rs stringForColumn:url])
                {
                    photo.photoURLArray[n] = [rs stringForColumn:url];
                }
                else
                {
                    photo.photoURLArray[n] = @"";
                }
            }
            photo.photoArray = [NSMutableArray arrayWithCapacity:9];
            for (NSInteger m = 0; m < 9; m++)
            {
                NSString *photoName = [NSString stringWithFormat:@"photo%ld", (long)(m + 1)];
                NSData *imageData = [rs dataForColumn:photoName];
                if (imageData)
                {
                    photo.photoArray[m] = imageData;
                }
            }
            if (!photo.content)
            {
                photo.content = @"";
            }
            if (!photo.location)
            {
                photo.location = @"";
            }
            [array addObject:photo];
        }
        [rs close];
        
        return array;
    }
}

//time : yyyy-MM-dd HH:mm:ss
+ (NSArray *)getPlanDateForStatisticsByTime:(NSString *)time
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return nil;
        }
        
        NSString *account = @"";
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            account = user.objectId;
        }
        
        NSMutableArray *array = [NSMutableArray array];
        NSString *sqlString = @"";
        FMResultSet *rs;
        if (time)
        {
            sqlString = [NSString stringWithFormat:@"SELECT createtime FROM %@ WHERE account=? AND createtime >? ORDER BY createtime", STRTableName2];
            rs = [__db executeQuery:sqlString withArgumentsInArray:@[account, time]];
        }
        else
        {
            sqlString = [NSString stringWithFormat:@"SELECT createtime FROM %@ WHERE account=? ORDER BY createtime", STRTableName2];
            rs = [__db executeQuery:sqlString withArgumentsInArray:@[account]];
        }

        while ([rs next])
        {
            NSString *time = [rs stringForColumn:@"createtime"];
            NSString *date = [[time componentsSeparatedByString:@" "] objectAtIndex:0];
            if (![array containsObject:date])
            {
                [array addObject:date];
            }
        }
        [rs close];
        
        return array;
    }
}

+ (NSArray *)getTaskForSync:(NSString *)syntime
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return nil;
        }
        
        NSString *account = @"";
        if ([LogIn isLogin])
        {
            BmobUser *user = [BmobUser currentUser];
            account = user.objectId;
        }
        
        NSMutableArray *array = [NSMutableArray array];
        
        NSString *sqlString = @"";
        if (syntime)
        {
            NSString *condition = [NSString stringWithFormat:@"datetime(updatetime)>=datetime('%@')", syntime];
            sqlString = [NSString stringWithFormat:@"SELECT taskId, content, totalCount, completionDate, createTime, updateTime, isNotify, notifyTime, isDeleted, isTomato, tomatoMinute, isRepeat, repeatType, taskOrder FROM %@ WHERE account=? AND %@", STRTableName5, condition];
        }
        else
        {
            sqlString = [NSString stringWithFormat:@"SELECT taskId, content, totalCount, completionDate, createTime, updateTime, isNotify, notifyTime, isDeleted, isTomato, tomatoMinute, isRepeat, repeatType, taskOrder FROM %@ WHERE account=?", STRTableName5];
        }
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account]];

        while ([rs next])
        {
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
            task.isTomato = [rs stringForColumn:@"isTomato"];
            task.tomatoMinute = [rs stringForColumn:@"tomatoMinute"];
            task.isRepeat = [rs stringForColumn:@"isRepeat"];
            task.repeatType = [rs stringForColumn:@"repeatType"];
            task.taskOrder = [rs stringForColumn:@"taskOrder"];
            if (!task.completionDate)
            {
                task.completionDate = @"";
            }
            if (!task.isNotify)
            {
                task.isNotify = @"0";
            }
            if (!task.notifyTime)
            {
                task.notifyTime = @"";
            }
            if (!task.isTomato)
            {
                task.isTomato = @"0";
            }
            if (!task.tomatoMinute)
            {
                task.tomatoMinute = @"";
            }
            if (!task.isRepeat)
            {
                task.isRepeat = @"0";
            }
            if (!task.repeatType)
            {
                task.repeatType = @"";
            }
            if (!task.taskOrder)
            {
                task.taskOrder = @"";
            }
            [array addObject:task];
        }
        [rs close];
        
        return array;
    }
}

+ (NSMutableArray *)getTaskRecordForSyncByTaskId:(NSString *)taskId syntime:(NSString *)syntime
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return nil;
        }
        
        NSMutableArray *array = [NSMutableArray array];
        
        NSString *sqlString = @"";
        if (syntime)
        {
            sqlString = [NSString stringWithFormat:@"SELECT recordId, createTime FROM %@ WHERE recordId=? AND createTime >=?", STRTableName6];
        }
        else
        {
            sqlString = [NSString stringWithFormat:@"SELECT recordId, createTime FROM %@ WHERE recordId=?", STRTableName6];
        }
        
        FMResultSet *rs = syntime == nil ? [__db executeQuery:sqlString withArgumentsInArray:@[taskId]] : [__db executeQuery:sqlString withArgumentsInArray:@[taskId, syntime]];
        
        while ([rs next])
        {
            TaskRecord *taskRecord = [[TaskRecord alloc] init];
            taskRecord.recordId = taskId;
            taskRecord.createTime = [rs stringForColumn:@"createTime"];
            
            [array addObject:taskRecord];
        }
        [rs close];
        
        return array;
    }
}

+ (void)cleanTaskRecordByTaskId:(NSString *)taskId
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return;
        }

        NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM %@ WHERE recordId=?", STRTableName6];

        BOOL b = [__db executeUpdate:sqlString withArgumentsInArray:@[taskId]];
        
        if (b)
        {
            NSLog(@"删除本地任务记录成功");
        }
        else
        {
            NSLog(@"删除本地任务记录失败");
        }
    }
}

+ (Task *)findTask:(NSString *)account taskId:(NSString *)taskId
{
    @synchronized(__db)
    {
        if (![__db open])
        {
            __db = nil;
            return nil;
        }
        
        NSString *sqlString = [NSString stringWithFormat:@"SELECT taskId, content, totalCount, completionDate, createTime, updateTime, isNotify, notifyTime, isDeleted, isTomato, tomatoMinute, isRepeat, repeatType, taskOrder FROM %@ WHERE account=? AND taskId =?", STRTableName5];
        
        FMResultSet *rs = [__db executeQuery:sqlString withArgumentsInArray:@[account, taskId]];
        
        Task *task = [[Task alloc] init];
        while ([rs next])
        {
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
            task.isTomato = [rs stringForColumn:@"isTomato"];
            task.tomatoMinute = [rs stringForColumn:@"tomatoMinute"];
            task.isRepeat = [rs stringForColumn:@"isRepeat"];
            task.repeatType = [rs stringForColumn:@"repeatType"];
            task.taskOrder = [rs stringForColumn:@"taskOrder"];
            if (!task.completionDate)
            {
                task.completionDate = @"";
            }
            if (!task.isNotify)
            {
                task.isNotify = @"0";
            }
            if (!task.notifyTime)
            {
                task.notifyTime = @"";
            }
            if (!task.isTomato)
            {
                task.isTomato = @"0";
            }
            if (!task.tomatoMinute)
            {
                task.tomatoMinute = @"";
            }
            if (!task.isRepeat)
            {
                task.isRepeat = @"0";
            }
            if (!task.repeatType)
            {
                task.repeatType = @"";
            }
            if (!task.taskOrder)
            {
                task.taskOrder = @"";
            }
        }
        [rs close];
        
        return task;
    }
}


@end
