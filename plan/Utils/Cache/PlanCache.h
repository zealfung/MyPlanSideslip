//
//  PlanCache.h
//  plan
//
//  Created by Fengzy on 15/8/29.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "Plan.h"
#import "Task.h"
#import "Photo.h"
#import "Settings.h"
#import "Messages.h"
#import "TaskRecord.h"
#import "Statistics.h"

@interface PlanCache : NSObject

+ (void)openDBWithAccount:(NSString *)account;

+ (void)storePersonalSettings:(Settings *)settings isNotify:(BOOL)isNotify;

+ (void)deletePersonalSettings:(Settings *)settings;

+ (BOOL)storePlan:(Plan *)plan;

/** 更新计划的完成状态 */
+ (BOOL)updatePlanState:(Plan *)plan;

+ (BOOL)storePhoto:(Photo *)photo;

+ (BOOL)storeStatistics:(Statistics *)statistics;

/** 
 * 保存任务
 * updateNotify:是否需要更新提醒时间
 */
+ (BOOL)storeTask:(Task *)task updateNotify:(BOOL)updateNotify;

/** 更新任务完成次数 */
+ (BOOL)updateTaskCount:(Task *)task;

/** 更新任务排序 */
+ (void)updateTaskOrder:(Task *)task;

+ (BOOL)storeTaskRecord:(TaskRecord *)taskRecord;

+ (BOOL)storeMessages:(Messages *)message;

+ (BOOL)setMessagesRead:(Messages *)message;

+ (BOOL)deletePlan:(Plan *)plan;

+ (void)cleanPlan:(Plan *)plan;

+ (BOOL)deletePhoto:(Photo *)photo;

+ (void)cleanPhoto:(Photo *)photo;

+ (BOOL)deleteTask:(Task *)task;

+ (void)cleanTask:(Task *)task;

+ (void)cleanTaskRecordByTaskId:(NSString *)taskId;

+ (BOOL)cleanHasReadMessages;

+ (BOOL)hasUnreadMessages;

+ (Settings *)getPersonalSettings;

+ (NSArray *)getPlan:(BOOL)isEverydayPlan startIndex:(NSInteger)startIndex;

/** 获取未完计划 */
+ (NSArray *)getUndonePlan;

/** 自动生成每日重复计划 */
+ (void)setRepeatPlan;

+ (NSArray *)searchPlan:(NSString *)key;

/** ALL全部 DAY每日计划 FUTURE未来计划 */
+ (NSString *)getPlanTotalCount:(NSString *)type;

+ (NSString *)getPlanCompletedCount;

+ (NSArray *)getPhoto:(NSInteger)startIndex;

+ (NSMutableArray *)getTask;

+ (Task *)getTaskById:(NSString *)taskId;

+ (NSArray *)getTaskRecord:(NSString *)recordId;

+ (NSArray *)getMessages;

+ (NSString *)getPhotoTotalCount;

+ (NSString *)getTaskTotalCount;

/** 按时间段统计任务完成次数 */
+ (NSArray *)getTaskStatisticsByStartDate:(NSString *)startDate endDate:(NSString *)endDate;

+ (Photo *)getPhotoById:(NSString *)photoid;

+ (Statistics *)getStatistics;

+ (void)updatePlanNotification:(Plan *)plan;

+ (void)linkedLocalDataToAccount;

+ (NSArray *)getPlanForSync:(NSString *)syntime;

+ (Plan *)findPlan:(NSString *)account planid:(NSString *)planid;

/** time:yyyy-MM-dd HH:mm:ss */
+ (NSArray *)getPlanDateForStatisticsByTime:(NSString *)time;

+ (NSArray *)getTaskForSync:(NSString *)syntime;

+ (NSArray *)getTaskRecordForSyncByTaskId:(NSString *)taskId syntime:(NSString *)syntime;

+ (Task *)findTask:(NSString *)account taskId:(NSString *)taskId;

+ (NSArray *)getPhotoForSync:(NSString *)syntime;

+ (void)addPlanNotification:(Plan *)plan;

+ (void)setFiveDayNotification;

@end
