//
//  PostsDetailViewController.m
//  plan
//
//  Created by Fengzy on 15/12/27.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "LogIn.h"
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
    BOOL isAnding;
}

@end

@implementation PostsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavBarButton];
    
    commentsArray = [NSArray array];
    [self createDetailHeaderView];
    [self createDetailView];
    [self createBottomBtnView];
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
        menu.backgroundColor = color_Blue;
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
            [self reportAction];
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
    yOffset += 20 + 20;

    if (commentsArray.count > 0) {
        for (BmobObject *obj in commentsArray) {
            UIView *viewComment = [self createCommentView:obj];
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
//    NSString *isHighlight = [self.posts objectForKey:@"isHighlight"];
    
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
}

- (UIView *)createCommentView:(BmobObject *)comment {
    BmobObject *author = [comment objectForKey:@"author"];
    NSString *nickName = [author objectForKey:@"nickName"];
    if (!nickName || nickName.length == 0) {
        nickName = @"匿名者";
    }
    NSString *avatarURL = [author objectForKey:@"avatarURL"];
    //    NSString *content = [self.posts objectForKey:@"content"];
    //    NSString *isTop = [self.posts objectForKey:@"isTop"];
    //    NSString *isHighlight = [self.posts objectForKey:@"isHighlight"];
    //    NSArray *imgURLArray = [NSArray arrayWithArray:[self.posts objectForKey:@"imgURLArray"]];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_FULL_SCREEN, 55)];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.borderWidth = 1;
    view.layer.borderColor = [color_dedede CGColor];
    //图像
    UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 5, 40, 40)];
    avatarView.layer.cornerRadius = 20;
    avatarView.clipsToBounds = YES;
    [avatarView sd_setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed:png_AvatarDefault1]];
    avatarView.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:avatarView];
    //昵称
    UILabel *labelNickName = [[UILabel alloc] initWithFrame:CGRectMake(57, 0, WIDTH_FULL_SCREEN / 2, 30)];
    labelNickName.textColor = color_Blue;
    labelNickName.font = font_Normal_16;
    labelNickName.text = nickName;
    [view addSubview:labelNickName];
    //发表时间
    UILabel *labelDate = [[UILabel alloc] initWithFrame:CGRectMake(57, 30, WIDTH_FULL_SCREEN / 2, 20)];
    labelDate.textColor = color_666666;
    labelDate.font = font_Normal_13;
    labelDate.text = [CommonFunction intervalSinceNow:self.posts.createdAt];
    [view addSubview:labelDate];
    
    NSString *content = [comment objectForKey:@"content"];
    UILabel *labelContent = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
    [labelContent setNumberOfLines:0];
    labelContent.lineBreakMode = NSLineBreakByWordWrapping;
    [labelContent setTextColor:color_333333];
    UIFont *font = font_Normal_16;
    [labelContent setFont:font];
    [labelContent setText:content];
    CGSize size = CGSizeMake(WIDTH_FULL_SCREEN - 24, 2000);
    CGSize labelsize = [content sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    labelContent.frame = CGRectMake(12, 50, labelsize.width, labelsize.height);
    [view addSubview:labelContent];
    
    CGRect frame = view.frame;
    frame.size.height += labelsize.height;
    view.frame = frame;
    
    return view;
}

- (void)createBottomBtnView {
    __weak typeof(self) weakSelf = self;
    [self getThreeSubViewForLeftBlock: ^{
        [weakSelf likeAction];
    } centerBlock:^{
        
    } rightBlock: ^{
        
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
    //需要查询的列
    BmobObject *post = [BmobObject objectWithoutDatatWithClassName:@"Posts" objectId:self.posts.objectId];
    [bquery whereObjectKey:@"comments" relatedTo:post];
    //查询该联系所有关联的评论
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        } else {
            for (BmobObject *comment in array) {
            }
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

- (void)refreshAction {
}

- (void)shareAction {
}

- (void)reportAction {
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
            NSLog(@"successful");
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

@end
