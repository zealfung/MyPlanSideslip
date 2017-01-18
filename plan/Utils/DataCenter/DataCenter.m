//
//  DataCenter.m
//  plan
//
//  Created by Fengzy on 15/10/3.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "LogIn.h"
#import "PlanCache.h"
#import "DataCenter.h"
#import <BmobSDK/BmobACL.h>
#import <BmobSDK/BmobFile.h>
#import "SDWebImageDownloader.h"
#import <BmobSDK/BmobObjectsBatch.h>

static BOOL finishSettings;
static BOOL finishUploadAvatar;
static BOOL finishUploadCenterTop;
static BOOL finishPlan;
static BOOL finishTask;

@implementation DataCenter

+ (void)setPlanBeginDate {
    NSString *flag = [UserDefaults objectForKey:STRBeginDateFlag];
    if (!flag || ![flag isEqualToString:@"1"]) {
        NSArray *array = [PlanCache getPlanForSync:nil];
        for (Plan *plan in array) {
            [PlanCache storePlan:plan];
        }
        [UserDefaults setObject:@"1" forKey:STRBeginDateFlag];
        [UserDefaults synchronize];
    }
}

+ (void)startSyncData {
    
    if (![LogIn isLogin]
        || [Config shareInstance].isSyncingData) return;
    
    //重置完成标识
    [self resetUploadFlag];
    
    //把本地无账号关联的数据与当前登录账号进行关联
    [PlanCache linkedLocalDataToAccount];
    
    //优化同步逻辑后，把本地数据都过一遍，防止之前同步落下的数据
    NSString *tmp = [UserDefaults objectForKey:STRCleanCacheFlag];
    if (!tmp || ![tmp isEqualToString:@"1"]) {
        [Config shareInstance].settings.syntime = @"2015-09-01 09:09:09";
    }

    //同步影像
    [self startSyncPhoto];
    
    //同步计划
    [self startSyncPlan];
    
    //同步任务
    [self startSyncTask];

    //同步个人设置 (一定要最后同步个人设置，因为需要更新同步时间)
    [self startSyncSettings];
}

+ (void)resetUploadFlag {
    [Config shareInstance].isSyncSettingsOnly = NO;
    [Config shareInstance].isSyncingData = YES;
    finishSettings = NO;
    finishUploadAvatar = NO;
    finishUploadCenterTop = NO;
    finishPlan = NO;
    finishTask = NO;
    //优化同步逻辑后，把本地数据都过一遍，防止之前同步落下的数据
    NSString *tmp = [UserDefaults objectForKey:STRCleanCacheFlag];
    if (!tmp || ![tmp isEqualToString:@"1"]) {
        [UserDefaults setObject:@"1" forKey:STRCleanCacheFlag];
        [UserDefaults synchronize];
    }
}

+ (void)IsAllUploadFinished {
    if (finishSettings
        && finishUploadAvatar
        && finishUploadCenterTop
        && finishPlan
        && finishTask) {
        [Config shareInstance].isSyncingData = NO;
        [AlertCenter alertNavBarGreenMessage:STRViewTips122];
    }
}

+ (void)startSyncSettings {

    if ([Config shareInstance].isSyncSettingsOnly) {
        finishSettings = NO;
        finishUploadAvatar = NO;
        finishUploadCenterTop = NO;
        finishPlan = NO;
        finishTask = NO;
    }
    __weak typeof(self) weakSelf = self;
    BmobUser *user = [BmobUser currentUser];
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"UserSettings"];
    [bquery whereKey:@"userObjectId" equalTo:user.objectId];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if (array.count > 0) {
            
            BmobObject *obj = array[0];
            
            NSString *serverNickName = [obj objectForKey:@"nickName"];
            NSString *serverUpdatedTime = [obj objectForKey:@"updatedTime"];
            if (serverNickName
                && serverNickName.length > 0
                && (![Config shareInstance].settings.nickname ||
                    [Config shareInstance].settings.nickname.length == 0)) {
                    //服务器上昵称不为空，本地昵称为空，用服务器配置覆盖本地的
                    [weakSelf syncServerToLocalForSettings:obj];
                } else if ((!serverNickName || serverNickName.length == 0)
                           && [Config shareInstance].settings.nickname
                           && [Config shareInstance].settings.nickname.length > 0) {
                    //服务器上昵称为空，本地昵称不为空，用本地的覆盖服务器的
                    [weakSelf updateSettings:obj];
                } else if ([Config shareInstance].settings.updatetime
                           && [Config shareInstance].settings.updatetime.length > 0
                           && (!serverUpdatedTime || serverUpdatedTime.length == 0)) {
                    //服务器上更新时间为空，本地更新时间不为空，用本地的覆盖服务器的
                    [weakSelf updateSettings:obj];
                } else if ((![Config shareInstance].settings.updatetime
                            || [Config shareInstance].settings.updatetime.length == 0)
                           && serverUpdatedTime
                           && serverUpdatedTime.length > 0) {
                    //服务器上更新时间不为空，本地更新时间为空，用服务器配置覆盖本地的
                    [weakSelf syncServerToLocalForSettings:obj];
                } else if ([Config shareInstance].settings.updatetime.length > 0
                           && serverUpdatedTime.length > 0) {
                    NSDate *localUpdatedTime = [CommonFunction NSStringDateToNSDate:[Config shareInstance].settings.updatetime formatter:STRDateFormatterType1];
                    NSDate *serverUpdatetime = [CommonFunction NSStringDateToNSDate:serverUpdatedTime formatter:STRDateFormatterType1];
                    
                    if ([localUpdatedTime compare:serverUpdatetime] == NSOrderedAscending) {
                        //服务器的设置较新
                        [weakSelf syncServerToLocalForSettings:obj];
                        
                    } else if ([localUpdatedTime compare:serverUpdatetime] == NSOrderedDescending) {
                        //本地的设置较新
                        [weakSelf syncLocalToServerForSettings];
                    }
                } else {
                    finishSettings = YES;
                    [weakSelf IsAllUploadFinished];
                }
        } else if (!error) {//防止网络超时也会新增
            //将本地的设置同步到服务器
            [weakSelf addSettingsToServer];
        }
    }];
}

