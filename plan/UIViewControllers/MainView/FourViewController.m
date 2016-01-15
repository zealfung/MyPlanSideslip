//
//  FourViewController.m
//  plan
//
//  Created by Fengzy on 15/12/19.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "LogIn.h"
#import "BmobUser.h"
#import "MJRefresh.h"
#import "BmobQuery.h"
#import "BmobRelation.h"
#import "PostsNoImageCell.h"
#import "WebViewController.h"
#import "PostsOneImageCell.h"
#import "PostsTwoImageCell.h"
#import "SDCycleScrollView.h"
#import "FourViewController.h"
#import "LogInViewController.h"
#import "LogInViewController.h"
#import <RESideMenu/RESideMenu.h>
#import "AddPostsViewController.h"
#import "UserLevelViewController.h"
#import "PostsDetailViewController.h"

@interface FourViewController () <SDCycleScrollViewDelegate> {
    
    BOOL isLoadMore;
    BOOL isLoadingBanner;
    BOOL isLoadingPosts;
    BOOL isSendingLikes;
    BOOL isLoadEnd;
    NSInteger startIndex;
    NSMutableArray *postsArray;
    NSArray *userTagsArray;
    SDCycleScrollView *bannerView;
    NSMutableArray *bannerObjArray;
    NSMutableArray *headerTitlesArray;
    NSMutableArray *headerImagesURLArray;
    NSMutableArray *headerDetailURLArray;
    UIButton *btnBackToTop;
    CGFloat buttonY;
    NSInteger checkLikeCount;
}

@end

@implementation FourViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = str_ViewTitle_14;
    self.tabBarItem.title = str_ViewTitle_14;
    [self createNavBarButton];
    
    userTagsArray = [NSArray array];
    postsArray = [NSMutableArray array];
    headerTitlesArray = [NSMutableArray array];
    headerImagesURLArray = [NSMutableArray array];
    headerDetailURLArray = [NSMutableArray array];
    
    [NotificationCenter addObserver:self selector:@selector(refreshPostsList) name:Notify_LogIn object:nil];
    [NotificationCenter addObserver:self selector:@selector(reloadPostsData) name:Notify_Posts_New object:nil];
    [NotificationCenter addObserver:self selector:@selector(refreshPostsList) name:Notify_Posts_Refresh object:nil];

    [self initTableView];
    
    [self createBack2TopButton];
    
    [self reloadBannerData];
    [self reloadPostsData];
    [self loadUserTagsData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //计算最近一次加载数据时间是否已经超过十分钟，如果是，就自动刷新一次数据
    NSDate *lastUpdatedTime = [UserDefaults objectForKey:str_PostsList_UpdatedTime];
    if (lastUpdatedTime) {
        NSTimeInterval late = [lastUpdatedTime timeIntervalSince1970]*1;
        NSTimeInterval now=[[NSDate date] timeIntervalSince1970]*1;

        if ((now-late)/3600 > 10) {//大于十分钟，自动重载一次数据
            [self reloadBannerData];
            [self reloadPostsData];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)createNavBarButton {
    self.leftBarButtonItem = [self createBarButtonItemWithNormalImageName:png_Btn_LeftMenu selectedImageName:png_Btn_LeftMenu selector:@selector(leftMenuAction:)];
    self.rightBarButtonItem = [self createBarButtonItemWithNormalImageName:png_Btn_Add selectedImageName:png_Btn_Add selector:@selector(addAction:)];
}

- (void)initTableView {
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableHeaderView = [self createTableHeaderView];
    self.tableView.tableFooterView = [[UIView alloc] init];
    __weak typeof(self) weakSelf = self;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //刷新banner数据
        [weakSelf reloadBannerData];
        //刷新帖子数据
        [weakSelf reloadPostsData];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_header = header;
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        isLoadMore = YES;
        //加载更多帖子数据
        [weakSelf reloadPostsData];
    }];
    self.tableView.mj_footer.hidden = YES;
}

- (void)createBack2TopButton {
    btnBackToTop = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH_FULL_SCREEN - 40, HEIGHT_FULL_VIEW - 100, 30, 30)];
    [btnBackToTop setBackgroundImage:[UIImage imageNamed:png_Btn_BackToTop] forState:UIControlStateNormal];
    btnBackToTop.layer.cornerRadius = 15;
    [btnBackToTop.layer setMasksToBounds:YES];
    btnBackToTop.alpha = 0.0;
    [btnBackToTop addTarget:self action:@selector(backToTop:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView addSubview:btnBackToTop];
    [self.tableView bringSubviewToFront:btnBackToTop];
    buttonY = btnBackToTop.frame.origin.y;
}

