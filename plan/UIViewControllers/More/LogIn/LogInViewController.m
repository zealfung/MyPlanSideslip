//
//  LogInViewController.m
//  plan
//
//  Created by Fengzy on 15/11/30.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "LogIn.h"
#import "AppDelegate.h"
#import <BmobSDK/BmobUser.h>
#import "RootViewController.h"
#import "LogInViewController.h"
#import "RegisterViewController.h"
#import "ForgotPasswordViewController.h"

@interface LogInViewController ()

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = str_Settings_LogIn;
    [self setControls];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setControls {

    self.txtEmail.placeholder = str_Register_Tips1;
    self.txtEmail.inputAccessoryView = [self getInputAccessoryView];
    [self.txtEmail becomeFirstResponder];

    self.txtPassword.placeholder = str_Register_Tips7;
    self.txtPassword.inputAccessoryView = [self getInputAccessoryView];

    if ([LogIn isLogin]) {
        BmobUser *user = [BmobUser getCurrentUser];
        NSString *email = [user objectForKey:@"username"];
        self.txtEmail.text = email;
        [self.txtEmail resignFirstResponder];
        [self.txtPassword becomeFirstResponder];
    }
    
    self.btnLogIn.layer.cornerRadius = 5;
    [self.btnLogIn setAllTitle:str_Settings_LogIn];
    [self.btnRegister setAllTitle:str_Register];
    [self.btnForgotPwd setAllTitle:str_ForgotPassword];
}

- (IBAction)logInAction:(id)sender {
    //检查输入
    if (self.txtEmail.text.length == 0) {
        [self alertToastMessage:str_Register_Tips2];
        [self.txtEmail becomeFirstResponder];
        return;
    }
    if (![CommonFunction validateEmail:self.txtEmail.text]) {
        [self alertToastMessage:str_Register_Tips3];
        [self.txtEmail becomeFirstResponder];
        return;
    }
    if (self.txtPassword.text.length == 0) {
        [self alertToastMessage:str_Register_Tips4];
        [self.txtPassword becomeFirstResponder];
        return;
    }
    [self showHUD];
    [self.view endEditing:YES];
    __weak typeof(self) weakSelf = self;
    NSString *acountEmail = [self.txtEmail.text lowercaseString];
    //登录账号
    [BmobUser loginWithUsernameInBackground:acountEmail password:self.txtPassword.text block:^(BmobUser *user, NSError *error) {
        
        [weakSelf hideHUD];
        if (error) {
            
            NSString *errorMsg = [error.userInfo objectForKey:@"error"];
            if ([errorMsg containsString:@"incorrect"]) {
                [weakSelf alertButtonMessage:str_LogIn_Tips1];
            }
            
        } else if (user) {
            //检查账号邮箱是否已经通过验证
            if ([[user objectForKey:@"emailVerified"] boolValue]) {
                if (self.isForgotGesture) {
                    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                    RootViewController *controller = [story instantiateViewControllerWithIdentifier:@"rootViewController"];
                    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    delegate.window.rootViewController = controller;
                    [delegate.window reloadInputViews];
                } else {
                    //登录后自动关联本地没有对应账号的数据
                    [PlanCache linkedLocalDataToAccount];
                    [NotificationCenter postNotificationName:Notify_LogIn object:nil];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
                
                [Config shareInstance].settings = [PlanCache getPersonalSettings];
                [Config shareInstance].settings.isUseGestureLock = @"0";
                [Config shareInstance].settings.gesturePasswod = @"";
                [PlanCache storePersonalSettings:[Config shareInstance].settings];
            } else {
                //用户没验证过邮箱
                [BmobUser logout];
                [weakSelf alertButtonMessage:str_LogIn_Tips2];
                [user verifyEmailInBackgroundWithEmailAddress:acountEmail];
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