+ (void)syncServerToLocalForSettings:(BmobObject *)obj {
    [Config shareInstance].settings.objectId = obj.objectId;
    [Config shareInstance].settings.nickname = [obj objectForKey:@"nickName"];
    [Config shareInstance].settings.birthday = [obj objectForKey:@"birthday"];
    [Config shareInstance].settings.gender = [obj objectForKey:@"gender"];
    [Config shareInstance].settings.lifespan = [obj objectForKey:@"lifespan"];
    [Config shareInstance].settings.isAutoSync = [obj objectForKey:@"isAutoSync"];
    [Config shareInstance].settings.createtime = [obj objectForKey:@"createdTime"];
    [Config shareInstance].settings.updatetime = [obj objectForKey:@"updatedTime"];
    [Config shareInstance].settings.syntime = [obj objectForKey:@"syncTime"];
    [Config shareInstance].settings.countdownType = [obj objectForKey:@"countdownType"];
    [Config shareInstance].settings.dayOrMonth = [obj objectForKey:@"dayOrMonth"];
    [Config shareInstance].settings.autoDelayUndonePlan = [obj objectForKey:@"autoDelayUndonePlan"];
    [Config shareInstance].settings.signature = [obj objectForKey:@"signature"];
    
    NSString *serverAvatarURL = [obj objectForKey:@"avatarURL"];
    NSString *serverCenterTopURL = [obj objectForKey:@"centerTopURL"];
    [Config shareInstance].settings.avatar = [NSData data];
    [Config shareInstance].settings.centerTop = [NSData data];
    
    if (!serverAvatarURL || serverAvatarURL.length == 0) {
        [Config shareInstance].settings.avatarURL = @"";
    } else {
        if (![[Config shareInstance].settings.avatarURL isEqualToString:serverAvatarURL]) {
            [Config shareInstance].settings.avatarURL = serverAvatarURL;
            
            SDWebImageDownloader *imageDownloader = [SDWebImageDownloader sharedDownloader];
            NSURL *url = [NSURL URLWithString: [Config shareInstance].settings.avatarURL];
            [imageDownloader downloadImageWithURL:url options:SDWebImageDownloaderLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                NSLog(@"下载头像图片进度： %ld/%ld",(long)receivedSize , (long)expectedSize);
            } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                
                if (data) {
                    [Config shareInstance].settings.avatar = data;
                    [PlanCache storePersonalSettings:[Config shareInstance].settings];
                }
            }];
        }
    }
    
    if (!serverCenterTopURL || serverCenterTopURL.length == 0) {
        [Config shareInstance].settings.centerTopURL = @"";
    } else {
        if (![[Config shareInstance].settings.centerTopURL isEqualToString:serverCenterTopURL]) {
            [Config shareInstance].settings.centerTopURL = serverCenterTopURL;
            
            SDWebImageDownloader *imageDownloader = [SDWebImageDownloader sharedDownloader];
            NSURL *url = [NSURL URLWithString: [Config shareInstance].settings.centerTopURL];
            [imageDownloader downloadImageWithURL:url options:SDWebImageDownloaderLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                NSLog(@"下载个人中心图片进度： %ld/%ld",(long)receivedSize , (long)expectedSize);
            } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                
                if (data) {
                    [Config shareInstance].settings.centerTop = data;
                    [PlanCache storePersonalSettings:[Config shareInstance].settings];
                }
            }];
        }
    }
    [PlanCache storePersonalSettings:[Config shareInstance].settings];
    finishSettings = YES;
    [self IsAllUploadFinished];
}

+ (void)syncLocalToServerForSettings {
    __weak typeof(self) weakSelf = self;
    BmobUser *user = [BmobUser currentUser];
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"UserSettings"];
    [bquery whereKey:@"userObjectId" equalTo:user.objectId];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (array.count > 0) {
            BmobObject *obj = array[0];
            [weakSelf updateSettings:obj];
        } else if (!error) {//防止网络请求失败也会新增
            [weakSelf addSettingsToServer];
        }
    }];
}

+ (void)updateSettings:(BmobObject *)settingsObject {
    if ([Config shareInstance].settings.nickname) {
        [settingsObject setObject:[Config shareInstance].settings.nickname forKey:@"nickName"];
    }
    if ([Config shareInstance].settings.birthday) {
        [settingsObject setObject:[Config shareInstance].settings.birthday forKey:@"birthday"];
    }
    if ([Config shareInstance].settings.gender) {
        [settingsObject setObject:[Config shareInstance].settings.gender forKey:@"gender"];
    }
    if ([Config shareInstance].settings.lifespan) {
        [settingsObject setObject:[Config shareInstance].settings.lifespan forKey:@"lifespan"];
    }
    if ([Config shareInstance].settings.isAutoSync) {
        [settingsObject setObject:[Config shareInstance].settings.isAutoSync forKey:@"isAutoSync"];
    }
    if ([Config shareInstance].settings.createtime) {
        [settingsObject setObject:[Config shareInstance].settings.createtime forKey:@"createdTime"];
    }
    if ([Config shareInstance].settings.countdownType) {
        [settingsObject setObject:[Config shareInstance].settings.countdownType forKey:@"countdownType"];
    }
    if ([Config shareInstance].settings.dayOrMonth) {
        [settingsObject setObject:[Config shareInstance].settings.dayOrMonth forKey:@"dayOrMonth"];
    }
    if ([Config shareInstance].settings.autoDelayUndonePlan) {
        [settingsObject setObject:[Config shareInstance].settings.autoDelayUndonePlan forKey:@"autoDelayUndonePlan"];
    }
    if ([Config shareInstance].settings.signature) {
        [settingsObject setObject:[Config shareInstance].settings.signature forKey:@"signature"];
    }

    //上传头像
    NSString *avatarUrl = [settingsObject objectForKey:@"avatarURL"];
    NSString *centerTopUrl = [settingsObject objectForKey:@"centerTopURL"];
    if ([Config shareInstance].settings.avatar
        && ![[Config shareInstance].settings.avatarURL isEqualToString:avatarUrl]) {
        [self uploadAvatar:settingsObject];
    } else {
        finishUploadAvatar = YES;
    }
    //上传个人中心顶部图片
    if ([Config shareInstance].settings.centerTop
        && ![[Config shareInstance].settings.centerTopURL isEqualToString:centerTopUrl]) {
        [self uploadCenterTop:settingsObject];
    } else {
        finishUploadCenterTop = YES;
    }
    
    NSString *timeNow = [CommonFunction getTimeNowString];
    if (finishUploadAvatar
        && finishUploadCenterTop
        && [Config shareInstance].settings.updatetime) {
        [settingsObject setObject:[Config shareInstance].settings.updatetime forKey:@"updatedTime"];
        if (![Config shareInstance].isSyncSettingsOnly) {
            [settingsObject setObject:timeNow forKey:@"syncTime"];
        }
    }
    __weak typeof(self) weakSelf = self;
    BmobACL *acl = [BmobACL ACL];
    [acl setPublicReadAccess];//设置所有人可读
    [acl setWriteAccessForUser:[BmobUser currentUser]];//设置只有当前用户可写
    settingsObject.ACL = acl;
    [settingsObject updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            if (finishUploadAvatar
                && finishUploadCenterTop) {
                [Config shareInstance].settings.syntime = timeNow;
                [PlanCache storePersonalSettings:[Config shareInstance].settings];
            }
        } else if (error){
            NSLog(@"更新本地设置到服务器失败：%@",error);
        } else {
            NSLog(@"更新本地设置到服务器遇到未知错误");
        }
        finishSettings = YES;
        [weakSelf IsAllUploadFinished];
    }];
}

