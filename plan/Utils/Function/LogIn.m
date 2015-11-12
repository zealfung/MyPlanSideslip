//
//  LogIn.m
//  plan
//
//  Created by Fengzy on 15/9/26.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "LogIn.h"
#import "WeiboSDK.h"
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

+ (BOOL)hasAuthorized:(BmobSNSPlatform)bmobSNSPlatform {
    
    BmobSNSPlatform platform = [LogIn getLogInPlatform];
    
    if (platform == bmobSNSPlatform) {
        return YES;
    } else {
        return NO;
    }
    
}

+ (void)bmobLogIn:(BmobSNSPlatform)bmobSNSPlatform accessToken:(NSString *)accessToken uid:(NSString *)uid expiresDate:(NSDate *)expiresDate {
    
    NSLog(@"acessToken:%@",accessToken);
    NSLog(@"UserId:%@",uid);
    NSLog(@"expiresDate:%@",expiresDate);
    NSDictionary *dic = @{@"access_token":accessToken, @"uid":uid, @"expirationDate":expiresDate};

    //通过授权信息注册登录
    [BmobUser loginInBackgroundWithAuthorDictionary:dic platform:bmobSNSPlatform block:^(BmobUser *user, NSError *error) {
        
        if (error) {
            
            NSLog(@"login error:%@",error);
            
        } else if (user) {
            
            NSLog(@"user objectid is :%@",user.objectId);
            
            [LogIn saveLogInPlatform:bmobSNSPlatform];
            //登录后自动关联本地没有对应账号的数据
            [PlanCache linkedLocalDataToAccount];
        }
        [NotificationCenter postNotificationName:Notify_LogIn object:nil];
        
    }];
    
}

+ (void)bmobLogOut {
    
    [BmobUser logout];
    [NotificationCenter postNotificationName:Notify_Settings_Save object:nil];
    [NotificationCenter postNotificationName:Notify_Plan_Save object:nil];
    [NotificationCenter postNotificationName:Notify_Photo_Save object:nil];
    
}

+ (void)saveLogInPlatform:(BmobSNSPlatform)bmobSNSPlatform {
    
    [UserDefaults setObject:@(bmobSNSPlatform) forKey:str_LogInPlatform];
    [UserDefaults synchronize];
    
}

+ (BmobSNSPlatform)getLogInPlatform {
    
    id platform = [UserDefaults objectForKey:str_LogInPlatform];
    NSInteger type = [platform integerValue];
    if (type == 1) {
        return BmobSNSPlatformSinaWeibo;
    } else if (type == 2) {
        return BmobSNSPlatformWeiXin;
    } else {
        return BmobSNSPlatformQQ;
    }
    
}

@end
