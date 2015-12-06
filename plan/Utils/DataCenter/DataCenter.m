//
//  DataCenter.m
//  plan
//
//  Created by Fengzy on 15/10/3.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "LogIn.h"
#import "BmobFile.h"
#import "BmobQuery.h"
#import "PlanCache.h"
#import "DataCenter.h"
#import "BmobObjectsBatch.h"
#import <BmobSDK/BmobProFile.h>
#import "SDWebImageDownloader.h"

static BOOL finishSettings;
static BOOL finishUploadAvatar;
static BOOL finishUploadCenterTop;
static BOOL finishPlan;
static BOOL finishTask;
static BOOL finishPhoto;

@implementation DataCenter

+ (void)startSyncData {
    
    if (![LogIn isLogin]) return;
    
    //把本地无账号关联的数据与当前登录账号进行关联
    [PlanCache linkedLocalDataToAccount];

    //同步计划
    [self startSyncPlan];
    
    //同步任务
    [self startSyncTask];
    
    //同步影像
    [self startSyncPhoto];
    
    //同步个人设置 (一定要最后同步个人设置，因为需要更新同步时间)
    [self compareSyncTime];
}

+ (void)resetUploadFlag {
    finishSettings = NO;
    finishUploadAvatar = NO;
    finishUploadCenterTop = NO;
    finishPlan = NO;
    finishTask = NO;
    finishPhoto = NO;
}

+ (void)IsAllUploadFinished {
    
    if (finishSettings
        && finishUploadAvatar
        && finishUploadCenterTop
        && finishPlan
        && finishTask
        && finishPhoto) {
        
        [AlertCenter alertNavBarMessage:@"同步文本完成"];
    }
}

+ (void)compareSyncTime {
    
    [self resetUploadFlag];
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"UserSettings"];
    [bquery whereKey:@"userObjectId" equalTo:[Config shareInstance].settings.account];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if (array.count > 0) {
            
            BmobObject *obj = array[0];
            
            if ([Config shareInstance].settings.updatetime) {
                //本地有上次同步时间记录，对比服务器的更新时间与本地同步记录时间
                NSDate *localSyntime = [CommonFunction NSStringDateToNSDate:[Config shareInstance].settings.updatetime formatter:str_DateFormatter_yyyy_MM_dd_HHmmss];
                NSDate *serverSynctime = [CommonFunction NSStringDateToNSDate:[obj objectForKey:@"syncTime"] formatter:str_DateFormatter_yyyy_MM_dd_HHmmss];
                
                /*
                - (NSComparisonResult)compare:(NSDate *)other;
                . 当实例保存的日期值与anotherDate相同时返回NSOrderedSame
                . 当实例保存的日期值晚于anotherDate时返回NSOrderedDescending
                . 当实例保存的日期值早于anotherDate时返回NSOrderedAscending
                 */
                if ((!localSyntime && !serverSynctime)
                    || (localSyntime && !serverSynctime)) {
                    //将本地的设置同步到服务器
                    [self addSettingsToServer];
                    
                } else if (!localSyntime && serverSynctime) {
                    //服务器的设置较新
                    [self syncServerToLocalForSettings:obj];
                    
                } else if ([localSyntime compare:serverSynctime] == NSOrderedAscending) {
                    //服务器的设置较新
                    [self syncServerToLocalForSettings:obj];
                    
                } else if ([localSyntime compare:serverSynctime] == NSOrderedDescending) {
                    //本地的设置较新
                    [self syncLocalToServerForSettings];
                }
                
            } else {
            
                //还没有同步过数据，以服务器设置覆盖本地设置
                [self syncServerToLocalForSettings:obj];
            }
        } else {
            //将本地的设置同步到服务器
            [self addSettingsToServer];
        }
    }];
}

