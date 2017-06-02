//
//  CommonFunction.h
//  plan
//
//  Created by Fengzy on 15/9/2.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "Plan.h"
#import <Foundation/Foundation.h>

@interface CommonFunction : NSObject

/** 获取设备型号 iPhone4、iPhone6 Plus */
+ (NSString *)getDeviceType;

/** 获取iOS系统版本号 */
+ (NSString *)getiOSVersion;

/** 获取应用版本号 */
+ (NSString *)getAppVersion;

/** 获取当前时间字符串：yyyy-MM-dd HH:mm:ss */
+ (NSString *)getTimeNowString;

+ (NSDateComponents *)getDateTime:(NSDate *)date;

/** 判断是否为空白字符串 */
+ (BOOL)isEmptyString:(NSString *)original;

/** 压缩图片 */
+ (NSData *)compressImage:(UIImage *)image;

/** 数组排序 yes升序排列，no,降序排列 */
+ (NSArray *)arraySort:(NSArray *)array ascending:(BOOL)ascending;

/** NSString转换NSDate */
+ (NSDate *)NSStringDateToNSDate:(NSString *)datetime formatter:(NSString *)format;

/** NSDate转换NSString */
+ (NSString *)NSDateToNSString:(NSDate *)datetime formatter:(NSString *)format;

/** 过滤纯数字 */
+ (BOOL)validateNumber:(NSString *)textString;

/** 校验邮箱地址格式 */
+ (BOOL)validateEmail:(NSString *)textString;

/** 判断两个日期是否为同一天 */
+ (BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2;

/** MD5 32位加密 */
+ (NSString *)md5HexDigest:(NSString*)password;

/** 超过仟的数字用K缩写 */
+ (NSString *)checkNumberForThousand:(NSInteger)number;

/** 时间间隔显示：刚刚，N分钟前，N天前... */
+ (NSString *)intervalSinceNow:(NSDate *)date;

+ (NSDictionary *)timeIntervalArrayFromString:(NSDate *)date;

/** 获取PNG图片的大小 */
+ (CGSize)getPNGImageSizeWithRequest:(NSMutableURLRequest*)request;

/** 获取gif图片的大小 */
+ (CGSize)getGIFImageSizeWithRequest:(NSMutableURLRequest*)request;

/** 获取jpg图片的大小 */
+ (CGSize)getJPGImageSizeWithRequest:(NSMutableURLRequest*)request;

/** 根据性别获取颜色 */
+ (UIColor *)getGenderColor;

/** 用户等级icon图标 */
+ (UIImage *)getUserLevelIcon:(NSString *)level;

/** 计划开始时间显示格式：今天，明天，或日期 */
+ (NSString *)getBeginDateStringForShow:(NSString *)date;

/** 计划提醒时间显示格式：今天，明天，或日期 */
+ (NSString *)getNotifyTimeStringForShow:(NSString *)time;

/** 计算剩余天数，toDay格式：2016-03-18 */
+ (NSInteger)howManyDaysLeft:(NSString*)toDay;

/** 将整型数字转换成带千分号的格式 */
+ (NSString *)integerToDecimalStyle:(NSInteger)integer;

/** 更新提醒时间，防止提醒时间早于当前时间导致的设置提醒无效 */
+ (NSString *)updateNotifyTime:(NSString *)notifyTime;

/** 获取随机数 */
+ (int)getRandomNumber:(int)from to:(int)to;

/** 更新本地通知 */
+ (void)updatePlanNotification:(Plan *)plan;

/** 取消本地通知 */
+ (void)cancelPlanNotification:(NSString*)planid;

/** 新增本地通知 */
+ (void)addPlanNotification:(Plan *)plan;

/** 计算两个日期之间的天数 */
+ (NSInteger)calculateDayFromDate:(NSDate *)date1 toDate:(NSDate *)date2;

@end
