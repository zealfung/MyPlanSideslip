//
//  ThemeCell.m
//  plan
//
//  Created by Fengzy on 16/7/27.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import "ThemeCell.h"

@implementation ThemeCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


+ (ThemeCell *)cellView {
    ThemeCell *cellView = [[NSBundle mainBundle] loadNibNamed:@"ThemeCell" owner:self options:nil].lastObject;
    
    cellView.imgView.clipsToBounds = YES;
//    cellView.imgView.layer.borderWidth = 1;
//    cellView.imgView.layer.borderColor = [color_dedede CGColor];
    cellView.imgView.contentMode = UIViewContentModeScaleAspectFill;
    cellView.imgView.layer.cornerRadius = 10;
    
    return cellView;
}

@end