#pragma mark - action
- (void)leftMenuAction:(UIButton *)button {
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void)addAction:(UIButton *)button {
    if ([LogIn isLogin]) {
        AddPostsViewController *controller = [[AddPostsViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        //登录界面
        LogInViewController *controller = [[LogInViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)mAction:(UIButton *)button {
    UserLevelViewController *controller = [[UserLevelViewController alloc] init];
    controller.userTagsArray = userTagsArray;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (UIView *)createTableHeaderView {
    CGFloat fullViewHeight = HEIGHT_FULL_VIEW;
    CGFloat headerViewHeight = fullViewHeight / 3;
    bannerView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 320, WIDTH_FULL_SCREEN, headerViewHeight) imageURLStringsGroup:headerImagesURLArray];
    bannerView.autoScrollTimeInterval = 6.0;
    bannerView.pageControlDotSize = CGSizeMake(5, 5);
    bannerView.backgroundColor = [UIColor whiteColor];
    bannerView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    bannerView.delegate = self;
    bannerView.titlesGroup = headerTitlesArray;
    bannerView.dotColor = [UIColor whiteColor]; //自定义分页控件小圆标颜色
    bannerView.placeholderImage = [UIImage imageNamed:png_ImageDefault_Rectangle];
    return bannerView;
}

- (void)backToTop:(id)sender {
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [UIView animateWithDuration:0.2 animations:^(void) {
        if (scrollView.contentOffset.y <= 150)
            btnBackToTop.alpha = 0.0;
        else
            btnBackToTop.alpha = 1.0;
    }];
    btnBackToTop.frame = CGRectMake(btnBackToTop.frame.origin.x, buttonY+self.tableView.contentOffset.y , btnBackToTop.frame.size.width, btnBackToTop.frame.size.height);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (postsArray.count > indexPath.row) {
        BmobObject *obj = postsArray[indexPath.row];
        NSArray *imgURLArray = [NSArray arrayWithArray:[obj objectForKey:@"imgURLArray"]];
        if (imgURLArray && imgURLArray.count > 0) {
            return 275.f;
        } else {
            return 130.f;
        }
    } else {
        return 44.f;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (postsArray.count > indexPath.row) {
        BmobObject *obj = postsArray[indexPath.row];
        BmobObject *author = [obj objectForKey:@"author"];
        NSString *nickName = [author objectForKey:@"nickName"];
        NSString *gender = [author objectForKey:@"gender"];
        NSString *level = [author objectForKey:@"level"];
        if (!nickName || nickName.length == 0) {
            nickName = str_NickName;
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
        if ([LogIn isLogin]) {
            isLike = [[obj objectForKey:@"isLike"] boolValue];
        }
        __weak typeof(self) weakSelf = self;
        if (imgURLArray && imgURLArray.count > 0) {
            if (imgURLArray.count == 1) {
                PostsOneImageCell *cell = [PostsOneImageCell cellView];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell.imgViewAvatar sd_setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed: png_AvatarDefault1]];
                
                [cell.subViewNickName.leftButton setAllTitle:nickName];
                if (!gender || [gender isEqualToString:@"1"]) {
                    [cell.subViewNickName.leftButton setAllTitleColor:color_Blue];
                } else {
                    [cell.subViewNickName.leftButton setAllTitleColor:color_Pink];
                }
                if (level) {
                    [cell.subViewNickName.centerButton setImage:[CommonFunction getUserLevelIcon:level] forState:UIControlStateNormal];
                }
                [cell.subViewNickName autoLayout];
                
                cell.labelPostTime.text = [CommonFunction intervalSinceNow:[obj objectForKey:@"updatedTime"]];
                cell.labelContent.text = content;
                if ([isTop isEqualToString:@"1"]) {
                    cell.labelIsTop.hidden = NO;
                }
                if ([isHighlight isEqualToString:@"1"]) {
                    cell.labelIsHighlight.hidden = NO;
                }
                [cell.imgViewOne sd_setImageWithURL:[NSURL URLWithString:imgURLArray[0]] placeholderImage:[UIImage imageNamed:png_ImageDefault_Rectangle]];
                if (isLike) {
                    cell.subViewButton.rightButton.selected = YES;
                    [cell.subViewButton.rightButton setAllTitleColor:color_Red];
                }
                [cell.subViewButton.leftButton setAllTitle:[CommonFunction checkNumberForThousand:readTimes]];
                [cell.subViewButton.centerButton setAllTitle:[CommonFunction checkNumberForThousand:commentsCount]];
                [cell.subViewButton.rightButton setAllTitle:[CommonFunction checkNumberForThousand:likesCount]];
                __weak typeof(PostsOneImageCell) *weakCell = cell;
                cell.postsCellViewBlock = ^(){
                    [weakSelf toPostsDetail:obj];
                };
                cell.postsCellCommentBlock = ^(){
                    [weakSelf toPostsDetail:obj];
                };
                cell.postsCellLikeBlock = ^(){
                    if ([LogIn isLogin]) {
                        BmobObject *obj = postsArray[indexPath.row];
                        weakCell.subViewButton.rightButton.selected = !weakCell.subViewButton.rightButton.selected;
                        if (weakCell.subViewButton.rightButton.selected) {
                            [weakSelf likePosts:obj];
                            NSInteger likesCount = [[obj objectForKey:@"likesCount"] integerValue];
                            likesCount += 1;
                            [weakCell.subViewButton.rightButton setAllTitle:[CommonFunction checkNumberForThousand:likesCount]];
                            [weakCell.subViewButton.rightButton setAllTitleColor:color_Red];
                        } else {
                            [weakSelf unlikePosts:obj];
                            NSInteger likesCount = [[obj objectForKey:@"likesCount"] integerValue];
                            likesCount -= 1;
                            [weakCell.subViewButton.rightButton setAllTitle:[CommonFunction checkNumberForThousand:likesCount]];
                            [weakCell.subViewButton.rightButton setAllTitleColor:color_8f8f8f];
                        }
                    } else {
                        [weakSelf toLogInView];
                    }
                };
                return cell;
            } else {
                PostsTwoImageCell *cell = [PostsTwoImageCell cellView];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell.imgViewAvatar sd_setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed: png_AvatarDefault1]];
                
                [cell.subViewNickName.leftButton setAllTitle:nickName];
                if (!gender || [gender isEqualToString:@"1"]) {
                    [cell.subViewNickName.leftButton setAllTitleColor:color_Blue];
                } else {
                    [cell.subViewNickName.leftButton setAllTitleColor:color_Pink];
                }
                if (level) {
                    [cell.subViewNickName.centerButton setImage:[CommonFunction getUserLevelIcon:level] forState:UIControlStateNormal];
                }
                [cell.subViewNickName autoLayout];
                
                cell.labelPostTime.text = [CommonFunction intervalSinceNow:[obj objectForKey:@"updatedTime"]];
                cell.labelContent.text = content;
                if ([isTop isEqualToString:@"1"]) {
                    cell.labelIsTop.hidden = NO;
                }
                if ([isHighlight isEqualToString:@"1"]) {
                    cell.labelIsHighlight.hidden = NO;
                }
                [cell.imgViewOne sd_setImageWithURL:[NSURL URLWithString:imgURLArray[0]] placeholderImage:[UIImage imageNamed:png_ImageDefault]];
                [cell.imgViewTwo sd_setImageWithURL:[NSURL URLWithString:imgURLArray[1]] placeholderImage:[UIImage imageNamed:png_ImageDefault]];
                if (isLike) {
                    cell.subViewButton.rightButton.selected = YES;
                    [cell.subViewButton.rightButton setAllTitleColor:color_Red];
                }
                [cell.subViewButton.leftButton setAllTitle:[CommonFunction checkNumberForThousand:readTimes]];
                [cell.subViewButton.centerButton setAllTitle:[CommonFunction checkNumberForThousand:commentsCount]];
                [cell.subViewButton.rightButton setAllTitle:[CommonFunction checkNumberForThousand:likesCount]];
                __weak typeof(PostsTwoImageCell) *weakCell = cell;
                cell.postsCellViewBlock = ^(){
                    [weakSelf toPostsDetail:obj];
                };
                cell.postsCellCommentBlock = ^(){
                    [weakSelf toPostsDetail:obj];
                };
                cell.postsCellLikeBlock = ^(){
                    if ([LogIn isLogin]) {
                        BmobObject *obj = postsArray[indexPath.row];
                        weakCell.subViewButton.rightButton.selected = !weakCell.subViewButton.rightButton.selected;
                        if (weakCell.subViewButton.rightButton.selected) {
                            [weakSelf likePosts:obj];
                            NSInteger likesCount = [[obj objectForKey:@"likesCount"] integerValue];
                            likesCount += 1;
                            [weakCell.subViewButton.rightButton setAllTitle:[CommonFunction checkNumberForThousand:likesCount]];
                            [weakCell.subViewButton.rightButton setAllTitleColor:color_Red];
                        } else {
                            [weakSelf unlikePosts:obj];
                            NSInteger likesCount = [[obj objectForKey:@"likesCount"] integerValue];
                            likesCount -= 1;
                            [weakCell.subViewButton.rightButton setAllTitle:[CommonFunction checkNumberForThousand:likesCount]];
                            [weakCell.subViewButton.rightButton setAllTitleColor:color_8f8f8f];
                        }
                    } else {
                        [weakSelf toLogInView];
                    }
                };
                return cell;
            }
        } else {
            PostsNoImageCell *cell = [PostsNoImageCell cellView];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.imgViewAvatar sd_setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed: png_AvatarDefault1]];

            [cell.subViewNickName.leftButton setAllTitle:nickName];
            if (!gender || [gender isEqualToString:@"1"]) {
                [cell.subViewNickName.leftButton setAllTitleColor:color_Blue];
            } else {
                [cell.subViewNickName.leftButton setAllTitleColor:color_Pink];
            }
            if (level) {
                [cell.subViewNickName.centerButton setImage:[CommonFunction getUserLevelIcon:level] forState:UIControlStateNormal];
            }
            [cell.subViewNickName autoLayout];
            
            cell.labelPostTime.text = [CommonFunction intervalSinceNow:[obj objectForKey:@"updatedTime"]];
            cell.labelContent.text = content;
            if ([isTop isEqualToString:@"1"]) {
                cell.labelIsTop.hidden = NO;
            }
            if ([isHighlight isEqualToString:@"1"]) {
                cell.labelIsHighlight.hidden = NO;
            }
            if (isLike) {
                cell.subViewButton.rightButton.selected = YES;
                [cell.subViewButton.rightButton setAllTitleColor:color_Red];
            }
            [cell.subViewButton.leftButton setAllTitle:[CommonFunction checkNumberForThousand:readTimes]];
            [cell.subViewButton.centerButton setAllTitle:[CommonFunction checkNumberForThousand:commentsCount]];
            [cell.subViewButton.rightButton setAllTitle:[CommonFunction checkNumberForThousand:likesCount]];
            __weak typeof(PostsNoImageCell) *weakCell = cell;
            cell.postsCellViewBlock = ^(){
                [weakSelf toPostsDetail:obj];
            };
            cell.postsCellCommentBlock = ^(){
                [weakSelf toPostsDetail:obj];
            };
            cell.postsCellLikeBlock = ^(){
                if ([LogIn isLogin]) {
                    BmobObject *obj = postsArray[indexPath.row];
                    weakCell.subViewButton.rightButton.selected = !weakCell.subViewButton.rightButton.selected;
                    if (weakCell.subViewButton.rightButton.selected) {
                        [weakSelf likePosts:obj];
                        NSInteger likesCount = [[obj objectForKey:@"likesCount"] integerValue];
                        likesCount += 1;
                        [weakCell.subViewButton.rightButton setAllTitle:[CommonFunction checkNumberForThousand:likesCount]];
                        [weakCell.subViewButton.rightButton setAllTitleColor:color_Red];
                    } else {
                        [weakSelf unlikePosts:obj];
                        NSInteger likesCount = [[obj objectForKey:@"likesCount"] integerValue];
                        likesCount -= 1;
                        [weakCell.subViewButton.rightButton setAllTitle:[CommonFunction checkNumberForThousand:likesCount]];
                        [weakCell.subViewButton.rightButton setAllTitleColor:color_8f8f8f];
                    }
                } else {
                    [weakSelf toLogInView];
                }
            };
            return cell;
        }
    } else {
        static NSString *noDataCellIdentifier = @"noDataCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noDataCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noDataCellIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"";
            cell.textLabel.frame = cell.contentView.bounds;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.textLabel.font = font_Bold_16;
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = isLoadEnd ? str_PostsList_Tips1 : @"";
        } else {
            cell.textLabel.text = nil;
        }
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (postsArray.count > 0) {
        return postsArray.count;
    } else {
        return 2;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (postsArray.count > indexPath.row) {
        BmobObject *obj = postsArray[indexPath.row];
        [self toPostsDetail:obj];
    } else {
        [self reloadBannerData];
        [self reloadPostsData];
    }
}

#pragma mark - SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"---点击了第%ld张图片", index);

    if (bannerObjArray.count > index) {
        //记录点击数
        BmobObject *obj = bannerObjArray[index];
        [self incrementBannerReadTimes:obj];
        //根据类型做不同处理
        NSString *bannerType = [obj objectForKey:@"bannerType"];
        if (bannerType) {
            switch ([bannerType integerValue]) {
                case 1://内部帖子
                {
                    NSString *postsObjectId = [obj objectForKey:@"postsObjectId"];
                    if (!postsObjectId) return;//如果帖子id为空就不用往下了
                    
                    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Posts"];
                    [bquery includeKey:@"author"];//声明该次查询需要将author关联对象信息一并查询出来
                    [bquery whereKey:@"objectId" equalTo:postsObjectId];
                    __weak typeof(self) weakSelf = self;
                    isLoadingPosts = YES;
                    [self showHUD];
                    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
                        [weakSelf hideHUD];
                        isLoadingPosts = NO;
                        if (!error && array.count > 0) {
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

- (void)refreshPostsList {
    [self.tableView reloadData];
}

- (void)reloadBannerData {
    if (isLoadingBanner) return;
    
    isLoadingBanner = YES;
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Banner"];
    [bquery whereKey:@"isDeleted" equalTo:@"0"];
    [bquery orderByDescending:@"createdAt"];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        isLoadingBanner = NO;
        if (!error && array.count > 0) {
            
            bannerObjArray = [NSMutableArray arrayWithArray:array];
            headerTitlesArray = [NSMutableArray array];
            headerImagesURLArray = [NSMutableArray array];
            headerDetailURLArray = [NSMutableArray array];
            for (BmobObject *obj in array) {
                NSString *imgURL = [obj objectForKey:@"imgURL"];
                NSString *title = [obj objectForKey:@"title"];
                NSString *detailURL = [obj objectForKey:@"detailURL"];
                if (imgURL) {
                    [headerImagesURLArray addObject:imgURL];
                } else {
                    [headerImagesURLArray addObject:@""];
                }
                
                if (title) {
                    [headerTitlesArray addObject:title];
                } else {
                    [headerTitlesArray addObject:@""];
                }
                
                if (detailURL) {
                    [headerDetailURLArray addObject:detailURL];
                } else {
                    [headerDetailURLArray addObject:@""];
                }
            }
            
            bannerView.titlesGroup = headerTitlesArray;
            bannerView.imageURLStringsGroup = headerImagesURLArray;
        }
    }];
}

- (void)reloadPostsData {
    if (isLoadingPosts) return;
    
    isLoadingPosts = YES;
    [self showHUD];
    if (!isLoadMore) {
        startIndex = 0;
        postsArray = [NSMutableArray array];
    }
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Posts"];
    [bquery includeKey:@"author"];//声明该次查询需要将author关联对象信息一并查询出来
    [bquery whereKey:@"isDeleted" equalTo:@"0"];
    [bquery orderByDescending:@"isTop"];//先按照是否置顶排序
    [bquery orderByDescending:@"updatedTime"];//再按照更新时间排序
    bquery.limit = 10;
    bquery.skip = postsArray.count;
    __weak typeof(self) weakSelf = self;
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        isLoadMore = NO;
        isLoadingPosts = NO;
        isLoadEnd = YES;
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
        //记录加载时间
        [UserDefaults setObject:[NSDate date] forKey:str_PostsList_UpdatedTime];
        [UserDefaults synchronize];
        
        if (!error && array.count > 0) {
            [postsArray addObjectsFromArray:array];
            [weakSelf checkIsLike:postsArray];
        } else {
            [weakSelf hideHUD];
        }
    }];
}

- (void)loadUserTagsData {
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"UserTags"];
    [bquery whereKey:@"isUsed" equalTo:@"1"];
    [bquery orderByAscending:@"orderNo"];

    __weak typeof(self) weakSelf = self;
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (!error && array.count > 0) {
            userTagsArray = [NSArray arrayWithArray:array];
            weakSelf.rightBarButtonItems = [NSArray arrayWithObjects:
                                        [weakSelf createBarButtonItemWithNormalImageName:png_Btn_Add selectedImageName:png_Btn_Add selector:@selector(addAction:)],
                                        [weakSelf createBarButtonItemWithNormalImageName:png_Btn_M selectedImageName:png_Btn_M selector:@selector(mAction:)], nil];
        }
    }];
}

