//
//  PostsOneImageCell.h
//  plan
//
//  Created by Fengzy on 15/12/20.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThreeSubView.h"

typedef void(^PostsOneImageCellLevelBlock)();
typedef void(^PostsOneImageCellViewBlock)();
typedef void(^PostsOneImageCellCommentBlock)();
typedef void(^PostsOneImageCellLikeBlock)();

@interface PostsOneImageCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelIsTop;
@property (strong, nonatomic) IBOutlet UILabel *labelIsHighlight;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewAvatar;
@property (weak, nonatomic) IBOutlet UILabel *labelNickName;
@property (weak, nonatomic) IBOutlet UIButton *btnUserLevel;
@property (strong, nonatomic) IBOutlet UILabel *labelPostTime;
@property (strong, nonatomic) IBOutlet UILabel *labelContent;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewOne;
@property (weak, nonatomic) IBOutlet UIView *viewEye;
@property (weak, nonatomic) IBOutlet UIView *viewComment;
@property (weak, nonatomic) IBOutlet UIView *viewLike;
@property (weak, nonatomic) IBOutlet UILabel *labelEye;
@property (weak, nonatomic) IBOutlet UILabel *labelComment;
@property (weak, nonatomic) IBOutlet UILabel *labelLike;
@property (weak, nonatomic) IBOutlet UIImageView *imgLike;
@property (assign, nonatomic) BOOL isLiked;

@property (strong, nonatomic) PostsOneImageCellLevelBlock postsCellLevelBlock;
@property (strong, nonatomic) PostsOneImageCellViewBlock postsCellViewBlock;
@property (strong, nonatomic) PostsOneImageCellCommentBlock postsCellCommentBlock;
@property (strong, nonatomic) PostsOneImageCellLikeBlock postsCellLikeBlock;


+ (PostsOneImageCell *)cellView;

@end
