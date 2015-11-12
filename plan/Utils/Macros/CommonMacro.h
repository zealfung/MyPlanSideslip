//
//  CommonMacro.h
//  plan
//
//  Created by Fengzy on 15/8/28.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#ifndef plan_CommonMacro_h
#define plan_CommonMacro_h

#define iOS6_LATER [[UIDevice currentDevice].systemVersion doubleValue] >= 5.9

#define iOS7_LATER [[UIDevice currentDevice].systemVersion doubleValue] >= 7.0

#define iOS8_LATER [[UIDevice currentDevice].systemVersion doubleValue] >= 8.0

#define iPhone4 [[CommonFunction getDeviceType] rangeOfString:@"4"].location != NSNotFound

#define iPhone5 [[CommonFunction getDeviceType] rangeOfString:@"5"].location != NSNotFound

#define iPhone6 [[CommonFunction getDeviceType] rangeOfString:@"6"].location != NSNotFound && [[CommonFunction getDeviceType] rangeOfString:@"iPhone 6Plus"].location == NSNotFound

#define iPhone6Plus [[CommonFunction getDeviceType] rangeOfString:@"iPhone 6Plus"].location != NSNotFound

#define WIDTH_FULL_SCREEN       ([UIScreen mainScreen].bounds.size.width)

#define HEIGHT_FULL_SCREEN      ([UIScreen mainScreen].bounds.size.height)

#endif
