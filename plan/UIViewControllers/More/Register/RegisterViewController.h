//
//  RegisterViewController.h
//  plan
//
//  Created by Fengzy on 15/11/24.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "FatherViewController.h"

@interface RegisterViewController : FatherViewController

@property (strong, nonatomic) IBOutlet UITextField *txtEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnRegister;
@property (strong, nonatomic) IBOutlet UIButton *btnforgotPwd;

@end
