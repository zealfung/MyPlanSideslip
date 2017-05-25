//
//  FourViewController.m
//  plan
//
//  Created by Fengzy on 15/12/19.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "LogIn.h"
#import "MJRefresh.h"
#import "ThemeNewCell.h"
#import "PostsNoImageCell.h"
#import <BmobSDK/BmobUser.h>
#import "WebViewController.h"
#import "PostsOneImageCell.h"
#import "PostsTwoImageCell.h"
#import "SDCycleScrollView.h"
#import <BmobSDK/BmobQuery.h>
#import "FourViewController.h"
#import "LogInViewController.h"
#import "LogInViewController.h"
#import "ThemeViewController.h"
#import <BmobSDK/BmobRelation.h>
#import "AddPostsViewController.h"
#import "UserLevelViewController.h"
#import "PostsDetailViewController.h"

@interface FourViewController () <SDCycleScrollViewDelegate>
    
@property (nonatomic, assign) BOOL isLoadMore;
@property (nonatomic, assign) BOOL isLoadingBanner;
@property (nonatomic, assign) BOOL isLoadingTheme;
@property (nonatomic, assign) BOOL isLoadingPosts;
@property (nonatomic, assign) BOOL isSendingLikes;
@property (nonatomic, assign) BOOL isLoadEnd;
@property (nonatomic, assign) NSInteger startIndex;
@property (nonatomic, strong) NSMutableArray *themeArray;
@property (nonatomic, strong) NSMutableArray *postsArray;
@property (nonatomic, strong) NSArray *userTagsArray;
@property (nonatomic, strong) SDCycleScrollView *bannerView;
@property (nonatomic, strong) NSMutableArray *bannerObjArray;
@property (nonatomic, strong) NSMutableArray *headerTitlesArray;
@property (nonatomic, strong) NSMutableArray *headerImagesURLArray;
@property (nonatomic, strong) NSMutableArray *headerDetailURLArray;
@property (nonatomic, strong) UIButton *btnBackToTop;
@property (nonatomic, assign) CGFloat buttonY;
@property (nonatomic, assign) NSInteger checkLikeCount;

@end

@implementation FourViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = STRViewTitle14;
    self.tabBarItem.title = STRViewTitle14;

    self.userTagsArray = [NSArray array];
    self.postsArray = [NSMutableArray array];
    self.themeArray = [NSMutableArray array];
    self.headerTitlesArray = [NSMutableArray array];
    self.headerImagesURLArray = [NSMutableArray array];
    self.headerDetailURLArray = [NSMutableArray array];
    
    [NotificationCenter addObserver:self selector:@selector(reloadData) name:NTFPostsNew object:nil];
    [NotificationCenter addObserver:self selector:@selector(reloadData) name:NTFPostsRefresh object:nil];

    [self initTableView];
    
    [self createBack2TopButton];
    
    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //计算最近一次加载数据时间是否已经超过十分钟，如果是，就自动刷新一次数据
    NSDate *lastUpdatedTime = [UserDefaults objectForKey:STRPostsListFlag];
    if (lastUpdatedTime)
    {
        NSTimeInterval last = [lastUpdatedTime timeIntervalSince1970];
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];

        if ((now-last)/60 > 10)
        {//大于十分钟，自动重载一次数据
            [self reloadData];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)createBack2TopButton
{
    self.btnBackToTop = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH_FULL_SCREEN - 60, HEIGHT_FULL_VIEW - 120, 50, 50)];
    [self.btnBackToTop setBackgroundImage:[UIImage imageNamed:png_Btn_BackToTop] forState:UIControlStateNormal];
    self.btnBackToTop.layer.cornerRadius = 25;
    [self.btnBackToTop.layer setMasksToBounds:YES];
    self.btnBackToTop.alpha = 0.0;
    [self.btnBackToTop addTarget:self action:@selector(backToTop:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView addSubview:self.btnBackToTop];
    [self.tableView bringSubviewToFront:self.btnBackToTop];
    self.buttonY = self.btnBackToTop.frame.origin.y;
}

- (void)reloadData
{
    [self reloadBannerData];
    [self reloadThemeData];
    [self reloadPostsData];
    [self loadUserTagsData];
}

- (void)initTableView
{
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableHeaderView = [self createTableHeaderView];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.tableView setEmptyWithText:@"加载失败，下拉列表重试"];
    __weak typeof(self) weakSelf = self;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.isLoadMore = NO;
        [weakSelf reloadData];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_header = header;
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.isLoadMore = YES;
        //加载更多帖子数据
        [weakSelf reloadPostsData];
    }];
}

