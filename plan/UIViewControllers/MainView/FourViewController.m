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
#import "UIImageView+WebCache.h"
#import <RESideMenu/RESideMenu.h>
#import "AddPostsViewController.h"
#import "PostsDetailViewController.h"

@interface FourViewController () <SDCycleScrollViewDelegate> {
    
    BOOL isLoadMore;
    NSInteger startIndex;
    NSMutableArray *postsArray;
    SDCycleScrollView *bannerView;
    NSMutableArray *bannerObjArray;
    NSMutableArray *headerTitlesArray;
    NSMutableArray *headerImagesURLArray;
    NSMutableArray *headerDetailURLArray;
    UIButton *btnBackToTop;
    CGFloat buttonY;
}

@end

@implementation FourViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = str_ViewTitle_14;
    self.tabBarItem.title = str_ViewTitle_14;
    [self createNavBarButton];
    
    postsArray = [NSMutableArray array];
    headerTitlesArray = [NSMutableArray array];
    headerImagesURLArray = [NSMutableArray array];
    headerDetailURLArray = [NSMutableArray array];
    
    [NotificationCenter addObserver:self selector:@selector(loadPostsData) name:Notify_Posts_New object:nil];
    
//    [headerImagesURLArray addObject:@"https://ss2.baidu.com/-vo3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a4b3d7085dee3d6d2293d48b252b5910/0e2442a7d933c89524cd5cd4d51373f0830200ea.jpg"
//                             ];
    
//    headerImagesURLArray = @[@"https://ss2.baidu.com/-vo3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a4b3d7085dee3d6d2293d48b252b5910/0e2442a7d933c89524cd5cd4d51373f0830200ea.jpg",
//                             @"https://ss0.baidu.com/-Po3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a41eb338dd33c895a62bcb3bb72e47c2/5fdf8db1cb134954a2192ccb524e9258d1094a1e.jpg",
//                             @"http://c.hiphotos.baidu.com/image/w%3D400/sign=c2318ff84334970a4773112fa5c8d1c0/b7fd5266d0160924c1fae5ccd60735fae7cd340d.jpg",

    [self initTableView];
    
    [self createBack2TopButton];
    
    [self loadBannerData];
    [self loadPostsData];
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
        [weakSelf loadBannerData];
        //刷新帖子数据
        [weakSelf loadPostsData];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_header = header;
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        isLoadMore = YES;
        //加载更多帖子数据
        [weakSelf loadPostsData];
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

