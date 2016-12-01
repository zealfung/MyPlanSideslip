//
//  RegisterViewController.m
//  plan
//
//  Created by Fengzy on 15/11/24.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import <BmobSDK/BmobACL.h>
#import <BmobSDK/BmobUser.h>
#import <BmobSDK/BmobQuery.h>
#import "RegisterViewController.h"
#import "ForgotPasswordViewController.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = STRViewTitle10;
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
    self.btnRegister.layer.cornerRadius = 5;
    [self.btnRegister setAllTitle:str_Register];
    [self.btnforgotPwd setAllTitle:str_ForgotPassword];
    self.labelTips.text = str_Register_Tips8;
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
    bUser.password = self.txtPassword.text;// [CommonFunction md5HexDigest:self.txtPassword.text];
    bUser.email = acountEmail;
    [bUser signUpInBackgroundWithBlock:^ (BOOL isSuccessful, NSError *error){
        
        [weakSelf hideHUD];
        if (isSuccessful){
            [weakSelf addSettingsToServer];
            [weakSelf alertButtonMessage:str_Register_Tips6];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } else {
            [BmobUser logout];
            [weakSelf alertButtonMessage:str_Register_Fail];
        }
    }];
}

- (void)addSettingsToServer {
    BmobUser *user = [BmobUser currentUser];
    BmobObject *userSettings = [BmobObject objectWithClassName:@"UserSettings"];
    [userSettings setObject:user.objectId forKey:@"userObjectId"];

    BmobACL *acl = [BmobACL ACL];
    [acl setPublicReadAccess];//设置所有人可读
    [acl setWriteAccessForUser:user];//设置只有当前用户可写
    userSettings.ACL = acl;
    [userSettings saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            [Config shareInstance].settings.objectId = userSettings.objectId;
            [PlanCache storePersonalSettings:[Config shareInstance].settings];
        }
        //先注销登录，让用户验证邮箱然后再登录
        [BmobUser logout];
    }];
}

@end
