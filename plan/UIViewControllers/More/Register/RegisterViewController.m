//
//  RegisterViewController.m
//  plan
//
//  Created by Fengzy on 15/11/24.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "BmobACL.h"
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
    self.txtEmail.placeholder = str_Register_Tips1;
    [self.txtEmail becomeFirstResponder];
    self.txtPassword.placeholder = str_Register_Tips7;
    self.btnRegister.layer.cornerRadius = 5;
    [self.btnRegister setAllTitle:str_Register];
    [self.btnforgotPwd setAllTitle:str_ForgotPassword];
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
        [self alertToastMessage:str_Register_Tips2];
        [self.txtEmail becomeFirstResponder];
        return NO;
    }
    if (![CommonFunction validateEmail:self.txtEmail.text]) {
        [self alertToastMessage:str_Register_Tips3];
        [self.txtEmail becomeFirstResponder];
        return NO;
    }
    if (self.txtPassword.text.length == 0) {
        [self alertToastMessage:str_Register_Tips4];
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
        } else {
            if (array && array.count > 0) {//已存在
                [weakSelf hideHUD];
                [weakSelf alertButtonMessage:str_Register_Tips5];
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
    bUser.password = [CommonFunction md5HexDigest:self.txtPassword.text];
    bUser.email = acountEmail;
    [bUser signUpInBackgroundWithBlock:^ (BOOL isSuccessful, NSError *error){
        
        [weakSelf hideHUD];
        if (isSuccessful){
            [BmobUser logout];
            [weakSelf alertButtonMessage:str_Register_Tips6];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } else {
            [weakSelf alertButtonMessage:str_Register_Fail];
        }
    }];
}

@end
