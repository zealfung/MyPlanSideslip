//
//  Messages.m
//  plan
//
//  Created by Fengzy on 15/12/10.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "Messages.h"

NSString *const kMessages_MessageId = @"messageId";
NSString *const kMessages_Title = @"title";
NSString *const kMessages_Content = @"content";
NSString *const kMessages_DetailURL = @"detailURL";
NSString *const kMessages_ImgURLArray = @"imgURLArray";
NSString *const kMessages_HasRead = @"hasRead";
NSString *const kMessages_CanShare = @"canShare";
NSString *const kMessages_ReadTimes = @"readTimes";
NSString *const kMessages_CreateTime = @"createTime";

@implementation Messages

@synthesize messageId = _messageId;
@synthesize title = _title;
@synthesize content = _content;
@synthesize detailURL = _detailURL;
@synthesize imgURLArray = _imgURLArray;
@synthesize hasRead = _hasRead;
@synthesize canShare = _canShare;
@synthesize readTimes = _readTimes;
@synthesize createTime = _createTime;

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.messageId = [dict objectOrNilForKey:kMessages_MessageId];
        self.title = [dict objectOrNilForKey:kMessages_Title];
        self.content = [dict objectOrNilForKey:kMessages_Content];
        self.detailURL = [dict objectOrNilForKey:kMessages_DetailURL];
        self.imgURLArray = [dict objectOrNilForKey:kMessages_ImgURLArray];
        self.hasRead = [dict objectOrNilForKey:kMessages_HasRead];
        self.canShare = [dict objectOrNilForKey:kMessages_CanShare];
        self.readTimes = [dict objectOrNilForKey:kMessages_ReadTimes];
        self.createTime = [dict objectOrNilForKey:kMessages_CreateTime];
    }
    return self;
}

#pragma mark - NSCoding Methods
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    self.messageId = [aDecoder decodeObjectForKey:kMessages_MessageId];
    self.title = [aDecoder decodeObjectForKey:kMessages_Title];
    self.content = [aDecoder decodeObjectForKey:kMessages_Content];
    self.detailURL = [aDecoder decodeObjectForKey:kMessages_DetailURL];
    self.imgURLArray = [aDecoder decodeObjectForKey:kMessages_ImgURLArray];
    self.hasRead = [aDecoder decodeObjectForKey:kMessages_HasRead];
    self.canShare = [aDecoder decodeObjectForKey:kMessages_CanShare];
    self.readTimes = [aDecoder decodeObjectForKey:kMessages_ReadTimes];
    self.createTime = [aDecoder decodeObjectForKey:kMessages_CreateTime];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_messageId forKey:kMessages_MessageId];
    [aCoder encodeObject:_title forKey:kMessages_Title];
    [aCoder encodeObject:_content forKey:kMessages_Content];
    [aCoder encodeObject:_detailURL forKey:kMessages_DetailURL];
    [aCoder encodeObject:_imgURLArray forKey:kMessages_ImgURLArray];
    [aCoder encodeObject:_hasRead forKey:kMessages_HasRead];
    [aCoder encodeObject:_canShare forKey:kMessages_CanShare];
    [aCoder encodeObject:_readTimes forKey:kMessages_ReadTimes];
    [aCoder encodeObject:_createTime forKey:kMessages_CreateTime];
}

- (id)copyWithZone:(NSZone *)zone {
    Messages *copy = [[Messages alloc] init];
    copy.messageId = [self.messageId copyWithZone:zone];
    copy.title = [self.title copyWithZone:zone];
    copy.content = [self.content copyWithZone:zone];
    copy.detailURL = [self.detailURL copyWithZone:zone];
    copy.imgURLArray = [self.imgURLArray copyWithZone:zone];
    copy.hasRead = [self.hasRead copyWithZone:zone];
    copy.canShare = [self.canShare copyWithZone:zone];
    copy.readTimes = [self.readTimes copyWithZone:zone];
    copy.createTime = [self.createTime copyWithZone:zone];
    return copy;
}

@end
