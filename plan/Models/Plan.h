//
//  Plan.h
//  plan
//
//  Created by Fengzy on 15/8/29.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "ModelBase.h"

typedef NS_ENUM(NSUInteger, PlanType)
{
    /** 每日计划 */
    EverydayPlan = 1,
    /** 未来计划 */
    FuturePlan
};

@interface Plan : ModelBase

/** 计划ID */
@property (nonatomic, strong) NSString *planid;
/** 计划所属账号 */
@property (nonatomic, strong) NSString *account;
/** 计划内容 */
@property (nonatomic, strong) NSString *content;
/** 计划创建日期 */
@property (nonatomic, strong) NSString *createtime;
/** 计划开始日期 */
@property (nonatomic, strong) NSString *beginDate;
/** 完成时间 */
@property (nonatomic, strong) NSString *completetime;
/** 更新时间 */
@property (nonatomic, strong) NSString *updatetime;
/** 是否已完成: 1是 0否 */
@property (nonatomic, strong) NSString *iscompleted;
/** 是否提醒: 1是 0否 */
@property (nonatomic, strong) NSString *isnotify;
/** 提醒时间 */
@property (nonatomic, strong) NSString *notifytime;
/** 是否已删除 1是 0否 */
@property (nonatomic, strong) NSString *isdeleted;
/** 是否每日重复 1是 0否 */
@property (nonatomic, strong) NSString *isRepeat;
/** 完成备注 */
@property (nonatomic, strong) NSString *remark;

@end
