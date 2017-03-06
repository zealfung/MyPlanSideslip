//
//  PlanDataCenter.h
//  plan
//
//  Created by Fengzy on 17/2/24.
//  Copyright © 2017年 Fengzy. All rights reserved.
//

#import "Plan.h"
#import <Foundation/Foundation.h>

@interface PlanDataCenter : NSObject

/** 加载计划数据 */
+ (NSArray *)getPlanFromStartIndex:(NSInteger)startIndex;

/** 新建计划 */
+ (void)addPlan:(Plan *)newPlan;

/** 修改计划 */
+ (void)updatePlan:(Plan *)plan;

@end
