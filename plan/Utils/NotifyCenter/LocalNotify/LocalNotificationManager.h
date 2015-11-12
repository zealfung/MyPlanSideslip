//
//  LocalNotificationManager.h
//  plan
//
//  Created by Fengzy on 15/9/6.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    NotificationTypePlan,       //计划通知
    NotificationTypeOthers,     //其他通知
} NotificationType;

@interface LocalNotificationManager : NSObject

/**
 *  添加本地通知
 *
 *  @param fireDate 通知提醒时间（准时提醒）
 *  @param userDic  对应该通知的详细字典数据。必须要包含三个字段：
 *          1、tag：提醒源的ID表示，如计划ID
 *          2、time：firDate的日期秒数
 *          3、type：所属分类。目前有两类，详见：NotificationType
 *
 *  @param body     提醒内容
 */
+ (void)createLocalNotification:(NSDate*)fireDate userInfo:(NSDictionary*)userDic alertBody:(NSString*)body;

/**
 *  取消指定的通知
 *
 *  @param tag 提醒源的ID表示，如计划ID
 *  @param time  firDate的日期秒数
 *  @param type  所属分类。目前有两类，详见：NotificationType
 *
 *  @return 是否找到对应的通知对象，找到返回YES，找不到返回NO
 */
+ (BOOL)cancelNotificationWithTag:(NSString*)aTag time:(NSTimeInterval)aTime type:(NotificationType)aType;

/**
 *  修改更新通知信息内容
 *
 *  @param tag 提醒源的ID表示，如计划ID
 *  @param time  firDate的日期秒数
 *  @param type  所属分类。目前有两类，详见：NotificationType
 *  @param fireDate 通知提醒时间（准时提醒）
 *  @param userDic  对应该通知的详细字典数据。必须要包含三个字段：
 *          1、tag：提醒源的ID表示，如计划ID
 *          2、time：firDate的日期秒数
 *          3、type：所属分类。目前有两类，详见：NotificationType
 *
 *  @return 修改成功返回YES，修改失败返回NO
 */
+ (BOOL)updateNotificationWithTag:(NSString*)aTag time:(NSTimeInterval)aTime type:(NotificationType)aType fireDate:(NSDate*)fireDate userInfo:(NSDictionary*)userDic alertBody:(NSString*)body;

/**
 *  修改更新指定通知信息内容
 *
 *  @param notification 需要更新的通知对象
 *  @param fireDate 通知提醒时间（准时提醒）
 *  @param userDic  对应该通知的详细字典数据。必须要包含三个字段：
 *          1、tag：提醒源的ID表示，如计划ID
 *          2、time：firDate的日期秒数
 *          3、type：所属分类。目前有两类，详见：NotificationType
 *
 *  @return 修改成功返回YES，修改失败返回NO
 */
+ (BOOL)updateNotificationWithTag:(UILocalNotification*)notification fireDate:(NSDate*)fireDate userInfo:(NSDictionary*)userDic alertBody:(NSString*)body;

/**
 *  返回指定特定的UILocalNotification对象
 *
 *  @param tag 提醒源的ID表示，如计划ID
 *  @param time  firDate的日期秒数
 *  @param type  所属分类。目前有两类，详见：NotificationType
 *
 *  @return 是否找到对应的通知对象，找到返回YES，找不到返回NO
 */
+ (UILocalNotification*)findNotification:(NSString*)aTag time:(NSTimeInterval)aTime type:(NotificationType)aType;

/**
 *  取消所有的通知
 */
+ (void)cancelAllLocalNotification;

/**
 *  取消特定的本地通知
 *
 *  @param notification 需要取消的对象
 */
+ (void)cancelNotification:(UILocalNotification*)notification;

/**
 *  获取所有的本地提醒
 *
 *  @return 本地提醒数组列表
 */
+ (NSArray *)getAllLocalNotification;

/**
 *  获取指定类型的本地通知
 *
 *  @param tag 提醒源的ID表示，如计划ID
 *  @param type  所属分类。目前有两类，详见：NotificationType
 *
 *  @return 所有符合要求的通知数组
 */
+ (NSArray *)getNotificationWithTag:(NSString*)aTag type:(NotificationType)aType;


@end