+ (void)updateVersionToServerForSettings
{
    __weak typeof(self) weakSelf = self;
    BmobUser *user = [BmobUser currentUser];
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"UserSettings"];
    [bquery whereKey:@"userObjectId" equalTo:user.objectId];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
     {
        if (array.count)
        {
            BmobObject *obj = array[0];
            [weakSelf updateVersionForSettings:obj];
        }
    }];
}

+ (void)updateVersionForSettings:(BmobObject *)settingsObject
{
    BmobObject *obj = [[BmobObject alloc] init];
    obj.objectId = settingsObject.objectId;
    [obj setObject:[CommonFunction getAppVersion] forKey:@"appVersion"];
    [obj setObject:[CommonFunction getDeviceType] forKey:@"deviceType"];
    [obj setObject:[CommonFunction getiOSVersion] forKey:@"iOSVersion"];

    BmobACL *acl = [BmobACL ACL];
    [acl setPublicReadAccess];//设置所有人可读
    [acl setWriteAccessForUser:[BmobUser currentUser]];//设置只有当前用户可写
    obj.ACL = acl;
    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
    {
        if (isSuccessful)
        {
            NSLog(@"更新版本号信息到服务器成功");
        }
        else if (error)
        {
            NSLog(@"更新版本号信息到服务器失败：%@",error);
        }
        else
        {
            NSLog(@"更新版本号信息到服务器遇到未知错误");
        }
    }];
}

+ (void)addSettingsToServer {
    BmobUser *user = [BmobUser currentUser];
    BmobObject *userSettings = [BmobObject objectWithClassName:@"UserSettings"];
    [Config shareInstance].settings = [PlanCache getPersonalSettings];
    
    [userSettings setObject:user.objectId forKey:@"userObjectId"];
    if ([Config shareInstance].settings.nickname) {
        [userSettings setObject:[Config shareInstance].settings.nickname forKey:@"nickName"];
    }
    if ([Config shareInstance].settings.birthday) {
        [userSettings setObject:[Config shareInstance].settings.birthday forKey:@"birthday"];
    }
    if ([Config shareInstance].settings.gender) {
        [userSettings setObject:[Config shareInstance].settings.gender forKey:@"gender"];
    }
    if ([Config shareInstance].settings.lifespan) {
        [userSettings setObject:[Config shareInstance].settings.lifespan forKey:@"lifespan"];
    }
    if ([Config shareInstance].settings.isAutoSync) {
        [userSettings setObject:[Config shareInstance].settings.isAutoSync forKey:@"isAutoSync"];
    }
    if ([Config shareInstance].settings.createtime) {
        [userSettings setObject:[Config shareInstance].settings.createtime forKey:@"createdTime"];
    }
    [userSettings setObject:@"2015-09-01 09:09:09" forKey:@"syncTime"];
    if ([Config shareInstance].settings.countdownType) {
        [userSettings setObject:[Config shareInstance].settings.countdownType forKey:@"countdownType"];
    }
    if ([Config shareInstance].settings.dayOrMonth) {
        [userSettings setObject:[Config shareInstance].settings.dayOrMonth forKey:@"dayOrMonth"];
    }
    if ([Config shareInstance].settings.autoDelayUndonePlan) {
        [userSettings setObject:[Config shareInstance].settings.autoDelayUndonePlan forKey:@"autoDelayUndonePlan"];
    }
    if ([Config shareInstance].settings.signature) {
        [userSettings setObject:[Config shareInstance].settings.signature forKey:@"signature"];
    }
    
    //上传头像
    if ([Config shareInstance].settings.avatar) {
        [self uploadAvatar:userSettings];
    } else {
        finishUploadAvatar = YES;
    }
    //上传个人中心顶部图片
    if ([Config shareInstance].settings.centerTop) {
        [self uploadCenterTop:userSettings];
    } else {
        finishUploadCenterTop = YES;
    }
    
    if (finishUploadAvatar
        && finishUploadCenterTop
        && [Config shareInstance].settings.updatetime) {
        [userSettings setObject:[Config shareInstance].settings.updatetime forKey:@"updatedTime"];
    }
    __weak typeof(self) weakSelf = self;
    BmobACL *acl = [BmobACL ACL];
    [acl setPublicReadAccess];//设置所有人可读
    [acl setWriteAccessForUser:user];//设置只有当前用户可写
    userSettings.ACL = acl;
    [userSettings saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        
        finishSettings = YES;
        if (isSuccessful) {
            [Config shareInstance].settings.objectId = userSettings.objectId;
            [PlanCache storePersonalSettings:[Config shareInstance].settings];
        } else if (error){
            NSLog(@"添加本地设置到服务器失败：%@",error);
        } else {
            NSLog(@"添加本地设置到服务器遇到未知错误");
        }
        [weakSelf IsAllUploadFinished];
    }];
}

