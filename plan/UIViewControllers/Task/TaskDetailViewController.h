//
//  TaskDetailViewController.h
//  plan
//
//  Created by Fengzy on 16/1/25.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import "Task.h"
#import "FatherViewController.h"

@interface TaskDetailViewController : FatherViewController

@property (strong, nonatomic) IBOutlet UITextView *txtViewContent;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewTomato;
@property (strong, nonatomic) IBOutlet UILabel *labelTomato;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewAlarm;
@property (strong, nonatomic) IBOutlet UILabel *labelAlram;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewRepeat;
@property (strong, nonatomic) IBOutlet UILabel *labelRepeat;
@property (strong, nonatomic) IBOutlet UILabel *labelFinishedTimes;
@property (strong, nonatomic) IBOutlet UITableView *tableRecord;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imgViewAlarmConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *labelAlarmConstraint;
@property (strong, nonatomic) Task *task;

@end