+ (void)syncServerToLocalForSettings:(BmobObject *)obj {
    
    [Config shareInstance].settings.nickname = [obj objectForKey:@"nickName"];
    [Config shareInstance].settings.birthday = [obj objectForKey:@"birthday"];
    [Config shareInstance].settings.gender = [obj objectForKey:@"gender"];
    [Config shareInstance].settings.lifespan = [obj objectForKey:@"lifespan"];
    [Config shareInstance].settings.isAutoSync = [obj objectForKey:@"isAutoSync"];
    [Config shareInstance].settings.syntime = [obj objectForKey:@"synctime"];
    
    if (![[Config shareInstance].settings.avatarURL isEqualToString:[obj objectForKey:@"avatarURL"]]) {
        [Config shareInstance].settings.avatarURL = [obj objectForKey:@"avatarURL"];
        
        SDWebImageDownloader *imageDownloader = [SDWebImageDownloader sharedDownloader];
        NSURL *url = [NSURL URLWithString: [Config shareInstance].settings.avatarURL];
        [imageDownloader downloadImageWithURL:url options:SDWebImageDownloaderLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            
            if (image) {
                [Config shareInstance].settings.avatar = image;
                [PlanCache storePersonalSettings:[Config shareInstance].settings];
                finishSettings = YES;
                [DataCenter IsAllUploadFinished];
            }
        }];
    }
    if (![[Config shareInstance].settings.centerTopURL isEqualToString:[obj objectForKey:@"centerTopURL"]]) {
        [Config shareInstance].settings.centerTopURL = [obj objectForKey:@"centerTopURL"];
        
        SDWebImageDownloader *imageDownloader = [SDWebImageDownloader sharedDownloader];
        NSURL *url = [NSURL URLWithString: [Config shareInstance].settings.centerTopURL];
        [imageDownloader downloadImageWithURL:url options:SDWebImageDownloaderLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            
            if (image) {
                [Config shareInstance].settings.centerTop = image;
                [PlanCache storePersonalSettings:[Config shareInstance].settings];
                finishSettings = YES;
                [DataCenter IsAllUploadFinished];
            }
        }];
    }
    
    [PlanCache storePersonalSettings:[Config shareInstance].settings];
    finishSettings = YES;
    [DataCenter IsAllUploadFinished];
}

+ (void)syncLocalToServerForSettings {
    
    __weak typeof(self) weakSelf = self;
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"UserSettings"];
    [bquery whereKey:@"userObjectId" equalTo:[Config shareInstance].settings.account];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if (array.count > 0) {
            BmobObject *obj = array[0];
            [weakSelf updateSettings:obj];
        } else {
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
    if ([Config shareInstance].settings.updatetime) {
        [settingsObject setObject:[Config shareInstance].settings.updatetime forKey:@"updatedTime"];
    }
    NSString *timeNow = [CommonFunction getTimeNowString];
    [Config shareInstance].settings.syntime = timeNow;
    if ([Config shareInstance].settings.syntime) {
        [settingsObject setObject:timeNow forKey:@"syncTime"];
    }
    
    [settingsObject updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            
            finishSettings = YES;
            [PlanCache storePersonalSettings:[Config shareInstance].settings];
            [DataCenter IsAllUploadFinished];
            
        } else if (error){
            NSLog(@"更新本地设置到服务器失败：%@",error);
        } else {
            NSLog(@"更新本地设置到服务器遇到未知错误");
        }
    }];
    
    //上传头像
    NSString *avatarUrl = [settingsObject objectForKey:@"avatarURL"];
    NSString *centerTopUrl = [settingsObject objectForKey:@"centerTopURL"];
    if (![[Config shareInstance].settings.avatarURL isEqualToString:avatarUrl]) {
        [self uploadAvatar:settingsObject];
    } else {
        finishUploadAvatar = YES;
        [DataCenter IsAllUploadFinished];
    }
    if (![[Config shareInstance].settings.centerTopURL isEqualToString:centerTopUrl]) {
        [self uploadCenterTop:settingsObject];
    } else {
        finishUploadCenterTop = YES;
        [DataCenter IsAllUploadFinished];
    }
}

