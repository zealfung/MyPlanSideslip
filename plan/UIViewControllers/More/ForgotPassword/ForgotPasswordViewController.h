//
//  ForgotPasswordViewController.h
//  plan
//
//  Created by Fengzy on 15/11/24.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "FatherViewController.h"

@interface ForgotPasswordViewController : FatherViewController

@property (nonatomic, strong) NSString *email;
@property (strong, nonatomic) IBOutlet UITextField *txtEmail;
@property (strong, nonatomic) IBOutlet UIButton *btnSubmit;

@end
