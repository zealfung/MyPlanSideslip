//
//  DataCenter.m
//  plan
//
//  Created by Fengzy on 15/10/3.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "LogIn.h"
#import "BmobQuery.h"
#import "PlanCache.h"
#import "DataCenter.h"
#import <BmobSDK/BmobProFile.h>
#import "BmobObjectsBatch.h"


@implementation DataCenter

+ (void)startSyncData {
    
    if (![LogIn isLogin]) return;
    
    //把本地无账号关联的数据与当前登录账号进行关联
    [PlanCache linkedLocalDataToAccount];
    
    //同步设置
    [self startSyncSettings];
    
    //加载本地同步时间
    
    //如果没有，则从服务器获取全部设置和计划数据（只取未删除标识的）
    
    //如果有，则从服务器获取设置和updatetime大于等于本地同步时间的数据（只取未删除标识的）
    
    //对比本地数据与服务器上的数据，取updatetime较新的数据进行同步保存
    
    //更新本地同步时间
}

+ (void)startSyncSettings {
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"UserSettings"];
    [bquery whereKey:@"userObjectId" equalTo:[Config shareInstance].settings.account];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if (array.count > 0) {
            
            BmobObject *obj = array[0];
            
            if ([Config shareInstance].settings.syntime) {
                //本地有上次同步时间记录，对比服务器的更新时间与本地同步记录时间
                NSDate *syntime = [CommonFunction NSStringDateToNSDate:[Config shareInstance].settings.syntime formatter:str_DateFormatter_yyyy_MM_dd_HHmmss];
                NSDate *updateAt = [obj updatedAt];
                
                /*
                - (NSComparisonResult)compare:(NSDate *)other;
                . 当实例保存的日期值与anotherDate相同时返回NSOrderedSame
                . 当实例保存的日期值晚于anotherDate时返回NSOrderedDescending
                . 当实例保存的日期值早于anotherDate时返回NSOrderedAscending
                 */
                if ([syntime compare:updateAt] == NSOrderedAscending) {
                    //服务器的设置较新
                    [self syncServerToLocalForSettings:obj];
                    
                } else if ([syntime compare:updateAt] == NSOrderedDescending) {
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
    
    NSData *avatarData = [obj objectForKey:@"avatar"];
    if (avatarData) {
        UIImage *image = [UIImage imageWithData:avatarData];
        [Config shareInstance].settings.avatar = image;
    }
    [Config shareInstance].settings.syntime = [CommonFunction getTimeNowString];
    
    [PlanCache storePersonalSettings:[Config shareInstance].settings];
    
}

+ (void)syncLocalToServerForSettings {
    
    BmobObject *userSettings = [BmobObject objectWithoutDatatWithClassName:@"UserSettings"  objectId:[Config shareInstance].settings.account];
    
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
    
    [userSettings updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            //修改成功后的动作
//            //更新本地syntime
//            [Config shareInstance].settings.syntime = [CommonFunction getTimeNowString];
//            [PlanCache storePersonalSettings:[Config shareInstance].settings];
            
        } else if (error){
            NSLog(@"%@",error);
        } else {
            NSLog(@"UnKnow error");
        }
    }];
    
    //上传头像
    [self uploadAvatar:userSettings];
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
    //异步保存
    [userSettings saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            
            NSLog(@"objectid :%@",userSettings.objectId);
            
//            //更新本地syntime
//            [Config shareInstance].settings.syntime = [CommonFunction getTimeNowString];
//            [PlanCache storePersonalSettings:[Config shareInstance].settings];
            
        } else if (error){
            
            NSLog(@"%@",error);
            
        } else {
            
            NSLog(@"Unknow error");
            
        }
    }];
    
    //上传头像
    [self uploadAvatar:userSettings];
}

+ (void)uploadAvatar:(BmobObject *)obj {
    //上传头像
    NSData *avatarData = [UserDefaults objectForKey:str_Avatar];
    if (avatarData) {
        //上传文件
        [BmobProFile uploadFileWithFilename:@"avatar.png" fileData:avatarData block:^(BOOL isSuccessful, NSError *error, NSString *filename, NSString *url, BmobFile *bmobFile) {
            if (isSuccessful) {
                
                //把上传完的文件保存到“头像”字段
                [obj setObject:bmobFile forKey:@"avatar"];
                [obj setObject:url forKey:@"avatarURL"];
                [obj saveInBackground];
                
//                //更新本地syntime
//                [Config shareInstance].settings.syntime = [CommonFunction getTimeNowString];
//                [PlanCache storePersonalSettings:[Config shareInstance].settings];
                
                //打印文件名
                NSLog(@"filename %@",filename);
                //打印url
                NSLog(@"url %@",url);
                NSLog(@"bmobFile:%@\n",bmobFile);
                
            } else if (error) {
                
                NSLog(@"error %@",error);
                
            }
            
        } progress:^(CGFloat progress) {
            //上传进度
            NSLog(@"progress %f",progress);
        }];
    }
}

