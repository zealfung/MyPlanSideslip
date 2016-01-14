//
//  ChangePasswordViewController.m
//  plan
//
//  Created by Fengzy on 16/1/14.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import "BmobUser.h"
#import "ChangePasswordViewController.h"

@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = str_ViewTitle_15;
    [self setControls];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setControls {
    self.txtOldPassword.placeholder = str_ChangePassword_Tips1;
    self.txtOldPassword.inputAccessoryView = [self getInputAccessoryView];
    self.txtNewPassword.placeholder = str_ChangePassword_Tips2;
    self.txtNewPassword.inputAccessoryView = [self getInputAccessoryView];
    self.txtNewPasswordAgain.placeholder = str_ChangePassword_Tips3;
    self.txtNewPasswordAgain.inputAccessoryView = [self getInputAccessoryView];
    [self.txtOldPassword becomeFirstResponder];
    self.btnSubmit.layer.cornerRadius = 5;
    [self.btnSubmit setAllTitle:str_ViewTitle_15];
}

- (IBAction)submitAction:(id)sender {
    [self.view endEditing:YES];
    if (![self checkInput]) return;
    [self submit];
}

- (BOOL)checkInput {
    if (self.txtOldPassword.text.length == 0) {
        [self.txtOldPassword becomeFirstResponder];
        [self alertToastMessage:str_ChangePassword_Tips1];
        return NO;
    }
    if (self.txtNewPassword.text.length == 0) {
        [self.txtNewPassword becomeFirstResponder];
        [self alertToastMessage:str_ChangePassword_Tips2];
        return NO;
    }
    if (self.txtNewPasswordAgain.text.length == 0) {
        [self.txtNewPasswordAgain becomeFirstResponder];
        [self alertToastMessage:str_ChangePassword_Tips3];
        return NO;
    }
    if (![self.txtNewPassword.text isEqualToString:self.txtNewPasswordAgain.text]) {
        self.txtNewPasswordAgain.text = @"";
        [self.txtNewPasswordAgain becomeFirstResponder];
        [self alertToastMessage:str_ChangePassword_Tips4];
        return NO;
    }
    return YES;
}

- (void)submit {
    [self showHUD];
    __weak typeof(self) weakSelf = self;
    BmobUser *user = [BmobUser getCurrentUser];
    [user updateCurrentUserPasswordWithOldPassword:self.txtOldPassword.text newPassword:self.txtNewPassword.text block:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            //用新密码登录
            [BmobUser loginInbackgroundWithAccount:user.username andPassword:self.txtNewPassword.text block:^(BmobUser *user, NSError *error) {
                [weakSelf hideHUD];
                if (error) {
                    [weakSelf alertToastMessage:str_ChangePassword_Tips7];
                    NSLog(@"login error:%@",error);
                } else {
                    [weakSelf alertToastMessage:str_ChangePassword_Tips5];
                }
                [NotificationCenter postNotificationName:Notify_LogIn object:nil];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
        } else {
            [weakSelf hideHUD];
            if ([error.description containsString:@"error=old password incorrect."]) {
                [weakSelf alertButtonMessage:str_ChangePassword_Tips9];
            } else {
                [weakSelf alertButtonMessage:str_ChangePassword_Tips6];
            }
            NSLog(@"change password error:%@",error);
        }
    }];
}

@end
