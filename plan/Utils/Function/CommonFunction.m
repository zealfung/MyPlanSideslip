//
//  CommonFunction.m
//  plan
//
//  Created by Fengzy on 15/9/2.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "UIDevice+Util.h"
#import "CommonFunction.h"

@implementation CommonFunction

//获取设备型号 iPhone4、iPhone6 Plus
+ (NSString *)getDeviceType {
    return [[UIDevice currentDevice] platformString];
}

//获取iOS系统版本号
+ (NSString *)getiOSVersion {
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)getAppVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

//获取当前时间字符串：yyyy-MM-dd HH:mm:ss
+ (NSString *)getTimeNowString {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:str_DateFormatter_yyyy_MM_dd_HHmmss];
    NSString *timeNow = [dateFormatter stringFromDate:[NSDate date]];
    
    return timeNow;
}

+ (NSDateComponents *)getDateTime:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday |
    NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    if (date == nil) {
        date = [NSDate date];
    }
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    
    return comps;
}

//判断是否为空白字符串
+ (BOOL)isEmptyString:(NSString *)original {
    
    return original == nil || [original isEqualToString:@""];
    
}

//压缩图片
+ (UIImage *)compressImage:(UIImage *)image {
    
    NSData *imgData = UIImageJPEGRepresentation(image, 0.7);
    return [UIImage imageWithData:imgData];
}

//数组排序 yes升序排列，no,降序排列
+ (NSArray *)arraySort:(NSArray *)array ascending:(BOOL)ascending {
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:nil ascending:ascending];
    return [array sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sd, nil]];

}

//NSString转换NSDate
+ (NSDate *)NSStringDateToNSDate:(NSString *)datetime formatter:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [formatter setDateFormat:format];
    NSDate *date = [formatter dateFromString:datetime];
    return date;
}

//NSDate转换NSString
+ (NSString *)NSDateToNSString:(NSDate *)datetime formatter:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:format];
    NSString *dateStr = [formatter stringFromDate:datetime];
    return dateStr;
}

+ (NSInteger)calculateDateInterval:(NSDate *)date1 toDate:(NSDate *)date2 calendarUnit:(int)calendarUnit {
    
    NSCalendar *userCalendar = [NSCalendar currentCalendar];
    unsigned int unitFlags = calendarUnit;
    NSDateComponents *components = [userCalendar components:unitFlags fromDate:date1 toDate:date2 options:0];
    switch (calendarUnit) {
        case NSDayCalendarUnit:
            return [components day];
            break;
        case NSMonthCalendarUnit:
            return [components month];
            break;
        case NSYearCalendarUnit:
            return [components year];
            break;
        default:
            return 0;
            break;
    }
}

@end
