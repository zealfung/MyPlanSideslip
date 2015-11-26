//
//  AlertCenter.m
//  plan
//
//  Created by Fengzy on 15/8/30.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "CRToast.h"
#import "AlertCenter.h"
#import "PromptMessage.h"

@implementation AlertCenter

+ (void)alertButtonMessage:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:str_Alert_GetIt otherButtonTitles:nil];
    [alertView show];
}

+ (void)alertToastMessage:(NSString *)message {
    PromptMessage *pbMessage = [[PromptMessage alloc] init];
    [pbMessage  showMessage:message];
}

+ (void)alertNavBarMessage:(NSString *)message {
    NSDictionary *options = @{
                              kCRToastNotificationTypeKey : @(CRToastTypeNavigationBar),
                              kCRToastNotificationPresentationTypeKey : @(CRToastPresentationTypeCover),
                              kCRToastUnderStatusBarKey : @(YES),
                              kCRToastTextKey : message,
                              kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                              kCRToastBackgroundColorKey : color_0BA32A,
                              kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                              kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                              kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                              kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop)
                              };
    [CRToastManager showNotificationWithOptions:options
                                completionBlock:^{
                                    NSLog(@"AlertNavBarMessage completed");
                                }];
}
@end
