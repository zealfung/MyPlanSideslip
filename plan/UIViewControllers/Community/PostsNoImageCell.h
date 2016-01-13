//
//  PostsNoImageCell.h
//  plan
//
//  Created by Fengzy on 15/12/20.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThreeSubView.h"

typedef void(^PostsNoImageCellViewBlock)();
typedef void(^PostsNoImageCellCommentBlock)();
typedef void(^PostsNoImageCellLikeBlock)();

@interface PostsNoImageCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelIsTop;
@property (strong, nonatomic) IBOutlet UILabel *labelIsHighlight;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewAvatar;
@property (strong, nonatomic) IBOutlet ThreeSubView *subViewNickName;
@property (strong, nonatomic) IBOutlet UILabel *labelPostTime;
@property (strong, nonatomic) IBOutlet UILabel *labelContent;
@property (strong, nonatomic) IBOutlet ThreeSubView *subViewButton;
@property (strong, nonatomic) PostsNoImageCellViewBlock postsCellViewBlock;
@property (strong, nonatomic) PostsNoImageCellCommentBlock postsCellCommentBlock;
@property (strong, nonatomic) PostsNoImageCellLikeBlock postsCellLikeBlock;


+ (PostsNoImageCell *)cellView;

@end
