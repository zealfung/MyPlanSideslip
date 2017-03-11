//
//  SettingsSetTextViewController.m
//  plan
//
//  Created by Fengzy on 15/9/2.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "SettingsSetTextViewController.h"

NSUInteger const kSettingsSetTextViewEdgeInset = 10;

@interface SettingsSetTextViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *button;

@end

@implementation SettingsSetTextViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    __weak typeof(self) weakSelf = self;
    [self customRightButtonWithImage:[UIImage imageNamed:png_Btn_Save] action:^(UIButton *sender)
     {
         [weakSelf saveAction:sender];
     }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.textField)
    {
        [self loadCustomView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)loadCustomView
{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    NSUInteger yOffset = kSettingsSetTextViewEdgeInset + 5;
    UIImage *image = [UIImage imageNamed:png_Bg_Input_Gray];
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(kSettingsSetTextViewEdgeInset, yOffset, WIDTH_FULL_SCREEN - kSettingsSetTextViewEdgeInset * 2, 50)];
    textField.background = [image resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
    textField.backgroundColor = [UIColor clearColor];
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.delegate = self;
    textField.inputAccessoryView = [self getInputAccessoryView];
    if (self.textFieldPlaceholder.length)
    {
        textField.placeholder = self.textFieldPlaceholder;
    }
    
    if (self.setType == SetLife)
    {
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    else if (self.setType == SetEmail)
    {
        textField.keyboardType = UIKeyboardTypeEmailAddress;
    }
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 50)];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.leftView = leftView;
    
    [textField becomeFirstResponder];
    [self.view addSubview:textField];
    self.textField = textField;
    
    yOffset = CGRectGetMaxY(textField.frame) + 15;
}

#pragma mark - action
- (void)saveAction:(UIButton *)sender
{
    if (self.finishedBlock)
    {
        self.finishedBlock(self.textField.text);
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    UIImage *image = [UIImage imageNamed:png_Bg_Input_Blue];
    textField.background = [image resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    UIImage *image = [UIImage imageNamed:png_Bg_Input_Gray];
    textField.background = [image resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
}


@end
