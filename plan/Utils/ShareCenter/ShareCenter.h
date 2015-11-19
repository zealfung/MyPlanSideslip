//
//  ShareCenter.h
//  plan
//
//  Created by Fengzy on 15/9/10.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>


@interface ShareCenter : NSObject

+ (void)showShareActionSheet:(UIView *)view image:(UIImage *)image;

+ (void)showShareActionSheet:(UIView *)view title:(NSString *)title content:(NSString*)content shareUrl:(NSString *)shareUrl sharedImageURL:(NSString *)sharedImageURL;

@end
