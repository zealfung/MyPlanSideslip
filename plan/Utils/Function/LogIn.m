//
//  LogIn.m
//  plan
//
//  Created by Fengzy on 15/9/26.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "LogIn.h"
#import "PlanCache.h"

@implementation LogIn

+ (BOOL)isLogin {
    
    BmobUser *bUser = [BmobUser getCurrentUser];
    if (bUser) {
        return YES;
    } else {
        return NO;
    }
}

@end