- (UIView *)createTableHeaderView
{
    CGFloat fullViewHeight = HEIGHT_FULL_VIEW;
    CGFloat headerViewHeight = fullViewHeight / 3;
    self.bannerView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 320, WIDTH_FULL_SCREEN, headerViewHeight) imageURLStringsGroup:self.headerImagesURLArray];
    self.bannerView.autoScrollTimeInterval = 6.0;
    self.bannerView.pageControlDotSize = CGSizeMake(5, 5);
    self.bannerView.backgroundColor = [UIColor whiteColor];
    self.bannerView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    self.bannerView.delegate = self;
    self.bannerView.titlesGroup = self.headerTitlesArray;
    self.bannerView.placeholderImage = [UIImage imageNamed:png_ImageDefault_Rectangle];
    return self.bannerView;
}

- (void)backToTop:(id)sender
{
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)mAction:(UIButton *)button
{
    UserLevelViewController *controller = [[UserLevelViewController alloc] init];
    controller.userTagsArray = self.userTagsArray;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [UIView animateWithDuration:0.2 animations:^(void) {
        if (scrollView.contentOffset.y <= 150)
        {
            self.btnBackToTop.alpha = 0.0;
        }
        else
        {
            self.btnBackToTop.alpha = 1.0;
        }
    }];
    self.btnBackToTop.frame = CGRectMake(self.btnBackToTop.frame.origin.x, self.buttonY+self.tableView.contentOffset.y , self.btnBackToTop.frame.size.width, self.btnBackToTop.frame.size.height);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && self.themeArray.count)
    {
        return 101.f;
    }
    else
    {
        if (self.postsArray.count > indexPath.row)
        {
            BmobObject *obj = self.postsArray[indexPath.row];
            NSArray *imgURLArray = [NSArray arrayWithArray:[obj objectForKey:@"imgURLArray"]];
            if (imgURLArray && imgURLArray.count)
            {
                return 275.f;
            }
            else
            {
                return 130.f;
            }
        }
        else
        {
            return 0;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 && self.themeArray.count)
    {
        return 1;
    }
    else
    {
        return self.postsArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (indexPath.section == 0)
    {
        if (self.themeArray.count >= 6)
        {
            __weak typeof(self) weakSelf = self;
            
            ThemeNewCell *cell = [ThemeNewCell cellView];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            BmobObject *obj1 = self.themeArray[0];
            NSString *name1 = [obj1 objectForKey:@"name"];
            NSString *imgURL1 = [obj1 objectForKey:@"imgURL"];
            cell.label1.text = name1;
            [cell.imgView1 sd_setImageWithURL:[NSURL URLWithString:imgURL1] placeholderImage:[UIImage imageNamed:png_ImageDefault_Theme]];
            cell.imgView1ClickedBlock = ^() {
                [weakSelf toThemeList:obj1];
            };
            
            BmobObject *obj2 = self.themeArray[1];
            NSString *name2 = [obj2 objectForKey:@"name"];
            NSString *imgURL2 = [obj2 objectForKey:@"imgURL"];
            cell.label2.text = name2;
            [cell.imgView2 sd_setImageWithURL:[NSURL URLWithString:imgURL2] placeholderImage:[UIImage imageNamed:png_ImageDefault_Theme]];
            cell.imgView2ClickedBlock = ^() {
                [weakSelf toThemeList:obj2];
            };
            
            BmobObject *obj3 = self.themeArray[2];
            NSString *name3 = [obj3 objectForKey:@"name"];
            NSString *imgURL3 = [obj3 objectForKey:@"imgURL"];
            cell.label3.text = name3;
            [cell.imgView3 sd_setImageWithURL:[NSURL URLWithString:imgURL3] placeholderImage:[UIImage imageNamed:png_ImageDefault_Theme]];
            cell.imgView3ClickedBlock = ^() {
                [weakSelf toThemeList:obj3];
            };
            
            BmobObject *obj4 = self.themeArray[3];
            NSString *name4 = [obj4 objectForKey:@"name"];
            NSString *imgURL4 = [obj4 objectForKey:@"imgURL"];
            cell.label4.text = name4;
            [cell.imgView4 sd_setImageWithURL:[NSURL URLWithString:imgURL4] placeholderImage:[UIImage imageNamed:png_ImageDefault_Theme]];
            cell.imgView4ClickedBlock = ^() {
                [weakSelf toThemeList:obj4];
            };
            
            BmobObject *obj5 = self.themeArray[4];
            NSString *name5 = [obj5 objectForKey:@"name"];
            NSString *imgURL5 = [obj5 objectForKey:@"imgURL"];
            cell.label5.text = name5;
            [cell.imgView5 sd_setImageWithURL:[NSURL URLWithString:imgURL5] placeholderImage:[UIImage imageNamed:png_ImageDefault_Theme]];
            cell.imgView5ClickedBlock = ^() {
                [weakSelf toThemeList:obj5];
            };
            
            BmobObject *obj6 = self.themeArray[5];
            NSString *name6 = [obj6 objectForKey:@"name"];
            NSString *imgURL6 = [obj6 objectForKey:@"imgURL"];
            cell.label6.text = name6;
            [cell.imgView6 sd_setImageWithURL:[NSURL URLWithString:imgURL6] placeholderImage:[UIImage imageNamed:png_ImageDefault_Theme]];
            cell.imgView6ClickedBlock = ^() {
                [weakSelf toThemeList:obj6];
            };
            
            return cell;
        }
        else
        {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            return cell;
        }
    }
    else
    {
        if (self.postsArray.count > indexPath.row)
        {
            BmobObject *obj = self.postsArray[indexPath.row];
            BmobObject *author = [obj objectForKey:@"author"];
            NSString *nickName = [author objectForKey:@"nickName"];
            NSString *gender = [author objectForKey:@"gender"];
            NSString *level = [author objectForKey:@"level"];
            if (!nickName || nickName.length == 0) {
                nickName = STRCommonTip12;
            }
            NSString *avatarURL = [author objectForKey:@"avatarURL"];
            NSString *content = [obj objectForKey:@"content"];
            NSString *isTop = [obj objectForKey:@"isTop"];
            NSString *isHighlight = [obj objectForKey:@"isHighlight"];
            NSInteger readTimes = [[obj objectForKey:@"readTimes"] integerValue];
            NSInteger likesCount = [[obj objectForKey:@"likesCount"] integerValue];
            NSInteger commentsCount = [[obj objectForKey:@"commentsCount"] integerValue];
            NSArray *imgURLArray = [NSArray arrayWithArray:[obj objectForKey:@"imgURLArray"]];
            BOOL isLike = NO;
            if ([LogIn isLogin])
            {
                isLike = [[obj objectForKey:@"isLike"] boolValue];
            }
            __weak typeof(self) weakSelf = self;
            if (imgURLArray && imgURLArray.count)
            {
                if (imgURLArray.count == 1)
                {
                    PostsOneImageCell *cell = [PostsOneImageCell cellView];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    [cell.imgViewAvatar sd_setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed: png_AvatarDefault1]];
                    
                    cell.labelNickName.text = nickName;
                    if (!gender || [gender isEqualToString:@"1"])
                    {
                        cell.labelNickName.textColor = color_Blue;
                    }
                    else
                    {
                        cell.labelNickName.textColor = color_Pink;
                    }
                    if (level)
                    {
                        cell.btnUserLevel.enabled = YES;
                        [cell.btnUserLevel setBackgroundImage:[CommonFunction getUserLevelIcon:level] forState:UIControlStateNormal];
                    }
                    else
                    {
                        cell.btnUserLevel.enabled = NO;
                    }
                    
                    cell.labelPostTime.text = [CommonFunction intervalSinceNow:[obj objectForKey:@"updatedTime"]];
                    cell.labelContent.text = content;
                    if ([isTop isEqualToString:@"1"])
                    {
                        cell.labelIsTop.hidden = NO;
                    }
                    if ([isHighlight isEqualToString:@"1"])
                    {
                        cell.labelIsHighlight.hidden = NO;
                    }
                    [cell.imgViewOne sd_setImageWithURL:[NSURL URLWithString:imgURLArray[0]] placeholderImage:[UIImage imageNamed:png_ImageDefault_Rectangle]];
                    if (isLike)
                    {
                        cell.isLiked = YES;
                        cell.imgLike.image = [UIImage imageNamed:png_Icon_Posts_Praise_Selected];
                        cell.labelLike.textColor = color_Red;
                    }
                    cell.labelEye.text = [CommonFunction checkNumberForThousand:readTimes];
                    cell.labelComment.text = [CommonFunction checkNumberForThousand:commentsCount];
                    cell.labelLike.text = [CommonFunction checkNumberForThousand:likesCount];
                    __weak typeof(PostsOneImageCell) *weakCell = cell;
                    cell.postsCellLevelBlock = ^() {
                        [weakSelf mAction:nil];
                    };
                    cell.postsCellViewBlock = ^(){
                        [weakSelf toPostsDetail:obj];
                    };
                    cell.postsCellCommentBlock = ^(){
                        [weakSelf toPostsDetail:obj];
                    };
                    cell.postsCellLikeBlock = ^(){
                        if ([LogIn isLogin])
                        {
                            BmobObject *obj = weakSelf.postsArray[indexPath.row];
                            weakCell.isLiked = !weakCell.isLiked;
                            if (weakCell.isLiked)
                            {
                                [weakSelf likePosts:obj];
                                NSInteger likesCount = [[obj objectForKey:@"likesCount"] integerValue];
                                likesCount += 1;
                                weakCell.imgLike.image = [UIImage imageNamed:png_Icon_Posts_Praise_Selected];
                                weakCell.labelLike.textColor = color_Red;
                                weakCell.labelLike.text = [CommonFunction checkNumberForThousand:likesCount];
                            }
                            else
                            {
                                [weakSelf unlikePosts:obj];
                                NSInteger likesCount = [[obj objectForKey:@"likesCount"] integerValue];
                                likesCount -= 1;
                                weakCell.imgLike.image = [UIImage imageNamed:png_Icon_Posts_Praise_Normal];
                                weakCell.labelLike.textColor = color_8f8f8f;
                                weakCell.labelLike.text = [CommonFunction checkNumberForThousand:likesCount];
                            }
                        }
                        else
                        {
                            [weakSelf toLogInView];
                        }
                    };
                    return cell;
                }
                else
                {
                    PostsTwoImageCell *cell = [PostsTwoImageCell cellView];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    [cell.imgViewAvatar sd_setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed: png_AvatarDefault1]];
                    
                    cell.labelNickName.text = nickName;
                    if (!gender || [gender isEqualToString:@"1"])
                    {
                        cell.labelNickName.textColor = color_Blue;
                    }
                    else
                    {
                        cell.labelNickName.textColor = color_Pink;
                    }
                    if (level)
                    {
                        cell.btnUserLevel.enabled = YES;
                        [cell.btnUserLevel setBackgroundImage:[CommonFunction getUserLevelIcon:level] forState:UIControlStateNormal];
                    }
                    else
                    {
                        cell.btnUserLevel.enabled = NO;
                    }
                    
                    cell.labelPostTime.text = [CommonFunction intervalSinceNow:[obj objectForKey:@"updatedTime"]];
                    cell.labelContent.text = content;
                    if ([isTop isEqualToString:@"1"])
                    {
                        cell.labelIsTop.hidden = NO;
                    }
                    if ([isHighlight isEqualToString:@"1"])
                    {
                        cell.labelIsHighlight.hidden = NO;
                    }
                    [cell.imgViewOne sd_setImageWithURL:[NSURL URLWithString:imgURLArray[0]] placeholderImage:[UIImage imageNamed:png_ImageDefault]];
                    [cell.imgViewTwo sd_setImageWithURL:[NSURL URLWithString:imgURLArray[1]] placeholderImage:[UIImage imageNamed:png_ImageDefault]];
                    if (isLike)
                    {
                        cell.isLiked = YES;
                        cell.imgLike.image = [UIImage imageNamed:png_Icon_Posts_Praise_Selected];
                        cell.labelLike.textColor = color_Red;
                    }
                    cell.labelEye.text = [CommonFunction checkNumberForThousand:readTimes];
                    cell.labelComment.text = [CommonFunction checkNumberForThousand:commentsCount];
                    cell.labelLike.text = [CommonFunction checkNumberForThousand:likesCount];
                    __weak typeof(PostsTwoImageCell) *weakCell = cell;
                    cell.postsCellLevelBlock = ^() {
                        [weakSelf mAction:nil];
                    };
                    cell.postsCellViewBlock = ^(){
                        [weakSelf toPostsDetail:obj];
                    };
                    cell.postsCellCommentBlock = ^(){
                        [weakSelf toPostsDetail:obj];
                    };
                    cell.postsCellLikeBlock = ^(){
                        if ([LogIn isLogin])
                        {
                            BmobObject *obj = weakSelf.postsArray[indexPath.row];
                            weakCell.isLiked = !weakCell.isLiked;
                            if (weakCell.isLiked) {
                                [weakSelf likePosts:obj];
                                NSInteger likesCount = [[obj objectForKey:@"likesCount"] integerValue];
                                likesCount += 1;
                                weakCell.imgLike.image = [UIImage imageNamed:png_Icon_Posts_Praise_Selected];
                                weakCell.labelLike.textColor = color_Red;
                                weakCell.labelLike.text = [CommonFunction checkNumberForThousand:likesCount];
                            }
                            else
                            {
                                [weakSelf unlikePosts:obj];
                                NSInteger likesCount = [[obj objectForKey:@"likesCount"] integerValue];
                                likesCount -= 1;
                                weakCell.imgLike.image = [UIImage imageNamed:png_Icon_Posts_Praise_Normal];
                                weakCell.labelLike.textColor = color_8f8f8f;
                                weakCell.labelLike.text = [CommonFunction checkNumberForThousand:likesCount];
                            }
                        }
                        else
                        {
                            [weakSelf toLogInView];
                        }
                    };
                    return cell;
                }
            }
            else
            {
                PostsNoImageCell *cell = [PostsNoImageCell cellView];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell.imgViewAvatar sd_setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed: png_AvatarDefault1]];
                
                cell.labelNickName.text = nickName;
                if (!gender || [gender isEqualToString:@"1"])
                {
                    cell.labelNickName.textColor = color_Blue;
                }
                else
                {
                    cell.labelNickName.textColor = color_Pink;
                }
                if (level)
                {
                    cell.btnUserLevel.enabled = YES;
                    [cell.btnUserLevel setBackgroundImage:[CommonFunction getUserLevelIcon:level] forState:UIControlStateNormal];
                }
                else
                {
                    cell.btnUserLevel.enabled = NO;
                }
                
                cell.labelPostTime.text = [CommonFunction intervalSinceNow:[obj objectForKey:@"updatedTime"]];
                cell.labelContent.text = content;
                if ([isTop isEqualToString:@"1"])
                {
                    cell.labelIsTop.hidden = NO;
                }
                if ([isHighlight isEqualToString:@"1"])
                {
                    cell.labelIsHighlight.hidden = NO;
                }
                if (isLike)
                {
                    cell.isLiked = YES;
                    cell.imgLike.image = [UIImage imageNamed:png_Icon_Posts_Praise_Selected];
                    cell.labelLike.textColor = color_Red;
                }
                cell.labelEye.text = [CommonFunction checkNumberForThousand:readTimes];
                cell.labelComment.text = [CommonFunction checkNumberForThousand:commentsCount];
                cell.labelLike.text = [CommonFunction checkNumberForThousand:likesCount];
                __weak typeof(PostsNoImageCell) *weakCell = cell;
                cell.postsCellLevelBlock = ^() {
                    [weakSelf mAction:nil];
                };
                cell.postsCellViewBlock = ^(){
                    [weakSelf toPostsDetail:obj];
                };
                cell.postsCellCommentBlock = ^(){
                    [weakSelf toPostsDetail:obj];
                };
                cell.postsCellLikeBlock = ^(){
                    if ([LogIn isLogin])
                    {
                        BmobObject *obj = weakSelf.postsArray[indexPath.row];
                        weakCell.isLiked = !weakCell.isLiked;
                        if (weakCell.isLiked)
                        {
                            [weakSelf likePosts:obj];
                            NSInteger likesCount = [[obj objectForKey:@"likesCount"] integerValue];
                            likesCount += 1;
                            weakCell.imgLike.image = [UIImage imageNamed:png_Icon_Posts_Praise_Selected];
                            weakCell.labelLike.textColor = color_Red;
                            weakCell.labelLike.text = [CommonFunction checkNumberForThousand:likesCount];
                        }
                        else
                        {
                            [weakSelf unlikePosts:obj];
                            NSInteger likesCount = [[obj objectForKey:@"likesCount"] integerValue];
                            likesCount -= 1;
                            weakCell.imgLike.image = [UIImage imageNamed:png_Icon_Posts_Praise_Normal];
                            weakCell.labelLike.textColor = color_8f8f8f;
                            weakCell.labelLike.text = [CommonFunction checkNumberForThousand:likesCount];
                        }
                    }
                    else
                    {
                        [weakSelf toLogInView];
                    }
                };
                return cell;
            }
        }
        else
        {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (((self.themeArray.count == 0 && indexPath.section == 0)
        || (self.themeArray.count && indexPath.section == 1))
        && (self.postsArray.count > indexPath.row))
    {
        BmobObject *obj = self.postsArray[indexPath.row];
        [self toPostsDetail:obj];
    }
    else
    {
        [self reloadData];
    }
}

