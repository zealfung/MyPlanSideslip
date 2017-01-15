//
//  TaskCell.m
//  plan
//
//  Created by Fengzy on 15/11/29.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "TaskCell.h"
#import "TaskRecord.h"
#import "UIView+Util.h"

@interface TaskCell ()

@property (strong, nonatomic) Task *task;

@end

@implementation TaskCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

+ (TaskCell *)cellView:(Task *)task
{
    TaskCell *cellView = [[NSBundle mainBundle] loadNibNamed:@"TaskCell" owner:self options:nil].lastObject;
    cellView.labelTask.text = task.content;
    cellView.task = [task copy];
    cellView.btnDone.clipsToBounds = YES;
    cellView.btnDone.layer.cornerRadius = cellView.btnDone.frame.size.width / 2;
    
    if (![task.isNotify isEqualToString:@"1"])
    {
        [cellView.imgViewAlarm setVisibility:UIViewVisibilityGone affectedMarginDirections:UIViewMarginDirectionRight];
    }

    [cellView.imgViewTomato setVisibility:UIViewVisibilityGone affectedMarginDirections:UIViewMarginDirectionAll];
    
    NSString *date = [CommonFunction NSDateToNSString:[NSDate date] formatter:STRDateFormatterType4];
    if ([task.completionDate isEqualToString:date])
    {
        cellView.labelTask.textColor = color_0BA32A;
        cellView.btnDone.enabled = NO;
        [cellView.btnDone setBackgroundColor:color_0BA32A];
        
    }
    else
    {
        cellView.btnDone.enabled = YES;
        [cellView.btnDone setBackgroundColor:color_57a4fe_05];
        
    }
    
    if (task.totalCount.length == 0
        || [task.totalCount integerValue] == 0)
    {
        [cellView.btnDone setAllTitle:@"0"];
    }
    else
    {
        [cellView.btnDone setAllTitle:task.totalCount];
    }
    
    return cellView;
}

- (IBAction)doneAction:(id)sender
{
    NSString *date = [CommonFunction NSDateToNSString:[NSDate date] formatter:STRDateFormatterType4];
    self.task.completionDate = date;
    NSString *count = self.task.totalCount;
    NSInteger totalCount = 0;
    if (count.length > 0)
    {
        totalCount = [count integerValue] + 1;
    }
    else
    {
        totalCount ++;
    }
    self.task.totalCount = [NSString stringWithFormat:@"%ld", (long)totalCount];
    NSString *time = [CommonFunction getTimeNowString];
    self.task.updateTime = time;
    
    TaskRecord *taskRecord = [[TaskRecord alloc] init];
    taskRecord.recordId = self.task.taskId;
    taskRecord.createTime = time;
    
    [PlanCache updateTaskCount:self.task];
    [PlanCache storeTaskRecord:taskRecord];
}

@end