+ (void)addSettingsToServer {
    
    BmobObject *userSettings = [BmobObject objectWithClassName:@"UserSettings"];

    if ([Config shareInstance].settings.account) {
        [userSettings setObject:[Config shareInstance].settings.account forKey:@"userObjectId"];
    }
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
    if ([Config shareInstance].settings.updatetime) {
        [userSettings setObject:[Config shareInstance].settings.updatetime forKey:@"updatedTime"];
    }
    NSString *timeNow = [CommonFunction getTimeNowString];
    [Config shareInstance].settings.syntime = timeNow;
    if ([Config shareInstance].settings.syntime) {
        [userSettings setObject:timeNow forKey:@"syncTime"];
    }
    //异步保存
    [userSettings saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            
            finishSettings = YES;
            [PlanCache storePersonalSettings:[Config shareInstance].settings];
            [DataCenter IsAllUploadFinished];
            
        } else if (error){
            NSLog(@"添加本地设置到服务器失败：%@",error);
        } else {
            NSLog(@"添加本地设置到服务器遇到未知错误");
        }
    }];
    
    //上传头像
    [self uploadAvatar:userSettings];
    [self uploadCenterTop:userSettings];
}

+ (void)uploadAvatar:(BmobObject *)obj {
    //上传头像
    NSData *avatarData = UIImageJPEGRepresentation([Config shareInstance].settings.avatar, 1.0);
    if (avatarData) {
        //上传文件
        [BmobProFile uploadFileWithFilename:@"avatar.png" fileData:avatarData block:^(BOOL isSuccessful, NSError *error, NSString *filename, NSString *url, BmobFile *bmobFile) {
            if (isSuccessful) {

                //把上传完的文件保存到“头像”字段
                [obj setObject:bmobFile.url forKey:@"avatarURL"];
                [obj updateInBackground];
                
                //把avatarUrl保存到本地
                [Config shareInstance].settings.avatarURL = bmobFile.url;
                [PlanCache storePersonalSettings:[Config shareInstance].settings];
                
                finishUploadAvatar = YES;
                [DataCenter IsAllUploadFinished];

            } else if (error) {
                NSLog(@"上传头像到服务器失败：%@",error);
            }
            
        } progress:^(CGFloat progress) {
            //上传进度
            NSLog(@"上传头像进度： %f",progress);
        }];
    }
}

+ (void)uploadCenterTop:(BmobObject *)obj {
    
    NSData *centerTopData = UIImageJPEGRepresentation([Config shareInstance].settings.centerTop, 1.0);
    if (centerTopData) {
        //上传文件
        [BmobProFile uploadFileWithFilename:@"centerTop.png" fileData:centerTopData block:^(BOOL isSuccessful, NSError *error, NSString *filename, NSString *url, BmobFile *bmobFile) {
            if (isSuccessful) {
                
                //把上传完的文件保存到“头像”字段
                [obj setObject:bmobFile.url forKey:@"centerTopURL"];
                [obj updateInBackground];
                
                //把centerTopURL保存到本地
                [Config shareInstance].settings.centerTopURL = bmobFile.url;
                [PlanCache storePersonalSettings:[Config shareInstance].settings];
                
                finishUploadCenterTop = YES;
                [DataCenter IsAllUploadFinished];
                
            } else if (error) {
                NSLog(@"上传个人中心图片到服务器失败：%@",error);
            }
            
        } progress:^(CGFloat progress) {
            //上传进度
            NSLog(@"上传个人中心图片进度： %f",progress);
        }];
    }
}

+ (void)startSyncPlan {
    
    [self syncLocalToServerForPlan];
    [self syncServerToLocalForPlan];
}

