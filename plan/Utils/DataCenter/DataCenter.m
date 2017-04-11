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


@implementation DataCenter

+ (void)startSyncData
{
    if (![LogIn isLogin])
        return;
    
    //把本地无账号关联的数据与当前登录账号进行关联
    [PlanCache linkedLocalDataToAccount];
    
    //同步影像
    [self startSyncPhoto];
    
    //同步计划
    [self startSyncPlan];
    
    //同步任务
    [self startSyncTask];

    //同步个人设置 (一定要最后同步个人设置，因为需要更新同步时间)
    [self startSyncSettings];
}

+ (void)startSyncSettings
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
             
             NSString *serverNickName = [obj objectForKey:@"nickName"];
             NSString *serverUpdatedTime = [obj objectForKey:@"updatedTime"];
             if ((!serverNickName || serverNickName.length == 0)
                      && [Config shareInstance].settings.nickname
                      && [Config shareInstance].settings.nickname.length)
             {
                 //服务器上昵称为空，本地昵称不为空，用本地的覆盖服务器的
                 [weakSelf updateSettings:obj];
             }
             else if ([Config shareInstance].settings.updatetime
                      && [Config shareInstance].settings.updatetime.length
                      && (!serverUpdatedTime || serverUpdatedTime.length == 0))
             {
                 //服务器上更新时间为空，本地更新时间不为空，用本地的覆盖服务器的
                 [weakSelf updateSettings:obj];
             }
             else if ([Config shareInstance].settings.updatetime.length
                      && serverUpdatedTime.length > 0) {
                 NSDate *localUpdatedTime = [CommonFunction NSStringDateToNSDate:[Config shareInstance].settings.updatetime formatter:STRDateFormatterType1];
                 NSDate *serverUpdatetime = [CommonFunction NSStringDateToNSDate:serverUpdatedTime formatter:STRDateFormatterType1];
                 
                 if ([localUpdatedTime compare:serverUpdatetime] == NSOrderedDescending)
                 {
                     //本地的设置较新
                     [weakSelf syncLocalToServerForSettings];
                 }
             }
             else
             {
                 [PlanCache deletePersonalSettings:[Config shareInstance].settings];
             }
         }
         else if (!error)
         {//防止网络超时也会新增
             //将本地的设置同步到服务器
             [weakSelf addSettingsToServer];
         }
     }];
}

+ (void)syncLocalToServerForSettings
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
            [weakSelf updateSettings:obj];
        }
        else if (!error)
        {//防止网络请求失败也会新增
            [weakSelf addSettingsToServer];
        }
    }];
}

