//
//  PostsDetailViewController.m
//  plan
//
//  Created by Fengzy on 15/12/27.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "LogIn.h"
#import "ShareCenter.h"
#import "BmobRelation.h"
#import "DOPNavbarMenu.h"
#import "SDPhotoBrowser.h"
#import "LogInViewController.h"
#import "PostsDetailViewController.h"

NSInteger const kDeleteTag = 20160110;

@interface PostsDetailViewController () <UITextViewDelegate, DOPNavbarMenuDelegate, SDPhotoBrowserDelegate> {
    
    NSInteger numberOfItemsInRow;
    DOPNavbarMenu *menu;
    CGFloat cell0Height;
    NSMutableArray *imgArray;
    NSArray *imgURLArray;
    NSArray *commentsArray;
    NSInteger checkLikeCount;
    BmobObject *selectedComment;
    NSInteger postImgDownloadCount;
    BOOL isAuthor;
    BOOL isAnding;
}

@end

@implementation PostsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isAuthor = [self checkIsAuthor];
    [self createNavBarButton];
    
    commentsArray = [NSArray array];
    [self createDetailHeaderView];
    [self getCommets];
    [self downloadPostImages];
    [self createBottomBtnView];

    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTouch)];
    [recognizer setNumberOfTapsRequired:1];
    [recognizer setNumberOfTouchesRequired:1];
    self.scrollView.delegate = self;
    [self.scrollView addGestureRecognizer:recognizer];
    
    self.inputView.placeholderFont = font_Normal_16;
    self.inputView.returnKeyType = UIReturnKeySend;
    [self.inputView setBorderWidth:1.0f andColor:color_eeeeee];
    self.inputView.backgroundColor = color_F2F3F5;
    [self.inputView setUpWithPlaceholder:str_PostsDetail_Comment_Tips1];
    self.inputView.delegate = self;
    self.inputView.hidden = YES;
    self.inputViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.inputView attribute:NSLayoutAttributeHeight         relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil         attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:[self minimumInputbarHeight]];
    [self.view addSubview:self.inputView];
    [self.view addConstraint:self.inputViewHeightConstraint];
    
    [NotificationCenter addObserver:self selector:@selector(refreshCommentsAndBottomBtn) name:Notify_LogIn object:nil];
    [NotificationCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [NotificationCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [NotificationCenter addObserver:self selector:@selector(textDidUpdate:)    name:UITextViewTextDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.menu) {
        [self.menu dismissWithAnimation:NO];
    }
}

- (void)createNavBarButton {
    numberOfItemsInRow = 3;
    self.rightBarButtonItem = [self createBarButtonItemWithNormalImageName:png_Btn_More selectedImageName:png_Btn_More selector:@selector(openMenu:)];
}

- (DOPNavbarMenu *)menu {
    if (menu == nil) {
        DOPNavbarMenuItem *itemRefresh = [DOPNavbarMenuItem ItemWithTitle:str_Refresh icon:[UIImage imageNamed:png_Btn_Refresh]];
        DOPNavbarMenuItem *itemShare = [DOPNavbarMenuItem ItemWithTitle:str_Share icon:[UIImage imageNamed:png_Btn_Share66]];
        NSString *reportTitle = isAuthor ? str_Delete : str_Report;
        NSString *reportIcon = isAuthor ? png_Btn_Delete66 : png_Btn_Report;
        DOPNavbarMenuItem *itemReport = [DOPNavbarMenuItem ItemWithTitle:reportTitle icon:[UIImage imageNamed:reportIcon]];
        menu = [[DOPNavbarMenu alloc] initWithItems:@[itemRefresh,itemShare,itemReport] width:self.view.dop_width maximumNumberInRow:numberOfItemsInRow];
        menu.backgroundColor = [CommonFunction getGenderColor];
        menu.separatarColor = [UIColor whiteColor];
        menu.delegate = self;
    }
    return menu;
}

- (void)openMenu:(id)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    if (self.menu.isOpen) {
        [self.menu dismissWithAnimation:YES];
    } else {
        [self.menu showInNavigationController:self.navigationController];
    }
}

- (void)didShowMenu:(DOPNavbarMenu *)menu {
}

- (void)didDismissMenu:(DOPNavbarMenu *)menu {
}

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index {
    switch (index) {
        case 0:
            [self refreshAction];
            break;
        case 1:
            [self shareAction];
            break;
        case 2:
        {
            if (isAuthor) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:str_Posts_Delete message:str_PostsList_Tips2 delegate:self cancelButtonTitle:str_Cancel otherButtonTitles:str_OK, nil];
                alertView.tag = kDeleteTag;
                [alertView show];
            } else {
                [self reportPostsAction];
            }
        }
            break;
        default:
            break;
    }
}

