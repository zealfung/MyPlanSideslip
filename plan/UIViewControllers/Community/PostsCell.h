//
//  PostsCell.h
//  plan
//
//  Created by Fengzy on 15/12/20.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThreeSubView.h"

@interface PostsCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelIsTop;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewAvatar;
@property (strong, nonatomic) IBOutlet UILabel *labelNickName;
@property (strong, nonatomic) IBOutlet UILabel *labelPostTime;
@property (strong, nonatomic) IBOutlet UILabel *labelContent;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewOne;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewTwo;
@property (strong, nonatomic) IBOutlet ThreeSubView *subViewButton;


+ (PostsCell *)cellView;

@end
