//
//  PhotoCell.h
//  plan
//
//  Created by Fengzy on 15/10/6.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "Photo.h"
#import <UIKit/UIKit.h>

extern CGFloat kPhotoCellHeight;

@interface PhotoCell : UITableViewCell

+ (PhotoCell *)cellView:(Photo *)photo;

@end