+ (void)syncLocalToServerForPlan {
    NSArray *localNewArray = [NSArray array];
    if ([Config shareInstance].settings.syntime) {
        
        localNewArray = [PlanCache getPlanForSync:[Config shareInstance].settings.syntime];
    } else {
        
        localNewArray = [PlanCache getPlanForSync:nil];
    }
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Plan"];
    
    for (Plan *plan in localNewArray) {
        
        [bquery whereKey:@"userObjectId" equalTo:[Config shareInstance].settings.account];
        [bquery whereKey:@"planId" equalTo:plan.planid];
        [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            
            if (array.count > 0) {
                
                BmobObject *obj = array[0];
                
                NSString *serverUpdatedTime = [obj objectForKey:@"updatedTime"];
                if (plan.updatetime.length == 0 && serverUpdatedTime.length == 0) {

                } else if (plan.updatetime.length != 0 && serverUpdatedTime.length == 0) {
                    [DataCenter updatePlanForServer:plan obj:obj];
                } else if (plan.updatetime.length == 0 && serverUpdatedTime.length != 0) {
                    
                } else {
                    
                    NSDate *localDate = [CommonFunction NSStringDateToNSDate:plan.updatetime formatter:str_DateFormatter_yyyy_MM_dd_HHmmss];
                    NSDate *serverDate = [CommonFunction NSStringDateToNSDate:serverUpdatedTime formatter:str_DateFormatter_yyyy_MM_dd_HHmmss];
                    
                    if ([localDate compare:serverDate] == NSOrderedAscending) {
                        
                    } else if ([localDate compare:serverDate] == NSOrderedDescending) {
                        //本地的设置较新
                        [DataCenter updatePlanForServer:plan obj:obj];
                    }
                }
                
            } else {
                
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
                                      @"planType":plan.plantype};
                [newPlan saveAllWithDictionary:dic];
                //异步保存
                [newPlan saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                    if (isSuccessful) {
                        //创建成功后的动作
                    } else if (error){
                        //发生错误后的动作
                        NSLog(@"%@",error);
                    } else {
                        NSLog(@"Unknow error");
                    }
                }];
            }
            
        }];

    }
}

+ (void)updatePlanForServer:(Plan *)plan obj:(BmobObject *)obj {
    if (plan.content) {
        [obj setObject:plan.content forKey:@"content"];
    }
    if (plan.completetime) {
        [obj setObject:plan.completetime forKey:@"completedTime"];
    }
    if (plan.updatetime) {
        [obj setObject:plan.updatetime forKey:@"updatedTime"];
    }
    if (plan.notifytime) {
        [obj setObject:plan.notifytime forKey:@"notifyTime"];
    }
    if (plan.iscompleted) {
        [obj setObject:plan.iscompleted forKey:@"isCompleted"];
    }
    if (plan.isnotify) {
        [obj setObject:plan.isnotify forKey:@"isNotify"];
    }
    if (plan.isdeleted) {
        [obj setObject:plan.isdeleted forKey:@"isDeleted"];
    }
    
    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
        } else if (error){
            NSLog(@"更新本地设置到服务器失败：%@",error);
        } else {
            NSLog(@"更新本地设置到服务器遇到未知错误");
        }
    }];
}

+ (void)syncServerToLocalForPlan {
    __weak typeof(self) weakSelf = self;
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Plan"];
    [bquery whereKey:@"userObjectId" equalTo:[Config shareInstance].settings.account];
    [bquery whereKey:@"isDeleted" notEqualTo:@"1"];
    [bquery orderByDescending:@"updatedAt"];
    bquery.limit = 100;
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (!error && array.count > 0) {
            
            for (BmobObject *obj in array) {
                
                Plan *plan = [PlanCache findPlan:[Config shareInstance].settings.account planid:[obj objectForKey:@"planId"]];
                if (plan.content) {
                    
                    NSDate *localDate = [CommonFunction NSStringDateToNSDate:plan.updatetime formatter:str_DateFormatter_yyyy_MM_dd_HHmmss];
                    NSDate *serverDate = [CommonFunction NSStringDateToNSDate:[obj objectForKey:@"updatedTime"] formatter:str_DateFormatter_yyyy_MM_dd_HHmmss];
                    
                    if ([localDate compare:serverDate] == NSOrderedAscending) {
                        //服务器的较新
                        [DataCenter updatePlanForLocal:plan obj:obj];
                        
                    } else if ([localDate compare:serverDate] == NSOrderedDescending) {
                        //本地的设置较新
                    }
                } else {
                    [DataCenter updatePlanForLocal:plan obj:obj];
                }
            }
            finishPlan = YES;
            [weakSelf IsAllUploadFinished];
        }
        
    }];
}