//检查是否是楼主
- (BOOL)checkIsAuthor {
    if ([LogIn isLogin]) {
        BmobObject *postsAuthor = [self.posts objectForKey:@"author"];
        NSString *postsUserObjectId = [postsAuthor objectForKey:@"userObjectId"];
        BmobUser *user = [BmobUser getCurrentUser];
        if ([postsUserObjectId isEqualToString:user.objectId]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

- (void)createDetailView {
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSString *content = [self.posts objectForKey:@"content"];
    CGFloat yOffset = 10;
    if (content && content.length > 0) {
        UITextView *contentView = [[UITextView alloc] initWithFrame:CGRectMake(5, yOffset, WIDTH_FULL_SCREEN - 10, 240)];
        contentView.textColor = color_333333;
        contentView.font = font_Normal_16;
        contentView.editable = NO;
        contentView.scrollEnabled = NO;
        contentView.text = content;
        [contentView sizeToFit];
        [self.scrollView addSubview:contentView];
        
        yOffset = contentView.frame.size.height + 20;
    }
    
    if (imgArray && imgArray.count > 0) {
        for (NSInteger i=0; i < imgArray.count; i++) {
            UIImage *image = imgArray[i];
            CGFloat kWidth = WIDTH_FULL_SCREEN - 10;
            CGFloat kHeight = WIDTH_FULL_SCREEN * image.size.height / image.size.width;
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, yOffset, kWidth, kHeight)];
            imageView.backgroundColor = [UIColor clearColor];
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.tag = i;
            imageView.image = image;
            imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedImageAction:)];
            [imageView addGestureRecognizer:singleTap];
            
            [self.scrollView addSubview:imageView];
            yOffset += kHeight + 3;
        }
    }
    
    if (yOffset < 200) {
        yOffset = 200;
    } else {
        yOffset += 20;
    }

    //评论区标题
    UILabel *labelCommentTitle = [[UILabel alloc] initWithFrame:CGRectMake(12, yOffset, 30, 20)];
    [labelCommentTitle setTextColor:color_666666];
    [labelCommentTitle setFont:font_Normal_13];
    [labelCommentTitle setText:str_Comment];
    [self.scrollView addSubview:labelCommentTitle];
    //分割线
    UILabel *labelLine = [[UILabel alloc] initWithFrame:CGRectMake(12 + 30, yOffset + 9.5, WIDTH_FULL_SCREEN - 24 - 30, 1)];
    [labelLine setBackgroundColor:color_dedede];
    [self.scrollView addSubview:labelLine];
    yOffset += 20 + 5;

    if (commentsArray.count > 0) {
        for (NSInteger i=0; i< commentsArray.count; i++) {
            BmobObject *obj = commentsArray[i];
            UIView *viewComment = [self createCommentView:obj index:i];
            CGRect frame = viewComment.frame;
            frame.origin.y = yOffset;
            viewComment.frame = frame;
            [self.scrollView addSubview:viewComment];
            yOffset += frame.size.height;
        }
    } else {
        UILabel *labelNoComment = [[UILabel alloc] initWithFrame:CGRectMake(12, yOffset, WIDTH_FULL_SCREEN - 24, 100)];
        [labelNoComment setTextColor:color_666666];
        [labelNoComment setFont:font_Normal_16];
        labelNoComment.textAlignment = NSTextAlignmentCenter;
        [labelNoComment setText:str_PostsDetail_Comment_Tips2];
        [self.scrollView addSubview:labelNoComment];
        yOffset += 100;
    }
    yOffset += 20;
    
    if (yOffset < HEIGHT_FULL_VIEW) {
        yOffset = HEIGHT_FULL_VIEW;
    }
    [self.scrollView setContentSize:CGSizeMake(WIDTH_FULL_SCREEN, yOffset)];
}

- (CGSize)contentSizeOfTextView:(UITextView *)textView {
    CGSize textViewSize = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, FLT_MAX)];
    return textViewSize;
}

- (void)createDetailHeaderView {
    BmobObject *author = [self.posts objectForKey:@"author"];
    NSString *nickName = [author objectForKey:@"nickName"];
    NSString *gender = [author objectForKey:@"gender"];
    NSString *level = [author objectForKey:@"level"];
    if (!nickName || nickName.length == 0) {
        nickName = str_NickName;
    }
    NSString *avatarURL = [author objectForKey:@"avatarURL"];
    NSString *isHighlight = [self.posts objectForKey:@"isHighlight"];
    
    //图像
    UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 5, 38, 38)];
    avatarView.layer.cornerRadius = 19;
    avatarView.clipsToBounds = YES;
    [avatarView sd_setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed:png_AvatarDefault1]];
    avatarView.contentMode = UIViewContentModeScaleAspectFit;
    [self.headerView addSubview:avatarView];
    //昵称
    ThreeSubView *tsViewNickname = [[ThreeSubView alloc] initWithFrame:CGRectMake(53, 5, WIDTH_FULL_SCREEN - 69, 18) leftButtonSelectBlock:^{
        
    } centerButtonSelectBlock:^{
        
    } rightButtonSelectBlock:^{
        
    }];
    [tsViewNickname.leftButton.titleLabel setFont:font_Normal_16];
    if (!gender || [gender isEqualToString:@"1"]) {
        [tsViewNickname.leftButton setAllTitleColor:color_Blue];
    } else {
        [tsViewNickname.leftButton setAllTitleColor:color_Pink];
    }
    [tsViewNickname.leftButton setAllTitle:nickName];
    tsViewNickname.leftButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    if (level) {
        tsViewNickname.centerButton.enabled = NO;
        tsViewNickname.centerButton.adjustsImageWhenDisabled = NO;
        [tsViewNickname.centerButton setImage:[CommonFunction getUserLevelIcon:level] forState:UIControlStateNormal];
    }
    
    tsViewNickname.fixCenterWidth = 18;
    [tsViewNickname autoLayout];
    [self.headerView addSubview:tsViewNickname];
    //发表时间
    UILabel *labelDate = [[UILabel alloc] initWithFrame:CGRectMake(53, 23, WIDTH_FULL_SCREEN / 2, 20)];
    labelDate.textColor = color_666666;
    labelDate.font = font_Normal_13;
    labelDate.text = [CommonFunction intervalSinceNow:self.posts.createdAt];
    [self.headerView addSubview:labelDate];
    //精华帖
    if ([isHighlight isEqualToString:@"1"]) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH_FULL_SCREEN - 35, 5, 30, 20)];
        btn.layer.cornerRadius = 5;
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = [color_Blue CGColor];
        [btn setAllTitle:str_Highlight];
        [btn setAllTitleColor:color_Blue];
        btn.titleLabel.font = font_Normal_13;
        [self.headerView addSubview:btn];
    }
}

