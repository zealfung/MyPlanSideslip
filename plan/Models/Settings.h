//
//  Settings.h
//  plan
//
//  Created by Fengzy on 15/8/29.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "ModelBase.h"

@interface Settings : ModelBase <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *birthday;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *gender; //性别：1男 0女
@property (nonatomic, strong) NSString *lifespan;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) UIImage *avatar;
@property (nonatomic, strong) NSString *avatarURL;
@property (nonatomic, strong) UIImage *centerTop;
@property (nonatomic, strong) NSString *centerTopURL;
@property (nonatomic, strong) NSString *isAutoSync;//是否自动同步数据 0否1是
@property (nonatomic, strong) NSString *isUseGestureLock;//是否手势解锁 0否1是
@property (nonatomic, strong) NSString *isShowGestureTrack;//是否显示手势轨迹 0否1是
@property (nonatomic, strong) NSString *gesturePasswod;//手势密码
@property (nonatomic, strong) NSString *syntime;
@property (nonatomic, strong) NSString *createtime;
@property (nonatomic, strong) NSString *updatetime;

@end