+ (void)startSyncPlan {
    
    [DataCenter getNewPlanFromServer];
}

+ (void)getNewPlanFromServer {
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Plan"];
    
    [bquery whereKey:@"userObjectId" equalTo:[Config shareInstance].settings.account];
    [bquery whereKey:@"isDeleted" equalTo:@"0"];
    [bquery orderByDescending:@"updatedTime"];
    
    if ([Config shareInstance].settings.syntime) {
        
        [bquery whereKey:@"updatedTime" greaterThanOrEqualTo:[Config shareInstance].settings.syntime];
        
    }
    bquery.limit = 1000;
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        [DataCenter compareServerNewWithLocalForPlan:array];
        
        [DataCenter getNewPlanFromLocal:array];
        
    }];
    
}

// 加载本地上次同步时间之后的计划数据进行对比
+ (void)getNewPlanFromLocal:(NSArray *)serverNewArray {
    
    NSArray *localNewArray = [NSArray array];
    if ([Config shareInstance].settings.syntime) {
        
        localNewArray = [PlanCache getPlanForSync:[Config shareInstance].settings.syntime];
    } else {
        
        localNewArray = [PlanCache getPlanForSync:nil];
    }
    
    BOOL flag = YES;
    for (Plan *plan in localNewArray) {
        
        flag = YES;
        
        for (BmobObject *obj in serverNewArray) {
            
            NSString *planid = [obj objectForKey:@"planId"];
            if ([plan.planid isEqualToString:planid]) {
                flag = NO;
                break;
            }
        }
        
        if (flag) {
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
        
    }
}

+ (void)compareServerNewWithLocalForPlan:(NSArray *)array {
    
    for (BmobObject *obj in array) {
        
        NSString *account = [obj objectForKey:@"userObjectId"];
        NSString *planid = [obj objectForKey:@"planId"];
        NSString *updatedTime = [obj objectForKey:@"updatedTime"];
        
        Plan *plan = [PlanCache findPlan:account planid:planid];
        if (plan.planid) {
            //本地存在，对比updatetime
            if ([updatedTime compare:plan.updatetime] == NSOrderedAscending) {
                //服务器的较新
                [DataCenter updatePlanToLocal:obj];
                
            } else {
                //本地的较新
                [DataCenter updatePlanToServer:obj plan:plan];
                
            }
        } else {
            //本地不存在，存入本地
            [DataCenter updatePlanToLocal:obj];
        }
        
    }
    
}

+ (void)updatePlanToLocal:(BmobObject *)obj {
    
    Plan *plan = [[Plan alloc] init];
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

+ (void)updatePlanToServer:(BmobObject *)obj plan:(Plan *)plan {
    
    BmobObject *bmobObject = [BmobObject objectWithoutDatatWithClassName:@"Plan"  objectId:[obj objectId]];
    if (plan.content) {
        [bmobObject setObject:plan.content forKey:@"content"];
    }
    if (plan.completetime) {
        [bmobObject setObject:plan.completetime forKey:@"completedTime"];
    }
    if (plan.updatetime) {
        [bmobObject setObject:plan.updatetime forKey:@"updatedTime"];
    }
    if (plan.notifytime) {
        [bmobObject setObject:plan.notifytime forKey:@"notifyTime"];
    }
    if (plan.iscompleted) {
        [bmobObject setObject:plan.iscompleted forKey:@"isCompleted"];
    }
    if (plan.isnotify) {
        [bmobObject setObject:plan.isnotify forKey:@"isNotify"];
    }
    if (plan.isdeleted) {
        [bmobObject setObject:plan.isdeleted forKey:@"isDeleted"];
    }
    [bmobObject updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            //修改成功后的动作
            
        } else if (error){
            NSLog(@"%@",error);
        } else {
            NSLog(@"UnKnow error");
        }
    }];
}

+ (void)syncLocalToServerForPlan {
}

@end
