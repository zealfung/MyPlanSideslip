//
//  Plan.h
//  plan
//
//  Created by Fengzy on 15/8/29.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "ModelBase.h"

typedef NS_ENUM(NSUInteger, PlanType) {
    
    EverydayPlan = 1, //每日计划
    
    FuturePlan //未来计划
};

@interface Plan : ModelBase <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *planid;
@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *createtime;
@property (nonatomic, strong) NSString *beginDate;//计划开始日期
@property (nonatomic, strong) NSString *completetime;
@property (nonatomic, strong) NSString *updatetime;
@property (nonatomic, strong) NSString *iscompleted; //是否已完成: 1是 0否
@property (nonatomic, strong) NSString *isnotify; //是否提醒: 1是 0否
@property (nonatomic, strong) NSString *notifytime;
@property (nonatomic, strong) NSString *isdeleted; //是否已删除 1是 0否

@end