#pragma mark - SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    if (self.bannerObjArray.count > index)
    {
        //记录点击数
        BmobObject *obj = self.bannerObjArray[index];
        [self incrementBannerReadTimes:obj];
        //根据类型做不同处理
        NSString *bannerType = [obj objectForKey:@"bannerType"];
        if (bannerType)
        {
            switch ([bannerType integerValue])
            {
                case 1://内部帖子
                {
                    NSString *postsObjectId = [obj objectForKey:@"postsObjectId"];
                    if (!postsObjectId) return;//如果帖子id为空就不用往下了
                    
                    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Posts"];
                    [bquery includeKey:@"author"];//声明该次查询需要将author关联对象信息一并查询出来
                    [bquery whereKey:@"objectId" equalTo:postsObjectId];
                    __weak typeof(self) weakSelf = self;
                    self.isLoadingTheme = YES;
                    [self showHUD];
                    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
                     {
                        [weakSelf hideHUD];
                        weakSelf.isLoadingTheme = NO;
                        if (!error && array.count)
                        {
                            BmobObject *obj = array[0];
                            [weakSelf toPostsDetail:obj];
                        }
                    }];
                }
                    break;
                case 2://网页URL
                {
                    NSString *detailURL = [obj objectForKey:@"detailURL"];
                    WebViewController *controller = [[WebViewController alloc] init];
                    controller.url = detailURL;
                    controller.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:controller animated:YES];
                }
                    break;
                default:
                    break;
            }
        }
    }
}