+ (void)uploadAvatar:(BmobObject *)obj {
    //上传头像
    __weak typeof(self) weakSelf = self;
    BmobFile *file = [[BmobFile alloc] initWithFileName:@"avatar.png" withFileData:[Config shareInstance].settings.avatar];
    [file saveInBackground:^(BOOL isSuccessful, NSError *error) {
        finishUploadAvatar = YES;
        if (isSuccessful) {
            NSString *timeNow = [CommonFunction getTimeNowString];
            [Config shareInstance].settings.avatarURL = file.url;
            if (finishUploadAvatar
                && finishUploadCenterTop
                && [Config shareInstance].settings.updatetime) {
                if (![Config shareInstance].isSyncSettingsOnly) {
                    [obj setObject:[Config shareInstance].settings.updatetime forKey:@"updatedTime"];
                    [obj setObject:timeNow forKey:@"syncTime"];
                    [Config shareInstance].settings.syntime = timeNow;
                }
            }
            //把上传完的文件保存到“头像”字段
            [obj setObject:file.url forKey:@"avatarURL"];
            [obj updateInBackground];
            [PlanCache storePersonalSettings:[Config shareInstance].settings];
        }
        [weakSelf IsAllUploadFinished];
    } withProgressBlock:^(CGFloat progress) {
        //上传进度
        NSLog(@"上传头像进度： %f",progress);
    }];
}

+ (void)uploadCenterTop:(BmobObject *)obj {
    __weak typeof(self) weakSelf = self;
    BmobFile *file = [[BmobFile alloc] initWithFileName:@"centerTop.png" withFileData:[Config shareInstance].settings.centerTop];
    [file saveInBackground:^(BOOL isSuccessful, NSError *error) {
        finishUploadCenterTop = YES;
        if (isSuccessful) {
            NSString *timeNow = [CommonFunction getTimeNowString];
            [Config shareInstance].settings.centerTopURL = file.url;
            if (finishUploadAvatar
                && finishUploadCenterTop
                && [Config shareInstance].settings.updatetime) {
                if (![Config shareInstance].isSyncSettingsOnly) {
                    [obj setObject:[Config shareInstance].settings.updatetime forKey:@"updatedTime"];
                    [obj setObject:timeNow forKey:@"syncTime"];
                    [Config shareInstance].settings.syntime = timeNow;
                }
            }
            
            [obj setObject:file.url forKey:@"centerTopURL"];
            [obj updateInBackground];
            [PlanCache storePersonalSettings:[Config shareInstance].settings];
        }
        [weakSelf IsAllUploadFinished];
    } withProgressBlock:^(CGFloat progress) {
        //上传进度
        NSLog(@"上传个人中心图片进度： %f",progress);
    }];
}

+ (void)startSyncPlan {
    [self syncLocalToServerForPlan];
    [self syncServerToLocalForPlan];
}

+ (void)syncLocalToServerForPlan
{
    NSArray *localNewArray = [NSArray array];
    if ([Config shareInstance].settings.syntime)
    {
        localNewArray = [PlanCache getPlanForSync:[Config shareInstance].settings.syntime];
    }
    else
    {
        localNewArray = [PlanCache getPlanForSync:nil];
    }
    __weak typeof(self) weakSelf = self;
    BmobUser *user = [BmobUser currentUser];
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Plan"];
    for (Plan *plan in localNewArray)
    {
        [bquery whereKey:@"userObjectId" equalTo:user.objectId];
        [bquery whereKey:@"planId" equalTo:plan.planid];
        [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
        {
            if (array.count)
            {
                BmobObject *obj = array[0];
                NSString *serverUpdatedTime = [obj objectForKey:@"updatedTime"];
                if (plan.updatetime.length == 0 && serverUpdatedTime.length == 0)
                {

                }
                else if (plan.updatetime.length != 0 && serverUpdatedTime.length == 0)
                {
                    [weakSelf updatePlanForServer:plan obj:obj];
                }
                else if (plan.updatetime.length == 0 && serverUpdatedTime.length != 0)
                {
                    
                }
                else
                {
                    NSDate *localDate = [CommonFunction NSStringDateToNSDate:plan.updatetime formatter:STRDateFormatterType1];
                    NSDate *serverDate = [CommonFunction NSStringDateToNSDate:serverUpdatedTime formatter:STRDateFormatterType1];
                    
                    if ([localDate compare:serverDate] == NSOrderedAscending)
                    {
                        
                    }
                    else if ([localDate compare:serverDate] == NSOrderedDescending)
                    {
                        //本地的设置较新
                        [weakSelf updatePlanForServer:plan obj:obj];
                    }
                }
            }
            else if (!error)
            {//防止网络超时也会新增
                BmobObject *newPlan = [BmobObject objectWithClassName:@"Plan"];
                NSDictionary *dic = @{@"userObjectId":plan.account,
                                      @"planId":plan.planid,
                                      @"content":plan.content,
                                      @"createdTime":plan.createtime,
                                      @"completedTime":plan.completetime,
                                      @"updatedTime":plan.updatetime,
                                      @"notifyTime":plan.notifytime,
                                      @"isCompleted":plan.iscompleted,
                                      @"isNotify":plan.isnotify,
                                      @"isDeleted":plan.isdeleted,
                                      @"isRepeat":plan.isRepeat,
                                      @"remark":plan.remark,
                                      @"beginDate":plan.beginDate};
                [newPlan saveAllWithDictionary:dic];
                BmobACL *acl = [BmobACL ACL];
                [acl setReadAccessForUser:user];//设置只有当前用户可读
                [acl setWriteAccessForUser:user];//设置只有当前用户可写
                newPlan.ACL = acl;
                [newPlan saveInBackground];
            }
        }];
    }
}

+ (void)updatePlanForServer:(Plan *)plan obj:(BmobObject *)obj
{
    if (plan.content)
    {
        [obj setObject:plan.content forKey:@"content"];
    }
    if (plan.completetime)
    {
        [obj setObject:plan.completetime forKey:@"completedTime"];
    }
    if (plan.updatetime)
    {
        [obj setObject:plan.updatetime forKey:@"updatedTime"];
    }
    if (plan.notifytime)
    {
        [obj setObject:plan.notifytime forKey:@"notifyTime"];
    }
    if (plan.iscompleted)
    {
        [obj setObject:plan.iscompleted forKey:@"isCompleted"];
    }
    if (plan.isnotify)
    {
        [obj setObject:plan.isnotify forKey:@"isNotify"];
    }
    if (plan.isdeleted)
    {
        [obj setObject:plan.isdeleted forKey:@"isDeleted"];
    }
    if (plan.isRepeat)
    {
        [obj setObject:plan.isRepeat forKey:@"isRepeat"];
    }
    if (plan.remark)
    {
        [obj setObject:plan.remark forKey:@"remark"];
    }
    if (plan.beginDate)
    {
        [obj setObject:plan.beginDate forKey:@"beginDate"];
    }
    BmobACL *acl = [BmobACL ACL];
    [acl setReadAccessForUser:[BmobUser currentUser]];//设置只有当前用户可读
    [acl setWriteAccessForUser:[BmobUser currentUser]];//设置只有当前用户可写
    obj.ACL = acl;
    [obj updateInBackground];
}