+ (void)updateSettings:(BmobObject *)settingsObject
{
    if ([Config shareInstance].settings.nickname)
    {
        [settingsObject setObject:[Config shareInstance].settings.nickname forKey:@"nickName"];
    }
    if ([Config shareInstance].settings.birthday)
    {
        [settingsObject setObject:[Config shareInstance].settings.birthday forKey:@"birthday"];
    }
    if ([Config shareInstance].settings.gender)
    {
        [settingsObject setObject:[Config shareInstance].settings.gender forKey:@"gender"];
    }
    if ([Config shareInstance].settings.lifespan)
    {
        [settingsObject setObject:[Config shareInstance].settings.lifespan forKey:@"lifespan"];
    }
    if ([Config shareInstance].settings.isAutoSync)
    {
        [settingsObject setObject:[Config shareInstance].settings.isAutoSync forKey:@"isAutoSync"];
    }
    if ([Config shareInstance].settings.createtime)
    {
        [settingsObject setObject:[Config shareInstance].settings.createtime forKey:@"createdTime"];
    }
    if ([Config shareInstance].settings.countdownType)
    {
        [settingsObject setObject:[Config shareInstance].settings.countdownType forKey:@"countdownType"];
    }
    if ([Config shareInstance].settings.dayOrMonth)
    {
        [settingsObject setObject:[Config shareInstance].settings.dayOrMonth forKey:@"dayOrMonth"];
    }
    if ([Config shareInstance].settings.autoDelayUndonePlan)
    {
        [settingsObject setObject:[Config shareInstance].settings.autoDelayUndonePlan forKey:@"autoDelayUndonePlan"];
    }
    if ([Config shareInstance].settings.signature)
    {
        [settingsObject setObject:[Config shareInstance].settings.signature forKey:@"signature"];
    }

    //上传头像
    NSString *avatarUrl = [settingsObject objectForKey:@"avatarURL"];
    NSString *centerTopUrl = [settingsObject objectForKey:@"centerTopURL"];
    if ([Config shareInstance].settings.avatar
        && ![[Config shareInstance].settings.avatarURL isEqualToString:avatarUrl])
    {
        [self uploadAvatar:settingsObject];
    }

    //上传个人中心顶部图片
    if ([Config shareInstance].settings.centerTop
        && ![[Config shareInstance].settings.centerTopURL isEqualToString:centerTopUrl])
    {
        [self uploadCenterTop:settingsObject];
    }

    BmobACL *acl = [BmobACL ACL];
    [acl setPublicReadAccess];//设置所有人可读
    [acl setWriteAccessForUser:[BmobUser currentUser]];//设置只有当前用户可写
    settingsObject.ACL = acl;
    [settingsObject updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
     {
        if (isSuccessful)
        {
            NSLog(@"更新本地设置到服务器成功");
        }
        else if (error)
        {
            NSLog(@"更新本地设置到服务器失败：%@",error);
        }
        else
        {
            NSLog(@"更新本地设置到服务器遇到未知错误");
        }
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

+ (void)updateVersionForSettings:(BmobObject *)obj
{
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

+ (void)addSettingsToServer
{
    BmobUser *user = [BmobUser currentUser];
    BmobObject *userSettings = [BmobObject objectWithClassName:@"UserSettings"];
    [Config shareInstance].settings = [PlanCache getPersonalSettings];
    
    [userSettings setObject:user.objectId forKey:@"userObjectId"];
    if ([Config shareInstance].settings.nickname)
    {
        [userSettings setObject:[Config shareInstance].settings.nickname forKey:@"nickName"];
    }
    if ([Config shareInstance].settings.birthday)
    {
        [userSettings setObject:[Config shareInstance].settings.birthday forKey:@"birthday"];
    }
    if ([Config shareInstance].settings.gender)
    {
        [userSettings setObject:[Config shareInstance].settings.gender forKey:@"gender"];
    }
    if ([Config shareInstance].settings.lifespan)
    {
        [userSettings setObject:[Config shareInstance].settings.lifespan forKey:@"lifespan"];
    }
    if ([Config shareInstance].settings.isAutoSync)
    {
        [userSettings setObject:[Config shareInstance].settings.isAutoSync forKey:@"isAutoSync"];
    }
    if ([Config shareInstance].settings.createtime)
    {
        [userSettings setObject:[Config shareInstance].settings.createtime forKey:@"createdTime"];
    }
    [userSettings setObject:@"2015-09-01 09:09:09" forKey:@"syncTime"];
    if ([Config shareInstance].settings.countdownType)
    {
        [userSettings setObject:[Config shareInstance].settings.countdownType forKey:@"countdownType"];
    }
    if ([Config shareInstance].settings.dayOrMonth)
    {
        [userSettings setObject:[Config shareInstance].settings.dayOrMonth forKey:@"dayOrMonth"];
    }
    if ([Config shareInstance].settings.autoDelayUndonePlan)
    {
        [userSettings setObject:[Config shareInstance].settings.autoDelayUndonePlan forKey:@"autoDelayUndonePlan"];
    }
    if ([Config shareInstance].settings.signature)
    {
        [userSettings setObject:[Config shareInstance].settings.signature forKey:@"signature"];
    }
    
    //上传头像
    if ([Config shareInstance].settings.avatar)
    {
        [self uploadAvatar:userSettings];
    }
    
    //上传个人中心顶部图片
    if ([Config shareInstance].settings.centerTop)
    {
        [self uploadCenterTop:userSettings];
    }

    BmobACL *acl = [BmobACL ACL];
    [acl setPublicReadAccess];//设置所有人可读
    [acl setWriteAccessForUser:user];//设置只有当前用户可写
    userSettings.ACL = acl;
    [userSettings saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
    {
        if (isSuccessful)
        {
            NSLog(@"添加本地设置到服务器成功");
        }
        else if (error)
        {
            NSLog(@"添加本地设置到服务器失败：%@",error);
        }
        else
        {
            NSLog(@"添加本地设置到服务器遇到未知错误");
        }
    }];
}

+ (void)uploadAvatar:(BmobObject *)obj
{
    //上传头像
    BmobFile *file = [[BmobFile alloc] initWithFileName:@"avatar.png" withFileData:[Config shareInstance].settings.avatar];
    [file saveInBackground:^(BOOL isSuccessful, NSError *error)
     {
        if (isSuccessful)
        {
            [Config shareInstance].settings.avatarURL = file.url;

            //把上传完的文件保存到“头像”字段
            [obj setObject:file.url forKey:@"avatarURL"];
            [obj updateInBackground];
            [PlanCache deletePersonalSettings:[Config shareInstance].settings];
        }
    }
    withProgressBlock:^(CGFloat progress)
     {
        //上传进度
        NSLog(@"上传头像进度： %f",progress);
    }];
}

+ (void)uploadCenterTop:(BmobObject *)obj
{
    BmobFile *file = [[BmobFile alloc] initWithFileName:@"centerTop.png" withFileData:[Config shareInstance].settings.centerTop];
    [file saveInBackground:^(BOOL isSuccessful, NSError *error)
    {
        if (isSuccessful)
        {
            [Config shareInstance].settings.centerTopURL = file.url;

            [obj setObject:file.url forKey:@"centerTopURL"];
            [obj updateInBackground];
        }
    }
    withProgressBlock:^(CGFloat progress)
    {
        //上传进度
        NSLog(@"上传个人中心图片进度： %f",progress);
    }];
}

+ (void)startSyncPlan
{
    [self syncLocalToServerForPlan];
}

+ (void)syncLocalToServerForPlan
{
    NSArray *localNewArray = [PlanCache getPlanForSync:nil];

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
                [weakSelf updatePlanForServer:plan obj:obj];
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
                [newPlan saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                    if (isSuccessful)
                    {
                        [PlanCache cleanPlan:plan];
                    }
                }];
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
    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful)
        {
            [PlanCache cleanPlan:plan];
        }
    }];
}

