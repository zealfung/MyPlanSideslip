//
//  ForgotPasswordViewController.m
//  plan
//
//  Created by Fengzy on 15/11/24.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import <BmobSDK/BmobUser.h>
#import "SettingsViewController.h"
#import "ForgotPasswordViewController.h"

@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = STRViewTitle11;
    [self setControls];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setControls {
    self.txtEmail.text = self.email;
    self.txtEmail.placeholder = STRViewTips86;
    self.txtEmail.inputAccessoryView = [self getInputAccessoryView];
    [self.txtEmail becomeFirstResponder];
    self.btnSubmit.layer.cornerRadius = 5;
    [self.btnSubmit setAllTitle:STRViewTips96];
}

- (IBAction)submitAction:(id)sender {
    if (![self checkInput]) return;
    [self submit];
}

- (BOOL)checkInput {
    if (self.txtEmail.text.length == 0) {
        [self alertToastMessage:STRViewTips87];
        [self.txtEmail becomeFirstResponder];
        return NO;
    }
    if (![CommonFunction validateEmail:self.txtEmail.text]) {
        [self alertToastMessage:STRViewTips88];
        [self.txtEmail becomeFirstResponder];
        return NO;
    }
    return YES;
}

- (void)submit {
    [BmobUser requestPasswordResetInBackgroundWithEmail:self.txtEmail.text];
    [self alertButtonMessage:STRViewTips97];
    NSArray *array = self.navigationController.viewControllers;
    for (UIViewController *controller in array) {
        if ([controller isKindOfClass:[SettingsViewController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}

@end
