//
//  CommonFunction.h
//  plan
//
//  Created by Fengzy on 15/9/2.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonFunction : NSObject

//获取设备型号 iPhone4、iPhone6 Plus
+ (NSString *)getDeviceType;

//获取iOS系统版本号
+ (NSString *)getiOSVersion;

//获取应用版本号
+ (NSString *)getAppVersion;

//获取当前时间字符串：yyyy-MM-dd HH:mm:ss
+ (NSString *)getTimeNowString;

+ (NSDateComponents *)getDateTime:(NSDate *)date;

//判断是否为空白字符串
+ (BOOL)isEmptyString:(NSString *)original;

//压缩图片
+ (UIImage *)compressImage:(UIImage *)image;

//数组排序 yes升序排列，no,降序排列
+ (NSArray *)arraySort:(NSArray *)array ascending:(BOOL)ascending;

//NSString转换NSDate
+ (NSDate *)NSStringDateToNSDate:(NSString *)datetime formatter:(NSString *)format;

//NSDate转换NSString
+ (NSString *)NSDateToNSString:(NSDate *)datetime formatter:(NSString *)format;

//过滤纯数字
+ (BOOL)validateNumber:(NSString *)textString;

//校验邮箱地址格式
+ (BOOL)validateEmail:(NSString *)textString;

//判断两个日期是否为同一天
+ (BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2;

// MD5 32位加密
+ (NSString *)md5HexDigest:(NSString*)password;

//超过仟的数字用K缩写
+ (NSString *)checkNumberForThousand:(NSInteger)number;

//时间间隔显示：刚刚，N分钟前，N天前...
+ (NSString *)intervalSinceNow:(NSDate *)date;

+ (NSDictionary *)timeIntervalArrayFromString:(NSDate *)date;

//获取PNG图片的大小
+ (CGSize)getPNGImageSizeWithRequest:(NSMutableURLRequest*)request;

//获取gif图片的大小
+ (CGSize)getGIFImageSizeWithRequest:(NSMutableURLRequest*)request;

//获取jpg图片的大小
+ (CGSize)getJPGImageSizeWithRequest:(NSMutableURLRequest*)request;

//根据性别获取颜色
+ (UIColor *)getGenderColor;

//根据性别获取icon图标
+ (UIImage *)getGenderIcon;

//用户等级icon图标
+ (UIImage *)getUserLevelIcon:(NSString *)level;

@end
