//
//  StatisticsCenter.m
//  plan
//
//  Created by Fengzy on 15/11/12.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "LogIn.h"
#import "BmobACL.h"
#import "BmobQuery.h"
#import "Statistics.h"
#import "StatisticsCenter.h"

@implementation StatisticsCenter

+ (BOOL)isCheckInToday {
    Statistics *statistics = [PlanCache getStatistics];
    if (statistics.updatetime && statistics.updatetime.length > 0) {
        NSDate *lastCheckInDate = [CommonFunction NSStringDateToNSDate:statistics.updatetime formatter:str_DateFormatter_yyyy_MM_dd_HHmmss];
        //已签到
        return [CommonFunction isSameDay:[NSDate date] date2:lastCheckInDate];
    }
    return NO;
}

+ (void)checkIn {
    
    if (![LogIn isLogin]) return;
    
    Statistics *statistics = [PlanCache getStatistics];
    if (statistics.updatetime && statistics.updatetime.length > 0) {
        NSDate *lastCheckInDate = [CommonFunction NSStringDateToNSDate:statistics.updatetime formatter:str_DateFormatter_yyyy_MM_dd_HHmmss];
        //已签到
        if ([CommonFunction isSameDay:[NSDate date] date2:lastCheckInDate]) return;
    }
    __weak typeof(self) weakSelf = self;
    BmobUser *user = [BmobUser getCurrentUser];
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"CheckIn"];
    [bquery whereKey:@"userObjectId" equalTo:user.objectId];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (!error && array.count == 1) {
            //服务器有签到记录
            BmobObject *obj = array[0];
            NSDate *recentEnd = [obj objectForKey:@"recentEnd"];
            NSInteger recentDates = [[obj objectForKey:@"recentDates"] integerValue];
            NSInteger maxDates = [[obj objectForKey:@"maxDates"] integerValue];
            NSDate *recentBegin = [obj objectForKey:@"recentBegin"];
            BOOL isContinuous = [self isContinuousDate:recentEnd date2:[NSDate date]];
            if (isContinuous) {
                
                recentDates += 1;
                recentEnd = [NSDate date];
                
                if (recentDates > maxDates) {
                    [obj setObject:[NSNumber numberWithInteger:recentDates] forKey:@"maxDates"];
                    [obj setObject:recentBegin forKey:@"maxBegin"];
                    [obj setObject:[NSDate date] forKey:@"maxEnd"];
                    [obj setObject:[NSNumber numberWithInteger:recentDates] forKey:@"recentDates"];
                    [obj setObject:[NSDate date] forKey:@"recentEnd"];
                    [weakSelf updateCheckIn:obj];
                } else {
                    [obj setObject:[NSNumber numberWithInteger:recentDates] forKey:@"recentDates"];
                    [obj setObject:[NSDate date] forKey:@"recentEnd"];
                    [weakSelf updateCheckIn:obj];
                }
            } else {
                //没有连续签到，重新开始算
                if (recentDates > maxDates) {
                    [obj setObject:[NSNumber numberWithInteger:recentDates] forKey:@"maxDates"];
                    [obj setObject:recentBegin forKey:@"maxBegin"];
                    [obj setObject:recentEnd forKey:@"maxEnd"];
                    [obj setObject:[NSNumber numberWithInt:1] forKey:@"recentDates"];
                    [obj setObject:[NSDate date] forKey:@"recentBegin"];
                    [obj setObject:[NSDate date] forKey:@"recentEnd"];
                    [weakSelf updateCheckIn:obj];
                } else {
                    [obj setObject:[NSNumber numberWithInt:1] forKey:@"recentDates"];
                    [obj setObject:[NSDate date] forKey:@"recentBegin"];
                    [obj setObject:[NSDate date] forKey:@"recentEnd"];
                    [weakSelf updateCheckIn:obj];
                }
            }
        } else {
            //服务器没有签到记录
            [weakSelf addCheckIn];
        }
    }];
}

