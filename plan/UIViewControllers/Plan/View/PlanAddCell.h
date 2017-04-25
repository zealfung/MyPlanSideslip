//
//  PlanAddCell.h
//  plan
//
//  Created by Fengzy on 2017/4/24.
//  Copyright © 2017年 Fengzy. All rights reserved.
//

#import "MPTextView.h"
#import <UIKit/UIKit.h>

@interface PlanAddCell : UITableViewCell

@property (weak, nonatomic) IBOutlet MPTextView *textView;

+ (PlanAddCell *)cellView;

@end