- (void)reloadBannerData
{
    if (self.isLoadingBanner) return;
    
    self.isLoadingBanner = YES;
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Banner"];
    [bquery whereKey:@"isDeleted" equalTo:@"0"];
    [bquery orderByDescending:@"createdAt"];
    __weak typeof(self) weakSelf = self;
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
     {
        weakSelf.isLoadingBanner = NO;
        if (!error && array.count)
        {
            weakSelf.bannerObjArray = [NSMutableArray arrayWithArray:array];
            weakSelf.headerTitlesArray = [NSMutableArray array];
            weakSelf.headerImagesURLArray = [NSMutableArray array];
            weakSelf.headerDetailURLArray = [NSMutableArray array];
            for (BmobObject *obj in array)
            {
                NSString *imgURL = [obj objectForKey:@"imgURL"];
                NSString *title = [obj objectForKey:@"title"];
                NSString *detailURL = [obj objectForKey:@"detailURL"];
                if (imgURL)
                {
                    [weakSelf.headerImagesURLArray addObject:imgURL];
                }
                else
                {
                    [weakSelf.headerImagesURLArray addObject:@""];
                }
                
                if (title)
                {
                    [weakSelf.headerTitlesArray addObject:title];
                }
                else
                {
                    [weakSelf.headerTitlesArray addObject:@""];
                }
                
                if (detailURL)
                {
                    [weakSelf.headerDetailURLArray addObject:detailURL];
                }
                else
                {
                    [weakSelf.headerDetailURLArray addObject:@""];
                }
            }
            
            weakSelf.bannerView.titlesGroup = weakSelf.headerTitlesArray;
            weakSelf.bannerView.imageURLStringsGroup = weakSelf.headerImagesURLArray;
        }
    }];
}