+ (void)addCheckIn {
    BmobUser *user = [BmobUser getCurrentUser];
    BmobObject  *checkIn = [BmobObject objectWithClassName:@"CheckIn"];
    [checkIn setObject:user.objectId forKey:@"userObjectId"];
    [checkIn setObject:[NSNumber numberWithInt:1] forKey:@"recentDates"];
    [checkIn setObject:[NSDate date] forKey:@"recentBegin"];
    [checkIn setObject:[NSDate date] forKey:@"recentEnd"];
    [checkIn setObject:[NSNumber numberWithInt:1] forKey:@"maxDates"];
    [checkIn setObject:[NSDate date] forKey:@"maxBegin"];
    [checkIn setObject:[NSDate date] forKey:@"maxEnd"];
    BmobACL *acl = [BmobACL ACL];
    [acl setReadAccessForUser:user];//设置只有当前用户可读
    [acl setWriteAccessForUser:user];//设置只有当前用户可写
    checkIn.ACL = acl;
    //异步保存
    [checkIn saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            Statistics *statistics = [[Statistics alloc] init];
            statistics.recentMax = [checkIn objectForKey:@"recentDates"];
            statistics.recentMaxBeginDate = [checkIn objectForKey:@"recentBegin"];
            statistics.recentMaxEndDate = [checkIn objectForKey:@"recentEnd"];
            statistics.recordMax = [checkIn objectForKey:@"maxDates"];
            statistics.recordMaxBeginDate = [checkIn objectForKey:@"maxBegin"];
            statistics.recordMaxEndDate = [checkIn objectForKey:@"maxEnd"];
            statistics.updatetime = [CommonFunction getTimeNowString];
            [PlanCache storeStatistics:statistics];
            NSLog(@"签到成功objectid :%@",checkIn.objectId);
            
        } else if (error){
            NSLog(@"签到失败%@",error);
        } else {
            NSLog(@"签到Unknow error");
        }
    }];
    [self addCheckInRecord];
}

+ (void)addCheckInRecord {
    BmobUser *user = [BmobUser getCurrentUser];
    BmobObject *checkInRecord = [BmobObject objectWithClassName:@"CheckInRecord"];
    [checkInRecord setObject:user.objectId forKey:@"userObjectId"];
    BmobACL *acl = [BmobACL ACL];
    [acl setReadAccessForUser:user];//设置只有当前用户可读
    [acl setWriteAccessForUser:user];//设置只有当前用户可写
    checkInRecord.ACL = acl;
    //异步保存
    [checkInRecord saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            NSLog(@"插入签到记录成功objectid :%@",checkInRecord.objectId);
        } else if (error){
            NSLog(@"插入签到记录失败%@",error);
        } else {
            NSLog(@"插入签到记录Unknow error");
        }
    }];
}

+ (void)updateCheckIn:(BmobObject *)obj {
    BmobACL *acl = [BmobACL ACL];
    [acl setReadAccessForUser:[BmobUser getCurrentUser]];//设置只有当前用户可读
    [acl setWriteAccessForUser:[BmobUser getCurrentUser]];//设置只有当前用户可写
    obj.ACL = acl;
    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            Statistics *statistics = [[Statistics alloc] init];
            statistics.recentMax = [obj objectForKey:@"recentDates"];
            statistics.recentMaxBeginDate = [obj objectForKey:@"recentBegin"];
            statistics.recentMaxEndDate = [obj objectForKey:@"recentEnd"];
            statistics.recordMax = [obj objectForKey:@"maxDates"];
            statistics.recordMaxBeginDate = [obj objectForKey:@"maxBegin"];
            statistics.recordMaxEndDate = [obj objectForKey:@"maxEnd"];
            statistics.updatetime = [CommonFunction getTimeNowString];
            [PlanCache storeStatistics:statistics];
            NSLog(@"更新签到成功objectid :%@", obj.objectId);
        } else if (error){
            NSLog(@"更新签到失败%@",error);
        } else {
            NSLog(@"更新签到UnKnow error");
        }
    }];
    [self addCheckInRecord];
}

+ (BOOL)isContinuousDate:(NSDate*)date1 date2:(NSDate*)date2 {
    NSTimeInterval time = [date2 timeIntervalSinceDate:date1];
    int days = ((int)time)/(3600*24);
    if (days < 1) {
        return true;
    } else {
        return false;
    }
}

@end
