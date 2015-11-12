//
//  AddPlanViewController.h
//  plan
//
//  Created by Fengzy on 15/8/30.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "Plan.h"
#import "FatherViewController.h"


@interface AddPlanViewController : FatherViewController

@property (nonatomic, assign) PlanType planType;
@property (nonatomic, assign) OperationType operationType;
@property (nonatomic, strong) Plan *plan;

@end
