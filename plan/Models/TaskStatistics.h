//
//  TaskStatistics.h
//  plan
//
//  Created by Fengzy on 16/8/13.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskStatistics : NSObject

/** 关联账号 */
@property (nonatomic, strong) NSString *account;
/** 任务内容 */
@property (nonatomic, strong) NSString *taskContent;
/** 任务统计 */
@property (nonatomic, assign) NSInteger taskCount;

@end
