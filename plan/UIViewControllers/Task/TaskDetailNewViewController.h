//
//  TaskDetailNewViewController.h
//  plan
//
//  Created by Fengzy on 16/1/25.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import "Task.h"
#import "FatherViewController.h"

@interface TaskDetailNewViewController : FatherViewController

@property (strong, nonatomic) IBOutlet UITextView *txtViewContent;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewAlarm;
@property (strong, nonatomic) IBOutlet UILabel *labelAlram;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewRepeat;
@property (strong, nonatomic) IBOutlet UILabel *labelRepeat;
@property (strong, nonatomic) IBOutlet UILabel *labelFinishedTimes;
@property (strong, nonatomic) IBOutlet UITableView *tableRecord;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *layoutConstraintTxtViewBottom;
@property (strong, nonatomic) IBOutlet UIButton *btnStart;
@property (strong, nonatomic) Task *task;

@end
