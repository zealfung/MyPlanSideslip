//
//  RegisterViewController.m
//  plan
//
//  Created by Fengzy on 15/11/24.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "BmobUser.h"
#import "BmobQuery.h"
#import "RegisterViewController.h"
#import "ForgotPasswordViewController.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = str_ViewTitle_10;
    [self setControls];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setControls {
    self.txtEmail.placeholder = @"邮箱地址Email";
    [self.txtEmail becomeFirstResponder];
    self.txtPassword.placeholder = @"密码";
    self.btnRegister.layer.cornerRadius = 5;
    [self.btnRegister setAllTitle:@"注册"];
    [self.btnforgotPwd setAllTitle:@"忘记密码"];
}

- (IBAction)registerAction:(id)sender {
    if (![self checkInput]) return;
    [self checkIfEmailHadRegisted];
}

- (IBAction)forgotPwdAction:(id)sender {
    ForgotPasswordViewController *controller = [[ForgotPasswordViewController alloc] init];
    controller.email = self.txtEmail.text;
    [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)checkInput {
    if (self.txtEmail.text.length == 0) {
        [self alertToastMessage:@"请输入邮箱地址"];
        [self.txtEmail becomeFirstResponder];
        return NO;
    }
    if (![CommonFunction validateEmail:self.txtEmail.text]) {
        [self alertToastMessage:@"邮箱地址格式不正确"];
        [self.txtEmail becomeFirstResponder];
        return NO;
    }
    if (self.txtPassword.text.length == 0) {
        [self alertToastMessage:@"请输入密码"];
        [self.txtPassword becomeFirstResponder];
        return NO;
    }
    return YES;
}

- (void)checkIfEmailHadRegisted {
    [self showHUD];
    __weak typeof(self) weakSelf = self;
    BmobQuery   *bquery = [BmobQuery queryWithClassName:@"_User"];
    [bquery whereKey:@"username" equalTo:self.txtEmail.text];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error){
            //进行错误处理
            [weakSelf hideHUD];
        }else{
            if (array && array.count > 0) {//已存在
                
                [weakSelf hideHUD];
                [weakSelf alertButtonMessage:@"该邮箱账号已经注册，如果密码丢失，可通过“忘记密码”找回"];
                
            } else {//可注册
                
                [weakSelf registerUser];
            }
        }
    }];
}

- (void)registerUser {
    __weak typeof(self) weakSelf = self;
    NSString *acountEmail = [self.txtEmail.text lowercaseString];
    BmobUser *bUser = [[BmobUser alloc] init];
    bUser.username = acountEmail;
    bUser.password = self.txtPassword.text;
    bUser.email = acountEmail;
    [bUser signUpInBackgroundWithBlock:^ (BOOL isSuccessful, NSError *error){
        [weakSelf hideHUD];
        
        if (isSuccessful){
            [weakSelf alertButtonMessage:@"我们给你的邮箱发了一封验证邮件，请先验证邮件后再登录使用"];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } else {
            [weakSelf alertButtonMessage:@"注册失败"];
        }
    }];
}

@end
