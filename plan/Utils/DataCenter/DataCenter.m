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
#import "PopupNewAppVersionView.h"
#import <BmobSDK/BmobObjectsBatch.h>

static int photoIndex;

@implementation DataCenter

+ (void)startSyncData
{
    if (![LogIn isLogin])
        return;
    
    //把本地无账号关联的数据与当前登录账号进行关联
    [PlanCache linkedLocalDataToAccount];
    
    //同步计划
    [self uploadPlanForServer];
    
    //同步个人设置 (一定要最后同步个人设置，因为需要更新同步时间)
    [self startSyncSettings];
}

+ (void)startSyncSettings
{
    NSLog(@"开始上传个人设置数据");
    __weak typeof(self) weakSelf = self;
    BmobUser *user = [BmobUser currentUser];
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"UserSettings"];
    [bquery whereKey:@"userObjectId" equalTo:user.objectId];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
     {
         if (array.count)
         {
             NSLog(@"从服务器查到该用户设置记录");
             BmobObject *obj = array[0];
             
             [weakSelf updateSettings:obj];
         }
         else if (!error)
         {//防止网络超时也会新增
             NSLog(@"将本地的设置同步到服务器");
             [weakSelf addSettingsToServer];
         }
     }];
}

+ (void)updateSettings:(BmobObject *)settingsObject
{
    NSLog(@"开始更新本地个人设置数据到服务器");
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

+ (void)checkNewVsrion
{
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"CheckUpdate"];
    [bquery whereKey:@"platform" equalTo:@"iOS"];
    [bquery whereKey:@"isDeleted" equalTo:@"0"];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
     {
         if (array.count)
         {
             BmobObject *obj = array[0];
             
             NSString *newVersion = [obj objectForKey:@"newVersion"];
             NSString *isForced = [obj objectForKey:@"isForced"];
             NSString *availableVersion = [obj objectForKey:@"availableVersion"];
             NSString *description = [obj objectForKey:@"description"];
             NSString *appVersion = [Utils getAppVersion];
             
             if ([availableVersion containsString:@"ALL"]
                 || [availableVersion containsString:appVersion])
             {
                 NSString *today = [Utils NSDateToNSString:[NSDate date] formatter:@"yyyy-MM-dd"];
                 NSString *showDate = [UserDefaults objectForKey:STRCheckNewVersion];
                 if (![today isEqualToString:showDate])
                 {
                     PopupNewAppVersionView *newVersionView = [PopupNewAppVersionView shareInstance:newVersion whatNew:description isForce:[isForced isEqualToString:@"1"]];
                     [newVersionView show];
                 }
             }
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
    [obj setObject:[Utils getAppVersion] forKey:@"appVersion"];
    [obj setObject:[Utils getDeviceType] forKey:@"deviceType"];
    [obj setObject:[Utils getiOSVersion] forKey:@"iOSVersion"];

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

+ (void)uploadPlanForServer
{
    NSLog(@"开始上传本地计划数据到服务器");
    NSArray *localNewArray = [PlanCache getPlanForSync:nil];
    
    if (localNewArray.count)
    {
        Plan *plan = localNewArray[0];
        
        BmobUser *user = [BmobUser currentUser];
        BmobQuery *bquery = [BmobQuery queryWithClassName:@"Plan"];
        [bquery whereKey:@"userObjectId" equalTo:user.objectId];
        [bquery whereKey:@"planId" equalTo:plan.planid];
        __weak typeof(self) weakSelf = self;
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
                         NSLog(@"清理本地计划");
                         [PlanCache cleanPlan:plan];
                     }
                     else
                     {
                         NSLog(@"新增本地计划到服务器失败");
                     }
                     [weakSelf uploadPlanForServer];
                 }];
             }
         }];
    }
    else
    {
        [self uploadTaskForServer];
    }
}

