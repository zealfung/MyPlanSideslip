//
//  CommonFunction.m
//  plan
//
//  Created by Fengzy on 15/9/2.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "UIDevice+Util.h"
#import "CommonFunction.h"
#import <CommonCrypto/CommonDigest.h>

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

+ (BOOL)validateNumber:(NSString *)textString {
    NSString *number = @"^[0-9]+$";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", number];
    return [numberPre evaluateWithObject:textString];
}

+ (BOOL)validateEmail:(NSString *)textString {
    NSString *email = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", email];
    return [emailPre evaluateWithObject:textString];
}

+ (BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2 {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents *comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents *comp2 = [calendar components:unitFlags fromDate:date2];
    return [comp1 day] == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year] == [comp2 year];
}

// MD5 32位加密
+ (NSString *)md5HexDigest:(NSString*)password {
    const char *original_str = [password UTF8String];
    unsigned char result[CC_MD5_BLOCK_BYTES];
    CC_MD5(original_str, (CC_LONG)strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < CC_MD5_BLOCK_BYTES; i++) {
        // %02X是格式控制符：‘x’表示以16进制输出，‘02’表示不足两位，前面补0；
        [hash appendFormat:@"%02X", result[i]];
    }
    NSString *mdfiveString = [hash lowercaseString];
    return mdfiveString;
}

//超过仟的数字用K缩写
+ (NSString *)checkNumberForThousand:(NSInteger)number {
    if (number > 100000) {
        return [NSString stringWithFormat:@"%.1fW", (CGFloat)number / 10000];
    } else if (number > 1000) {
        return [NSString stringWithFormat:@"%.1fK", (CGFloat)number / 1000];
    } else {
        return [NSString stringWithFormat:@"%ld", (long)number];
    }
}

@end
