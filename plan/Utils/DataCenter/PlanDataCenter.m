//
//  PlanDataCenter.m
//  plan
//
//  Created by Fengzy on 17/2/24.
//  Copyright © 2017年 Fengzy. All rights reserved.
//

#import "PlanDataCenter.h"

@implementation PlanDataCenter

+ (NSArray *)getPlanFromStartIndex:(NSInteger)startIndex
{
    return nil;
//    BmobUser *user = [BmobUser currentUser];
//    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Plan"];
//    [bquery whereKey:@"userObjectId" equalTo:user.objectId];
//    [bquery whereKey:@"isDeleted" notEqualTo:@"1"];
//    [bquery orderByDescending:@"updatedTime"];
//    bquery.limit = 100;
//    bquery.skip = startIndex;//跳过3条数据
//    
//    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
//     {
//         if (!error && array.count)
//         {
//             for (BmobObject *obj in array)
//             {
//                 Plan *plan = [PlanCache findPlan:user.objectId planid:[obj objectForKey:@"planId"]];
//                 if (plan.content)
//                 {
//                     NSDate *localDate = [CommonFunction NSStringDateToNSDate:plan.updatetime formatter:STRDateFormatterType1];
//                     NSDate *serverDate = [CommonFunction NSStringDateToNSDate:[obj objectForKey:@"updatedTime"] formatter:STRDateFormatterType1];
//                     
//                     if ([localDate compare:serverDate] == NSOrderedAscending)
//                     {
//                         //服务器的较新
//                         [weakSelf updatePlanForLocal:plan obj:obj];
//                         
//                     }
//                     else if ([localDate compare:serverDate] == NSOrderedDescending)
//                     {
//                         //本地的设置较新
//                     }
//                 }
//                 else
//                 {
//                     [weakSelf updatePlanForLocal:plan obj:obj];
//                 }
//             }
//         }
//         finishPlan = YES;
//         [weakSelf IsAllUploadFinished];
//     }];
}

+ (void)addPlan:(Plan *)newPlan
{
    BmobUser *user = [BmobUser currentUser];
    BmobObject *obj = [BmobObject objectWithClassName:@"Plan"];
    NSDictionary *dic = @{@"userObjectId":newPlan.account,
                          @"planId":newPlan.planid,
                          @"content":newPlan.content,
                          @"createdTime":newPlan.createtime,
                          @"completedTime":newPlan.completetime,
                          @"updatedTime":newPlan.updatetime,
                          @"notifyTime":newPlan.notifytime,
                          @"isCompleted":newPlan.iscompleted,
                          @"isNotify":newPlan.isnotify,
                          @"isDeleted":newPlan.isdeleted,
                          @"isRepeat":newPlan.isRepeat,
                          @"remark":newPlan.remark,
                          @"beginDate":newPlan.beginDate};
    [obj saveAllWithDictionary:dic];
    BmobACL *acl = [BmobACL ACL];
    [acl setReadAccessForUser:user];//设置只有当前用户可读
    [acl setWriteAccessForUser:user];//设置只有当前用户可写
    obj.ACL = acl;

    [obj saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
    {
        if (isSuccessful && !error)
        {
            //添加提醒
            if ([newPlan.isnotify isEqualToString:@"1"])
            {
                [PlanCache addPlanNotification:newPlan];
            }
            //更新5天没有新建计划的提醒时间
            [PlanCache setFiveDayNotification];
            
            [NotificationCenter postNotificationName:NTFPlanSave object:nil];
            
            [AlertCenter alertToastMessage:STRCommonTip13];
        }
        else
        {
            [AlertCenter alertToastMessage:STRCommonTip14];
        }
    }];
}

+ (void)updatePlan:(Plan *)plan
{
//    __weak typeof(self) weakSelf = self;
//    BmobUser *user = [BmobUser currentUser];
//    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Plan"];
//    [bquery whereKey:@"userObjectId" equalTo:user.objectId];
//    [bquery whereKey:@"planId" equalTo:plan.planid];
}

@end
