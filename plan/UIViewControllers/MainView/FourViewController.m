//
//  FourViewController.m
//  plan
//
//  Created by Fengzy on 15/12/19.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "LogIn.h"
#import "MJRefresh.h"
#import "ThemeCell.h"
#import "WZLBadgeImport.h"
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
#import <RESideMenu/RESideMenu.h>
#import "AddPostsViewController.h"
#import "UserLevelViewController.h"


@interface FourViewController () <SDCycleScrollViewDelegate> {
    
    BOOL isLoadingBanner;
    BOOL isLoadingTheme;
    BOOL isLoadEnd;
    NSMutableArray *themeArray;
    SDCycleScrollView *bannerView;
    NSMutableArray *bannerObjArray;
    NSMutableArray *headerTitlesArray;
    NSMutableArray *headerImagesURLArray;
    NSMutableArray *headerDetailURLArray;
}

@end

@implementation FourViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = STRViewTitle14;
    self.tabBarItem.title = STRViewTitle14;
    [self createNavBarButton];

    themeArray = [NSMutableArray array];
    headerTitlesArray = [NSMutableArray array];
    headerImagesURLArray = [NSMutableArray array];
    headerDetailURLArray = [NSMutableArray array];
    
    [NotificationCenter addObserver:self selector:@selector(refreshRedDot) name:NTFMessagesSave object:nil];

    [self initTableView];
    
    [self reloadBannerData];
    [self reloadThemeData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshRedDot];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //计算最近一次加载数据时间是否已经超过十分钟，如果是，就自动刷新一次数据
    NSDate *lastUpdatedTime = [UserDefaults objectForKey:str_PostsList_UpdatedTime];
    if (lastUpdatedTime) {
        NSTimeInterval last = [lastUpdatedTime timeIntervalSince1970];
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];

        if ((now-last)/60 > 10) {//大于十分钟，自动重载一次数据
            [self reloadBannerData];
            [self reloadThemeData];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)createNavBarButton {
    self.leftBarButtonItem = [self createBarButtonItemWithNormalImageName:png_Btn_LeftMenu selectedImageName:png_Btn_LeftMenu selector:@selector(leftMenuAction:)];
//    self.rightBarButtonItem = [self createBarButtonItemWithNormalImageName:png_Btn_Add selectedImageName:png_Btn_Add selector:@selector(addAction:)];
}

- (void)refreshRedDot {
    //小红点
    if ([PlanCache hasUnreadMessages]) {
        [self.leftBarButtonItem showBadgeWithStyle:WBadgeStyleRedDot value:0 animationType:WBadgeAnimTypeNone];
        self.leftBarButtonItem.badgeCenterOffset = CGPointMake(-8, 0);
    } else {
        [self.leftBarButtonItem clearBadge];
    }
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
        [weakSelf reloadThemeData];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_header = header;
    self.tableView.mj_footer.hidden = YES;
}

#pragma mark - action
- (void)leftMenuAction:(UIButton *)button {
    [self.sideMenuViewController presentLeftMenuViewController];
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
//    bannerView.pageDotColor = [UIColor whiteColor]; //自定义分页控件小圆标颜色
    bannerView.placeholderImage = [UIImage imageNamed:png_ImageDefault_Rectangle];
    return bannerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return WIDTH_FULL_SCREEN / 3;
//    if (themeArray.count > indexPath.row) {
//        BmobObject *obj = themeArray[indexPath.row];
//        NSArray *imgURLArray = [NSArray arrayWithArray:[obj objectForKey:@"imgURLArray"]];
//        if (imgURLArray && imgURLArray.count > 0) {
//            return 275.f;
//        } else {
//            return 130.f;
//        }
//    } else {
//        return 44.f;
//    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (themeArray.count > 0) {
        return themeArray.count;
    } else {
        return 2;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_FULL_SCREEN, 30)];
    view.backgroundColor = color_e9eff1;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 10, WIDTH_FULL_SCREEN - 24, 10)];
    label.textColor = color_666666;
    label.font = font_Normal_16;
    label.text = @"主题计划";
    [view addSubview:label];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (themeArray.count > indexPath.row) {
        
        BmobObject *obj = themeArray[indexPath.row];
        NSString *name = [obj objectForKey:@"name"];
        NSString *imgURL = [obj objectForKey:@"imgURL"];

        ThemeCell *cell = [ThemeCell cellView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.labelName.text = name;
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[UIImage imageNamed:png_ImageDefault_Theme]];

        return cell;

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
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (themeArray.count > indexPath.row) {
        BmobObject *obj = themeArray[indexPath.row];
        [self toThemeList:obj];
    } else {
        [self reloadBannerData];
        [self reloadThemeData];
    }
}

#pragma mark - SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"banner被点击了第%ld张图片", (long)index);

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
                    isLoadingTheme = YES;
                    [self showHUD];
                    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
                        [weakSelf hideHUD];
                        isLoadingTheme = NO;
                        if (!error && array.count > 0) {
                            BmobObject *obj = array[0];
                            [weakSelf toThemeList:obj];
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

- (void)reloadThemeData {
    if (isLoadingTheme) return;
    
    isLoadingTheme = YES;
    [self showHUD];

    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Theme"];
    [bquery whereKey:@"isShow" equalTo:@"1"];
    [bquery orderByAscending:@"orderNo"];

    __weak typeof(self) weakSelf = self;
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {

        [weakSelf hideHUD];
        
        isLoadingTheme = NO;
        isLoadEnd = YES;
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
        //记录加载时间
        [UserDefaults setObject:[NSDate date] forKey:str_PostsList_UpdatedTime];
        [UserDefaults synchronize];
        
        themeArray = [NSMutableArray arrayWithArray:array];
        [self.tableView reloadData];
        
    }];
}

- (void)incrementBannerReadTimes:(BmobObject *)obj {
    BmobObject *banner = [BmobObject objectWithoutDataWithClassName:@"Banner" objectId:obj.objectId];
    //查看数加1
    [banner incrementKey:@"readTimes"];
    if ([LogIn isLogin]) {
        //新建relation对象
        BmobRelation *relation = [[BmobRelation alloc] init];
        BmobUser *user = [BmobUser currentUser];
        [relation addObject:[BmobObject objectWithoutDataWithClassName:@"_User" objectId:user.objectId]];
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

- (void)toThemeList:(BmobObject *)theme {
    ThemeViewController *controller = [[ThemeViewController alloc] init];
    controller.theme = theme;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