- (void)reloadThemeData
{
    if (self.isLoadingTheme) return;
    
    self.isLoadingTheme = YES;
    [self showHUD];

    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Theme"];
    [bquery whereKey:@"isShow" equalTo:@"1"];
    [bquery orderByAscending:@"orderNo"];

    __weak typeof(self) weakSelf = self;
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
     {
        [weakSelf hideHUD];
        
        weakSelf.isLoadingTheme = NO;
        weakSelf.isLoadEnd = YES;
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
        //记录加载时间
        [UserDefaults setObject:[NSDate date] forKey:STRPostsListFlag];
        [UserDefaults synchronize];
        
        weakSelf.themeArray = [NSMutableArray arrayWithArray:array];
        [weakSelf.tableView reloadData];
    }];
}

- (void)reloadPostsData
{
    if (self.isLoadingPosts) return;
    
    self.isLoadingPosts = YES;
    [self showHUD];
    if (!self.isLoadMore)
    {
        self.startIndex = 0;
        self.postsArray = [NSMutableArray array];
    }
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Posts"];
    [bquery includeKey:@"author"];//声明该次查询需要将author关联对象信息一并查询出来
    [bquery whereKey:@"isDeleted" equalTo:@"0"];
    [bquery orderByDescending:@"isTop"];//先按照是否置顶排序
    [bquery orderByDescending:@"updatedTime"];//再按照更新时间排序
    bquery.limit = 10;
    bquery.skip = self.postsArray.count;
    __weak typeof(self) weakSelf = self;
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
    {
        [weakSelf hideHUD];
        
        //自动回顶部
        if (!weakSelf.isLoadMore)
        {
            [weakSelf backToTop:nil];
        }
        weakSelf.isLoadMore = NO;
        weakSelf.isLoadingPosts = NO;
        weakSelf.isLoadEnd = YES;
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];

        //记录加载时间
        [UserDefaults setObject:[NSDate date] forKey:STRPostsListFlag];
        [UserDefaults synchronize];
        
        if (!error && array.count)
        {
            [weakSelf.postsArray addObjectsFromArray:array];
            [weakSelf checkIsLike:weakSelf.postsArray];
        }
        else
        {
            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            [weakSelf hideHUD];
        }
    }];
}