+ (void)syncServerToLocalForPlan
{
    BmobUser *user = [BmobUser currentUser];
    NSString *count = [PlanCache getPlanTotalCount:@"ALL"];
    __weak typeof(self) weakSelf = self;
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Plan"];
    [bquery whereKey:@"userObjectId" equalTo:user.objectId];
    [bquery whereKey:@"isDeleted" notEqualTo:@"1"];
    [bquery orderByDescending:@"updatedTime"];
    if ([count integerValue])
    {
        bquery.limit = 100;
    }
    else
    {
        bquery.limit = 999;
    }
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
    {
        if (!error && array.count)
        {
            for (BmobObject *obj in array)
            {
                Plan *plan = [PlanCache findPlan:user.objectId planid:[obj objectForKey:@"planId"]];
                if (plan.content)
                {
                    NSDate *localDate = [CommonFunction NSStringDateToNSDate:plan.updatetime formatter:STRDateFormatterType1];
                    NSDate *serverDate = [CommonFunction NSStringDateToNSDate:[obj objectForKey:@"updatedTime"] formatter:STRDateFormatterType1];
                    
                    if ([localDate compare:serverDate] == NSOrderedAscending)
                    {
                        //服务器的较新
                        [weakSelf updatePlanForLocal:plan obj:obj];
                        
                    }
                    else if ([localDate compare:serverDate] == NSOrderedDescending)
                    {
                        //本地的设置较新
                    }
                }
                else
                {
                    [weakSelf updatePlanForLocal:plan obj:obj];
                }
            }
        }
        finishPlan = YES;
        [weakSelf IsAllUploadFinished];
    }];
}

+ (void)updatePlanForLocal:(Plan *)plan obj:(BmobObject *)obj
{
    plan.account = [obj objectForKey:@"userObjectId"];
    plan.planid = [obj objectForKey:@"planId"];
    plan.content = [obj objectForKey:@"content"];
    plan.createtime = [obj objectForKey:@"createdTime"];
    plan.completetime = [obj objectForKey:@"completedTime"];
    plan.updatetime = [obj objectForKey:@"updatedTime"];
    plan.notifytime = [obj objectForKey:@"notifyTime"];
    plan.iscompleted = [obj objectForKey:@"isCompleted"];
    plan.isnotify = [obj objectForKey:@"isNotify"];
    plan.isdeleted = [obj objectForKey:@"isDeleted"];
    plan.isRepeat = [obj objectForKey:@"isRepeat"];
    plan.remark = [obj objectForKey:@"remark"];
    plan.beginDate = [obj objectForKey:@"beginDate"];
    [PlanCache storePlan:plan];
}

+ (void)startSyncPhoto {
    //优化同步逻辑后，把本地数据都过一遍，防止之前同步落下的数据
    NSString *tmp = [UserDefaults objectForKey:STRCleanCacheFlag];
    if (!tmp || ![tmp isEqualToString:@"1"]) {
        [self syncLocalToServerForPhoto];
    } else {
        [self syncLocalToServerForPhoto];
        [self syncServerToLocalForPhoto];
    }
}

+ (void)syncLocalToServerForPhoto {
    __weak typeof(self) weakSelf = self;
    NSArray *localNewArray = [NSArray array];
    if ([Config shareInstance].settings.syntime.length > 0) {
        localNewArray = [PlanCache getPhotoForSync:[Config shareInstance].settings.syntime];
    } else {
        localNewArray = [PlanCache getPhotoForSync:nil];
    }
    BmobUser *user = [BmobUser currentUser];
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Photo"];
    for (Photo *photo in localNewArray) {
        [bquery whereKey:@"userObjectId" equalTo:user.objectId];
        [bquery whereKey:@"photoId" equalTo:photo.photoid];
        [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            if (array.count > 0) {
                BmobObject *obj = array[0];
                //优化同步逻辑后，把本地数据都过一遍，防止之前同步落下的数据
                NSString *tmp = [UserDefaults objectForKey:STRCleanCacheFlag];
                if (!tmp || ![tmp isEqualToString:@"1"]) {
                    [weakSelf updatePhotoForServer:photo obj:obj];
                } else {
                    NSString *serverUpdatedTime = [obj objectForKey:@"updatedTime"];
                    NSDate *localDate = [CommonFunction NSStringDateToNSDate:photo.updatetime formatter:STRDateFormatterType1];
                    NSDate *serverDate = [CommonFunction NSStringDateToNSDate:serverUpdatedTime formatter:STRDateFormatterType1];
                    
                    if ([localDate compare:serverDate] == NSOrderedAscending) {
                        
                    } else if ([localDate compare:serverDate] == NSOrderedDescending) {
                        //本地的设置较新
                        [weakSelf updatePhotoForServer:photo obj:obj];
                    }
                }
            } else if (!error) {//防止网络超时也会新增
                [weakSelf addPhotoToServer:photo];
            }
        }];
    }
}

+ (void)addPhotoToServer:(Photo *)photo {
    BmobObject *newPhoto = [BmobObject objectWithClassName:@"Photo"];
    NSDictionary *dic = @{@"userObjectId":photo.account,
                          @"photoId":photo.photoid,
                          @"content":photo.content,
                          @"location":photo.location,
                          @"createdTime":photo.createtime,
                          @"photoTime":photo.phototime,
                          @"updatedTime":@"2015-09-09 09:09:09",
                          @"isDeleted":photo.isdeleted};
    [newPhoto saveAllWithDictionary:dic];
    __weak typeof(self) weakSelf = self;
    BmobACL *acl = [BmobACL ACL];
    [acl setReadAccessForUser:[BmobUser currentUser]];//设置只有当前用户可读
    [acl setWriteAccessForUser:[BmobUser currentUser]];//设置只有当前用户可写
    newPhoto.ACL = acl;
    [newPhoto saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            for (NSInteger i = 0; i < photo.photoArray.count; i++) {
                [weakSelf uploadPhoto:photo index:i obj:newPhoto];
            }
        } else if (error){
            NSLog(@"新增岁月影像到服务器失败：%@",error);
        } else {
            NSLog(@"新增岁月影像到服务器失败：Unknow error");
        }
    }];
}

