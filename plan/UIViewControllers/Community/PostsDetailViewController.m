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
#import "LogInViewController.h"
#import "PostsDetailContentCell.h"
#import "PostsDetailViewController.h"

@interface PostsDetailViewController () <UITextViewDelegate, DOPNavbarMenuDelegate> {
    
    NSInteger numberOfItemsInRow;
    DOPNavbarMenu *menu;
    CGFloat cell0Height;
    NSArray *commentsArray;
    NSInteger checkLikeCount;
    BmobObject *selectedComment;
    BOOL isAnding;
}

@end

@implementation PostsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavBarButton];
    
    commentsArray = [NSArray array];
    [self createDetailHeaderView];
    [self getCommets];
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
        DOPNavbarMenuItem *itemRefresh = [DOPNavbarMenuItem ItemWithTitle:@"刷新" icon:[UIImage imageNamed:png_Btn_Refresh]];
        DOPNavbarMenuItem *itemShare = [DOPNavbarMenuItem ItemWithTitle:@"分享" icon:[UIImage imageNamed:png_Btn_Share66]];
        DOPNavbarMenuItem *itemReport = [DOPNavbarMenuItem ItemWithTitle:@"举报" icon:[UIImage imageNamed:png_Btn_Report]];
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
            [self reportPostsAction];
            break;
        default:
            break;
    }
}

- (void)createDetailView {
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    NSString *content = [self.posts objectForKey:@"content"];
    CGFloat yOffset = 10;
    if (content && content.length > 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
        [label setNumberOfLines:0];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        [label setTextColor:color_333333];
        UIFont *font = font_Normal_16;
        [label setFont:font];
        [label setText:content];
        CGSize size = CGSizeMake(WIDTH_FULL_SCREEN - 24, 2000);
        CGSize labelsize = [content sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
        label.frame = CGRectMake(12, yOffset, labelsize.width, labelsize.height);
        [self.scrollView addSubview:label];
        yOffset = labelsize.height + 20;
    }
    NSArray *imgURLArray = [NSArray arrayWithArray:[self.posts objectForKey:@"imgURLArray"]];
    if (imgURLArray && imgURLArray.count > 0) {
        
        for (NSInteger i=0; i < imgURLArray.count; i++) {
            NSURL *URL = nil;
            if ([imgURLArray[i] isKindOfClass:[NSString class]]) {
                URL = [NSURL URLWithString:imgURLArray[i]];
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
                NSString *pathExtendsion = [URL.pathExtension lowercaseString];
                
                CGSize size = CGSizeZero;
                if ([pathExtendsion isEqualToString:@"png"]) {
                    size =  [CommonFunction getPNGImageSizeWithRequest:request];
                } else if([pathExtendsion isEqual:@"gif"]) {
                    size =  [CommonFunction getGIFImageSizeWithRequest:request];
                } else {
                    size = [CommonFunction getJPGImageSizeWithRequest:request];
                }
                if (CGSizeEqualToSize(CGSizeZero, size)) { // 如果获取文件头信息失败,发送异步请求请求原图
                    NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:URL] returningResponse:nil error:nil];
                    UIImage *image = [UIImage imageWithData:data];
                    if (image) {
                        size = image.size;
                    }
                    CGFloat kWidth = WIDTH_FULL_SCREEN;
                    CGFloat kHeight = fabs(WIDTH_FULL_SCREEN * fabs(size.height) / fabs(size.width));

                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, yOffset, kWidth, kHeight)];
                    imageView.backgroundColor = [UIColor clearColor];
                    imageView.image = image;
                    imageView.clipsToBounds = YES;
                    imageView.contentMode = UIViewContentModeScaleAspectFit; //UIViewContentModeScaleToFill;
                    [self.scrollView addSubview:imageView];
                    yOffset += kHeight + 3;
                } else {
                    CGFloat kWidth = WIDTH_FULL_SCREEN;
                    CGFloat kHeight = fabs(WIDTH_FULL_SCREEN * fabs(size.height) / fabs(size.width));
                    
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, yOffset, kWidth, kHeight)];
                    imageView.backgroundColor = [UIColor clearColor];
                    imageView.clipsToBounds = YES;
                    imageView.contentMode = UIViewContentModeScaleAspectFit;//UIViewContentModeScaleToFill;
                    [imageView sd_setImageWithURL:URL placeholderImage:[UIImage imageNamed:png_Bg_LaunchImage]];
                    [self.scrollView addSubview:imageView];
                    yOffset += kHeight + 3;
                }
            }
        }
    }
    
    if (yOffset < 200) {
        yOffset = 200;
    }

    //评论区标题
    UILabel *labelCommentTitle = [[UILabel alloc] initWithFrame:CGRectMake(12, yOffset, 30, 20)];
    [labelCommentTitle setTextColor:color_666666];
    [labelCommentTitle setFont:font_Normal_13];
    [labelCommentTitle setText:@"评论"];
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
        [labelNoComment setText:@"暂无评论，快占沙发~"];
        [self.scrollView addSubview:labelNoComment];
        yOffset += 100;
    }
    yOffset += 20;
    
    if (yOffset < HEIGHT_FULL_VIEW) {
        yOffset = HEIGHT_FULL_VIEW;
    }
    [self.scrollView setContentSize:CGSizeMake(WIDTH_FULL_SCREEN, yOffset)];
}

