//
//  ForgotPasswordViewController.m
//  plan
//
//  Created by Fengzy on 15/11/24.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import <BmobSDK/BmobUser.h>
#import "ForgotPasswordViewController.h"

@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = STRViewTitle11;
    [self setControls];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setControls
{
    self.txtEmail.text = self.email;
    self.txtEmail.placeholder = STRViewTips86;
    self.txtEmail.inputAccessoryView = [self getInputAccessoryView];
    [self.txtEmail becomeFirstResponder];
    self.btnSubmit.layer.cornerRadius = 2;
    self.btnSubmit.backgroundColor = color_Blue;
    [self.btnSubmit setAllTitle:STRViewTips96];
}

- (IBAction)submitAction:(id)sender
{
    if (![self checkInput]) return;
    [self submit];
}

- (BOOL)checkInput
{
    if (self.txtEmail.text.length == 0)
    {
        [self alertToastMessage:STRViewTips87];
        [self.txtEmail becomeFirstResponder];
        return NO;
    }
    if (![CommonFunction validateEmail:self.txtEmail.text])
    {
        [self alertToastMessage:STRViewTips88];
        [self.txtEmail becomeFirstResponder];
        return NO;
    }
    return YES;
}

- (void)submit
{
    __weak typeof(self) weakSelf = self;
    [self showHUD];
    [BmobUser requestPasswordResetInBackgroundWithEmail:self.txtEmail.text block:^(BOOL isSuccessful, NSError *error)
    {
        [weakSelf hideHUD];
        if (isSuccessful)
        {
            [weakSelf alertButtonMessage:STRViewTips97];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [weakSelf alertButtonMessage:@"请求失败"];
        }
    }];
}

@end
