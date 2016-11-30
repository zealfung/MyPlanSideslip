//
//  PostsOneImageCell.m
//  plan
//
//  Created by Fengzy on 15/12/20.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "PostsOneImageCell.h"

@implementation PostsOneImageCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

+ (PostsOneImageCell *)cellView {
    PostsOneImageCell *cellView = [[NSBundle mainBundle] loadNibNamed:@"PostsOneImageCell" owner:self options:nil].lastObject;
    
    cellView.imgViewAvatar.clipsToBounds = YES;
    cellView.imgViewAvatar.layer.borderWidth = 1;
    cellView.imgViewAvatar.layer.borderColor = [color_dedede CGColor];
    cellView.imgViewAvatar.contentMode = UIViewContentModeScaleAspectFit;
    cellView.imgViewAvatar.layer.cornerRadius = 15.f;
    cellView.labelIsTop.hidden = YES;
    cellView.labelIsHighlight.hidden = YES;
    
    UITapGestureRecognizer *viewEyeTapRecognizer;
    viewEyeTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:cellView action:@selector(viewEyeTap:)];
    viewEyeTapRecognizer.numberOfTapsRequired = 1;
    [cellView.viewEye addGestureRecognizer:viewEyeTapRecognizer];
    
    UITapGestureRecognizer *viewCommentTapRecognizer;
    viewCommentTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:cellView action:@selector(viewCommentTap:)];
    viewCommentTapRecognizer.numberOfTapsRequired = 1;
    [cellView.viewComment addGestureRecognizer:viewCommentTapRecognizer];
    
    UITapGestureRecognizer *viewLikeTapRecognizer;
    viewLikeTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:cellView action:@selector(viewLikeTap:)];
    viewLikeTapRecognizer.numberOfTapsRequired = 1;
    [cellView.viewLike addGestureRecognizer:viewLikeTapRecognizer];
    
    return cellView;
}

- (IBAction)userLevelClickedAction:(id)sender {
    if (self.postsCellLevelBlock) {
        self.postsCellLevelBlock ();
    }
}

- (void)viewEyeTap:(UITapGestureRecognizer*)recognizer {
    if (self.postsCellViewBlock) {
        self.postsCellViewBlock ();
    }
}

- (void)viewCommentTap:(UITapGestureRecognizer*)recognizer {
    if (self.postsCellCommentBlock) {
        self.postsCellCommentBlock ();
    }
}

- (void)viewLikeTap:(UITapGestureRecognizer*)recognizer {
    if (self.postsCellLikeBlock) {
        self.postsCellLikeBlock ();
    }
}

@end
