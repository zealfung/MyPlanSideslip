//
//  TaskCell.h
//  plan
//
//  Created by Fengzy on 15/11/29.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "Task.h"
#import <UIKit/UIKit.h>

@interface TaskCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelTask;
@property (strong, nonatomic) IBOutlet UIButton *btnCount;
@property (strong, nonatomic) Task *task;

+ (TaskCell *)cellView:(Task *)task;

@end
