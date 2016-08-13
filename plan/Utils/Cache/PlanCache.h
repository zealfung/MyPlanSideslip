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

+ (void)storePersonalSettings:(Settings *)settings;

+ (BOOL)storePlan:(Plan *)plan;

+ (BOOL)storePhoto:(Photo *)photo;

+ (BOOL)storeStatistics:(Statistics *)statistics;

+ (BOOL)storeTask:(Task *)task updateNotify:(BOOL)updateNotify;

+ (BOOL)storeTaskRecord:(TaskRecord *)taskRecord;

+ (BOOL)storeMessages:(Messages *)message;

+ (BOOL)setMessagesRead:(Messages *)message;

+ (BOOL)deletePlan:(Plan *)plan;

+ (BOOL)deletePhoto:(Photo *)photo;

+ (BOOL)deleteTask:(Task *)task;

+ (BOOL)cleanHasReadMessages;

+ (BOOL)hasUnreadMessages;

+ (Settings *)getPersonalSettings;

+ (NSArray *)getPlan:(BOOL)isEverydayPlan startIndex:(NSInteger)startIndex;

/** 获取未完计划 */
+ (NSArray *)getUndonePlan;

+ (NSArray *)searchPlan:(NSString *)key;

//ALL全部 DAY每日计划 FUTURE未来计划
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

//time:yyyy-MM-dd HH:mm:ss
+ (NSArray *)getPlanDateForStatisticsByTime:(NSString *)time;

+ (NSArray *)getTaskForSync:(NSString *)syntime;

+ (NSArray *)getTaskRecordForSyncByTaskId:(NSString *)taskId syntime:(NSString *)syntime;

+ (Task *)findTask:(NSString *)account taskId:(NSString *)taskId;

+ (NSArray *)getPhotoForSync:(NSString *)syntime;

@end
