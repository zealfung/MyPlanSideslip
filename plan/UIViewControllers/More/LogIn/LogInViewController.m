//
//  LogInViewController.m
//  plan
//
//  Created by Fengzy on 15/11/30.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "LogIn.h"
#import <BmobSDK/BmobUser.h>
#import "LogInViewController.h"
#import "RegisterViewController.h"
#import "ForgotPasswordViewController.h"

@interface LogInViewController ()

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"登录";
    [self setControls];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setControls {

    self.txtEmail.placeholder = @"账号邮箱Email";
    self.txtEmail.inputAccessoryView = [self getInputAccessoryView];
    [self.txtEmail becomeFirstResponder];

    self.txtPassword.placeholder = @"密码Password";
    self.txtPassword.inputAccessoryView = [self getInputAccessoryView];

    if (self.isForgotGesture && [LogIn isLogin]) {
        BmobUser *user = [BmobUser getCurrentUser];
        NSString *email = [user objectForKey:@"username"];
        self.txtEmail.text = email;
        [self.txtEmail resignFirstResponder];
        [self.txtPassword becomeFirstResponder];
    }
    
    self.btnLogIn.layer.cornerRadius = 5;
    [self.btnLogIn setAllTitle:@"登录"];
    [self.btnRegister setAllTitle:@"注册账号"];
    [self.btnForgotPwd setAllTitle:@"忘记密码"];
}

- (IBAction)logInAction:(id)sender {
    //检查输入
    if (self.txtEmail.text.length == 0) {
        [self alertToastMessage:@"请输入账号邮箱"];
        [self.txtEmail becomeFirstResponder];
        return;
    }
    if (![CommonFunction validateEmail:self.txtEmail.text]) {
        [self alertToastMessage:@"账号邮箱格式不正确"];
        [self.txtEmail becomeFirstResponder];
        return;
    }
    if (self.txtPassword.text.length == 0) {
        [self alertToastMessage:@"请输入密码"];
        [self.txtPassword becomeFirstResponder];
        return;
    }
    [self showHUD];
    __weak typeof(self) weakSelf = self;
    NSString *acountEmail = [self.txtEmail.text lowercaseString];
    //登录账号
    [BmobUser loginWithUsernameInBackground:acountEmail password:self.txtPassword.text block:^(BmobUser *user, NSError *error) {
        
        [weakSelf hideHUD];
        if (error) {
            
            NSString *errorMsg = [error.userInfo objectForKey:@"error"];
            if ([errorMsg containsString:@"incorrect"]) {
                [weakSelf alertButtonMessage:@"账号或密码不正确"];
            }
            
        } else if (user) {
            
            //检查账号邮箱是否已经通过验证
            if ([user objectForKey:@"emailVerified"]) {
                //用户没验证过邮箱
                if (![[user objectForKey:@"emailVerified"] boolValue]) {
                    [weakSelf hideHUD];
                    [BmobUser logout];
                    [weakSelf alertButtonMessage:@"你的账号邮箱还没通过验证，请先登录账号邮箱查看验证邮件"];
                    [user verifyEmailInBackgroundWithEmailAddress:acountEmail];
                    
                } else {
                    
                    if (self.isForgotGesture) {
                        [Config shareInstance].settings.isUseGestureLock = @"0";
                        [Config shareInstance].settings.gesturePasswod = @"";
                        [PlanCache storePersonalSettings:[Config shareInstance].settings];
//                        [weakSelf dismissViewControllerAnimated:YES completion:nil];
                    } else {
                        //登录后自动关联本地没有对应账号的数据
                        [PlanCache linkedLocalDataToAccount];
                        [NotificationCenter postNotificationName:Notify_LogIn object:nil];
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }
                }
            }
        }
    }];
}

- (IBAction)registerAction:(id)sender {
    RegisterViewController *controller = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)forgotPwdAction:(id)sender {
    ForgotPasswordViewController *controller = [[ForgotPasswordViewController alloc] init];
    controller.email = self.txtEmail.text;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
