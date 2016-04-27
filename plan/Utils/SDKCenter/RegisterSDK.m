//
//  RegisterSDK.m
//  plan
//
//  Created by Fengzy on 15/9/26.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "WXApi.h"
#import "WeiboSDK.h"
#import "WeiboUser.h"
#import "RegisterSDK.h"
#import <BmobSDK/Bmob.h>
#import <ShareSDK/ShareSDK.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <ShareSDKConnector/ShareSDKConnector.h>

@implementation RegisterSDK

+ (void)registerSDK {

    [Bmob registerWithAppKey:IDSTRBmobApplicationID];
    
    [ShareSDK registerApp:IDSTRShareSDKAppKey activePlatforms:@[@(SSDKPlatformTypeSinaWeibo),@(SSDKPlatformTypeQQ),@(SSDKPlatformTypeWechat)] onImport:^(SSDKPlatformType platformType) {
        
        switch (platformType) {
            case SSDKPlatformTypeSinaWeibo:
                [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                break;
            case SSDKPlatformTypeQQ:
                [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                break;
            case SSDKPlatformTypeWechat:
                [ShareSDKConnector connectWeChat:[WXApi class]];
                break;
            default:
                break;
        }
        
    } onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
        
        switch (platformType) {
            case SSDKPlatformTypeSinaWeibo:
                [appInfo SSDKSetupSinaWeiboByAppKey:IDSTRSinaWeiboAppKey appSecret:IDSTRSinaWeiboAppSecret redirectUri:str_SinaWeibo_RedirectURI authType:SSDKAuthTypeBoth];
                break;
            case SSDKPlatformTypeQQ:
                [appInfo SSDKSetupQQByAppId:IDSTRQQAppID appKey:IDSTRQQAppKey authType:SSDKAuthTypeBoth];
                break;
            case SSDKPlatformTypeWechat:
                [appInfo SSDKSetupWeChatByAppId:IDSTRWechatAppKey appSecret:IDSTRWechatAppSecret];
                break;
                
            default:
                break;
        }
        
    }];
    
}

@end