- (UIView *)createCommentView:(BmobObject *)comment index:(NSInteger)index {
    BmobObject *commentAuthor = [comment objectForKey:@"author"];
    NSString *nickName = [commentAuthor objectForKey:@"nickName"];
    NSString *gender = [commentAuthor objectForKey:@"gender"];
    NSString *level = [commentAuthor objectForKey:@"level"];
    if (!nickName || nickName.length == 0) {
        nickName = str_NickName;
    }
    NSString *avatarURL = [commentAuthor objectForKey:@"avatarURL"];
    NSInteger likesCount = [[comment objectForKey:@"likesCount"] integerValue];
    BOOL isLike = NO;
    if ([LogIn isLogin]) {
        isLike = [[comment objectForKey:@"isLike"] boolValue];
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_FULL_SCREEN, 85)];
    //图像
    UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 2.5, 25, 25)];
    avatarView.layer.cornerRadius = 12.5;
    avatarView.clipsToBounds = YES;
    [avatarView sd_setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed:png_AvatarDefault1]];
    avatarView.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:avatarView];
    //昵称
    ThreeSubView *tsViewNickname = [[ThreeSubView alloc] initWithFrame:CGRectMake(40, 0, WIDTH_FULL_SCREEN - 159, 15) leftButtonSelectBlock:^{
        
    } centerButtonSelectBlock:^{
        
    } rightButtonSelectBlock:^{
        
    }];
    [tsViewNickname.leftButton.titleLabel setFont:font_Normal_13];
    if (!gender || [gender isEqualToString:@"1"]) {
        [tsViewNickname.leftButton setAllTitleColor:color_Blue];
    } else {
        [tsViewNickname.leftButton setAllTitleColor:color_Pink];
    }
    [tsViewNickname.leftButton setAllTitle:nickName];
    tsViewNickname.leftButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    [tsViewNickname.centerButton.titleLabel setFont:font_Normal_11];
    [tsViewNickname.centerButton setAllTitleColor:color_666666];
    tsViewNickname.centerButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    if (level) {
        tsViewNickname.centerButton.enabled = NO;
        tsViewNickname.centerButton.adjustsImageWhenDisabled = NO;
        [tsViewNickname.centerButton setImage:[CommonFunction getUserLevelIcon:level] forState:UIControlStateNormal];
        tsViewNickname.fixCenterWidth = 15;
    } else {
        tsViewNickname.fixCenterWidth = 0;
    }
    
    //楼主
    BmobObject *postsAuthor = [self.posts objectForKey:@"author"];
    NSString *postsUserObjectId = [postsAuthor objectForKey:@"userObjectId"];
    NSString *commentUserObjectId = [commentAuthor objectForKey:@"userObjectId"];
    [tsViewNickname.rightButton.titleLabel setFont:font_Normal_11];
    [tsViewNickname.rightButton setAllTitleColor:color_666666];
    tsViewNickname.fixRightWidth = 30;
    tsViewNickname.rightButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    if ([postsUserObjectId isEqualToString:commentUserObjectId]) {
        [tsViewNickname.rightButton setAllTitle:str_Author];
    }
    [tsViewNickname autoLayout];
    [view addSubview:tsViewNickname];
    //赞、举报
    __weak typeof(self) weakSelf = self;
    ThreeSubView *tsViewLikes = [[ThreeSubView alloc] initWithFrame:CGRectMake(WIDTH_FULL_SCREEN - 12 - 90, 0, 90, 20) leftButtonSelectBlock:^{
        [weakSelf reportCommentAction:comment];
    } centerButtonSelectBlock:^{
        
    } rightButtonSelectBlock:^{
        if ([LogIn isLogin]) {
            if (isLike) {
                [weakSelf unlikeComment:comment];
            } else {
                [weakSelf likeComment:comment];
            }
        } else {
            [weakSelf toLogInView];
        }
        
    }];
    tsViewLikes.fixLeftWidth = 30;
    [tsViewLikes.leftButton.titleLabel setFont:font_Normal_11];
    [tsViewLikes.leftButton setAllTitleColor:color_8f8f8f];
    [tsViewLikes.leftButton setAllTitle:str_Report];
    tsViewLikes.leftButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    tsViewLikes.fixCenterWidth = 20;
    [tsViewLikes.centerButton.titleLabel setFont:font_Normal_11];
    [tsViewLikes.centerButton setAllTitleColor:color_666666];
    [tsViewLikes.centerButton setAllTitle:@""];

    tsViewLikes.fixRightWidth = 40;
    [tsViewLikes.rightButton.titleLabel setFont:font_Normal_11];
    [tsViewLikes.rightButton setAllTitle:str_Like];
    if (likesCount > 0) {
        [tsViewLikes.rightButton setAllTitle:[NSString stringWithFormat:@"%@%@", [CommonFunction checkNumberForThousand:likesCount], str_Like]];
    } else {
        [tsViewLikes.rightButton setAllTitle:str_Like];
    }
    if (isLike) {
        tsViewLikes.rightButton.selected = YES;
        [tsViewLikes.rightButton setAllTitleColor:color_Red];
        tsViewLikes.rightButton.layer.borderColor = [color_Red CGColor];
    } else {
        tsViewLikes.rightButton.selected = NO;
        [tsViewLikes.rightButton setAllTitleColor:color_666666];
        tsViewLikes.rightButton.layer.borderColor = [color_666666 CGColor];
    }
    tsViewLikes.rightButton.layer.cornerRadius = 5;
    tsViewLikes.rightButton.layer.borderWidth = 0.5;
    tsViewLikes.rightButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [tsViewLikes autoLayout];
    [view addSubview:tsViewLikes];
    //发表时间
    UILabel *labelDate = [[UILabel alloc] initWithFrame:CGRectMake(40, 15, WIDTH_FULL_SCREEN / 2, 15)];
    labelDate.textColor = color_666666;
    labelDate.font = font_Normal_11;
    labelDate.text = [CommonFunction intervalSinceNow:comment.createdAt];
    [view addSubview:labelDate];

    CGFloat yOffset = 35;
    
    //回复XX
    BmobObject *replyAuthor = [comment objectForKey:@"replyAuthor"];
    NSString *replyNickName = [replyAuthor objectForKey:@"nickName"];
    if (replyNickName && replyNickName.length > 0) {
        UILabel *labelReply = [[UILabel alloc] initWithFrame:CGRectMake(12, yOffset, WIDTH_FULL_SCREEN / 2, 20)];
        labelReply.textColor = color_666666;
        labelReply.font = font_Normal_13;
        labelReply.text = [NSString stringWithFormat:@"%@ %@：", str_Reply, replyNickName];
        [view addSubview:labelReply];
        yOffset += 25;
    }
    
    NSString *content = [comment objectForKey:@"content"];
    UILabel *labelContent = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
    [labelContent setNumberOfLines:0];
    labelContent.lineBreakMode = NSLineBreakByWordWrapping;
    [labelContent setTextColor:color_333333];
    UIFont *font = font_Normal_13;
    [labelContent setFont:font];
    [labelContent setText:content];
    CGSize size = CGSizeMake(WIDTH_FULL_SCREEN - 24, 2000);
    CGSize labelsize = [content sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    labelContent.frame = CGRectMake(12, yOffset, labelsize.width, labelsize.height);
    [view addSubview:labelContent];
    yOffset += labelsize.height + 5;
    
    //分隔线
    UILabel *labelLine = [[UILabel alloc] initWithFrame:CGRectMake(12, yOffset, WIDTH_FULL_SCREEN - 24, 1)];
    labelLine.backgroundColor = color_dedede;
    [view addSubview:labelLine];
    
    yOffset += 5;
    
    CGRect frame = view.frame;
    frame.size.height = yOffset;
    view.frame = frame;
    
    //添加单击事件
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(replyCommentAction:)];
    [recognizer setNumberOfTapsRequired:1];
    [recognizer setNumberOfTouchesRequired:1];
    view.tag = index;
    [view addGestureRecognizer:recognizer];
    
    return view;
}