- (void)checkIsLike:(NSMutableArray *)array {
    if ([LogIn isLogin]) {
        checkLikeCount = 0;
        for (NSInteger i=0; i < array.count; i++) {
            [self isLikedPost:array[i]];
        }
    } else {
        [self hideHUD];
        [self.tableView reloadData];
    }
}

- (void)incrementBannerReadTimes:(BmobObject *)obj {
    BmobObject *banner = [BmobObject objectWithoutDatatWithClassName:@"Banner" objectId:obj.objectId];
    //查看数加1
    [banner incrementKey:@"readTimes"];
    if ([LogIn isLogin]) {
        //新建relation对象
        BmobRelation *relation = [[BmobRelation alloc] init];
        BmobUser *user = [BmobUser getCurrentUser];
        [relation addObject:[BmobObject objectWithoutDatatWithClassName:@"_User" objectId:user.objectId]];
        //添加关联关系到readUser列中
        [banner addRelation:relation forKey:@"readUser"];
    }
    //异步更新obj的数据
    [banner updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            NSLog(@"successful");
        }else{
            NSLog(@"error %@",[error description]);
        }
    }];
}

- (void)incrementPostsReadTimes:(BmobObject *)posts {
    BmobObject *obj = [BmobObject objectWithoutDatatWithClassName:@"Posts" objectId:posts.objectId];
    //查看数加1
    [obj incrementKey:@"readTimes"];
    if ([LogIn isLogin]) {
        //新建relation对象
        BmobRelation *relation = [[BmobRelation alloc] init];
        BmobUser *user = [BmobUser getCurrentUser];
        [relation addObject:[BmobObject objectWithoutDatatWithClassName:@"_User" objectId:user.objectId]];
        //添加关联关系到readUser列中
        [obj addRelation:relation forKey:@"readUser"];
    }
    //异步更新obj的数据
    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            NSLog(@"successful");
        }else{
            NSLog(@"error %@",[error description]);
        }
    }];
}