+ (void)updatePlanForServer:(Plan *)plan obj:(BmobObject *)obj
{
    NSLog(@"更新本地计划到服务器");
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
    __weak typeof(self) weakSelf = self;
    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful)
        {
            NSLog(@"清理本地计划");
            [PlanCache cleanPlan:plan];
        }
        else
        {
            NSLog(@"更新本地计划到服务器失败");
        }
        [weakSelf uploadPlanForServer];
    }];
}

+ (void)uploadPhotoForServer
{
    NSLog(@"开始上传本地岁月影像");
    NSArray *localNewArray = [PlanCache getPhotoForSync:nil];
    
    if (localNewArray.count)
    {
        Photo *photo = localNewArray[0];
        
        BmobUser *user = [BmobUser currentUser];
        BmobQuery *bquery = [BmobQuery queryWithClassName:@"Photo"];
        [bquery whereKey:@"userObjectId" equalTo:user.objectId];
        [bquery whereKey:@"photoId" equalTo:photo.photoid];
        __weak typeof(self) weakSelf = self;
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
    NSLog(@"新增本地岁月影像数据到服务器");
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
    __weak typeof(self) weakSelf = self;
    [newPhoto saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
    {
        if (isSuccessful)
        {
            photoIndex = 0;
            [weakSelf uploadImageInPhoto:[NSMutableArray arrayWithArray:photo.photoArray] obj:newPhoto photo:photo];
        }
        else if (error)
        {
            NSLog(@"新增岁月影像到服务器失败：%@",error);
            [weakSelf uploadPhotoForServer];
        }
        else
        {
            NSLog(@"新增岁月影像到服务器失败：Unknow error");
            [weakSelf uploadPhotoForServer];
        }
    }];
}

+ (void)updatePhotoForServer:(Photo *)photo obj:(BmobObject *)obj
{
    NSLog(@"开始更新本地岁月影像数据到服务器");
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
    
    photoIndex = 0;
    [self uploadImageInPhoto:[NSMutableArray arrayWithArray:photo.photoArray] obj:obj photo:photo];
}

+ (void)uploadImageInPhoto:(NSMutableArray *)photoArray obj:(BmobObject *)obj photo:(Photo *)photo
{
    if (photoArray.count)
    {
        NSData *imgData = photoArray[0];
        NSString *urlName = [NSString stringWithFormat:@"photo%ldURL", (long)(photoIndex+1)];
        if (imgData)
        {
            BmobFile *file = [[BmobFile alloc] initWithFileName:@"imgPhoto.png" withFileData:imgData];
            __weak typeof(self) weakSelf = self;
            [file saveInBackground:^(BOOL isSuccessful, NSError *error)
             {
                 if (isSuccessful)
                 {
                     [obj setObject:file.url forKey:urlName];
                     [obj setObject:photo.updatetime forKey:@"updatedTime"];
                     [obj updateInBackground];
                 }
                 [photoArray removeObject:imgData];
                 [weakSelf uploadImageInPhoto:photoArray obj:obj photo:photo];
             }
             withProgressBlock:^(CGFloat progress)
             {
                 //上传进度
                 NSLog(@"上传影像图片进度： %f",progress);
             }];
        }
    }
    else
    {
        NSLog(@"清理本地岁月影像");
        [PlanCache cleanPhoto:photo];
        [self uploadPhotoForServer];
    }
}

+ (void)uploadTaskForServer
{
    NSLog(@"开始上传本地任务到服务器");
    NSArray *localNewArray = [PlanCache getTaskForSync:nil];
    
    if (localNewArray.count)
    {
        Task *task = localNewArray[0];
        
        BmobUser *user = [BmobUser currentUser];
        BmobQuery *bquery = [BmobQuery queryWithClassName:@"Task"];
        [bquery whereKey:@"userObjectId" equalTo:user.objectId];
        [bquery whereKey:@"taskId" equalTo:task.taskId];
        __weak typeof(self) weakSelf = self;
        [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
         {
             if (array.count)
             {
                 BmobObject *obj = array[0];
                 NSString *serverUpdatedTime = [obj objectForKey:@"updatedTime"];
                 NSDate *localDate = [Utils NSStringDateToNSDate:task.updateTime formatter:STRDateFormatterType1];
                 NSDate *serverDate = [Utils NSStringDateToNSDate:serverUpdatedTime formatter:STRDateFormatterType1];
                 
                 if ([localDate compare:serverDate] == NSOrderedDescending)
                 {
                     //本地的设置较新
                     [weakSelf updateTaskForServer:task obj:obj];
                     //同时上传改任务的完成记录
                     [weakSelf uploadTaskRecordForServer:task.taskId];
                 }
                 else
                 {
                     NSLog(@"清理本地任务");
                     [PlanCache cleanTask:task];
                     [weakSelf uploadTaskForServer];
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
                         NSLog(@"上传本地任务成功，清理本地任务");
                         [PlanCache cleanTask:task];
                     }
                     else
                     {
                         NSLog(@"上传本地任务失败");
                     }
                     [weakSelf uploadTaskForServer];
                 }];
                 //同时上传改任务的完成记录
                 [weakSelf uploadTaskRecordForServer:task.taskId];
             }
         }];
    }
    else
    {
        [self uploadPhotoForServer];
    }
}