- (void)createBottomBtnView {
    __weak typeof(self) weakSelf = self;
    [self getThreeSubViewForLeftBlock: ^{
        [weakSelf likeAction];
    } centerBlock:^{
        
    } rightBlock: ^{
        selectedComment = nil;
        [weakSelf commentAction];
    }];
    
    [self.bottomBtnView autoLayout];
    
    BOOL isLike = NO;
    if ([LogIn isLogin]) {
        isLike = [[self.posts objectForKey:@"isLike"] boolValue];
    }
    if (isLike) {
        self.bottomBtnView.leftButton.selected = YES;
        [self.bottomBtnView.leftButton setAllTitleColor:color_Red];
    }
    NSInteger likesCount = [[self.posts objectForKey:@"likesCount"] integerValue];
    [self.bottomBtnView.leftButton setAllTitle:[CommonFunction checkNumberForThousand:likesCount]];
}

- (void)getThreeSubViewForLeftBlock:(ButtonSelectBlock)leftBlock centerBlock:(ButtonSelectBlock)centerBlock rightBlock:(ButtonSelectBlock)rightBlock {
    
    [self.bottomBtnView setLeftButtonSelectBlock:leftBlock centerButtonSelectBlock:centerBlock rightButtonSelectBlock:rightBlock];
    
    self.bottomBtnView.backgroundColor = color_e9eff1;
    CGFloat btnWidth = WIDTH_FULL_SCREEN / 2 - 10;
    
    self.bottomBtnView.fixLeftWidth = btnWidth;
    self.bottomBtnView.fixCenterWidth = 10;
    self.bottomBtnView.fixRightWidth = btnWidth;
    
    [self.bottomBtnView.leftButton setImage:[UIImage imageNamed:png_Icon_Posts_Praise_Normal] forState:UIControlStateNormal];
    [self.bottomBtnView.leftButton setImage:[UIImage imageNamed:png_Icon_Posts_Praise_Selected] forState:UIControlStateSelected];
    
    [self.bottomBtnView.centerButton setAllTitle:@"|"];
    
    [self.bottomBtnView.rightButton setImage:[UIImage imageNamed:png_Icon_Posts_Comment] forState:UIControlStateNormal];
    [self.bottomBtnView.rightButton setImage:[UIImage imageNamed:png_Icon_Posts_Comment] forState:UIControlStateSelected];
    [self.bottomBtnView.rightButton setAllTitle:str_Reply];
    
    self.bottomBtnView.leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.bottomBtnView.centerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.bottomBtnView.rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.bottomBtnView.leftButton.titleLabel.font = font_Normal_13;
    self.bottomBtnView.centerButton.titleLabel.font = font_Normal_14;
    self.bottomBtnView.rightButton.titleLabel.font = font_Normal_14;
    self.bottomBtnView.leftButton.titleLabel.textAlignment = NSTextAlignmentRight;
    [self.bottomBtnView.leftButton setAllTitleColor:color_8f8f8f];
    [self.bottomBtnView.centerButton setAllTitleColor:color_8f8f8f];
    [self.bottomBtnView.rightButton setAllTitleColor:color_8f8f8f];
}

