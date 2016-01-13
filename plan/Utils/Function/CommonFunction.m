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


static NSString * const kKeyYears = @"years";
static NSString * const kKeyMonths = @"months";
static NSString * const kKeyDays = @"days";
static NSString * const kKeyHours = @"hours";
static NSString * const kKeyMinutes = @"minutes";

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
    NSData *imgData = UIImageJPEGRepresentation(image, 0.5);
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

//时间间隔显示：刚刚，N分钟前，N天前...
+ (NSString *)intervalSinceNow:(NSDate *)date {
    NSDictionary *dic = [CommonFunction timeIntervalArrayFromString:date];
    NSInteger months = [[dic objectForKey:kKeyMonths] integerValue];
    NSInteger days = [[dic objectForKey:kKeyDays] integerValue];
    NSInteger hours = [[dic objectForKey:kKeyHours] integerValue];
    NSInteger minutes = [[dic objectForKey:kKeyMinutes] integerValue];
    
    if (minutes < 1) {
        return str_Common_Time1;
    } else if (minutes < 60) {
        return [NSString stringWithFormat:str_Common_Time5, (long)minutes];
    } else if (hours < 24) {
        return [NSString stringWithFormat:str_Common_Time6, (long)hours];
    } else if (hours < 48 && days == 1) {
        return str_Common_Time3;
    } else if (days < 30) {
        return [NSString stringWithFormat:str_Common_Time7, (long)days];
    } else if (days < 60) {
        return str_Common_Time4;
    } else if (months < 12) {
        return [NSString stringWithFormat:str_Common_Time8, (long)months];
    } else {
        return [CommonFunction NSDateToNSString:date formatter:str_DateFormatter_yyyy_MM_dd_HHmmss];
    }
}

+ (NSDictionary *)timeIntervalArrayFromString:(NSDate *)date {
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *compsPast = [calendar components:unitFlags fromDate:date];
    NSDateComponents *compsNow = [calendar components:unitFlags fromDate:[NSDate date]];
    
    NSInteger years = [compsNow year] - [compsPast year];
    NSInteger months = [compsNow month] - [compsPast month] + years * 12;
    NSInteger days = [compsNow day] - [compsPast day] + months * 30;
    NSInteger hours = [compsNow hour] - [compsPast hour] + days * 24;
    NSInteger minutes = [compsNow minute] - [compsPast minute] + hours * 60;
    
    return @{
             kKeyYears:  @(years),
             kKeyMonths: @(months),
             kKeyDays:   @(days),
             kKeyHours:  @(hours),
             kKeyMinutes:@(minutes)
             };
}

//获取PNG图片的大小
+ (CGSize)getPNGImageSizeWithRequest:(NSMutableURLRequest*)request {
    [request setValue:@"bytes=16-23" forHTTPHeaderField:@"Range"];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if(data.length == 8)
    {
        int w1 = 0, w2 = 0, w3 = 0, w4 = 0;
        [data getBytes:&w1 range:NSMakeRange(0, 1)];
        [data getBytes:&w2 range:NSMakeRange(1, 1)];
        [data getBytes:&w3 range:NSMakeRange(2, 1)];
        [data getBytes:&w4 range:NSMakeRange(3, 1)];
        int w = (w1 << 24) + (w2 << 16) + (w3 << 8) + w4;
        int h1 = 0, h2 = 0, h3 = 0, h4 = 0;
        [data getBytes:&h1 range:NSMakeRange(4, 1)];
        [data getBytes:&h2 range:NSMakeRange(5, 1)];
        [data getBytes:&h3 range:NSMakeRange(6, 1)];
        [data getBytes:&h4 range:NSMakeRange(7, 1)];
        int h = (h1 << 24) + (h2 << 16) + (h3 << 8) + h4;
        return CGSizeMake(w, h);
    }
    return CGSizeZero;
}

//获取gif图片的大小
+ (CGSize)getGIFImageSizeWithRequest:(NSMutableURLRequest*)request {
    [request setValue:@"bytes=6-9" forHTTPHeaderField:@"Range"];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if(data.length == 4)
    {
        short w1 = 0, w2 = 0;
        [data getBytes:&w1 range:NSMakeRange(0, 1)];
        [data getBytes:&w2 range:NSMakeRange(1, 1)];
        short w = w1 + (w2 << 8);
        short h1 = 0, h2 = 0;
        [data getBytes:&h1 range:NSMakeRange(2, 1)];
        [data getBytes:&h2 range:NSMakeRange(3, 1)];
        short h = h1 + (h2 << 8);
        return CGSizeMake(w, h);
    }
    return CGSizeZero;
}

//获取jpg图片的大小
+ (CGSize)getJPGImageSizeWithRequest:(NSMutableURLRequest*)request {
    [request setValue:@"bytes=0-209" forHTTPHeaderField:@"Range"];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if ([data length] <= 0x58) {
        return CGSizeZero;
    }
    
    if ([data length] < 210) {// 肯定只有一个DQT字段
        short w1 = 0, w2 = 0;
        [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
        [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
        short w = (w1 << 8) + w2;
        short h1 = 0, h2 = 0;
        [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
        [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
        short h = (h1 << 8) + h2;
        return CGSizeMake(w, h);
    } else {
        short word = 0x0;
        [data getBytes:&word range:NSMakeRange(0x15, 0x1)];
        if (word == 0xdb) {
            [data getBytes:&word range:NSMakeRange(0x5a, 0x1)];
            if (word == 0xdb) {// 两个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0xa5, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0xa6, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0xa3, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0xa4, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            } else {// 一个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            }
        } else {
            return CGSizeZero;
        }
    }
}

//根据性别获取颜色
+ (UIColor *)getGenderColor {
    //昵称：男蓝女粉
    NSString *gender = [Config shareInstance].settings.gender;
    if (gender && [gender isEqualToString:@"0"]) {
        return color_Pink;
    } else {
        return color_Blue;
    }
}

//根据性别获取icon图标
+ (UIImage *)getGenderIcon {
    NSString *gender = [Config shareInstance].settings.gender;
    if (gender && [gender isEqualToString:@"0"]) {
        return [UIImage imageNamed:png_Icon_Gender_F_Selected];
    } else {
        return [UIImage imageNamed:png_Icon_Gender_M_Selected];
    }
}

//用户等级icon图标
+ (UIImage *)getUserLevelIcon:(NSString *)level {
    NSInteger levelCode = [level integerValue];
    switch (levelCode) {
        case 9:
            return [UIImage imageNamed:png_Icon_Icon_UserLevel_9];
            break;
        case 8:
            return [UIImage imageNamed:png_Icon_Icon_UserLevel_8];
            break;
        case 7:
            return [UIImage imageNamed:png_Icon_Icon_UserLevel_7];
            break;
        case 6:
            return [UIImage imageNamed:png_Icon_Icon_UserLevel_6];
            break;
        case 5:
            return [UIImage imageNamed:png_Icon_Icon_UserLevel_5];
            break;
        case 4:
            return [UIImage imageNamed:png_Icon_Icon_UserLevel_4];
            break;
        default:
            return nil;
            break;
    }
}

@end