- (void)loadUserTagsData
{
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"UserTags"];
    [bquery whereKey:@"isUsed" equalTo:@"1"];
    [bquery orderByAscending:@"orderNo"];
    __weak typeof(self) weakSelf = self;
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
     {
        if (!error && array.count)
        {
            weakSelf.userTagsArray = [NSArray arrayWithArray:array];
        }
    }];
}

- (void)checkIsLike:(NSMutableArray *)array
{
    if ([LogIn isLogin])
    {
        self.checkLikeCount = 0;
        for (NSInteger i=0; i < array.count; i++)
        {
            [self isLikedPost:array[i]];
        }
    }
    else
    {
        [self hideHUD];
        [self.tableView reloadData];
    }
}

- (void)incrementBannerReadTimes:(BmobObject *)obj
{
    BmobObject *banner = [BmobObject objectWithoutDataWithClassName:@"Banner" objectId:obj.objectId];
    //查看数加1
    [banner incrementKey:@"readTimes"];
    if ([LogIn isLogin])
    {
        //新建relation对象
        BmobRelation *relation = [[BmobRelation alloc] init];
        BmobUser *user = [BmobUser currentUser];
        [relation addObject:[BmobObject objectWithoutDataWithClassName:@"_User" objectId:user.objectId]];
        //添加关联关系到readUser列中
        [banner addRelation:relation forKey:@"readUser"];
    }
    //异步更新obj的数据
    [banner updateInBackground];
}