- (UIView *)createTableHeaderView {
    CGFloat fullViewHeight = HEIGHT_FULL_VIEW;
    CGFloat headerViewHeight = fullViewHeight / 3;
    bannerView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 320, WIDTH_FULL_SCREEN, headerViewHeight) imageURLStringsGroup:headerImagesURLArray];
    bannerView.backgroundColor = [UIColor whiteColor];
    bannerView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    bannerView.delegate = self;
    bannerView.titlesGroup = headerTitlesArray;
    bannerView.dotColor = [UIColor whiteColor]; //自定义分页控件小圆标颜色
    bannerView.placeholderImage = [UIImage imageNamed:png_Bg_SideTop];
    //--- 模拟加载延迟
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        cycleScrollView2.imageURLStringsGroup = headerImagesURLArray;
//    });
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
            return 295.f;
        } else {
            return 140.f;
        }
    } else {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (postsArray.count > indexPath.row) {
        BmobObject *obj = postsArray[indexPath.row];
        BmobObject *author = [obj objectForKey:@"author"];
        NSString *nickName = [author objectForKey:@"nickName"];
        if (!nickName || nickName.length == 0) {
            nickName = @"匿名者";
        }
        NSString *avatarURL = [author objectForKey:@"avatarURL"];
        NSString *content = [obj objectForKey:@"content"];
        NSString *isTop = [obj objectForKey:@"isTop"];
        NSString *isHighlight = [obj objectForKey:@"isHighlight"];
        NSInteger readTimes = [[obj objectForKey:@"readTimes"] integerValue];
        NSArray *likesArray = [NSArray arrayWithArray:[obj objectForKey:@"likes"]];
        NSArray *commentsArray = [NSArray arrayWithArray:[obj objectForKey:@"comments"]];
        NSArray *imgURLArray = [NSArray arrayWithArray:[obj objectForKey:@"imgURLArray"]];
        __weak typeof(self) weakSelf = self;
        if (imgURLArray && imgURLArray.count > 0) {
            if (imgURLArray.count == 1) {
                PostsOneImageCell *cell = [PostsOneImageCell cellView];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell.imgViewAvatar sd_setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed: png_AvatarDefault1]];
                cell.labelNickName.text = nickName;
                cell.labelPostTime.text = [CommonFunction NSDateToNSString:obj.updatedAt formatter:str_DateFormatter_yyyy_MM_dd_HHmm];
                cell.labelContent.text = content;
                if ([isTop isEqualToString:@"1"]) {
                    cell.labelIsTop.hidden = NO;
                }
                if ([isHighlight isEqualToString:@"1"]) {
                    cell.labelIsHighlight.hidden = NO;
                }
                [cell.imgViewOne sd_setImageWithURL:[NSURL URLWithString:imgURLArray[0]] placeholderImage:[UIImage imageNamed:png_Bg_SideTop]];
                [cell.subViewButton.leftButton setAllTitle:[NSString stringWithFormat:@"%ld", (long)readTimes]];
                [cell.subViewButton.centerButton setAllTitle:[NSString stringWithFormat:@"%ld", (long)commentsArray.count]];
                [cell.subViewButton.rightButton setAllTitle:[NSString stringWithFormat:@"%ld", (long)likesArray.count]];
                __weak typeof(PostsOneImageCell) *weakCell = cell;
                cell.postsCellViewBlock = ^(){
                    [weakSelf toPostsDetail:@"1"];
                };
                cell.postsCellCommentBlock = ^(){
                    [weakSelf toPostsDetail:@"1"];
                };
                cell.postsCellLikeBlock = ^(){
                    weakCell.subViewButton.rightButton.selected = !weakCell.subViewButton.rightButton.selected;
                    if (weakCell.subViewButton.rightButton.selected) {
                        [weakCell.subViewButton.rightButton setAllTitleColor:color_Red];
                    } else {
                        [weakCell.subViewButton.rightButton setAllTitleColor:color_8f8f8f];
                    }
                };
                return cell;
            } else {
                PostsTwoImageCell *cell = [PostsTwoImageCell cellView];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell.imgViewAvatar sd_setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed: png_AvatarDefault1]];
                cell.labelNickName.text = nickName;
                cell.labelPostTime.text = [CommonFunction NSDateToNSString:obj.updatedAt formatter:str_DateFormatter_yyyy_MM_dd_HHmm];
                cell.labelContent.text = content;
                if ([isTop isEqualToString:@"1"]) {
                    cell.labelIsTop.hidden = NO;
                }
                if ([isHighlight isEqualToString:@"1"]) {
                    cell.labelIsHighlight.hidden = NO;
                }
                [cell.imgViewOne sd_setImageWithURL:[NSURL URLWithString:imgURLArray[0]] placeholderImage:[UIImage imageNamed:png_Bg_SideTop]];
                [cell.imgViewTwo sd_setImageWithURL:[NSURL URLWithString:imgURLArray[1]] placeholderImage:[UIImage imageNamed:png_Bg_SideTop]];
                [cell.subViewButton.leftButton setAllTitle:[NSString stringWithFormat:@"%ld", (long)readTimes]];
                [cell.subViewButton.centerButton setAllTitle:[NSString stringWithFormat:@"%ld", (long)commentsArray.count]];
                [cell.subViewButton.rightButton setAllTitle:[NSString stringWithFormat:@"%ld", (long)likesArray.count]];
                __weak typeof(PostsTwoImageCell) *weakCell = cell;
                cell.postsCellViewBlock = ^(){
                    [weakSelf toPostsDetail:@"1"];
                };
                cell.postsCellCommentBlock = ^(){
                    [weakSelf toPostsDetail:@"1"];
                };
                cell.postsCellLikeBlock = ^(){
                    weakCell.subViewButton.rightButton.selected = !weakCell.subViewButton.rightButton.selected;
                    if (weakCell.subViewButton.rightButton.selected) {
                        [weakCell.subViewButton.rightButton setAllTitleColor:color_Red];
                    } else {
                        [weakCell.subViewButton.rightButton setAllTitleColor:color_8f8f8f];
                    }
                };
                return cell;
            }
        } else {
            PostsNoImageCell *cell = [PostsNoImageCell cellView];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.imgViewAvatar sd_setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed: png_AvatarDefault1]];
            cell.labelNickName.text = nickName;
            cell.labelPostTime.text = [CommonFunction NSDateToNSString:obj.updatedAt formatter:str_DateFormatter_yyyy_MM_dd_HHmm];
            cell.labelContent.text = content;
            if ([isTop isEqualToString:@"1"]) {
                cell.labelIsTop.hidden = NO;
            }
            if ([isHighlight isEqualToString:@"1"]) {
                cell.labelIsHighlight.hidden = NO;
            }
            [cell.subViewButton.leftButton setAllTitle:[NSString stringWithFormat:@"%ld", (long)readTimes]];
            [cell.subViewButton.centerButton setAllTitle:[NSString stringWithFormat:@"%ld", (long)commentsArray.count]];
            [cell.subViewButton.rightButton setAllTitle:[NSString stringWithFormat:@"%ld", (long)likesArray.count]];
            __weak typeof(PostsNoImageCell) *weakCell = cell;
            cell.postsCellViewBlock = ^(){
                [weakSelf toPostsDetail:@"1"];
            };
            cell.postsCellCommentBlock = ^(){
                [weakSelf toPostsDetail:@"1"];
            };
            cell.postsCellLikeBlock = ^(){
                weakCell.subViewButton.rightButton.selected = !weakCell.subViewButton.rightButton.selected;
                if (weakCell.subViewButton.rightButton.selected) {
                    [weakCell.subViewButton.rightButton setAllTitleColor:color_Red];
                } else {
                    [weakCell.subViewButton.rightButton setAllTitleColor:color_8f8f8f];
                }
            };
            return cell;
        }
    } else {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        return  cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
//    if (tableView == self.tableView) {
//        
//        return cardArray.count;
//        
//    } else if (tableView == searchDisplayController.searchResultsTableView) {
//        
//        return searchResultArray.count;
//    }
    
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (postsArray.count > indexPath.row) {
        BmobObject *obj = postsArray[indexPath.row];
        [self incrementPostsReadTimes:obj];
        [self toPostsDetail:@"1"];
    }
}