- (void)refreshCommentsAndBottomBtn {
    [self getCommets];
    [self createBottomBtnView];
}

- (void)getCommets {
    if (isAnding) return;
    
    [self showHUD];
    __weak typeof(self) weakSelf = self;
    //关联评论表
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Comments"];
    [bquery includeKey:@"author,replyAuthor"];
    [bquery whereKey:@"isDeleted" equalTo:@"0"];
    //需要查询的列
    BmobObject *post = [BmobObject objectWithoutDatatWithClassName:@"Posts" objectId:self.posts.objectId];
    [bquery whereObjectKey:@"comments" relatedTo:post];
    [bquery orderByDescending:@"createdAt"];
    //查询该联系所有关联的评论
    isAnding = YES;
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        isAnding = NO;
        if (error) {
            NSLog(@"%@",error);
            [weakSelf hideHUD];
            [weakSelf createDetailView];
        } else {
            commentsArray = [NSArray arrayWithArray:array];
            [weakSelf checkIsLike];
        }
    }];
}

- (void)checkIsLike {
    if ([LogIn isLogin] && commentsArray.count > 0) {
        checkLikeCount = 0;
        for (NSInteger i=0; i < commentsArray.count; i++) {
            [self isLikedComment:commentsArray[i]];
        }
    } else {
        [self hideHUD];
        [self createDetailView];
    }
}

- (void)isLikedComment:(BmobObject *)comment {
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Comments"];
    BmobQuery *inQuery = [BmobQuery queryWithClassName:@"UserSettings"];
    BmobUser *user = [BmobUser getCurrentUser];
    [inQuery whereKey:@"userObjectId" equalTo:user.objectId];
    //匹配查询
    [bquery whereKey:@"likes" matchesQuery:inQuery];//（查询所有有关联的数据）
    [bquery whereKey:@"objectId" equalTo:comment.objectId];
    __weak typeof(self) weakSelf = self;
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (!error && array.count > 0) {
            [comment setObject:@(YES) forKey:@"isLike"];
        } else {
            [comment setObject:@(NO) forKey:@"isLike"];
        }
        
        checkLikeCount ++;
        if (checkLikeCount == commentsArray.count) {
            [weakSelf hideHUD];
            [weakSelf createDetailView];
        }
    }];
}

- (void)downloadPostImages {
    imgURLArray = [NSArray arrayWithArray:[self.posts objectForKey:@"imgURLArray"]];
    if (imgURLArray && imgURLArray.count > 0) {
        
        imgArray = [NSMutableArray array];
        postImgDownloadCount = 0;
        for (NSInteger i=0; i < imgURLArray.count; i++) {

            if ([imgURLArray[i] isKindOfClass:[NSString class]]) {
                
                [self downloadImages:imgURLArray[i] index:i];
            }
        }
    }
}

- (void)downloadImages:(NSString *)imgURL index:(NSInteger)index {
    UIImage *imgDefault = [UIImage imageNamed:png_ImageDefault_Rectangle];
    [imgArray addObject:imgDefault];
    NSURL *URL = [NSURL URLWithString:imgURLArray[index]];
    
    CGFloat kWidth = WIDTH_FULL_SCREEN - 10;
    CGFloat kHeight = WIDTH_FULL_SCREEN * imgDefault.size.height / imgDefault.size.width;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, kWidth, kHeight)];
    __weak typeof(self) weakSelf = self;
    [imageView sd_setImageWithURL:URL placeholderImage:imgArray[index] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        postImgDownloadCount ++;
        
        if (!error && image) {
            imgArray[index] = image;
        }
        if (postImgDownloadCount == imgURLArray.count) {
            [weakSelf createDetailView];
        }
    }];
}