+ (void)startSyncPhoto
{
    [self syncLocalToServerForPhoto];
}

+ (void)syncLocalToServerForPhoto
{
    __weak typeof(self) weakSelf = self;
    NSArray *localNewArray = [PlanCache getPhotoForSync:nil];
    
    BmobUser *user = [BmobUser currentUser];
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Photo"];
    
    for (Photo *photo in localNewArray)
    {
        [bquery whereKey:@"userObjectId" equalTo:user.objectId];
        [bquery whereKey:@"photoId" equalTo:photo.photoid];
        [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
        {
            if (array.count)
            {
                BmobObject *obj = array[0];
                
                [weakSelf updatePhotoForServer:photo obj:obj];
            }
            else if (!error)
            {//防止网络超时也会新增
                [weakSelf addPhotoToServer:photo];
            }
        }];
    }
}

+ (void)addPhotoToServer:(Photo *)photo
{
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

    BmobACL *acl = [BmobACL ACL];
    [acl setReadAccessForUser:[BmobUser currentUser]];//设置只有当前用户可读
    [acl setWriteAccessForUser:[BmobUser currentUser]];//设置只有当前用户可写
    newPhoto.ACL = acl;
    [newPhoto saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
    {
        if (isSuccessful)
        {
            __block int count = 0;
            for (NSInteger i = 0; i < photo.photoArray.count; i++)
            {
                NSData *imgData = photo.photoArray[i];
                NSString *urlName = [NSString stringWithFormat:@"photo%ldURL", (long)(index+1)];
                if (imgData)
                {
                    BmobFile *file = [[BmobFile alloc] initWithFileName:@"imgPhoto.png" withFileData:imgData];
                    [file saveInBackground:^(BOOL isSuccessful, NSError *error)
                     {
                         count++;
                         if (isSuccessful)
                         {
                             [newPhoto setObject:file.url forKey:urlName];
                             [newPhoto setObject:photo.updatetime forKey:@"updatedTime"];
                             [newPhoto updateInBackground];
                         }
                         if (count == photo.photoArray.count)
                         {
                             [PlanCache cleanPhoto:photo];
                         }
                     }
                    withProgressBlock:^(CGFloat progress)
                     {
                         //上传进度
                         NSLog(@"上传影像图片进度： %f",progress);
                     }];
                }
            }
        }
        else if (error)
        {
            NSLog(@"新增岁月影像到服务器失败：%@",error);
        }
        else
        {
            NSLog(@"新增岁月影像到服务器失败：Unknow error");
        }
    }];
}

