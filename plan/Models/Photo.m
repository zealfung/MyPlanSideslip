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
NSString *const kPhoto_PhotoArray = @"photoarray";
NSString *const kPhoto_Photo1NSData = @"photo1NSData";
NSString *const kPhoto_Photo2NSData = @"photo2NSData";
NSString *const kPhoto_Photo3NSData = @"photo3NSData";
NSString *const kPhoto_Photo4NSData = @"photo4NSData";
NSString *const kPhoto_Photo5NSData = @"photo5NSData";
NSString *const kPhoto_Photo6NSData = @"photo6NSData";
NSString *const kPhoto_Photo7NSData = @"photo7NSData";
NSString *const kPhoto_Photo8NSData = @"photo8NSData";
NSString *const kPhoto_Photo9NSData = @"photo9NSData";
NSString *const kPhoto_Photo1URL = @"photo1URL";
NSString *const kPhoto_Photo2URL = @"photo2URL";
NSString *const kPhoto_Photo3URL = @"photo3URL";
NSString *const kPhoto_Photo4URL = @"photo4URL";
NSString *const kPhoto_Photo5URL = @"photo5URL";
NSString *const kPhoto_Photo6URL = @"photo6URL";
NSString *const kPhoto_Photo7URL = @"photo7URL";
NSString *const kPhoto_Photo8URL = @"photo8URL";
NSString *const kPhoto_Photo9URL = @"photo9URL";
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
@synthesize photo1NSData = _photo1NSData;
@synthesize photo2NSData = _photo2NSData;
@synthesize photo3NSData = _photo3NSData;
@synthesize photo4NSData = _photo4NSData;
@synthesize photo5NSData = _photo5NSData;
@synthesize photo6NSData = _photo6NSData;
@synthesize photo7NSData = _photo7NSData;
@synthesize photo8NSData = _photo8NSData;
@synthesize photo9NSData = _photo9NSData;
@synthesize photo1URL = _photo1URL;
@synthesize photo2URL = _photo2URL;
@synthesize photo3URL = _photo3URL;
@synthesize photo4URL = _photo4URL;
@synthesize photo5URL = _photo5URL;
@synthesize photo6URL = _photo6URL;
@synthesize photo7URL = _photo7URL;
@synthesize photo8URL = _photo8URL;
@synthesize photo9URL = _photo9URL;
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
        self.photo1NSData = [dict objectOrNilForKey:kPhoto_Photo1NSData];
        self.photo2NSData = [dict objectOrNilForKey:kPhoto_Photo2NSData];
        self.photo3NSData = [dict objectOrNilForKey:kPhoto_Photo3NSData];
        self.photo4NSData = [dict objectOrNilForKey:kPhoto_Photo4NSData];
        self.photo5NSData = [dict objectOrNilForKey:kPhoto_Photo5NSData];
        self.photo6NSData = [dict objectOrNilForKey:kPhoto_Photo6NSData];
        self.photo7NSData = [dict objectOrNilForKey:kPhoto_Photo7NSData];
        self.photo8NSData = [dict objectOrNilForKey:kPhoto_Photo8NSData];
        self.photo9NSData = [dict objectOrNilForKey:kPhoto_Photo9NSData];
        self.photo1URL = [dict objectOrNilForKey:kPhoto_Photo1URL];
        self.photo2URL = [dict objectOrNilForKey:kPhoto_Photo2URL];
        self.photo3URL = [dict objectOrNilForKey:kPhoto_Photo3URL];
        self.photo4URL = [dict objectOrNilForKey:kPhoto_Photo4URL];
        self.photo5URL = [dict objectOrNilForKey:kPhoto_Photo5URL];
        self.photo6URL = [dict objectOrNilForKey:kPhoto_Photo6URL];
        self.photo7URL = [dict objectOrNilForKey:kPhoto_Photo7URL];
        self.photo8URL = [dict objectOrNilForKey:kPhoto_Photo8URL];
        self.photo9URL = [dict objectOrNilForKey:kPhoto_Photo9URL];
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
    self.photo1NSData = [aDecoder decodeObjectForKey:kPhoto_Photo1NSData];
    self.photo2NSData = [aDecoder decodeObjectForKey:kPhoto_Photo2NSData];
    self.photo3NSData = [aDecoder decodeObjectForKey:kPhoto_Photo3NSData];
    self.photo4NSData = [aDecoder decodeObjectForKey:kPhoto_Photo4NSData];
    self.photo5NSData = [aDecoder decodeObjectForKey:kPhoto_Photo5NSData];
    self.photo6NSData = [aDecoder decodeObjectForKey:kPhoto_Photo6NSData];
    self.photo7NSData = [aDecoder decodeObjectForKey:kPhoto_Photo7NSData];
    self.photo8NSData = [aDecoder decodeObjectForKey:kPhoto_Photo8NSData];
    self.photo9NSData = [aDecoder decodeObjectForKey:kPhoto_Photo9NSData];
    self.photo1URL = [aDecoder decodeObjectForKey:kPhoto_Photo1URL];
    self.photo2URL = [aDecoder decodeObjectForKey:kPhoto_Photo2URL];
    self.photo3URL = [aDecoder decodeObjectForKey:kPhoto_Photo3URL];
    self.photo4URL = [aDecoder decodeObjectForKey:kPhoto_Photo4URL];
    self.photo5URL = [aDecoder decodeObjectForKey:kPhoto_Photo5URL];
    self.photo6URL = [aDecoder decodeObjectForKey:kPhoto_Photo6URL];
    self.photo7URL = [aDecoder decodeObjectForKey:kPhoto_Photo7URL];
    self.photo8URL = [aDecoder decodeObjectForKey:kPhoto_Photo8URL];
    self.photo9URL = [aDecoder decodeObjectForKey:kPhoto_Photo9URL];
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
    [aCoder encodeObject:_photo1NSData forKey:kPhoto_Photo1NSData];
    [aCoder encodeObject:_photo2NSData forKey:kPhoto_Photo2NSData];
    [aCoder encodeObject:_photo3NSData forKey:kPhoto_Photo3NSData];
    [aCoder encodeObject:_photo4NSData forKey:kPhoto_Photo4NSData];
    [aCoder encodeObject:_photo5NSData forKey:kPhoto_Photo5NSData];
    [aCoder encodeObject:_photo6NSData forKey:kPhoto_Photo6NSData];
    [aCoder encodeObject:_photo7NSData forKey:kPhoto_Photo7NSData];
    [aCoder encodeObject:_photo8NSData forKey:kPhoto_Photo8NSData];
    [aCoder encodeObject:_photo9NSData forKey:kPhoto_Photo9NSData];
    [aCoder encodeObject:_photo1URL forKey:kPhoto_Photo1URL];
    [aCoder encodeObject:_photo2URL forKey:kPhoto_Photo2URL];
    [aCoder encodeObject:_photo3URL forKey:kPhoto_Photo3URL];
    [aCoder encodeObject:_photo4URL forKey:kPhoto_Photo4URL];
    [aCoder encodeObject:_photo5URL forKey:kPhoto_Photo5URL];
    [aCoder encodeObject:_photo6URL forKey:kPhoto_Photo6URL];
    [aCoder encodeObject:_photo7URL forKey:kPhoto_Photo7URL];
    [aCoder encodeObject:_photo8URL forKey:kPhoto_Photo8URL];
    [aCoder encodeObject:_photo9URL forKey:kPhoto_Photo9URL];
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
    copy.photo1NSData = [self.photo1NSData copyWithZone:zone];
    copy.photo2NSData = [self.photo2NSData copyWithZone:zone];
    copy.photo3NSData = [self.photo3NSData copyWithZone:zone];
    copy.photo4NSData = [self.photo4NSData copyWithZone:zone];
    copy.photo5NSData = [self.photo5NSData copyWithZone:zone];
    copy.photo6NSData = [self.photo6NSData copyWithZone:zone];
    copy.photo7NSData = [self.photo7NSData copyWithZone:zone];
    copy.photo8NSData = [self.photo8NSData copyWithZone:zone];
    copy.photo9NSData = [self.photo9NSData copyWithZone:zone];
    copy.photo1URL = [self.photo1URL copyWithZone:zone];
    copy.photo2URL = [self.photo2URL copyWithZone:zone];
    copy.photo3URL = [self.photo3URL copyWithZone:zone];
    copy.photo4URL = [self.photo4URL copyWithZone:zone];
    copy.photo5URL = [self.photo5URL copyWithZone:zone];
    copy.photo6URL = [self.photo6URL copyWithZone:zone];
    copy.photo7URL = [self.photo7URL copyWithZone:zone];
    copy.photo8URL = [self.photo8URL copyWithZone:zone];
    copy.photo9URL = [self.photo9URL copyWithZone:zone];
    copy.isdeleted = [self.isdeleted copyWithZone:zone];
    return copy;
}

@end
