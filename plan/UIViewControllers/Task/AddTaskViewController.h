//
//  AddTaskViewController.h
//  plan
//
//  Created by Fengzy on 15/11/29.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "Task.h"
#import "FatherViewController.h"

@interface AddTaskViewController : FatherViewController

@property (strong, nonatomic) IBOutlet UITextView *txtView;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewTomato;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewAlarm;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewRepeat;
@property (strong, nonatomic) IBOutlet UISwitch *switchTomato;
@property (strong, nonatomic) IBOutlet UISwitch *switchAlarm;
@property (strong, nonatomic) IBOutlet UISwitch *switchRepeat;
@property (strong, nonatomic) IBOutlet UILabel *labelTomatoTips1;
@property (strong, nonatomic) IBOutlet UILabel *labelTomatoTips2;
@property (strong, nonatomic) IBOutlet UITextField *txtMinute;
@property (strong, nonatomic) IBOutlet UILabel *labelAlarmTime;
@property (strong, nonatomic) IBOutlet UILabel *labelRepeat;
@property (strong, nonatomic) IBOutlet UILabel *labelTomatoTips3;

@property (assign, nonatomic) OperationType operationType;
@property (strong, nonatomic) Task *task;

@end