- (void)createDetailHeaderView {
    BmobObject *author = [self.posts objectForKey:@"author"];
    NSString *nickName = [author objectForKey:@"nickName"];
    if (!nickName || nickName.length == 0) {
        nickName = @"匿名者";
    }
    NSString *avatarURL = [author objectForKey:@"avatarURL"];
    NSString *isHighlight = [self.posts objectForKey:@"isHighlight"];
    
    self.headerView.layer.borderWidth = 1;
    self.headerView.layer.borderColor = [color_dedede CGColor];
    
    //图像
    UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 5, 40, 40)];
    avatarView.layer.cornerRadius = 20;
    avatarView.clipsToBounds = YES;
    [avatarView sd_setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed:png_AvatarDefault1]];
    avatarView.contentMode = UIViewContentModeScaleAspectFit;
    [self.headerView addSubview:avatarView];
    //昵称
    UILabel *labelNickName = [[UILabel alloc] initWithFrame:CGRectMake(57, 0, WIDTH_FULL_SCREEN / 2, 30)];
    labelNickName.textColor = color_Blue;
    labelNickName.font = font_Normal_16;
    labelNickName.text = nickName;
    [self.headerView addSubview:labelNickName];
    //发表时间
    UILabel *labelDate = [[UILabel alloc] initWithFrame:CGRectMake(57, 30, WIDTH_FULL_SCREEN / 2, 20)];
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
        [btn setAllTitle:@"精华"];
        [btn setAllTitleColor:color_Blue];
        btn.titleLabel.font = font_Normal_13;
        [self.headerView addSubview:btn];
    }
}

