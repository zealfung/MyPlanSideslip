//
//  ChangePasswordViewController.m
//  plan
//
//  Created by Fengzy on 16/1/14.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import <BmobSDK/BmobUser.h>
#import "ChangePasswordViewController.h"

@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = STRViewTitle15;
    [self setControls];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setControls
{
    self.txtOldPassword.placeholder = STRViewTips98;
    self.txtOldPassword.inputAccessoryView = [self getInputAccessoryView];
    self.txtNewPassword.placeholder = STRViewTips98;
    self.txtNewPassword.inputAccessoryView = [self getInputAccessoryView];
    self.txtNewPasswordAgain.placeholder = STRViewTips100;
    self.txtNewPasswordAgain.inputAccessoryView = [self getInputAccessoryView];
    [self.txtOldPassword becomeFirstResponder];
    self.btnSubmit.layer.cornerRadius = 2;
    self.btnSubmit.backgroundColor = color_Blue;
    [self.btnSubmit setAllTitle:STRViewTitle15];
}

- (IBAction)submitAction:(id)sender
{
    [self.view endEditing:YES];
    if (![self checkInput]) return;
    [self submit];
}

- (BOOL)checkInput
{
    if (self.txtOldPassword.text.length == 0)
    {
        [self.txtOldPassword becomeFirstResponder];
        [self alertToastMessage:STRViewTips98];
        return NO;
    }
    if (self.txtNewPassword.text.length == 0)
    {
        [self.txtNewPassword becomeFirstResponder];
        [self alertToastMessage:STRViewTips98];
        return NO;
    }
    if (self.txtNewPasswordAgain.text.length == 0)
    {
        [self.txtNewPasswordAgain becomeFirstResponder];
        [self alertToastMessage:STRViewTips100];
        return NO;
    }
    if (![self.txtNewPassword.text isEqualToString:self.txtNewPasswordAgain.text])
    {
        self.txtNewPasswordAgain.text = @"";
        [self.txtNewPasswordAgain becomeFirstResponder];
        [self alertToastMessage:STRViewTips101];
        return NO;
    }
    return YES;
}

- (void)submit
{
    [self showHUD];
    __weak typeof(self) weakSelf = self;
    BmobUser *user = [BmobUser currentUser];
    [user updateCurrentUserPasswordWithOldPassword:self.txtOldPassword.text newPassword:self.txtNewPassword.text block:^(BOOL isSuccessful, NSError *error)
     {
        if (isSuccessful)
        {
            //用新密码登录
            [BmobUser loginInbackgroundWithAccount:user.username andPassword:self.txtNewPassword.text block:^(BmobUser *user, NSError *error)
            {
                [weakSelf hideHUD];
                if (error)
                {
                    [weakSelf alertToastMessage:STRViewTips104];
                    NSLog(@"login error:%@",error);
                }
                else
                {
                    [weakSelf alertToastMessage:STRViewTips102];
                }
                [NotificationCenter postNotificationName:NTFLogIn object:nil];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
        }
        else
        {
            [weakSelf hideHUD];
            if ([error.description containsString:@"error=old password incorrect."])
            {
                [weakSelf alertButtonMessage:STRViewTips105];
            }
            else
            {
                [weakSelf alertButtonMessage:STRViewTips103];
            }
            NSLog(@"change password error:%@",error);
        }
    }];
}

@end