- (void)incrementPostsReadTimes:(BmobObject *)posts
{
    BmobObject *obj = [BmobObject objectWithoutDataWithClassName:@"Posts" objectId:posts.objectId];
    //查看数加1
    [obj incrementKey:@"readTimes"];
    if ([LogIn isLogin]) {
        //新建relation对象
        BmobRelation *relation = [[BmobRelation alloc] init];
        BmobUser *user = [BmobUser currentUser];
        [relation addObject:[BmobObject objectWithoutDataWithClassName:@"_User" objectId:user.objectId]];
        //添加关联关系到readUser列中
        [obj addRelation:relation forKey:@"readUser"];
    }
    //异步更新obj的数据
    [obj updateInBackground];
}

- (void)likePosts:(BmobObject *)posts
{
    BOOL isLike = [[posts objectForKey:@"isLike"] boolValue];
    if (self.isSendingLikes && isLike) return;
    
    __weak typeof(self) weakSelf = self;
    BmobObject *obj = [BmobObject objectWithoutDataWithClassName:@"Posts" objectId:posts.objectId];
    [obj incrementKey:@"likesCount"];
    BmobRelation *relation = [[BmobRelation alloc] init];
    [relation addObject:[BmobObject objectWithoutDataWithClassName:@"UserSettings" objectId:[Config shareInstance].settings.objectId]];
    [obj addRelation:relation forKey:@"likes"];
    self.isSendingLikes = YES;
    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
    {
        weakSelf.isSendingLikes = NO;
        if (isSuccessful)
        {
            NSInteger likesCount = [[posts objectForKey:@"likesCount"] integerValue];
            likesCount += 1;
            [posts setObject:@(likesCount) forKey:@"likesCount"];
            [posts setObject:@(YES) forKey:@"isLike"];
            [weakSelf addNoticesForLikesPosts:posts];
        }
        else
        {
            NSLog(@"error %@",[error description]);
        }
    }];
}

