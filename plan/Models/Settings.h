//
//  Settings.h
//  plan
//
//  Created by Fengzy on 15/8/29.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "ModelBase.h"

@interface Settings : ModelBase <NSCoding, NSCopying>

/** 对应服务器表的objectId */
@property (nonatomic, strong) NSString *objectId;
/** 账号 */
@property (nonatomic, strong) NSString *account;
/** 昵称 */
@property (nonatomic, strong) NSString *nickname;
/** 生日，格式：2016-04-16 */
@property (nonatomic, strong) NSString *birthday;
/** 电子邮箱 */
@property (nonatomic, strong) NSString *email;
/** 性别：1男 0女 */
@property (nonatomic, strong) NSString *gender;
/** 寿命 */
@property (nonatomic, strong) NSString *lifespan;
/** 密码 */
@property (nonatomic, strong) NSString *password;
/** 头像 */
@property (nonatomic, strong) NSData *avatar;
/** 头像url */
@property (nonatomic, strong) NSString *avatarURL;
/** 个人中心封面图片 */
@property (nonatomic, strong) NSData *centerTop;
/** 个人中心封面图片url */
@property (nonatomic, strong) NSString *centerTopURL;
/** 是否自动同步数据 0否1是 */
@property (nonatomic, strong) NSString *isAutoSync;
/** 是否手势解锁 0否1是 */
@property (nonatomic, strong) NSString *isUseGestureLock;
/** 是否显示手势轨迹 0否1是 */
@property (nonatomic, strong) NSString *isShowGestureTrack;
/** 手势密码 */
@property (nonatomic, strong) NSString *gesturePasswod;
/** 同步时间，格式：2016-04-16 ）7:37:11 */
@property (nonatomic, strong) NSString *syntime;
/** 创建时间，格式：2016-04-16 ）7:37:11 */
@property (nonatomic, strong) NSString *createtime;
/** 更新时间，格式：2016-04-16 ）7:37:11 */
@property (nonatomic, strong) NSString *updatetime;
/** 首页倒计时模式 0只显示秒 1只显示分 2只显示时 3全部都显示 */
@property (nonatomic, strong) NSString *countdownType;
/** 个性签名 */
@property (nonatomic, strong) NSString *signature;
/** 首页日月模式 0显示剩余天数 1显示剩余月数 */
@property (nonatomic, strong) NSString *dayOrMonth;

@end