+ (void)updatePhotoForServer:(Photo *)photo obj:(BmobObject *)obj
{
    BmobUser *user = [BmobUser currentUser];
    if (photo.content)
    {
        [obj setObject:photo.content forKey:@"content"];
    }
    if (photo.phototime)
    {
        [obj setObject:photo.phototime forKey:@"photoTime"];
    }
    if (photo.location)
    {
        [obj setObject:photo.location forKey:@"location"];
    }
    if (photo.photoArray.count < 9)
    {
        for (NSInteger i = photo.photoArray.count; i < 9; i++)
        {
            NSString *urlName = [NSString stringWithFormat:@"photo%ldURL", (long)(i+1)];
            [obj setObject:@"" forKey:urlName];
        }
    }
    BmobACL *acl = [BmobACL ACL];
    [acl setReadAccessForUser:user];//设置只有当前用户可读
    [acl setWriteAccessForUser:user];//设置只有当前用户可写
    obj.ACL = acl;
    [obj updateInBackground];
    
    __block int count = 0;
    for (NSInteger i = 0; i < photo.photoArray.count; i++)
    {
        NSData *imgData = photo.photoArray[i];
        NSString *urlName = [NSString stringWithFormat:@"photo%ldURL", (long)(index+1)];
        if (imgData)
        {
            BmobFile *file = [[BmobFile alloc] initWithFileName:@"imgPhoto.png" withFileData:imgData];
            [file saveInBackground:^(BOOL isSuccessful, NSError *error)
             {
                 count ++;
                 if (isSuccessful)
                 {
                     [obj setObject:file.url forKey:urlName];
                     [obj setObject:photo.updatetime forKey:@"updatedTime"];
                     [obj updateInBackground];
                 }
                 if (count == photo.photoArray.count)
                 {
                     [PlanCache cleanPhoto:photo];
                 }
             }
            withProgressBlock:^(CGFloat progress)
             {
                 //上传进度
                 NSLog(@"上传影像图片进度： %f",progress);
             }];
        }
    }
}

+ (void)startSyncTask
{
    [self syncLocalToServerForTask];
}

+ (void)syncLocalToServerForTask
{
    __weak typeof(self) weakSelf = self;
    BmobUser *user = [BmobUser currentUser];
    NSArray *localNewArray = [PlanCache getTaskForSync:nil];

    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Task"];
    for (Task *task in localNewArray)
    {
        [bquery whereKey:@"userObjectId" equalTo:user.objectId];
        [bquery whereKey:@"taskId" equalTo:task.taskId];
        [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
        {
            if (array.count)
            {
                BmobObject *obj = array[0];
                NSString *serverUpdatedTime = [obj objectForKey:@"updatedTime"];
                NSDate *localDate = [CommonFunction NSStringDateToNSDate:task.updateTime formatter:STRDateFormatterType1];
                NSDate *serverDate = [CommonFunction NSStringDateToNSDate:serverUpdatedTime formatter:STRDateFormatterType1];
                
                if ([localDate compare:serverDate] == NSOrderedDescending)
                {
                    //本地的设置较新
                    [weakSelf updateTaskForServer:task obj:obj];
                    //同时上传改任务的完成记录
                    [weakSelf syncTaskRecord:task.taskId syncTime:[Config shareInstance].settings.syntime];
                }
            }
            else if (!error)
            {
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
                [newTask saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                    if (isSuccessful)
                    {
                        [PlanCache cleanTask:task];
                    }
                }];
                //同时上传改任务的完成记录
                [weakSelf syncTaskRecord:task.taskId syncTime:[Config shareInstance].settings.syntime];
            }
        }];
    }
}

