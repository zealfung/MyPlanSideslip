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

/** 检查新版本 */
+ (void)checkNewVsrion;

/** 更新版本号信息到服务器 */
+ (void)updateVersionToServerForSettings;

@end