#pragma mark - SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"---点击了第%ld张图片", index);
    if (headerDetailURLArray.count > index) {
        NSString *url = headerDetailURLArray[index];
        WebViewController *controller = [[WebViewController alloc] init];
        controller.url = url;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    if (bannerObjArray.count > index) {
        //记录点击数
        BmobObject *obj = bannerObjArray[index];
        [self incrementBannerReadTimes:obj];
    }
}

- (void)loadBannerData {
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Banner"];
    [bquery whereKey:@"isDeleted" equalTo:@"0"];
    [bquery orderByDescending:@"updatedAt"];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
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

- (void)loadPostsData {
    [self showHUD];
    if (!isLoadMore) {
        startIndex = 0;
        postsArray = [NSMutableArray array];
    }
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Posts"];
    [bquery includeKey:@"author"];//声明该次查询需要将author关联对象信息一并查询出来
    [bquery whereKey:@"isDeleted" equalTo:@"0"];
    [bquery orderByDescending:@"isTop"];//先按照是否置顶排序
    [bquery orderByDescending:@"updatedAt"];//再按照更新时间排序
    bquery.limit = 10;
    bquery.skip = postsArray.count;
    __weak typeof(self) weakSelf = self;
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        [weakSelf hideHUD];
        isLoadMore = NO;
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
        if (!error && array.count > 0) {
            [postsArray addObjectsFromArray:array];
            [weakSelf.tableView reloadData];
        }
    }];
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

- (void)toPostsDetail:(NSString *)postId {
    PostsDetailViewController *controller = [[PostsDetailViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
