//
//  ChangePasswordViewController.h
//  plan
//
//  Created by Fengzy on 16/1/14.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import "FatherViewController.h"

@interface ChangePasswordViewController : FatherViewController

@property (strong, nonatomic) IBOutlet UITextField *txtOldPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtNewPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtNewPasswordAgain;
@property (strong, nonatomic) IBOutlet UIButton *btnSubmit;

@end
