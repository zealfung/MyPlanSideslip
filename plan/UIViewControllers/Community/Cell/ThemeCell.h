//
//  ThemeCell.h
//  plan
//
//  Created by Fengzy on 16/7/27.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThemeCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UILabel *labelName;

+ (ThemeCell *)cellView;

@end