+ (void)uploadTaskRecordForServer:(NSString *)taskId
{
    NSMutableArray *localNewArray = [PlanCache getTaskRecordForSyncByTaskId:taskId syntime:nil];

    [self uploadTaskRecordOneByOne:localNewArray taskId:taskId];
}

+ (void)uploadTaskRecordOneByOne:(NSMutableArray *)array taskId:(NSString *)taskId
{
    if (array.count)
    {
        TaskRecord *taskrecord = array[0];
        
        BmobUser *user = [BmobUser currentUser];
        BmobObject *newTaskRecord = [BmobObject objectWithClassName:@"TaskRecord"];
        NSDictionary *dic = @{@"userObjectId":user.objectId,
                              @"recordId":taskrecord.recordId,
                              @"createdTime":taskrecord.createTime};
        [newTaskRecord saveAllWithDictionary:dic];
        BmobACL *acl = [BmobACL ACL];
        [acl setReadAccessForUser:user];//设置只有当前用户可读
        [acl setWriteAccessForUser:user];//设置只有当前用户可写
        newTaskRecord.ACL = acl;
        __weak typeof(self) weakSelf = self;
        [newTaskRecord saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            
            [array removeObject:taskrecord];
            [weakSelf uploadTaskRecordOneByOne:array taskId:taskId];
        }];
    }
    else
    {
        NSLog(@"清理本地任务记录");
        [PlanCache cleanTaskRecordByTaskId:taskId];
    }
}

+ (void)updateTaskForServer:(Task *)task obj:(BmobObject *)obj
{
    NSLog(@"更新本地任务到服务器");
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
    __weak typeof(self) weakSelf = self;
    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful)
        {
            NSLog(@"更新本地任务到服务器成功，清理本地任务");
            [PlanCache cleanTask:task];
        }
        else
        {
            NSLog(@"更新本地任务到服务器失败");
        }
        [weakSelf uploadTaskForServer];
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
            NSString *appVersion1 = [obj objectForKey:@"appVersion"];
            NSString *appVersion2 = [Utils getAppVersion];
            if ([appVersion1 isEqualToString:appVersion2])
            {
                //过滤同级版本的版本升级提醒
                continue;
            }
            
            Messages *message = [[Messages alloc] init];
            message.messageId = obj.objectId;
            message.title = [obj objectForKey:@"title"];
            message.content = [obj objectForKey:@"content"];
            message.detailURL = [obj objectForKey:@"detailURL"];
            message.imgURLArray = [obj objectForKey:@"imgURLArray"];
            message.canShare = [obj objectForKey:@"canShare"];
            message.messageType = @"1";
            message.createTime = [Utils NSDateToNSString:obj.createdAt formatter:STRDateFormatterType1];
            
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
                message.createTime = [Utils NSDateToNSString:obj.createdAt formatter:STRDateFormatterType1];
                
                [PlanCache storeMessages:message];
            }
        }];
    }
}

@end
