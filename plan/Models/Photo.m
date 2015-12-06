//
//  Photo.m
//  plan
//
//  Created by Fengzy on 15/10/6.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "Photo.h"

NSString *const kPhoto_PhotoId = @"photoid";
NSString *const kPhoto_Account = @"account";
NSString *const kPhoto_Content = @"content";
NSString *const kPhoto_CreateTime = @"createtime";
NSString *const kPhoto_PhotoTime = @"phototime";
NSString *const kPhoto_UpdateTime = @"updatetime";
NSString *const kPhoto_Location = @"location";
NSString *const kPhoto_PhotoArray = @"photoArray";
NSString *const kPhoto_PhotoURLArray = @"photoURLArray";
NSString *const kPhoto_IsDeleted = @"isdeleted";

@implementation Photo

@synthesize photoid = _photoid;
@synthesize account = _account;
@synthesize content = _content;
@synthesize createtime = _createtime;
@synthesize phototime = _phototime;
@synthesize updatetime = _updatetime;
@synthesize location = _location;
@synthesize photoArray = _photoArray;
@synthesize photoURLArray = _photoURLArray;
@synthesize isdeleted = _isdeleted;


- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.photoid = [dict objectOrNilForKey:kPhoto_PhotoId];
        self.account = [dict objectOrNilForKey:kPhoto_Account];
        self.content = [dict objectOrNilForKey:kPhoto_Content];
        self.createtime = [dict objectOrNilForKey:kPhoto_CreateTime];
        self.phototime = [dict objectOrNilForKey:kPhoto_PhotoTime];
        self.updatetime = [dict objectOrNilForKey:kPhoto_UpdateTime];
        self.location = [dict objectOrNilForKey:kPhoto_Location];
        self.photoArray = [dict objectOrNilForKey:kPhoto_PhotoArray];
        self.photoURLArray = [dict objectOrNilForKey:kPhoto_PhotoURLArray];
        self.isdeleted = [dict objectOrNilForKey:kPhoto_IsDeleted];
    }
    return self;
}

#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    self.photoid = [aDecoder decodeObjectForKey:kPhoto_PhotoId];
    self.account = [aDecoder decodeObjectForKey:kPhoto_Account];
    self.content = [aDecoder decodeObjectForKey:kPhoto_Content];
    self.createtime = [aDecoder decodeObjectForKey:kPhoto_CreateTime];
    self.phototime = [aDecoder decodeObjectForKey:kPhoto_PhotoTime];
    self.updatetime = [aDecoder decodeObjectForKey:kPhoto_UpdateTime];
    self.location = [aDecoder decodeObjectForKey:kPhoto_Location];
    self.photoArray = [aDecoder decodeObjectForKey:kPhoto_PhotoArray];
    self.photoURLArray = [aDecoder decodeObjectForKey:kPhoto_PhotoURLArray];
    self.isdeleted = [aDecoder decodeObjectForKey:kPhoto_IsDeleted];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_photoid forKey:kPhoto_PhotoId];
    [aCoder encodeObject:_account forKey:kPhoto_Account];
    [aCoder encodeObject:_content forKey:kPhoto_Content];
    [aCoder encodeObject:_createtime forKey:kPhoto_CreateTime];
    [aCoder encodeObject:_phototime forKey:kPhoto_PhotoTime];
    [aCoder encodeObject:_updatetime forKey:kPhoto_UpdateTime];
    [aCoder encodeObject:_location forKey:kPhoto_Location];
    [aCoder encodeObject:_photoArray forKey:kPhoto_PhotoArray];
    [aCoder encodeObject:_photoURLArray forKey:kPhoto_PhotoURLArray];
    [aCoder encodeObject:_isdeleted forKey:kPhoto_IsDeleted];
}

- (id)copyWithZone:(NSZone *)zone {
    Photo *copy = [[Photo alloc] init];
    copy.photoid = [self.photoid copyWithZone:zone];
    copy.account = [self.account copyWithZone:zone];
    copy.content = [self.content copyWithZone:zone];
    copy.createtime = [self.createtime copyWithZone:zone];
    copy.phototime = [self.phototime copyWithZone:zone];
    copy.updatetime = [self.updatetime copyWithZone:zone];
    copy.location = [self.location copyWithZone:zone];
    copy.photoArray = [self.photoArray copyWithZone:zone];
    copy.photoURLArray = [self.photoURLArray copyWithZone:zone];
    copy.isdeleted = [self.isdeleted copyWithZone:zone];
    return copy;
}

@end
