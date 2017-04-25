//
//  PlanAddCell.m
//  plan
//
//  Created by Fengzy on 2017/4/24.
//  Copyright © 2017年 Fengzy. All rights reserved.
//

#import "PlanAddCell.h"

@implementation PlanAddCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

+ (PlanAddCell *)cellView
{
    PlanAddCell *cell = [[NSBundle mainBundle] loadNibNamed:@"PlanAddCell" owner:self options:nil].lastObject;
    cell.textView.textColor = color_333333;
    cell.textView.font = font_Normal_16;
    return cell;
}

@end
