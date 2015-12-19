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

#define iPhone6S [[CommonFunction getDeviceType] rangeOfString:@"6S"].location != NSNotFound && [[CommonFunction getDeviceType] rangeOfString:@"iPhone 6SPlus"].location == NSNotFound

#define iPhone6SPlus [[CommonFunction getDeviceType] rangeOfString:@"iPhone 6SPlus"].location != NSNotFound

#define WIDTH_FULL_SCREEN    ([UIScreen mainScreen].bounds.size.width)

#define HEIGHT_FULL_SCREEN   ([UIScreen mainScreen].bounds.size.height)

//除导航栏和状态栏外的视图的高度
#define HEIGHT_FULL_VIEW     ([UIScreen mainScreen].bounds.size.height) - 64

//计划分页，每批次加载数据行数
#define kPlanLoadMax 50
//影像分页，每批次加载数据行数
#define kPhotoLoadMax (iPhone6 || iPhone6Plus || iPhone6S || iPhone6SPlus) ? 3 : 2

#endif
