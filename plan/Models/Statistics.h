//
//  Statistics.h
//  plan
//
//  Created by Fengzy on 15/11/11.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "ModelBase.h"

@interface Statistics : ModelBase <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *recentMax;//最近连续计划天数
@property (nonatomic, strong) NSString *recentMaxBeginDate;//最近连续计划天数开始日期
@property (nonatomic, strong) NSString *recentMaxEndDate;//最近连续计划天数结束日期
@property (nonatomic, strong) NSString *recordMax;//最大连续计划天数
@property (nonatomic, strong) NSString *recordMaxBeginDate;//最大连续计划天数开始日期
@property (nonatomic, strong) NSString *recordMaxEndDate;//最大连续计划天数结束日期
@property (nonatomic, strong) NSString *updatetime;//更新时间
@end