- (UIView *)createCommentView:(BmobObject *)comment index:(NSInteger)index {
    BmobObject *commentAuthor = [comment objectForKey:@"author"];
    NSString *nickName = [commentAuthor objectForKey:@"nickName"];
    if (!nickName || nickName.length == 0) {
        nickName = @"匿名者";
    }
    NSString *avatarURL = [commentAuthor objectForKey:@"avatarURL"];
    NSInteger likesCount = [[comment objectForKey:@"likesCount"] integerValue];
    BOOL isLike = NO;
    if ([LogIn isLogin]) {
        isLike = [[comment objectForKey:@"isLike"] boolValue];
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_FULL_SCREEN, 85)];
    //图像
    UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 2.5, 30, 30)];
    avatarView.layer.cornerRadius = 15;
    avatarView.clipsToBounds = YES;
    [avatarView sd_setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed:png_AvatarDefault1]];
    avatarView.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:avatarView];
    //昵称
    ThreeSubView *tsViewNickname = [[ThreeSubView alloc] initWithFrame:CGRectMake(47, 0, WIDTH_FULL_SCREEN - 24, 20) leftButtonSelectBlock:^{
        
    } centerButtonSelectBlock:^{
        
    } rightButtonSelectBlock:^{
        
    }];
    [tsViewNickname.leftButton.titleLabel setFont:font_Normal_13];
    [tsViewNickname.leftButton setAllTitleColor:color_333333];
    [tsViewNickname.leftButton setAllTitle:nickName];
    tsViewNickname.leftButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    [tsViewNickname.centerButton.titleLabel setFont:font_Normal_11];
    [tsViewNickname.centerButton setAllTitleColor:color_666666];
    tsViewNickname.leftButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    //楼主
    BmobObject *postsAuthor = [self.posts objectForKey:@"author"];
    NSString *postsUserObjectId = [postsAuthor objectForKey:@"userObjectId"];
    NSString *commentUserObjectId = [commentAuthor objectForKey:@"userObjectId"];
    if ([postsUserObjectId isEqualToString:commentUserObjectId]) {
        [tsViewNickname.centerButton setAllTitle:@"楼主"];
        tsViewNickname.fixCenterWidth = 30;
    } else {
        [tsViewNickname.centerButton setAllTitle:@""];
        tsViewNickname.fixCenterWidth = 0;
    }
    [tsViewNickname.rightButton.titleLabel setFont:font_Normal_13];
    [tsViewNickname.rightButton setAllTitleColor:color_333333];
    [tsViewNickname.rightButton setAllTitle:@""];
    tsViewNickname.fixRightWidth = 0;
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
    [tsViewLikes.leftButton setAllTitleColor:color_666666];
    [tsViewLikes.leftButton setAllTitle:@"举报"];
    tsViewLikes.leftButton.layer.cornerRadius = 5;
    tsViewLikes.leftButton.layer.borderWidth = 0.5;
    tsViewLikes.leftButton.layer.borderColor = [color_666666 CGColor];
    tsViewLikes.leftButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    tsViewLikes.fixCenterWidth = 20;
    [tsViewLikes.centerButton.titleLabel setFont:font_Normal_11];
    [tsViewLikes.centerButton setAllTitleColor:color_666666];
    [tsViewLikes.centerButton setAllTitle:@""];

    tsViewLikes.fixRightWidth = 40;
    [tsViewLikes.rightButton.titleLabel setFont:font_Normal_11];
    [tsViewLikes.rightButton setAllTitle:@"赞"];
    if (likesCount > 0) {
        [tsViewLikes.rightButton setAllTitle:[NSString stringWithFormat:@"%@赞", [CommonFunction checkNumberForThousand:likesCount]]];
    } else {
        [tsViewLikes.rightButton setAllTitle:@"赞"];
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
    UILabel *labelDate = [[UILabel alloc] initWithFrame:CGRectMake(47, 20, WIDTH_FULL_SCREEN / 2, 15)];
    labelDate.textColor = color_666666;
    labelDate.font = font_Normal_11;
    labelDate.text = [CommonFunction intervalSinceNow:comment.createdAt];
    [view addSubview:labelDate];

    CGFloat yOffset = 40;
    
    //回复XX
    BmobObject *replyAuthor = [comment objectForKey:@"replyAuthor"];
    NSString *replyNickName = [replyAuthor objectForKey:@"nickName"];
    if (replyNickName && replyNickName.length > 0) {
        UILabel *labelReply = [[UILabel alloc] initWithFrame:CGRectMake(12, yOffset, WIDTH_FULL_SCREEN / 2, 20)];
        labelReply.textColor = color_666666;
        labelReply.font = font_Normal_13;
        labelReply.text = [NSString stringWithFormat:@"回复 %@：", replyNickName];
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
    [self.bottomBtnView.rightButton setAllTitle:@"回复"];
    
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

- (CGFloat)cellHeight:(BmobObject *)obj {
    NSString *content = [obj objectForKey:@"content"];
    CGFloat yOffset = 10;
    if (content && content.length > 0) {
        UIFont *font = font_Normal_16;
        CGSize size = CGSizeMake(WIDTH_FULL_SCREEN - 24, 2000);
        CGSize labelsize = [content sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
        yOffset = labelsize.height + 20;
    }
    NSArray *imgURLArray = [NSArray arrayWithArray:[obj objectForKey:@"imgURLArray"]];
    if (imgURLArray && imgURLArray.count > 0) {
        
        for (NSInteger i=0; i < imgURLArray.count; i++) {
            NSURL *URL = nil;
            if ([imgURLArray[i] isKindOfClass:[NSString class]]) {
                URL = [NSURL URLWithString:imgURLArray[i]];
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
                NSString *pathExtendsion = [URL.pathExtension lowercaseString];
                
                CGSize size = CGSizeZero;
                if ([pathExtendsion isEqualToString:@"png"]) {
                    size =  [CommonFunction getPNGImageSizeWithRequest:request];
                } else if([pathExtendsion isEqual:@"gif"]) {
                    size =  [CommonFunction getGIFImageSizeWithRequest:request];
                } else {
                    size = [CommonFunction getJPGImageSizeWithRequest:request];
                }
                if (CGSizeEqualToSize(CGSizeZero, size)) { // 如果获取文件头信息失败,发送异步请求请求原图
                    NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:URL] returningResponse:nil error:nil];
                    UIImage *image = [UIImage imageWithData:data];
                    if (image) {
                        size = image.size;
                    }
                }
                CGFloat kWidth = fabs(size.width);
                CGFloat kHeight = fabs(size.height);
                if (kWidth > WIDTH_FULL_SCREEN) {
                    kHeight = WIDTH_FULL_SCREEN * size.height / size.width;
                }
                yOffset += kHeight + 10;
            }
        }
    }
    return fabs(yOffset);
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
                self.inputView.placeholder = [NSString stringWithFormat:@"回复 %@：", nickName];
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

- (void)refreshAction {
    [self getCommets];
}

- (void)shareAction {
    [ShareCenter showShareActionSheet:self.view title:str_App_Title content:[self.posts objectForKey:@"content"] shareUrl:@"" sharedImageURL:@""];
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
            [weakSelf alertToastMessage:@"举报成功"];
        } else {
            [weakSelf alertButtonMessage:@"举报失败"];
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
            [weakSelf alertToastMessage:@"举报成功"];
        } else {
            [weakSelf alertButtonMessage:@"举报失败"];
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

            [weakSelf alertToastMessage:@"评论成功"];
            [weakSelf getCommets];
        } else {
            [weakSelf alertButtonMessage:@"评论失败"];
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
