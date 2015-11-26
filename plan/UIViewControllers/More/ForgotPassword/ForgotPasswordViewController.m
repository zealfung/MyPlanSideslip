//
//  ForgotPasswordViewController.m
//  plan
//
//  Created by Fengzy on 15/11/24.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "BmobUser.h"
#import "SettingsViewController.h"
#import "ForgotPasswordViewController.h"

@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = str_ViewTitle_11;
    [self setControls];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setControls {
    self.txtEmail.text = self.email;
    self.txtEmail.placeholder = @"邮箱地址Email";
    [self.txtEmail becomeFirstResponder];
    self.btnSumbit.layer.cornerRadius = 5;
    [self.btnSumbit setAllTitle:@"马上找回"];
}

- (IBAction)submitAction:(id)sender {
    if (![self checkInput]) return;
    [self submit];
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
    return YES;
}

- (void)submit {

    [BmobUser requestPasswordResetInBackgroundWithEmail:self.txtEmail.text];
    [self alertButtonMessage:@"我们给你的邮箱发了一封重置密码的邮件，请注意查收"];
    NSArray *array = self.navigationController.viewControllers;
    for (UIViewController *controller in array) {
        if ([controller isKindOfClass:[SettingsViewController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}

@end