- (void)likeAction {
    if ([LogIn isLogin]) {
        self.bottomBtnView.leftButton.selected = !self.bottomBtnView.leftButton.selected;
        if (self.bottomBtnView.leftButton.selected) {
            [self likePosts:self.posts];
            NSInteger likesCount = [[self.posts objectForKey:@"likesCount"] integerValue];
            likesCount += 1;
            [self.bottomBtnView.leftButton setAllTitle:[CommonFunction checkNumberForThousand:likesCount]];
            [self.bottomBtnView.leftButton setAllTitleColor:color_Red];
        } else {
            [self unlikePosts:self.posts];
            NSInteger likesCount = [[self.posts objectForKey:@"likesCount"] integerValue];
            likesCount -= 1;
            [self.bottomBtnView.leftButton setAllTitle:[CommonFunction checkNumberForThousand:likesCount]];
            [self.bottomBtnView.leftButton setAllTitleColor:color_8f8f8f];
        }
    } else {
        [self toLogInView];
    }
}

- (void)commentAction {
    if ([LogIn isLogin]) {
        if (selectedComment) {
            BmobObject *commentAuthor = [selectedComment objectForKey:@"author"];
            NSString *nickName = [commentAuthor objectForKey:@"nickName"];
            if (nickName && nickName.length > 0) {
                self.inputView.placeholder = [NSString stringWithFormat:@"%@ %@：", str_Reply, nickName];
            }
        } else {
            self.inputView.placeholder = str_PostsDetail_Comment_Tips1;
        }
        [self.inputView becomeFirstResponder];
    } else {
        [self toLogInView];
    }
}

- (void)replyCommentAction:(id)sender {
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    UIView *view = (UIView *)tap.view;
    NSInteger i = view.tag;
    if (i < commentsArray.count) {
        selectedComment = commentsArray[i];
    }
    [self commentAction];
}

- (void)clickedImageAction:(id)sender {
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    UIImageView *imgView = (UIImageView *)tap.view;

    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    browser.sourceImagesContainerView = self.scrollView;
    browser.imageCount = imgURLArray.count; //图片总数
    browser.currentImageIndex = imgView.tag;
    browser.delegate = self;
    [browser show];
}

- (void)refreshAction {
    [self getCommets];
}

- (void)shareAction {
    [ShareCenter showShareActionSheet:self.view title:str_Share_Tips3 content:[self.posts objectForKey:@"content"] shareUrl:@"" sharedImageURL:@""];
}

- (void)deleteAction {
    if (isAnding) return;
    
    [self showHUD];
    __weak typeof(self) weakSelf = self;
    BmobObject *post = [BmobObject objectWithoutDatatWithClassName:@"Posts" objectId:self.posts.objectId];
    [post setObject:@"1" forKey:@"isDeleted"];
    [post updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        isAnding = NO;
        [weakSelf hideHUD];
        if (isSuccessful) {
            [NotificationCenter postNotificationName:Notify_Posts_New object:nil];
            [weakSelf alertToastMessage:str_Delete_Success];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } else {
            [weakSelf alertButtonMessage:str_Delete_Fail];
        }
    }];
}

- (void)reportPostsAction {
    if (isAnding) return;
    
    [self showHUD];
    __weak typeof(self) weakSelf = self;
    BmobObject *newPosts = [BmobObject objectWithClassName:@"Report"];
    [newPosts setObject:@"1" forKey:@"reportType"];//举报类型：1帖子 2评论
    [newPosts setObject:self.posts.objectId forKey:@"reportId"];
    [newPosts setObject:@"0" forKey:@"isSolved"];
    if ([LogIn isLogin]) {
        BmobUser *user = [BmobUser getCurrentUser];
        [newPosts setObject:user.objectId forKey:@"reporterObjectId"];
    }
    isAnding = YES;
    //异步保存
    [newPosts saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        isAnding = NO;
        [weakSelf hideHUD];
        if (isSuccessful) {
            [weakSelf alertToastMessage:str_Report_Success];
        } else {
            [weakSelf alertButtonMessage:str_Report_Fail];
        }
    }];
}

- (void)reportCommentAction:(BmobObject *)comment {
    if (isAnding) return;
    
    [self showHUD];
    __weak typeof(self) weakSelf = self;
    BmobObject *newPosts = [BmobObject objectWithClassName:@"Report"];
    [newPosts setObject:@"2" forKey:@"reportType"];//举报类型：1帖子 2评论
    [newPosts setObject:comment.objectId forKey:@"reportId"];
    [newPosts setObject:@"0" forKey:@"isSolved"];
    if ([LogIn isLogin]) {
        BmobUser *user = [BmobUser getCurrentUser];
        [newPosts setObject:user.objectId forKey:@"reporterObjectId"];
    }
    isAnding = YES;
    //异步保存
    [newPosts saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        isAnding = NO;
        [weakSelf hideHUD];
        if (isSuccessful) {
            [weakSelf alertToastMessage:str_Report_Success];
        } else {
            [weakSelf alertButtonMessage:str_Report_Fail];
        }
    }];
}

