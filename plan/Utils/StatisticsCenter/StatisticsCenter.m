//
//  StatisticsCenter.m
//  plan
//
//  Created by Fengzy on 15/11/12.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "Statistics.h"
#import "StatisticsCenter.h"

@implementation StatisticsCenter

//计算最大连续天数
- (void)calculateMaximumNumberOfConsecutiveDays {
    
    NSInteger recentMax = 0;
    NSInteger recordMax = 0;
    Statistics *statistics = [PlanCache getStatistics];
    NSArray *dateArray = [PlanCache getPlanDateForStatisticsByTime:nil];
    
    NSDate *date1;
    NSDate *date2;
    NSInteger daysCount = 0;
    for (int i = 0; i < dateArray.count - 1; i++) {
        date1 = [CommonFunction NSStringDateToNSDate:dateArray[i] formatter:str_DateFormatter_yyyy_MM_dd];
        date2 = [CommonFunction NSStringDateToNSDate:dateArray[i + 1] formatter:str_DateFormatter_yyyy_MM_dd];
        
        NSInteger intervalDays = [CommonFunction calculateDateInterval:date1 toDate:date2 calendarUnit:NSDayCalendarUnit];
        if (intervalDays > 1) {
            
            if (recentMax == 0) {
                recentMax = daysCount;
            }
            if (daysCount > recordMax) {
                recordMax = daysCount;
            }
            daysCount = 0;
            
        } else {
            
            daysCount++;
        }
    }
}

@end
