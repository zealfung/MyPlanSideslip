//
//  Task.h
//  plan
//
//  Created by Fengzy on 15/11/29.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "ModelBase.h"

@interface Task : ModelBase <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *taskId;
@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *totalCount;//完成次数
@property (nonatomic, strong) NSString *completionDate;//完成日期（记录最近完成一次任务的日期）
@property (nonatomic, strong) NSString *createTime;
@property (nonatomic, strong) NSString *updateTime;
@property (nonatomic, strong) NSString *isNotify; //是否提醒: 1是 0否
@property (nonatomic, strong) NSString *notifyTime;
@property (nonatomic, strong) NSString *isDeleted; //是否已删除 1是 0否

@end
