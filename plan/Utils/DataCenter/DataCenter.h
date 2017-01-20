//
//  DataCenter.h
//  plan
//
//  Created by Fengzy on 15/10/3.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import <BmobSDK/BmobQuery.h>

@interface DataCenter : NSObject

+ (void)startSyncData;

+ (void)startSyncSettings;

+ (void)getMessagesFromServer;

+ (void)setPlanBeginDate;

/** 自动生成每日重复计划 */
+ (void)setRepeatPlan;

/** 更新版本号信息到服务器 */
+ (void)updateVersionToServerForSettings;

@end