+ (void)updatePlanForLocal:(Plan *)plan obj:(BmobObject *)obj {
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
    plan.plantype = [obj objectForKey:@"planType"];
    [PlanCache storePlan:plan];
}

+ (void)startSyncPhoto {
    [self syncLocalToServerForPhoto];
    [self syncServerToLocalForPhoto];
}

+ (void)syncLocalToServerForPhoto {
    __weak typeof(self) weakSelf = self;
    NSArray *localNewArray = [NSArray array];
    if ([Config shareInstance].settings.syntime.length > 0) {
        
        localNewArray = [PlanCache getPhotoForSync:[Config shareInstance].settings.syntime];
    } else {
        
        localNewArray = [PlanCache getPhotoForSync:nil];
    }
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Photo"];
    
    for (Photo *photo in localNewArray) {
        
        [bquery whereKey:@"userObjectId" equalTo:[Config shareInstance].settings.account];
        [bquery whereKey:@"photoId" equalTo:photo.photoid];
        [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            
            if (array.count > 0) {
                
                BmobObject *obj = array[0];
                
                NSString *serverUpdatedTime = [obj objectForKey:@"updatedTime"];
                NSDate *localDate = [CommonFunction NSStringDateToNSDate:photo.updatetime formatter:str_DateFormatter_yyyy_MM_dd_HHmmss];
                NSDate *serverDate = [CommonFunction NSStringDateToNSDate:serverUpdatedTime formatter:str_DateFormatter_yyyy_MM_dd_HHmmss];
                
                if ([localDate compare:serverDate] == NSOrderedAscending) {
                    
                } else if ([localDate compare:serverDate] == NSOrderedDescending) {
                    //本地的设置较新
                    [weakSelf updatePhotoForServer:photo obj:obj];
                }
            } else {
                
                BmobObject *newPhoto = [BmobObject objectWithClassName:@"Photo"];
                NSDictionary *dic = @{@"userObjectId":photo.account,
                                      @"photoId":photo.photoid,
                                      @"content":photo.content,
                                      @"location":photo.location,
                                      @"createdTime":photo.createtime,
                                      @"photoTime":photo.phototime,
                                      @"updatedTime":photo.updatetime,
                                      @"photo1URL":photo.photoURLArray[0],
                                      @"photo2URL":photo.photoURLArray[1],
                                      @"photo3URL":photo.photoURLArray[2],
                                      @"photo4URL":photo.photoURLArray[3],
                                      @"photo5URL":photo.photoURLArray[4],
                                      @"photo6URL":photo.photoURLArray[5],
                                      @"photo7URL":photo.photoURLArray[6],
                                      @"photo8URL":photo.photoURLArray[7],
                                      @"photo9URL":photo.photoURLArray[8],
                                      @"isDeleted":photo.isdeleted};
                [newPhoto saveAllWithDictionary:dic];
                //异步保存
                [newPhoto saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                    if (isSuccessful) {
                        //创建成功后的动作
                    } else if (error){
                        //发生错误后的动作
                        NSLog(@"%@",error);
                    } else {
                        NSLog(@"Unknow error");
                    }
                }];
                for (NSInteger i = 0; i < photo.photoArray.count; i++) {
                    [weakSelf uploadPhoto:photo index:i obj:newPhoto];
                }
            }
        }];
    }
}

