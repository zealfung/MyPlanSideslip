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

//计算date1和date2的时间差 calendarUnit:NSDayCalendarUnit相差天数、NSMonthCalendarUnit相差月数、NSYearCalendarUnit相差年数
+ (NSInteger)calculateDateInterval:(NSDate *)date1 toDate:(NSDate *)date2 calendarUnit:(int)calendarUnit;

@end
