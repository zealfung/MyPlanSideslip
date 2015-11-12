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

    [Bmob registerWithAppKey:str_Bmob_ApplicationID];
    
    [ShareSDK registerApp:str_ShareSDK_AppKey activePlatforms:@[@(SSDKPlatformTypeSinaWeibo),@(SSDKPlatformTypeQQ),@(SSDKPlatformTypeWechat)] onImport:^(SSDKPlatformType platformType) {
        
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
                [appInfo SSDKSetupSinaWeiboByAppKey:str_SinaWeibo_AppKey appSecret:str_SinaWeibo_AppSecret redirectUri:str_SinaWeibo_RedirectURI authType:SSDKAuthTypeBoth];
                break;
            case SSDKPlatformTypeQQ:
                [appInfo SSDKSetupQQByAppId:str_QQ_AppID appKey:str_QQ_AppKey authType:SSDKAuthTypeBoth];
                break;
            case SSDKPlatformTypeWechat:
                [appInfo SSDKSetupWeChatByAppId:str_Wechat_AppKey appSecret:str_Wechat_AppSecret];
                break;
                
            default:
                break;
        }
        
    }];
    
}

@end