+ (void)updatePhotoForServer:(Photo *)photo obj:(BmobObject *)obj {
    if (photo.content) {
        [obj setObject:photo.content forKey:@"content"];
    }
    if (photo.phototime) {
        [obj setObject:photo.phototime forKey:@"photoTime"];
    }
    if (photo.updatetime) {
        [obj setObject:photo.updatetime forKey:@"updatedTime"];
    }
    if (photo.location) {
        [obj setObject:photo.location forKey:@"location"];
    }
    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
        } else if (error){
            NSLog(@"更新本地影像到服务器失败：%@",error);
        } else {
            NSLog(@"更新本地影像到服务器遇到未知错误");
        }
    }];
    for (NSInteger i = 0; i < photo.photoArray.count; i++) {
        [self uploadPhoto:photo index:i obj:obj];
    }
}

+ (void)uploadPhoto:(Photo *)photo index:(NSInteger)index obj:(BmobObject *)obj {
    UIImage *image = photo.photoArray[index];
    NSString *url = [NSString stringWithFormat:@"photo%ldURL", index+1];
    if (![photo.photoURLArray[index] isEqualToString:[obj objectForKey:url]]
        && image) {
        NSData *imgData = UIImageJPEGRepresentation(image, 1.0);
        [BmobProFile uploadFileWithFilename:@"imgPhoto.png" fileData:imgData block:^(BOOL isSuccessful, NSError *error, NSString *filename, NSString *url, BmobFile *bmobFile) {
            if (isSuccessful) {
                
                [obj setObject:bmobFile.url forKey:url];
                [obj updateInBackground];
                
                photo.photoURLArray[index] = bmobFile.url;
                [PlanCache storePhoto:photo];
            } else if (error) {
            }
        } progress:^(CGFloat progress) {
        }];
    }
}

+ (void)syncServerToLocalForPhoto {
    __weak typeof(self) weakSelf = self;
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Photo"];
    [bquery whereKey:@"userObjectId" equalTo:[Config shareInstance].settings.account];
    [bquery whereKey:@"isDeleted" notEqualTo:@"1"];
    [bquery orderByDescending:@"updatedAt"];
    bquery.limit = 100;
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (!error && array.count > 0) {
            
            for (BmobObject *obj in array) {
                
                Photo *photo = [PlanCache getPhotoById:[obj objectForKey:@"photoId"]];
                if (photo.createtime) {
                    
                    NSDate *localDate = [CommonFunction NSStringDateToNSDate:photo.updatetime formatter:str_DateFormatter_yyyy_MM_dd_HHmmss];
                    NSDate *serverDate = [CommonFunction NSStringDateToNSDate:[obj objectForKey:@"updatedTime"] formatter:str_DateFormatter_yyyy_MM_dd_HHmmss];
                    
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
            finishPlan = YES;
            [weakSelf IsAllUploadFinished];
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
    
    for (NSInteger i = 0; i < 9; i++) {
        NSString *url = [NSString stringWithFormat:@"photo%ldURL", i + 1];
        NSString *serverPhotoURL = [obj objectForKey:url];
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
        
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        
        if (image) {
            if (index < photo.photoArray.count) {
                photo.photoArray[index] = image;
            } else {
                [photo.photoArray addObject:image];
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
    NSArray *localNewArray = [NSArray array];
    if ([Config shareInstance].settings.syntime.length > 0) {
        
        localNewArray = [PlanCache getTaskForSync:[Config shareInstance].settings.syntime];
    } else {
        
        localNewArray = [PlanCache getTaskForSync:nil];
    }
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Task"];
    
    for (Task *task in localNewArray) {
        
        [bquery whereKey:@"userObjectId" equalTo:[Config shareInstance].settings.account];
        [bquery whereKey:@"taskId" equalTo:task.taskId];
        [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            
            if (array.count > 0) {
                
                BmobObject *obj = array[0];
                
                NSString *serverUpdatedTime = [obj objectForKey:@"updatedTime"];
                NSDate *localDate = [CommonFunction NSStringDateToNSDate:task.updateTime formatter:str_DateFormatter_yyyy_MM_dd_HHmmss];
                NSDate *serverDate = [CommonFunction NSStringDateToNSDate:serverUpdatedTime formatter:str_DateFormatter_yyyy_MM_dd_HHmmss];
                
                if ([localDate compare:serverDate] == NSOrderedAscending) {
                    
                } else if ([localDate compare:serverDate] == NSOrderedDescending) {
                    //本地的设置较新
                    [DataCenter updateTaskForServer:task obj:obj];
                    //同时上传改任务的完成记录
                    [weakSelf syncTaskRecord:task.taskId syncTime:[Config shareInstance].settings.syntime];
                }
                
            } else {
                
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
                                      @"isDeleted":task.isDeleted};
                [newTask saveAllWithDictionary:dic];
                //异步保存
                [newTask saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                    if (isSuccessful) {
                        //创建成功后的动作
                    } else if (error){
                        //发生错误后的动作
                        NSLog(@"%@",error);
                    } else {
                        NSLog(@"Unknow error");
                    }
                }];
                //同时上传改任务的完成记录
                [weakSelf syncTaskRecord:task.taskId syncTime:[Config shareInstance].settings.syntime];
            }
        }];
    }
}

+ (void)syncTaskRecord:(NSString *)taskId syncTime:(NSString *)syncTime {
    NSArray *localNewArray = [NSArray array];
    if (syncTime.length > 0) {
        
        localNewArray = [PlanCache getTeaskRecordForSyncByTaskId:taskId syntime:syncTime];
    } else {
        
        localNewArray = [PlanCache getTeaskRecordForSyncByTaskId:taskId syntime:nil];
    }
    for (TaskRecord *taskrecord in localNewArray) {
        
        BmobObject *newTaskRecord = [BmobObject objectWithClassName:@"TaskRecord"];
        NSDictionary *dic = @{@"recordId":taskrecord.recordId,
                              @"createdTime":taskrecord.createTime};
        [newTaskRecord saveAllWithDictionary:dic];
        //异步保存
        [newTaskRecord saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            if (isSuccessful) {
                //创建成功后的动作
            } else if (error){
                //发生错误后的动作
                NSLog(@"%@",error);
            } else {
                NSLog(@"Unknow error");
            }
        }];
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
    if (task.isDeleted) {
        [obj setObject:task.isDeleted forKey:@"isDeleted"];
    }
    
    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
        } else if (error){
            NSLog(@"更新本地任务到服务器失败：%@",error);
        } else {
            NSLog(@"更新本地任务到服务器遇到未知错误");
        }
    }];
}

