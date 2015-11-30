//
//  Task.m
//  plan
//
//  Created by Fengzy on 15/11/29.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "Task.h"

NSString *const kTask_Taskid = @"taskId";
NSString *const kTask_Account = @"account";
NSString *const kTask_Content = @"content";
NSString *const kTask_TotalCount = @"totalCount";
NSString *const kTask_CompletionDate = @"completionDate";
NSString *const kTask_CreateTime = @"createTime";
NSString *const kTask_UpdateTime = @"updateTime";
NSString *const kTask_IsNotify = @"isNotify";
NSString *const kTask_NotifyTime = @"notifyTime";
NSString *const kTask_IsDeleted = @"isDeleted";

@implementation Task

@synthesize taskId = _taskId;
@synthesize account = _account;
@synthesize totalCount = _totalCount;
@synthesize completionDate = _completionDate;
@synthesize content = _content;
@synthesize createTime = _createTime;
@synthesize updateTime = _updateTime;
@synthesize isNotify = _isNotify;
@synthesize notifyTime = _notifyTime;
@synthesize isDeleted = _isDeleted;

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.taskId = [dict objectOrNilForKey:kTask_Taskid];
        self.account = [dict objectOrNilForKey:kTask_Account];
        self.content = [dict objectOrNilForKey:kTask_Content];
        self.totalCount = [dict objectOrNilForKey:kTask_TotalCount];
        self.completionDate = [dict objectOrNilForKey:kTask_CompletionDate];
        self.createTime = [dict objectOrNilForKey:kTask_CreateTime];
        self.updateTime = [dict objectOrNilForKey:kTask_UpdateTime];
        self.isNotify = [dict objectOrNilForKey:kTask_IsNotify];
        self.notifyTime = [dict objectOrNilForKey:kTask_NotifyTime];
        self.isDeleted = [dict objectOrNilForKey:kTask_IsDeleted];
    }
    return self;
}

#pragma mark - NSCoding Methods
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    self.taskId = [aDecoder decodeObjectForKey:kTask_Taskid];
    self.account = [aDecoder decodeObjectForKey:kTask_Account];
    self.content = [aDecoder decodeObjectForKey:kTask_Content];
    self.totalCount = [aDecoder decodeObjectForKey:kTask_TotalCount];
    self.completionDate = [aDecoder decodeObjectForKey:kTask_CompletionDate];
    self.createTime = [aDecoder decodeObjectForKey:kTask_CreateTime];
    self.updateTime = [aDecoder decodeObjectForKey:kTask_UpdateTime];
    self.isNotify = [aDecoder decodeObjectForKey:kTask_IsNotify];
    self.notifyTime = [aDecoder decodeObjectForKey:kTask_NotifyTime];
    self.isDeleted = [aDecoder decodeObjectForKey:kTask_IsDeleted];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_taskId forKey:kTask_Taskid];
    [aCoder encodeObject:_account forKey:kTask_Account];
    [aCoder encodeObject:_content forKey:kTask_Content];
    [aCoder encodeObject:_totalCount forKey:kTask_TotalCount];
    [aCoder encodeObject:_completionDate forKey:kTask_CompletionDate];
    [aCoder encodeObject:_createTime forKey:kTask_CreateTime];
    [aCoder encodeObject:_updateTime forKey:kTask_UpdateTime];
    [aCoder encodeObject:_isNotify forKey:kTask_IsNotify];
    [aCoder encodeObject:_notifyTime forKey:kTask_NotifyTime];
    [aCoder encodeObject:_isDeleted forKey:kTask_IsDeleted];
}

- (id)copyWithZone:(NSZone *)zone {
    Task *copy = [[Task alloc] init];
    copy.taskId = [self.taskId copyWithZone:zone];
    copy.account = [self.account copyWithZone:zone];
    copy.content = [self.content copyWithZone:zone];
    copy.totalCount = [self.totalCount copyWithZone:zone];
    copy.completionDate = [self.completionDate copyWithZone:zone];
    copy.createTime = [self.createTime copyWithZone:zone];
    copy.updateTime = [self.updateTime copyWithZone:zone];
    copy.isNotify = [self.isNotify copyWithZone:zone];
    copy.notifyTime = [self.notifyTime copyWithZone:zone];
    copy.isDeleted = [self.isDeleted copyWithZone:zone];
    return copy;
}


@end