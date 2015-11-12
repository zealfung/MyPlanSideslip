//
//  AlertCenter.m
//  plan
//
//  Created by Fengzy on 15/8/30.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

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
    return;
}

@end
