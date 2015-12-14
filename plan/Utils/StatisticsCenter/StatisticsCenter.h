//
//  StatisticsCenter.h
//  plan
//
//  Created by Fengzy on 15/11/12.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StatisticsCenter : NSObject

//签到
+ (void)checkIn;

//今天已签到
+ (BOOL)isCheckInToday;

@end