+ (void)syncServerToLocalForTask {
    __weak typeof(self) weakSelf = self;
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Task"];
    [bquery whereKey:@"userObjectId" equalTo:[Config shareInstance].settings.account];
    [bquery whereKey:@"isDeleted" notEqualTo:@"1"];
    [bquery orderByDescending:@"updatedAt"];
    bquery.limit = 100;
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (!error && array.count > 0) {
            
            for (BmobObject *obj in array) {
                
                Task *task = [PlanCache findTask:[Config shareInstance].settings.account taskId:[obj objectForKey:@"taskId"]];
                if (task.content) {
                    
                    NSDate *localDate = [CommonFunction NSStringDateToNSDate:task.updateTime formatter:str_DateFormatter_yyyy_MM_dd_HHmmss];
                    NSDate *serverDate = [CommonFunction NSStringDateToNSDate:[obj objectForKey:@"updatedTime"] formatter:str_DateFormatter_yyyy_MM_dd_HHmmss];
                    
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
            finishPlan = YES;
            [weakSelf IsAllUploadFinished];
        }
        
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
    task.isDeleted = [obj objectForKey:@"isDeleted"];
    [self getNewTaskRecordFromServer:task.taskId];
    [PlanCache storeTask:task];
}

+ (void)getNewTaskRecordFromServer:(NSString *)recordId {
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"TaskRecord"];
    [bquery whereKey:@"recordId" equalTo:recordId];
    [bquery whereKey:@"createdTime" greaterThanOrEqualTo:[Config shareInstance].settings.syntime];
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

@end
