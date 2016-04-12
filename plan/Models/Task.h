//
//  Task.h
//  plan
//
//  Created by Fengzy on 15/11/29.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "ModelBase.h"

@interface Task : ModelBase <NSCoding, NSCopying>

/** 任务id */
@property (nonatomic, strong) NSString *taskId;
/** 关联账号 */
@property (nonatomic, strong) NSString *account;
/** 任务内容 */
@property (nonatomic, strong) NSString *content;
/** 已完成次数 */
@property (nonatomic, strong) NSString *totalCount;
/** 最近一次的完成日期，格式：2016-04-12 17:59:59 */
@property (nonatomic, strong) NSString *completionDate;
/** 提醒时间，格式：2016-04-12 16:58 */
@property (nonatomic, strong) NSString *createTime;
@property (nonatomic, strong) NSString *updateTime;
@property (nonatomic, strong) NSString *isNotify; //是否提醒: 1是 0否
/** 提醒时间，格式：2016-04-12 16:58 */
@property (nonatomic, strong) NSString *notifyTime;
/** 是否已删除 1是 0否 */
@property (nonatomic, strong) NSString *isDeleted;
/** 是否番茄任务：1是 0否 */
@property (nonatomic, strong) NSString *isTomato;
/** 番茄时间（分钟） */
@property (nonatomic, strong) NSString *tomatoMinute;
/** 是否重复提醒：1是 0否 */
@property (nonatomic, strong) NSString *isRepeat;
/** 重复类型: 0每天 1每周 2每月 3每年 4不重复 */
@property (nonatomic, strong) NSString *repeatType;
/** 拖动排列序号 */
@property (nonatomic, strong) NSString *taskOrder;

@end