- (void)likePosts:(BmobObject *)posts {
    if (isSendingLikes) return;
    
    BmobObject *obj = [BmobObject objectWithoutDatatWithClassName:@"Posts" objectId:posts.objectId];
    [obj incrementKey:@"likesCount"];
    BmobRelation *relation = [[BmobRelation alloc] init];
    [relation addObject:[BmobObject objectWithoutDatatWithClassName:@"UserSettings" objectId:[Config shareInstance].settings.objectId]];
    [obj addRelation:relation forKey:@"likes"];
    isSendingLikes = YES;
    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        isSendingLikes = NO;
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
    if (isSendingLikes) return;
    
    BmobObject *obj = [BmobObject objectWithoutDatatWithClassName:@"Posts" objectId:posts.objectId];
    [obj decrementKey:@"likesCount"];
    BmobRelation *relation = [[BmobRelation alloc] init];
    [relation removeObject:[BmobObject objectWithoutDatatWithClassName:@"UserSettings" objectId:[Config shareInstance].settings.objectId]];
    [obj addRelation:relation forKey:@"likes"];
    isSendingLikes = YES;
    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        isSendingLikes = NO;
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

- (void)isLikedPost:(BmobObject *)posts {
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Posts"];
    BmobQuery *inQuery = [BmobQuery queryWithClassName:@"UserSettings"];
    BmobUser *user = [BmobUser getCurrentUser];
    [inQuery whereKey:@"userObjectId" equalTo:user.objectId];
    //匹配查询
    [bquery whereKey:@"likes" matchesQuery:inQuery];//（查询所有有关联的数据）
    [bquery whereKey:@"objectId" equalTo:posts.objectId];
    __weak typeof(self) weakSelf = self;
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (!error && array.count > 0) {
            [posts setObject:@(YES) forKey:@"isLike"];
        } else {
            [posts setObject:@(NO) forKey:@"isLike"];
        }
        
        checkLikeCount ++;
        if (checkLikeCount == postsArray.count) {
            [weakSelf hideHUD];
            [weakSelf.tableView reloadData];
        }
    }];
}

- (void)toPostsDetail:(BmobObject *)posts {
    [self incrementPostsReadTimes:posts];
    NSInteger readTimes = [[posts objectForKey:@"readTimes"] integerValue];
    readTimes += 1;
    [posts setObject:@(readTimes) forKey:@"readTimes"];
    
    PostsDetailViewController *controller = [[PostsDetailViewController alloc] init];
    controller.posts = posts;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)toLogInView {
    LogInViewController *controller = [[LogInViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