+ (void)updatePhotoForServer:(Photo *)photo obj:(BmobObject *)obj {
    BmobUser *user = [BmobUser currentUser];
    if (photo.content) {
        [obj setObject:photo.content forKey:@"content"];
    }
    if (photo.phototime) {
        [obj setObject:photo.phototime forKey:@"photoTime"];
    }
    if (photo.location) {
        [obj setObject:photo.location forKey:@"location"];
    }
    if (photo.photoArray.count < 9) {
        for (NSInteger i = photo.photoArray.count; i < 9; i++) {
            NSString *urlName = [NSString stringWithFormat:@"photo%ldURL", (long)(i+1)];
            [obj setObject:@"" forKey:urlName];
        }
    }
    BmobACL *acl = [BmobACL ACL];
    [acl setReadAccessForUser:user];//设置只有当前用户可读
    [acl setWriteAccessForUser:user];//设置只有当前用户可写
    obj.ACL = acl;
    [obj updateInBackground];

    for (NSInteger i = 0; i < photo.photoArray.count; i++) {
        [self uploadPhoto:photo index:i obj:obj];
    }
}

+ (void)uploadPhoto:(Photo *)photo index:(NSInteger)index obj:(BmobObject *)obj {
    NSData *imgData = photo.photoArray[index];
    NSString *urlName = [NSString stringWithFormat:@"photo%ldURL", (long)(index+1)];
    NSString *serverURL = [obj objectForKey:urlName];
    if ((!serverURL
         || serverURL.length == 0
         || ![photo.photoURLArray[index] isEqualToString:serverURL])
        && imgData) {
        
        BmobFile *file = [[BmobFile alloc] initWithFileName:@"imgPhoto.png" withFileData:imgData];
        [file saveInBackground:^(BOOL isSuccessful, NSError *error) {
            
            if (isSuccessful) {
                [obj setObject:file.url forKey:urlName];
                [obj setObject:photo.updatetime forKey:@"updatedTime"];
                [obj updateInBackground];
                
                photo.photoURLArray[index] = file.url;
                [PlanCache storePhoto:photo];
            }

        } withProgressBlock:^(CGFloat progress) {
            //上传进度
            NSLog(@"上传影像图片进度： %f",progress);
        }];
    }
}

+ (void)syncServerToLocalForPhoto {
    NSString *count = [PlanCache getPhotoTotalCount];
    BmobUser *user = [BmobUser currentUser];
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Photo"];
    [bquery whereKey:@"userObjectId" equalTo:user.objectId];
    [bquery whereKey:@"isDeleted" notEqualTo:@"1"];
    [bquery orderByDescending:@"updatedTime"];
    if ([count integerValue] > 0) {
        bquery.limit = 100;
    } else {
        bquery.limit = 999;
    }
    __weak typeof(self) weakSelf = self;
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (!error && array.count > 0) {
            for (BmobObject *obj in array) {
                Photo *photo = [PlanCache getPhotoById:[obj objectForKey:@"photoId"]];
                if (photo.createtime) {
                    NSDate *localDate = [CommonFunction NSStringDateToNSDate:photo.updatetime formatter:STRDateFormatterType1];
                    NSDate *serverDate = [CommonFunction NSStringDateToNSDate:[obj objectForKey:@"updatedTime"] formatter:STRDateFormatterType1];
                    
                    if ([localDate compare:serverDate] == NSOrderedAscending) {
                        //服务器的较新
                        [weakSelf updatePhotoForLocal:photo obj:obj];
                        
                    } else if ([localDate compare:serverDate] == NSOrderedDescending) {
                        //本地的设置较新
                    }
                } else {
                    [weakSelf updatePhotoForLocal:photo obj:obj];
                }
            }
        }
    }];
}

+ (void)updatePhotoForLocal:(Photo *)photo obj:(BmobObject *)obj {
    photo.account = [obj objectForKey:@"userObjectId"];
    photo.photoid = [obj objectForKey:@"photoId"];
    photo.content = [obj objectForKey:@"content"];
    photo.createtime = [obj objectForKey:@"createdTime"];
    photo.phototime = [obj objectForKey:@"photoTime"];
    photo.updatetime = [obj objectForKey:@"updatedTime"];
    photo.location = [obj objectForKey:@"location"];
    photo.isdeleted = @"0";
    if (!photo.photoURLArray) {
        photo.photoURLArray = [NSMutableArray arrayWithCapacity:9];
        for (NSInteger i = 0; i < 9; i++) {
            photo.photoURLArray[i] = @"";
        }
    }
    if (!photo.photoArray) {
        photo.photoArray = [NSMutableArray array];
    }
    for (NSInteger i = 0; i < 9; i++) {
        NSString *urlName = [NSString stringWithFormat:@"photo%ldURL", (long)(i + 1)];
        NSString *serverPhotoURL = [obj objectForKey:urlName];
        if (serverPhotoURL
            && serverPhotoURL.length > 0
            && ![photo.photoURLArray[i] isEqualToString:serverPhotoURL]) {
            //本地与服务器的URL不一样，需要更新本地图片
            [self downloadPhoto:photo index:i url:serverPhotoURL];
        }
    }
    [PlanCache storePhoto:photo];
}

+ (void)downloadPhoto:(Photo *)photo index:(NSInteger)index url:(NSString *)url {
    photo.photoURLArray[index] = url;
    
    SDWebImageDownloader *imageDownloader = [SDWebImageDownloader sharedDownloader];
    [imageDownloader downloadImageWithURL:[NSURL URLWithString:url] options:SDWebImageDownloaderLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        NSLog(@"下载影像图片进度： %ld/%ld",receivedSize , expectedSize);
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        
        if (data) {
            if (index < photo.photoArray.count) {
                photo.photoArray[index] = data;
            } else {
                [photo.photoArray addObject:data];
            }
            [PlanCache storePhoto:photo];
        }
    }];
}

