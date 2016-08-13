//
//  PersonalCenterTaskStatisticsViewController.h
//  plan
//
//  Created by Fengzy on 16/8/12.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import "FatherViewController.h"

@interface PersonalCenterTaskStatisticsViewController : FatherViewController

@property (strong, nonatomic) IBOutlet UIButton *btnLeft;
@property (strong, nonatomic) IBOutlet UIButton *btnRight;
@property (strong, nonatomic) IBOutlet UILabel *labelDate;
@property (strong, nonatomic) IBOutlet UITableView *tableStatistics;

@end