- (void)likePosts:(BmobObject *)posts {
    if (isAnding) return;
    
    BmobObject *obj = [BmobObject objectWithoutDatatWithClassName:@"Posts" objectId:posts.objectId];
    [obj incrementKey:@"likesCount"];
    BmobRelation *relation = [[BmobRelation alloc] init];
    [relation addObject:[BmobObject objectWithoutDatatWithClassName:@"UserSettings" objectId:[Config shareInstance].settings.objectId]];
    [obj addRelation:relation forKey:@"likes"];
    isAnding = YES;
    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        isAnding = NO;
        if (isSuccessful) {
            NSInteger likesCount = [[posts objectForKey:@"likesCount"] integerValue];
            likesCount += 1;
            [posts setObject:@(likesCount) forKey:@"likesCount"];
            [posts setObject:@(YES) forKey:@"isLike"];
            [NotificationCenter postNotificationName:Notify_Posts_Refresh object:nil];
        }else{
            NSLog(@"error %@",[error description]);
        }
    }];
}

- (void)unlikePosts:(BmobObject *)posts {
    if (isAnding) return;
    
    BmobObject *obj = [BmobObject objectWithoutDatatWithClassName:@"Posts" objectId:posts.objectId];
    [obj decrementKey:@"likesCount"];
    BmobRelation *relation = [[BmobRelation alloc] init];
    [relation removeObject:[BmobObject objectWithoutDatatWithClassName:@"UserSettings" objectId:[Config shareInstance].settings.objectId]];
    [obj addRelation:relation forKey:@"likes"];
    isAnding = YES;
    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        isAnding = NO;
        if (isSuccessful) {
            NSInteger likesCount = [[posts objectForKey:@"likesCount"] integerValue];
            likesCount -= 1;
            [posts setObject:@(likesCount) forKey:@"likesCount"];
            [posts setObject:@(NO) forKey:@"isLike"];
            [NotificationCenter postNotificationName:Notify_Posts_Refresh object:nil];
        }else{
            NSLog(@"error %@",[error description]);
        }
    }];
}

- (void)likeComment:(BmobObject *)comment {
    if (isAnding) return;
    
    BmobObject *obj = [BmobObject objectWithoutDatatWithClassName:@"Comments" objectId:comment.objectId];
    [obj incrementKey:@"likesCount"];
    BmobRelation *relation = [[BmobRelation alloc] init];
    [relation addObject:[BmobObject objectWithoutDatatWithClassName:@"UserSettings" objectId:[Config shareInstance].settings.objectId]];
    [obj addRelation:relation forKey:@"likes"];
    isAnding = YES;
    __weak typeof(self) weakSelf = self;
    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        isAnding = NO;
        if (isSuccessful) {
            NSInteger likesCount = [[comment objectForKey:@"likesCount"] integerValue];
            likesCount += 1;
            [comment setObject:@(likesCount) forKey:@"likesCount"];
            [comment setObject:@(YES) forKey:@"isLike"];
            [weakSelf createDetailView];
            NSLog(@"successful");
        }else{
            NSLog(@"error %@",[error description]);
        }
    }];
}

- (void)unlikeComment:(BmobObject *)comment {
    if (isAnding) return;
    
    BmobObject *obj = [BmobObject objectWithoutDatatWithClassName:@"Comments" objectId:comment.objectId];
    [obj decrementKey:@"likesCount"];
    BmobRelation *relation = [[BmobRelation alloc] init];
    [relation removeObject:[BmobObject objectWithoutDatatWithClassName:@"UserSettings" objectId:[Config shareInstance].settings.objectId]];
    [obj addRelation:relation forKey:@"likes"];
    isAnding = YES;
    __weak typeof(self) weakSelf = self;
    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        isAnding = NO;
        if (isSuccessful) {
            NSInteger likesCount = [[comment objectForKey:@"likesCount"] integerValue];
            likesCount -= 1;
            [comment setObject:@(likesCount) forKey:@"likesCount"];
            [comment setObject:@(NO) forKey:@"isLike"];
            [weakSelf createDetailView];
            NSLog(@"successful");
        }else{
            NSLog(@"error %@",[error description]);
        }
    }];
}