+ (void)startSyncTask {
    [self syncLocalToServerForTask];
    [self syncServerToLocalForTask];
}

+ (void)syncLocalToServerForTask {
    __weak typeof(self) weakSelf = self;
    BmobUser *user = [BmobUser currentUser];
    NSArray *localNewArray = [NSArray array];
    if ([Config shareInstance].settings.syntime.length > 0) {
        
        localNewArray = [PlanCache getTaskForSync:[Config shareInstance].settings.syntime];
    } else {
        
        localNewArray = [PlanCache getTaskForSync:nil];
    }
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Task"];
    for (Task *task in localNewArray) {
        [bquery whereKey:@"userObjectId" equalTo:user.objectId];
        [bquery whereKey:@"taskId" equalTo:task.taskId];
        [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            
            if (array.count > 0) {
                BmobObject *obj = array[0];
                NSString *serverUpdatedTime = [obj objectForKey:@"updatedTime"];
                NSDate *localDate = [CommonFunction NSStringDateToNSDate:task.updateTime formatter:STRDateFormatterType1];
                NSDate *serverDate = [CommonFunction NSStringDateToNSDate:serverUpdatedTime formatter:STRDateFormatterType1];
                
                if ([localDate compare:serverDate] == NSOrderedAscending) {
                    
                } else if ([localDate compare:serverDate] == NSOrderedDescending) {
                    //本地的设置较新
                    [weakSelf updateTaskForServer:task obj:obj];
                    //同时上传改任务的完成记录
                    [weakSelf syncTaskRecord:task.taskId syncTime:[Config shareInstance].settings.syntime];
                }
            } else if (!error) {
                BmobObject *newTask = [BmobObject objectWithClassName:@"Task"];
                NSDictionary *dic = @{@"userObjectId":task.account,
                                      @"taskId":task.taskId,
                                      @"content":task.content,
                                      @"totalCount":task.totalCount,
                                      @"completionDate":task.completionDate,
                                      @"createdTime":task.createTime,
                                      @"updatedTime":task.updateTime,
                                      @"isNotify":task.isNotify,
                                      @"notifyTime":task.notifyTime,
                                      @"isTomato":task.isTomato,
                                      @"tomatoMinute":task.tomatoMinute,
                                      @"isRepeat":task.isRepeat,
                                      @"repeatType":task.repeatType,
                                      @"taskOrder":task.taskOrder,
                                      @"isDeleted":task.isDeleted};
                [newTask saveAllWithDictionary:dic];
                BmobACL *acl = [BmobACL ACL];
                [acl setReadAccessForUser:[BmobUser currentUser]];//设置只有当前用户可读
                [acl setWriteAccessForUser:[BmobUser currentUser]];//设置只有当前用户可写
                newTask.ACL = acl;
                [newTask saveInBackground];
                //同时上传改任务的完成记录
                [weakSelf syncTaskRecord:task.taskId syncTime:[Config shareInstance].settings.syntime];
            }
        }];
    }
}

+ (void)syncTaskRecord:(NSString *)taskId syncTime:(NSString *)syncTime {
    NSArray *localNewArray = [NSArray array];
    if (syncTime.length > 0) {
        localNewArray = [PlanCache getTaskRecordForSyncByTaskId:taskId syntime:syncTime];
    } else {
        localNewArray = [PlanCache getTaskRecordForSyncByTaskId:taskId syntime:nil];
    }
    BmobUser *user = [BmobUser currentUser];
    for (TaskRecord *taskrecord in localNewArray) {
        
        BmobObject *newTaskRecord = [BmobObject objectWithClassName:@"TaskRecord"];
        NSDictionary *dic = @{@"userObjectId":user.objectId,
                              @"recordId":taskrecord.recordId,
                              @"createdTime":taskrecord.createTime};
        [newTaskRecord saveAllWithDictionary:dic];
        BmobACL *acl = [BmobACL ACL];
        [acl setReadAccessForUser:user];//设置只有当前用户可读
        [acl setWriteAccessForUser:user];//设置只有当前用户可写
        newTaskRecord.ACL = acl;
        [newTaskRecord saveInBackground];
    }
}

+ (void)updateTaskForServer:(Task *)task obj:(BmobObject *)obj {
    if (task.content) {
        [obj setObject:task.content forKey:@"content"];
    }
    if (task.totalCount) {
        [obj setObject:task.totalCount forKey:@"totalCount"];
    }
    if (task.completionDate) {
        [obj setObject:task.completionDate forKey:@"completionDate"];
    }
    if (task.updateTime) {
        [obj setObject:task.updateTime forKey:@"updatedTime"];
    }
    if (task.isNotify) {
        [obj setObject:task.isNotify forKey:@"isNotify"];
    }
    if (task.notifyTime) {
        [obj setObject:task.notifyTime forKey:@"notifyTime"];
    }
    if (task.isTomato) {
        [obj setObject:task.isTomato forKey:@"isTomato"];
    }
    if (task.tomatoMinute) {
        [obj setObject:task.tomatoMinute forKey:@"tomatoMinute"];
    }
    if (task.isRepeat) {
        [obj setObject:task.isRepeat forKey:@"isRepeat"];
    }
    if (task.repeatType) {
        [obj setObject:task.repeatType forKey:@"repeatType"];
    }
    if (task.taskOrder) {
        [obj setObject:task.taskOrder forKey:@"taskOrder"];
    }
    if (task.isDeleted) {
        [obj setObject:task.isDeleted forKey:@"isDeleted"];
    }
    BmobACL *acl = [BmobACL ACL];
    [acl setReadAccessForUser:[BmobUser currentUser]];//设置只有当前用户可读
    [acl setWriteAccessForUser:[BmobUser currentUser]];//设置只有当前用户可写
    obj.ACL = acl;
    [obj updateInBackground];
}

