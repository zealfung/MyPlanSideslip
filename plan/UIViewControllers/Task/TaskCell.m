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
    cellView.labelTask.text = task.content;
    cellView.task = task;
    if (![task.isNotify isEqualToString:@"1"]) {
        cellView.imgViewAlarm.hidden = YES;
    }
    if (![task.isTomato isEqualToString:@"1"]) {
        cellView.imgViewTomato.hidden = YES;
    }
    return cellView;
}

@end
