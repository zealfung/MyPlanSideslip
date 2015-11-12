//
//  LogIn.h
//  plan
//
//  Created by Fengzy on 15/9/26.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import <BmobSDK/BmobUser.h>
#import <Foundation/Foundation.h>

@interface LogIn : NSObject

+ (BOOL)isLogin;

+ (BOOL)hasAuthorized:(BmobSNSPlatform)bmobSNSPlatform;

+ (void)bmobLogIn:(BmobSNSPlatform)bmobSNSPlatform accessToken:(NSString *)accessToken uid:(NSString *)uid expiresDate:(NSDate *)expiresDate;

+ (void)bmobLogOut;

@end