+ (void)syncServerToLocalForTask {
    __weak typeof(self) weakSelf = self;
    BmobUser *user = [BmobUser currentUser];
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Task"];
    [bquery whereKey:@"userObjectId" equalTo:user.objectId];
    [bquery whereKey:@"isDeleted" notEqualTo:@"1"];
    [bquery orderByDescending:@"updatedTime"];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (!error && array.count > 0) {
            
            for (BmobObject *obj in array) {
                
                Task *task = [PlanCache findTask:user.objectId taskId:[obj objectForKey:@"taskId"]];
                if (task.content) {
                    
                    NSDate *localDate = [CommonFunction NSStringDateToNSDate:task.updateTime formatter:STRDateFormatterType1];
                    NSDate *serverDate = [CommonFunction NSStringDateToNSDate:[obj objectForKey:@"updatedTime"] formatter:STRDateFormatterType1];
                    
                    if ([localDate compare:serverDate] == NSOrderedAscending) {
                        //服务器的较新
                        [weakSelf updateTaskForLocal:task obj:obj];
                        
                    } else if ([localDate compare:serverDate] == NSOrderedDescending) {
                        //本地的设置较新
                    }
                } else {
                    [weakSelf updateTaskForLocal:task obj:obj];
                }
            }
        }
        finishTask = YES;
        [weakSelf IsAllUploadFinished];
    }];
}

+ (void)updateTaskForLocal:(Task *)task obj:(BmobObject *)obj {
    task.account = [obj objectForKey:@"userObjectId"];
    task.taskId = [obj objectForKey:@"taskId"];
    task.content = [obj objectForKey:@"content"];
    task.totalCount = [obj objectForKey:@"totalCount"];
    task.completionDate = [obj objectForKey:@"completionDate"];
    task.createTime = [obj objectForKey:@"createdTime"];
    task.updateTime = [obj objectForKey:@"updatedTime"];
    task.isNotify = [obj objectForKey:@"isNotify"];
    task.notifyTime = [obj objectForKey:@"notifyTime"];
    task.isTomato = [obj objectForKey:@"isTomato"];
    task.tomatoMinute = [obj objectForKey:@"tomatoMinute"];
    task.isRepeat = [obj objectForKey:@"isRepeat"];
    task.repeatType = [obj objectForKey:@"repeatType"];
    task.taskOrder = [obj objectForKey:@"taskOrder"];
    task.isDeleted = [obj objectForKey:@"isDeleted"];
    [self getNewTaskRecordFromServer:task.taskId];
    [PlanCache storeTask:task updateNotify:YES];
}

+ (void)getNewTaskRecordFromServer:(NSString *)recordId {
    BmobUser *user = [BmobUser currentUser];
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"TaskRecord"];
    [bquery whereKey:@"userObjectId" equalTo:user.objectId];
    [bquery whereKey:@"recordId" equalTo:recordId];
    NSString *time = [Config shareInstance].settings.syntime;
    [bquery whereKey:@"createdTime" greaterThanOrEqualTo:time];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (!error && array.count > 0) {
            
            for (BmobObject *obj in array) {
                
                TaskRecord *taskRecord = [[TaskRecord alloc] init];
                taskRecord.recordId = recordId;
                taskRecord.createTime = [obj objectForKey:@"createdTime"];
                [PlanCache storeTaskRecord:taskRecord];
            }
        }
    }];
}

+ (void)getMessagesFromServer {
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Messages"];
    //构造约束条件
    BmobQuery *inQuery = [BmobQuery queryWithClassName:@"_User"];
    if ([LogIn isLogin]) {
        BmobUser *user = [BmobUser currentUser];
        [inQuery whereKey:@"username" equalTo:user.username];
        //匹配查询
        //    [bquery whereKey:@"hasRead" matchesQuery:inQuery];（查询所有有关联的数据）
        [bquery whereKey:@"hasRead" doesNotMatchQuery:inQuery];//（查询所有无关联的数据）
    }
    [bquery whereKey:@"isDeleted" equalTo:@"0"];//只加载未删除的
    [bquery orderByDescending:@"createdAt"];
    bquery.limit = 10;
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {

        for (BmobObject *obj in array) {
            Messages *message = [[Messages alloc] init];
            message.messageId = obj.objectId;
            message.title = [obj objectForKey:@"title"];
            message.content = [obj objectForKey:@"content"];
            message.detailURL = [obj objectForKey:@"detailURL"];
            message.imgURLArray = [obj objectForKey:@"imgURLArray"];
            message.canShare = [obj objectForKey:@"canShare"];
            message.messageType = @"1";
            message.createTime = [CommonFunction NSDateToNSString:obj.createdAt formatter:STRDateFormatterType1];
            
            [PlanCache storeMessages:message];
        }
    }];

    //加载回复和点赞通知
    if ([LogIn isLogin]) {
        BmobUser *user = [BmobUser currentUser];
        BmobQuery *nquery = [BmobQuery queryWithClassName:@"Notices"];
        [nquery includeKey:@"fromUser"];
        [nquery whereKey:@"hasRead" equalTo:@"0"];
        [nquery whereKey:@"toAuthorObjectId" equalTo:user.objectId];
        [nquery orderByDescending:@"createdAt"];
        [nquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            
            for (BmobObject *obj in array) {
                BmobObject *author = [obj objectForKey:@"fromUser"];
                NSString *noticeType = [obj objectForKey:@"noticeType"];
                NSString *nickName = [author objectForKey:@"nickName"];
                if (!nickName || nickName.length == 0) nickName = STRViewTips116;
                
                Messages *message = [[Messages alloc] init];
                message.messageId = obj.objectId;
                switch ([noticeType integerValue]) {//通知类型：1赞帖子 2赞评论 3回复帖子 4回复评论
                    case 1:
                        message.title = [NSString stringWithFormat:@"%@ %@", nickName, STRViewTips117];
                        break;
                    case 2:
                        message.title = [NSString stringWithFormat:@"%@ %@", nickName, STRViewTips118];
                        break;
                    case 3:
                        message.title = [NSString stringWithFormat:@"%@ %@", nickName, STRViewTips119];
                        break;
                    case 4:
                        message.title = [NSString stringWithFormat:@"%@ %@", nickName, STRViewTips120];
                        break;
                    default:
                        break;
                }
                message.content = [obj objectForKey:@"noticeForContent"];
                message.detailURL = [obj objectForKey:@"postsObjectId"];
                message.canShare = @"0";
                message.messageType = @"2";
                message.createTime = [CommonFunction NSDateToNSString:obj.createdAt formatter:STRDateFormatterType1];
                
                [PlanCache storeMessages:message];
            }
        }];
    }
}

@end