- (void)toLogInView {
    LogInViewController *controller = [[LogInViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)scrollViewTouch {
    [self.view endEditing:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - textView的基本设置
- (GrowingTextView *)textView {
    return self.inputView;
}

- (CGFloat)minimumInputbarHeight {
    return self.bottomBtnView.frame.size.height;
}

- (CGFloat)deltaInputbarHeight {
    return self.bottomBtnView.frame.size.height - self.textView.font.lineHeight;
}

- (CGFloat)barHeightForLines:(NSUInteger)numberOfLines {
    CGFloat height = [self deltaInputbarHeight];
    height += roundf(self.textView.font.lineHeight * numberOfLines);
    return height;
}

#pragma mark - photobrowser代理方法
// 返回临时占位图片（即原来的小图）
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index {
    return imgArray[index];
}

// 返回高质量图片的url
- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index {
    NSString *urlStr = imgURLArray[index];
    return [NSURL URLWithString:urlStr];
}

#pragma mark - 调整bar的高度
- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardBounds = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.inputViewConstraint.constant = keyboardBounds.size.height;
    self.inputView.hidden = NO;
    [self setBottomBarHeight];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.inputViewConstraint.constant = 0;
    self.inputView.hidden = YES;
    [self setBottomBarHeight];
}

- (void)setBottomBarHeight {
    [self.view setNeedsUpdateConstraints];
    [UIView animateKeyframesWithDuration:0.25       //animationDuration
                                   delay:0
                                 options:7 << 16    //animationOptions
                              animations:^{
                                  [self.view layoutIfNeeded];
                              } completion:nil];
}

#pragma mark - 编辑框相关
- (void)textDidUpdate:(NSNotification *)notification {
    [self updateInputBarHeight];
}

- (void)updateInputBarHeight {
    CGFloat inputbarHeight = [self appropriateInputbarHeight];
    if (inputbarHeight != self.inputViewHeightConstraint.constant) {
        self.inputViewHeightConstraint.constant = inputbarHeight;
        [self.view layoutIfNeeded];
    }
}

- (CGFloat)appropriateInputbarHeight {
    CGFloat height = 0;
    CGFloat minimumHeight = [self minimumInputbarHeight];
    CGFloat newSizeHeight = [self.textView measureHeight];
    CGFloat maxHeight     = self.textView.maxHeight;
    
    self.textView.scrollEnabled = newSizeHeight >= maxHeight;
    
    if (newSizeHeight < minimumHeight) {
        height = minimumHeight;
    } else if (newSizeHeight < maxHeight) {
        height = newSizeHeight;
    } else {
        height = self.textView.maxHeight;;
    }
    return roundf(height);
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString: @"\n"]) {

        [self sendContent:textView.text];
        [self.view endEditing:YES];

        return NO;
    }
    return YES;
}

- (void)textViewDidEndEditing:(PlaceholderTextView *)textView {
    [textView checkShouldHidePlaceholder];
}

- (void)textViewDidChange:(PlaceholderTextView *)textView {
    [textView checkShouldHidePlaceholder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kDeleteTag && buttonIndex == 1) {
        [self deleteAction];
    }
}

- (void)sendContent:(NSString *)content {
    if (isAnding) return;
    
    __weak typeof(self) weakSelf = self;
    BmobObject *newComments = [BmobObject objectWithClassName:@"Comments"];
    [newComments setObject:content forKey:@"content"];
    [newComments setObject:@"0" forKey:@"isDeleted"];
    
    //新建relation对象
    BmobRelation *relation = [[BmobRelation alloc] init];
    [relation addObject:[BmobObject objectWithoutDatatWithClassName:@"Posts" objectId:self.posts.objectId]];
    //添加关联关系到readUser列中
    [newComments addRelation:relation forKey:@"posts"];
    
    //回复对象
    if (selectedComment) {
        BmobRelation *relationReply = [[BmobRelation alloc] init];
        [relationReply addObject:selectedComment];
        [newComments addRelation:relationReply forKey:@"comments"];

        BmobObject *replyAuthor = [selectedComment objectForKey:@"author"];
        [newComments setObject:replyAuthor forKey:@"replyAuthor"];
    }

    //设置评论关联的作者
    [Config shareInstance].settings = [PlanCache getPersonalSettings];
    BmobObject *author = [BmobObject objectWithoutDatatWithClassName:@"UserSettings" objectId:[Config shareInstance].settings.objectId];
    [newComments setObject:author forKey:@"author"];
    [self showHUD];
    isAnding = YES;
    //异步保存
    [newComments saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        [weakSelf hideHUD];
        isAnding = NO;
        
        if (isSuccessful) {
            //把评论关联到帖子的评论字段
            [weakSelf relationCommentToPost:newComments.objectId];

            //刷新帖子列表评论数
            NSInteger commentsCount = [[self.posts objectForKey:@"commentsCount"] integerValue];
            commentsCount += 1;
            [self.posts setObject:@(commentsCount) forKey:@"commentsCount"];
            [NotificationCenter postNotificationName:Notify_Posts_Refresh object:nil];
            
            [weakSelf alertToastMessage:str_Comment_Success];
            [weakSelf getCommets];
        } else {
            [weakSelf alertButtonMessage:str_Comment_Fail];
            NSLog(@"%@",error);
        }
    }];
    
    self.inputView.text = @"";
    NSLog(@"发送内容：%@", content);
}

- (void)relationCommentToPost:(NSString *)commentsObjectId {
    BmobObject *post = [BmobObject objectWithoutDatatWithClassName:@"Posts" objectId:self.posts.objectId];
    BmobRelation *relation = [[BmobRelation alloc] init];
    [relation addObject:[BmobObject objectWithoutDatatWithClassName:@"Comments" objectId:commentsObjectId]];
    [post addRelation:relation forKey:@"comments"];
    [post incrementKey:@"commentsCount"];
    [post setObject:[NSDate date] forKey:@"updatedTime"];
    [post updateInBackground];
}

@end