- (void)unlikePosts:(BmobObject *)posts
{
    NSInteger likesCount = [[posts objectForKey:@"likesCount"] integerValue];
    BOOL isLike = [[posts objectForKey:@"isLike"] boolValue];
    if (self.isSendingLikes || likesCount < 1 || !isLike) return;
    
    BmobObject *obj = [BmobObject objectWithoutDataWithClassName:@"Posts" objectId:posts.objectId];
    [obj decrementKey:@"likesCount"];
    BmobRelation *relation = [[BmobRelation alloc] init];
    [relation removeObject:[BmobObject objectWithoutDataWithClassName:@"UserSettings" objectId:[Config shareInstance].settings.objectId]];
    [obj addRelation:relation forKey:@"likes"];
    self.isSendingLikes = YES;
    __weak typeof(self) weakSelf = self;
    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
    {
        weakSelf.isSendingLikes = NO;
        if (isSuccessful)
        {
            NSInteger likesCount = [[posts objectForKey:@"likesCount"] integerValue];
            likesCount -= 1;
            [posts setObject:@(likesCount) forKey:@"likesCount"];
            [posts setObject:@(NO) forKey:@"isLike"];
            NSLog(@"successful");
        }
        else
        {
            NSLog(@"error %@",[error description]);
        }
    }];
}

- (void)isLikedPost:(BmobObject *)posts
{
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Posts"];
    BmobQuery *inQuery = [BmobQuery queryWithClassName:@"UserSettings"];
    BmobUser *user = [BmobUser currentUser];
    [inQuery whereKey:@"userObjectId" equalTo:user.objectId];
    //匹配查询
    [bquery whereKey:@"likes" matchesQuery:inQuery];//（查询所有有关联的数据）
    [bquery whereKey:@"objectId" equalTo:posts.objectId];
    __weak typeof(self) weakSelf = self;
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
     {
        if (!error && array.count)
        {
            [posts setObject:@(YES) forKey:@"isLike"];
        }
        else
        {
            [posts setObject:@(NO) forKey:@"isLike"];
        }
        
        weakSelf.checkLikeCount ++;
        if (weakSelf.checkLikeCount == weakSelf.postsArray.count)
        {
            [weakSelf hideHUD];
            [weakSelf.tableView reloadData];
        }
    }];
}

- (void)addNoticesForLikesPosts:(BmobObject *)posts
{
    BmobObject *author = [posts objectForKey:@"author"];
    NSString *userObjectId = [author objectForKey:@"userObjectId"];
    BmobUser *user = [BmobUser currentUser];
    if ([user.objectId isEqualToString:userObjectId]) return;
    
    BmobObject *newNotice = [BmobObject objectWithClassName:@"Notices"];
    [newNotice setObject:@"1" forKey:@"noticeType"];//通知类型：1赞帖子 2赞评论 3回复帖子 4回复评论
    [newNotice setObject:posts.objectId forKey:@"postsObjectId"];//被评论或点赞的帖子id
    [newNotice setObject:[posts objectForKey:@"content"] forKey:@"noticeForContent"];//被评论的帖子内容
    BmobObject *fromUser = [BmobObject objectWithoutDataWithClassName:@"UserSettings" objectId:[Config shareInstance].settings.objectId];
    [newNotice setObject:fromUser forKey:@"fromUser"];
    [newNotice setObject:userObjectId forKey:@"toAuthorObjectId"];//评论对象的ID
    [newNotice setObject:@"0" forKey:@"hasRead"];// 0未读 1已读
    [newNotice saveInBackground];
}

- (void)toThemeList:(BmobObject *)theme
{
    ThemeViewController *controller = [[ThemeViewController alloc] init];
    controller.theme = theme;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)toPostsDetail:(BmobObject *)posts
{
    [self incrementPostsReadTimes:posts];
    NSInteger readTimes = [[posts objectForKey:@"readTimes"] integerValue];
    readTimes += 1;
    [posts setObject:@(readTimes) forKey:@"readTimes"];
    
    PostsDetailViewController *controller = [[PostsDetailViewController alloc] init];
    controller.posts = posts;
    controller.userTagsArray = [NSArray arrayWithArray:self.userTagsArray];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)toLogInView
{
    LogInViewController *controller = [[LogInViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
