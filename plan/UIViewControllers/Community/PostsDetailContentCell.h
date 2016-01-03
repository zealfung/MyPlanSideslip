//
//  PostsDetailContentCell.h
//  plan
//
//  Created by Fengzy on 16/1/2.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import "BmobQuery.h"
#import <UIKit/UIKit.h>

@interface PostsDetailContentCell : UITableViewCell

+ (PostsDetailContentCell *)cellView:(BmobObject *)posts;

@end
