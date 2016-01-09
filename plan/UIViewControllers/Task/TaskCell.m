//
//  TaskCell.m
//  plan
//
//  Created by Fengzy on 15/11/29.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "TaskCell.h"
#import "TaskRecord.h"

@implementation TaskCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

+ (TaskCell *)cellView:(Task *)task {
    TaskCell *cellView = [[NSBundle mainBundle] loadNibNamed:@"TaskCell" owner:self options:nil].lastObject;
    cellView.btnCount.layer.cornerRadius = 20;
    cellView.labelTask.text = task.content;
    cellView.task = task;
    NSString *date = [CommonFunction NSDateToNSString:[NSDate date] formatter:str_DateFormatter_yyyy_MM_dd];
    if ([task.completionDate isEqualToString:date]) {
        cellView.btnCount.enabled = NO;
        [cellView.btnCount setAllTitle:task.totalCount];
        [cellView.btnCount setBackgroundColor:color_0BA32A];
        cellView.btnCount.titleLabel.font = font_Bold_23;
    } else {
        cellView.btnCount.enabled = YES;
        [cellView.btnCount setAllTitle:str_Task_AddRecord];
        [cellView.btnCount setBackgroundColor:[CommonFunction getGenderColor]];
        cellView.btnCount.titleLabel.font = font_Bold_16;
    }
    
    return cellView;
}

- (IBAction)addAction:(id)sender {
    
    NSString *date = [CommonFunction NSDateToNSString:[NSDate date] formatter:str_DateFormatter_yyyy_MM_dd];
    self.task.completionDate = date;
    NSString *count = self.task.totalCount;
    NSInteger totalCount = 0;
    if (count.length > 0) {
        totalCount = [count integerValue] + 1;
    }
    self.task.totalCount = [NSString stringWithFormat:@"%ld", (long)totalCount];
    NSString *time = [CommonFunction getTimeNowString];
    self.task.updateTime = time;
    
    TaskRecord *taskRecord = [[TaskRecord alloc] init];
    taskRecord.recordId = self.task.taskId;
    taskRecord.createTime = time;
    
    [PlanCache storeTask:self.task];
    [PlanCache storeTaskRecord:taskRecord];
}

@end
