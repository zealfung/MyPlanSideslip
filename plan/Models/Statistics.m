//
//  Statistics.m
//  plan
//
//  Created by Fengzy on 15/11/11.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "Statistics.h"

NSString *const kStatistics_Account = @"account";
NSString *const kStatistics_RecentMax = @"recentMax";
NSString *const kStatistics_RecentMaxBeginDate = @"recentMaxBeginDate";
NSString *const kStatistics_RecentMaxEndDate = @"recentMaxEndDate";
NSString *const kStatistics_RecordMax = @"recordMax";
NSString *const kStatistics_RecordMaxBeginDate = @"recordMaxBeginDate";
NSString *const kStatistics_RecordMaxEndDate = @"recordMaxEndDate";
NSString *const kStatistics_Updatetime = @"updatetime";

@implementation Statistics

@synthesize account = _account;
@synthesize recentMax = _recentMax;
@synthesize recentMaxBeginDate = _recentMaxBeginDate;
@synthesize recentMaxEndDate = _recentMaxEndDate;
@synthesize recordMax = _recordMax;
@synthesize recordMaxBeginDate = _recordMaxBeginDate;
@synthesize recordMaxEndDate = _recordMaxEndDate;


- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.account = [dict objectOrNilForKey:kStatistics_Account];
        self.recentMax = [dict objectOrNilForKey:kStatistics_RecentMax];
        self.recentMaxBeginDate = [dict objectOrNilForKey:kStatistics_RecentMaxBeginDate];
        self.recentMaxEndDate = [dict objectOrNilForKey:kStatistics_RecentMaxEndDate];
        self.recordMax = [dict objectOrNilForKey:kStatistics_RecordMax];
        self.recordMaxBeginDate = [dict objectOrNilForKey:kStatistics_RecordMaxBeginDate];
        self.recordMaxEndDate = [dict objectOrNilForKey:kStatistics_RecordMaxEndDate];
        self.updatetime = [dict objectOrNilForKey:kStatistics_Updatetime];
    }
    return self;
}

#pragma mark - NSCoding Methods
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    self.account = [aDecoder decodeObjectForKey:kStatistics_Account];
    self.recentMax = [aDecoder decodeObjectForKey:kStatistics_RecentMax];
    self.recentMaxBeginDate = [aDecoder decodeObjectForKey:kStatistics_RecentMaxBeginDate];
    self.recentMaxEndDate = [aDecoder decodeObjectForKey:kStatistics_RecentMaxEndDate];
    self.recordMax = [aDecoder decodeObjectForKey:kStatistics_RecordMax];
    self.recordMaxBeginDate = [aDecoder decodeObjectForKey:kStatistics_RecordMaxBeginDate];
    self.recordMaxEndDate = [aDecoder decodeObjectForKey:kStatistics_RecordMaxEndDate];
    self.updatetime = [aDecoder decodeObjectForKey:kStatistics_Updatetime];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_account forKey:kStatistics_Account];
    [aCoder encodeObject:_recentMax forKey:kStatistics_RecentMax];
    [aCoder encodeObject:_recentMaxBeginDate forKey:kStatistics_RecentMaxBeginDate];
    [aCoder encodeObject:_recentMaxEndDate forKey:kStatistics_RecentMaxEndDate];
    [aCoder encodeObject:_recordMax forKey:kStatistics_RecordMax];
    [aCoder encodeObject:_recordMaxBeginDate forKey:kStatistics_RecordMaxBeginDate];
    [aCoder encodeObject:_recordMaxEndDate forKey:kStatistics_RecordMaxEndDate];
    [aCoder encodeObject:_updatetime forKey:kStatistics_Updatetime];
}

- (id)copyWithZone:(NSZone *)zone {
    Statistics *copy = [[Statistics alloc] init];
    copy.account = [self.account copyWithZone:zone];
    copy.recentMax = [self.recentMax copyWithZone:zone];
    copy.recentMaxBeginDate = [self.recentMaxBeginDate copyWithZone:zone];
    copy.recentMaxEndDate = [self.recentMaxEndDate copyWithZone:zone];
    copy.recordMax = [self.recordMax copyWithZone:zone];
    copy.recordMaxBeginDate = [self.recordMaxBeginDate copyWithZone:zone];
    copy.recordMaxEndDate = [self.recordMaxEndDate copyWithZone:zone];
    copy.updatetime = [self.updatetime copyWithZone:zone];
    return copy;
}

@end