+ (void)syncTaskRecord:(NSString *)taskId syncTime:(NSString *)syncTime
{
    NSArray *localNewArray = [NSArray array];
    if (syncTime.length)
    {
        localNewArray = [PlanCache getTaskRecordForSyncByTaskId:taskId syntime:syncTime];
    }
    else
    {
        localNewArray = [PlanCache getTaskRecordForSyncByTaskId:taskId syntime:nil];
    }
    BmobUser *user = [BmobUser currentUser];
    for (TaskRecord *taskrecord in localNewArray)
    {
        BmobObject *newTaskRecord = [BmobObject objectWithClassName:@"TaskRecord"];
        NSDictionary *dic = @{@"userObjectId":user.objectId,
                              @"recordId":taskrecord.recordId,
                              @"createdTime":taskrecord.createTime};
        [newTaskRecord saveAllWithDictionary:dic];
        BmobACL *acl = [BmobACL ACL];
        [acl setReadAccessForUser:user];//设置只有当前用户可读
        [acl setWriteAccessForUser:user];//设置只有当前用户可写
        newTaskRecord.ACL = acl;
        [newTaskRecord saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            if (isSuccessful)
            {
                [PlanCache cleanTaskRecordByTaskId:taskId];
            }
        }];
    }
}

+ (void)updateTaskForServer:(Task *)task obj:(BmobObject *)obj
{
    if (task.content)
    {
        [obj setObject:task.content forKey:@"content"];
    }
    if (task.totalCount)
    {
        [obj setObject:task.totalCount forKey:@"totalCount"];
    }
    if (task.completionDate)
    {
        [obj setObject:task.completionDate forKey:@"completionDate"];
    }
    if (task.updateTime)
    {
        [obj setObject:task.updateTime forKey:@"updatedTime"];
    }
    if (task.isNotify)
    {
        [obj setObject:task.isNotify forKey:@"isNotify"];
    }
    if (task.notifyTime)
    {
        [obj setObject:task.notifyTime forKey:@"notifyTime"];
    }
    if (task.isTomato)
    {
        [obj setObject:task.isTomato forKey:@"isTomato"];
    }
    if (task.tomatoMinute)
    {
        [obj setObject:task.tomatoMinute forKey:@"tomatoMinute"];
    }
    if (task.isRepeat)
    {
        [obj setObject:task.isRepeat forKey:@"isRepeat"];
    }
    if (task.repeatType)
    {
        [obj setObject:task.repeatType forKey:@"repeatType"];
    }
    if (task.taskOrder)
    {
        [obj setObject:task.taskOrder forKey:@"taskOrder"];
    }
    if (task.isDeleted)
    {
        [obj setObject:task.isDeleted forKey:@"isDeleted"];
    }
    BmobACL *acl = [BmobACL ACL];
    [acl setReadAccessForUser:[BmobUser currentUser]];//设置只有当前用户可读
    [acl setWriteAccessForUser:[BmobUser currentUser]];//设置只有当前用户可写
    obj.ACL = acl;
    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful)
        {
            [PlanCache cleanTask:task];
        }
    }];
}

+ (void)getMessagesFromServer
{
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Messages"];
    //构造约束条件
    BmobQuery *inQuery = [BmobQuery queryWithClassName:@"_User"];
    if ([LogIn isLogin])
    {
        BmobUser *user = [BmobUser currentUser];
        [inQuery whereKey:@"username" equalTo:user.username];
        //匹配查询
        //    [bquery whereKey:@"hasRead" matchesQuery:inQuery];（查询所有有关联的数据）
        [bquery whereKey:@"hasRead" doesNotMatchQuery:inQuery];//（查询所有无关联的数据）
    }
    [bquery whereKey:@"isDeleted" equalTo:@"0"];//只加载未删除的
    [bquery orderByDescending:@"createdAt"];
    bquery.limit = 10;
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
    {
        for (BmobObject *obj in array)
        {
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
    if ([LogIn isLogin])
    {
        BmobUser *user = [BmobUser currentUser];
        BmobQuery *nquery = [BmobQuery queryWithClassName:@"Notices"];
        [nquery includeKey:@"fromUser"];
        [nquery whereKey:@"hasRead" equalTo:@"0"];
        [nquery whereKey:@"toAuthorObjectId" equalTo:user.objectId];
        [nquery orderByDescending:@"createdAt"];
        [nquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
        {
            for (BmobObject *obj in array)
            {
                BmobObject *author = [obj objectForKey:@"fromUser"];
                NSString *noticeType = [obj objectForKey:@"noticeType"];
                NSString *nickName = [author objectForKey:@"nickName"];
                if (!nickName || nickName.length == 0) nickName = STRViewTips116;
                
                Messages *message = [[Messages alloc] init];
                message.messageId = obj.objectId;
                switch ([noticeType integerValue])
                {//通知类型：1赞帖子 2赞评论 3回复帖子 4回复评论
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
