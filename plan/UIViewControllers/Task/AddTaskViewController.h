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
@property (strong, nonatomic) IBOutlet UILabel *labelCountTips;
@property (strong, nonatomic) IBOutlet UIButton *btnCount;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) OperationType operationType;
@property (strong, nonatomic) Task *task;

@end
