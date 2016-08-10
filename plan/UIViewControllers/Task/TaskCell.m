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
        [cellView.imgViewAlarm setVisibility:UIViewVisibilityGone affectedMarginDirections:UIViewMarginDirectionRight];
    }
//    if (![task.isTomato isEqualToString:@"1"]) {
        [cellView.imgViewTomato setVisibility:UIViewVisibilityGone affectedMarginDirections:UIViewMarginDirectionAll];
//    }
    
    NSString *date = [CommonFunction NSDateToNSString:[NSDate date] formatter:str_DateFormatter_yyyy_MM_dd];
    if (
//        [task.isTomato isEqualToString:@"0"]
//        &&
        [task.completionDate isEqualToString:date]) {
        
        cellView.labelTask.textColor = color_0BA32A;
    }
    return cellView;
}

@end
