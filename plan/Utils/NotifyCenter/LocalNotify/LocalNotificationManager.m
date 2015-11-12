//
//  LocalNotificationManager.m
//  plan
//
//  Created by Fengzy on 15/9/6.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "LocalNotificationManager.h"

static LocalNotificationManager * instance = nil;

@implementation LocalNotificationManager


+ (void)createLocalNotification:(NSDate*)fireDate userInfo:(NSDictionary*)userDic alertBody:(NSString*)body {
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    //如果时间已到，则不继续添加通知
    if (!fireDate || [fireDate compare:[NSDate date]] == NSOrderedAscending) {
        return;
    }
    NSArray *arry = [LocalNotificationManager getAllLocalNotification];
    //查询是否已经添加该通知,如果已经存在该通知，则不再继续添加
    for (UILocalNotification *item in arry) {
        NSDictionary *sourceN = item.userInfo;
        NSString *tag = [sourceN objectForKey:@"tag"];
        NSTimeInterval time = [[sourceN objectForKey:@"time"] doubleValue];
        NotificationType type = [[sourceN objectForKey:@"type"] integerValue];
        if ([tag longLongValue] == [[userDic objectForKey:@"tag"] longLongValue] &&
            time == [[userDic objectForKey:@"time"] doubleValue] &&
            type == [[userDic objectForKey:@"type"] integerValue]) {
            NSLog(@"UILocalNotification is exist:\ntag:%@\n time:%@\n type:%lu", tag, [sourceN objectForKey:@"time"], (unsigned long)type);
            return;
        }
    }
    localNotif.fireDate = fireDate;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertBody = body;
    localNotif.alertAction = str_Show;
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.userInfo = userDic;
    localNotif.applicationIconBadgeNumber = 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

+ (BOOL)cancelNotificationWithTag:(NSString*)aTag time:(NSTimeInterval)aTime type:(NotificationType)aType {
    UILocalNotification *localNotification = [LocalNotificationManager findNotification:aTag time:aTime type:aType];
    if (localNotification) {
        //如果找到对应的通知，则做更新处理
        // 获得 UIApplication
        UIApplication *app = [UIApplication sharedApplication];
        //不推送 取消推送
        [app cancelLocalNotification:localNotification];
        
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)updateNotificationWithTag:(NSString*)aTag time:(NSTimeInterval)aTime type:(NotificationType)aType fireDate:(NSDate*)fireDate userInfo:(NSDictionary*)userDic alertBody:(NSString*)body {
    UILocalNotification *localNotification = [LocalNotificationManager findNotification:aTag time:aTime type:aType];
    if (localNotification) {
        [LocalNotificationManager cancelNotification:localNotification];
        [LocalNotificationManager createLocalNotification:fireDate userInfo:userDic alertBody:body];
        
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)updateNotificationWithTag:(UILocalNotification*)notification fireDate:(NSDate*)fireDate userInfo:(NSDictionary*)userDic alertBody:(NSString*)body {
    if (notification) {
        [LocalNotificationManager cancelNotification:notification];
        [LocalNotificationManager createLocalNotification:fireDate userInfo:userDic alertBody:body];
        
        return YES;
    } else {
        return NO;
    }
}

+ (UILocalNotification*)findNotification:(NSString*)aTag time:(NSTimeInterval)aTime type:(NotificationType)aType {
    // 获得 UIApplication
    UIApplication *app = [UIApplication sharedApplication];
    //获取本地推送数组
    NSArray *localArray = [app scheduledLocalNotifications];
    UILocalNotification *localNotification = nil;
    for (UILocalNotification *noti in localArray) {
        NSDictionary *dict = noti.userInfo;
        if (dict) {
            NSString *tag = [dict objectForKey:@"tag"];
            NSTimeInterval time = [[dict objectForKey:@"time"] doubleValue];
            NotificationType type = [[dict objectForKey:@"type"] integerValue];
            if ([tag longLongValue] == [aTag longLongValue] &&
                time == aTime &&
                type == aType) {
                localNotification = noti;
                break;
            }
        }
    }
    return localNotification;
}

+ (void)cancelAllLocalNotification {
    // 获得 UIApplication
    UIApplication *app = [UIApplication sharedApplication];
    [app cancelAllLocalNotifications];
}

+ (void)cancelNotification:(UILocalNotification*)notification {
    if (notification == nil) {
        return;
    }
    // 获得 UIApplication
    UIApplication *app = [UIApplication sharedApplication];
    [app cancelLocalNotification:notification];
}

+ (NSArray *)getAllLocalNotification {
    // 获得 UIApplication
    UIApplication *app = [UIApplication sharedApplication];
    //获取本地推送数组
    NSArray *localArray = [app scheduledLocalNotifications];
    
    return localArray;
}

+ (NSArray *)getNotificationWithTag:(NSString*)aTag type:(NotificationType)aType {
    // 获得 UIApplication
    UIApplication *app = [UIApplication sharedApplication];
    //获取本地推送数组
    NSArray *localArray = [app scheduledLocalNotifications];
    NSMutableArray *resultArray = [NSMutableArray array];
    for (UILocalNotification *noti in localArray) {
        NSDictionary *dict = noti.userInfo;
        if (dict) {
            NSString *tag = [dict objectForKey:@"tag"];
            NotificationType type = [[dict objectForKey:@"type"] integerValue];
            if ([tag longLongValue] == [aTag longLongValue] &&
                type == aType) {
                [resultArray addObject:noti];
            }
        }
    }
    return resultArray;
}


@end
