//
//  Settings.m
//  plan
//
//  Created by Fengzy on 15/8/29.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "Settings.h"

NSString *const kSettings_Account = @"account";
NSString *const kSettings_NickName = @"nickname";
NSString *const kSettings_Birthday = @"birthday";
NSString *const kSettings_Email = @"email";
NSString *const kSettings_Gender = @"gender";
NSString *const kSettings_Lifespan = @"lifespan";
NSString *const kSettings_Password = @"password";
NSString *const kSettings_Avatar = @"avatar";
NSString *const kSettings_AvatarURL = @"avatarURL";
NSString *const kSettings_CenterTop = @"centerTop";
NSString *const kSettings_CenterTopURL = @"centerTopURL";
NSString *const kSettings_Updatetime = @"updatetime";
NSString *const kSettings_Syntime = @"syntime";

@implementation Settings

@synthesize account = _account;
@synthesize nickname = _nickname;
@synthesize birthday = _birthday;
@synthesize email = _email;
@synthesize gender = _gender;
@synthesize lifespan = _lifespan;
@synthesize password = _password;
@synthesize avatar = _avatar;
@synthesize avatarURL = _avatarURL;
@synthesize centerTop = _centerTop;
@synthesize centerTopURL = _centerTopURL;
@synthesize updatetime = _updatetime;
@synthesize syntime = _syntime;


- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.account = [dict objectOrNilForKey:kSettings_Account];
        self.nickname = [dict objectOrNilForKey:kSettings_NickName];
        self.birthday = [dict objectOrNilForKey:kSettings_Birthday];
        self.email = [dict objectOrNilForKey:kSettings_Email];
        self.gender = [dict objectOrNilForKey:kSettings_Gender];
        self.lifespan = [dict objectOrNilForKey:kSettings_Lifespan];
        self.password = [dict objectOrNilForKey:kSettings_Password];
        self.avatar = [dict objectOrNilForKey:kSettings_Avatar];
        self.avatarURL = [dict objectOrNilForKey:kSettings_AvatarURL];
        self.centerTop = [dict objectOrNilForKey:kSettings_CenterTop];
        self.centerTopURL = [dict objectOrNilForKey:kSettings_CenterTopURL];
        self.updatetime = [dict objectOrNilForKey:kSettings_Updatetime];
        self.syntime = [dict objectOrNilForKey:kSettings_Syntime];
    }
    return self;
}

#pragma mark - NSCoding Methods
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    self.account = [aDecoder decodeObjectForKey:kSettings_Account];
    self.nickname = [aDecoder decodeObjectForKey:kSettings_NickName];
    self.birthday = [aDecoder decodeObjectForKey:kSettings_Birthday];
    self.email = [aDecoder decodeObjectForKey:kSettings_Email];
    self.gender = [aDecoder decodeObjectForKey:kSettings_Gender];
    self.lifespan = [aDecoder decodeObjectForKey:kSettings_Lifespan];
    self.password = [aDecoder decodeObjectForKey:kSettings_Password];
    self.avatar = [aDecoder decodeObjectForKey:kSettings_Avatar];
    self.avatarURL = [aDecoder decodeObjectForKey:kSettings_AvatarURL];
    self.centerTop = [aDecoder decodeObjectForKey:kSettings_CenterTop];
    self.centerTopURL = [aDecoder decodeObjectForKey:kSettings_CenterTopURL];
    self.updatetime = [aDecoder decodeObjectForKey:kSettings_Updatetime];
    self.syntime = [aDecoder decodeObjectForKey:kSettings_Syntime];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_account forKey:kSettings_Account];
    [aCoder encodeObject:_nickname forKey:kSettings_NickName];
    [aCoder encodeObject:_birthday forKey:kSettings_Birthday];
    [aCoder encodeObject:_email forKey:kSettings_Email];
    [aCoder encodeObject:_gender forKey:kSettings_Gender];
    [aCoder encodeObject:_lifespan forKey:kSettings_Lifespan];
    [aCoder encodeObject:_password forKey:kSettings_Password];
    [aCoder encodeObject:_avatar forKey:kSettings_Avatar];
    [aCoder encodeObject:_avatarURL forKey:kSettings_AvatarURL];
    [aCoder encodeObject:_centerTop forKey:kSettings_CenterTop];
    [aCoder encodeObject:_centerTopURL forKey:kSettings_CenterTopURL];
    [aCoder encodeObject:_updatetime forKey:kSettings_Updatetime];
    [aCoder encodeObject:_syntime forKey:kSettings_Syntime];
}

- (id)copyWithZone:(NSZone *)zone {
    Settings *copy = [[Settings alloc] init];
    copy.account = [self.account copyWithZone:zone];
    copy.nickname = [self.nickname copyWithZone:zone];
    copy.birthday = [self.birthday copyWithZone:zone];
    copy.email = [self.email copyWithZone:zone];
    copy.gender = [self.gender copyWithZone:zone];
    copy.lifespan = [self.lifespan copyWithZone:zone];
    copy.password = [self.password copyWithZone:zone];
    copy.avatar = self.avatar;
    copy.avatarURL = [self.avatarURL copyWithZone:zone];
    copy.centerTop = self.centerTop;
    copy.centerTopURL = [self.centerTopURL copyWithZone:zone];
    copy.updatetime = [self.updatetime copyWithZone:zone];
    copy.syntime = [self.syntime copyWithZone:zone];
    return copy;
}

@end