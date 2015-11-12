//
//  Plan.h
//  plan
//
//  Created by Fengzy on 15/8/29.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "ModelBase.h"

typedef NS_ENUM(NSUInteger, PlanType) {
    
    PlanEveryday = 1, //今日计划
    
    PlanLife //长远计划
    
};

@interface Plan : ModelBase <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *planid;
@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *createtime;
@property (nonatomic, strong) NSString *completetime;
@property (nonatomic, strong) NSString *updatetime;
@property (nonatomic, strong) NSString *iscompleted; //是否已完成: 1是 0否
@property (nonatomic, strong) NSString *isnotify; //是否提醒: 1是 0否
@property (nonatomic, strong) NSString *notifytime;
@property (nonatomic, strong) NSString *plantype; //计划类型 1每日计划 0长远计划
@property (nonatomic, strong) NSString *isdeleted; //是否已删除 1是 0否

@end
