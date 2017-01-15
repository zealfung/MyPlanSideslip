//
//  PlanEditViewController.h
//  plan
//
//  Created by Fengzy on 17/1/15.
//  Copyright © 2017年 Fengzy. All rights reserved.
//

#import "Plan.h"
#import "FatherViewController.h"

@interface PlanEditViewController : FatherViewController

/** 待编辑计划 */
@property (nonatomic, strong) Plan *plan;

@end
