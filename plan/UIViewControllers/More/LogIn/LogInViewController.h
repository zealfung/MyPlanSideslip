//
//  LogInViewController.h
//  plan
//
//  Created by Fengzy on 15/11/30.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "FatherViewController.h"

@interface LogInViewController : FatherViewController

@property (strong, nonatomic) IBOutlet UITextField *txtEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnLogIn;
@property (strong, nonatomic) IBOutlet UIButton *btnRegister;
@property (strong, nonatomic) IBOutlet UIButton *btnForgotPwd;
@property (assign, nonatomic) BOOL isForgotGesture;

@end
