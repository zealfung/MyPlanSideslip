//
//  ShareCenter.m
//  plan
//
//  Created by Fengzy on 15/9/10.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "ShareCenter.h"
#import "AlertCenter.h"

@implementation ShareCenter

/**
 *  显示分享菜单
 *
 *  @param view 容器视图
 */
+ (void)showShareActionSheet:(UIView *)view image:(UIImage *)image {

    UIImage *shareImg = [UIImage imageNamed:png_Icon_Logo_512];
    if (image) {
        shareImg = image;
    }
    //1、创建分享参数
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    NSArray* imageArray = @[shareImg];
    [shareParams SSDKSetupShareParamsByText:STRViewTips111
                                     images:imageArray
                                        url:[NSURL URLWithString:STRAppWebsite]
                                      title:STRAppSlogan
                                       type:SSDKContentTypeImage];
    
    //1.2、自定义分享平台
    NSMutableArray *activePlatforms = [NSMutableArray arrayWithArray:@[@(SSDKPlatformTypeSinaWeibo), @(SSDKPlatformSubTypeWechatSession), @(SSDKPlatformSubTypeWechatTimeline), @(SSDKPlatformSubTypeQQFriend)]];
    
    //2、分享
    [ShareSDK showShareActionSheet:view
                             items:activePlatforms
                       shareParams:shareParams
               onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                   
                   switch (state) {
                           
                       case SSDKResponseStateBegin:
                       {
                           break;
                       }
                       case SSDKResponseStateSuccess:
                       {
                           [AlertCenter alertToastMessage:STRViewTips107];
                           break;
                       }
                       case SSDKResponseStateFail:
                       {
                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:STRViewTips108
                                                                           message:[NSString stringWithFormat:@"%@",error]
                                                                          delegate:nil
                                                                 cancelButtonTitle:STRCommonTip27
                                                                 otherButtonTitles:nil, nil];
                           [alert show];
                           break;
                       }
                       case SSDKResponseStateCancel:
                       {
                           //                           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:STRViewTips109
                           //                                                                               message:nil
                           //                                                                              delegate:nil
                           //                                                                     cancelButtonTitle:str_OK
                           //                                                                     otherButtonTitles:nil];
                           //                           [alertView show];
                           break;
                       }
                       default:
                           break;
                   }
                   
                   if (state != SSDKResponseStateBegin)
                   {
                   }
                   
               }];
}

/**
 *  显示分享菜单
 *
 *  @param view 容器视图
 */
+ (void)showShareActionSheet:(UIView *)view title:(NSString *)title content:(NSString *)content shareUrl:(NSString *)shareUrl sharedImageURL:(NSString *)sharedImageURL {
    if (!shareUrl || [shareUrl isEqualToString:@""]) {
        shareUrl = STRAppWebsite;
    }
    //1、创建分享参数
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    NSArray* imageArray = @[[UIImage imageNamed:png_Icon_Logo_512]];
    [shareParams SSDKSetupShareParamsByText:content
                                     images:imageArray
                                        url:[NSURL URLWithString:shareUrl]
                                      title:title
                                       type:SSDKContentTypeAuto];
    
    //1.2、自定义分享平台
    NSMutableArray *activePlatforms = [NSMutableArray arrayWithArray:@[@(SSDKPlatformTypeSinaWeibo), @(SSDKPlatformSubTypeWechatSession), @(SSDKPlatformSubTypeWechatTimeline), @(SSDKPlatformSubTypeQQFriend), @(SSDKPlatformSubTypeQZone), @(SSDKPlatformTypeQQ)]];
    
    //2、分享
    [ShareSDK showShareActionSheet:view
                             items:activePlatforms
                       shareParams:shareParams
               onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                   
                   switch (state) {
                           
                       case SSDKResponseStateBegin:
                       {
                           break;
                       }
                       case SSDKResponseStateSuccess:
                       {
                           [AlertCenter alertToastMessage:STRViewTips107];
                           break;
                       }
                       case SSDKResponseStateFail:
                       {
                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:STRViewTips108
                                                                           message:[NSString stringWithFormat:@"%@",error]
                                                                          delegate:nil
                                                                 cancelButtonTitle:STRCommonTip27
                                                                 otherButtonTitles:nil, nil];
                           [alert show];
                           break;
                       }
                       case SSDKResponseStateCancel:
                       {
//                           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:STRViewTips109
//                                                                               message:nil
//                                                                              delegate:nil
//                                                                     cancelButtonTitle:str_OK
//                                                                     otherButtonTitles:nil];
//                           [alertView show];
                           break;
                       }
                       default:
                           break;
                   }
                   
                   if (state != SSDKResponseStateBegin)
                   {
                   }
                   
               }];
}

@end
