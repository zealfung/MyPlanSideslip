//
//  TaskRecord.m
//  plan
//
//  Created by Fengzy on 15/11/29.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "TaskRecord.h"

NSString *const kTaskRecord_RecordId = @"recordId";
NSString *const kTaskRecord_CreateTime = @"createTime";

@implementation TaskRecord

@synthesize recordId = _recordId;
@synthesize createTime = _createTime;

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.recordId = [dict objectOrNilForKey:kTaskRecord_RecordId];
        self.createTime = [dict objectOrNilForKey:kTaskRecord_CreateTime];
    }
    return self;
}

#pragma mark - NSCoding Methods
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    self.recordId = [aDecoder decodeObjectForKey:kTaskRecord_RecordId];
    self.createTime = [aDecoder decodeObjectForKey:kTaskRecord_CreateTime];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_recordId forKey:kTaskRecord_RecordId];
    [aCoder encodeObject:_createTime forKey:kTaskRecord_CreateTime];
}

- (id)copyWithZone:(NSZone *)zone {
    TaskRecord *copy = [[TaskRecord alloc] init];
    copy.recordId = [self.recordId copyWithZone:zone];
    copy.createTime = [self.createTime copyWithZone:zone];
    return copy;
}

@end