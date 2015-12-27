//
//  FourViewController.m
//  plan
//
//  Created by Fengzy on 15/12/19.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "PostsNoImageCell.h"
#import "PostsOneImageCell.h"
#import "PostsTwoImageCell.h"
#import "SDCycleScrollView.h"
#import "FourViewController.h"
#import "UIImageView+WebCache.h"
#import <RESideMenu/RESideMenu.h>

@interface FourViewController () <SDCycleScrollViewDelegate> {
    NSMutableArray *postsArray;
    NSArray *headerImagesURLArray;
    NSArray *headerTitlesArray;
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
    headerImagesURLArray = @[@"https://ss2.baidu.com/-vo3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a4b3d7085dee3d6d2293d48b252b5910/0e2442a7d933c89524cd5cd4d51373f0830200ea.jpg",
                             @"https://ss0.baidu.com/-Po3dSag_xI4khGko9WTAnF6hhy/super/whfpf%3D425%2C260%2C50/sign=a41eb338dd33c895a62bcb3bb72e47c2/5fdf8db1cb134954a2192ccb524e9258d1094a1e.jpg",
                             @"http://c.hiphotos.baidu.com/image/w%3D400/sign=c2318ff84334970a4773112fa5c8d1c0/b7fd5266d0160924c1fae5ccd60735fae7cd340d.jpg",
                                  @"http://file.bmob.cn/M02/FB/EF/oYYBAFZwp3uAbaT3AAYWayl5rTc443.png",
                                  @"http://file.bmob.cn/M02/FB/EF/oYYBAFZwp3SAV2t-AASOgiiHmA4853.png",
                                  @"http://file.bmob.cn/M02/FB/F0/oYYBAFZwp4KAfkI-AAg3Y3SaXls642.png"
                                  ];

    headerTitlesArray = @[@"好‘计’友，一辈子",
                          @"标题二",
                          @"标题三",
                          @"感谢您的支持，如果下载的",
                        @"如果代码在使用过程中出现问题",
                        @"您可以发邮件到gsdios@126.com",
                        @"感谢您的支持"
                        ];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableHeaderView = [self createTableHeaderView];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)createNavBarButton {
    self.leftBarButtonItem = [self createBarButtonItemWithNormalImageName:png_Btn_LeftMenu selectedImageName:png_Btn_LeftMenu selector:@selector(leftMenuAction:)];
    self.rightBarButtonItem = [self createBarButtonItemWithNormalImageName:png_Btn_Add selectedImageName:png_Btn_Add selector:@selector(addAction:)];
}

#pragma mark - action
- (void)leftMenuAction:(UIButton *)button {
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void)addAction:(UIButton *)button {
    
//    AddTaskViewController *controller = [[AddTaskViewController alloc] init];
//    controller.operationType = Add;
//    controller.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:controller animated:YES];
}

- (UIView *)createTableHeaderView {
    CGFloat fullViewHeight = HEIGHT_FULL_VIEW;
    CGFloat headerViewHeight = fullViewHeight / 3;
    SDCycleScrollView *cycleScrollView2 = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 320, WIDTH_FULL_SCREEN, headerViewHeight) imageURLStringsGroup:headerImagesURLArray];
    cycleScrollView2.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    cycleScrollView2.delegate = self;
    cycleScrollView2.titlesGroup = headerTitlesArray;
    cycleScrollView2.dotColor = [UIColor whiteColor]; //自定义分页控件小圆标颜色
    cycleScrollView2.placeholderImage = [UIImage imageNamed:@"placeholder"];
    //--- 模拟加载延迟
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        cycleScrollView2.imageURLStringsGroup = headerImagesURLArray;
//    });
    return cycleScrollView2;
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
    if (indexPath.row == 1) {
        return 140.f;
    }
    return 295.f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 1) {
        PostsNoImageCell *cell = [PostsNoImageCell cellView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.labelIsTop.hidden = YES;
        return cell;
    } else if (indexPath.row == 2) {
        PostsOneImageCell *cell = [PostsOneImageCell cellView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.labelIsTop.hidden = YES;
        [cell.imgViewOne sd_setImageWithURL:[NSURL URLWithString:@"http://file.bmob.cn/M02/FB/F0/oYYBAFZwp4KAfkI-AAg3Y3SaXls642.png"] placeholderImage:[UIImage imageNamed:png_Bg_SideTop]];
        return cell;
    } else {
        PostsTwoImageCell *cell = [PostsTwoImageCell cellView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.imgViewOne sd_setImageWithURL:[NSURL URLWithString:@"http://file.bmob.cn/M02/FB/F0/oYYBAFZwp4KAfkI-AAg3Y3SaXls642.png"] placeholderImage:[UIImage imageNamed:png_Bg_SideTop]];
        [cell.imgViewTwo sd_setImageWithURL:[NSURL URLWithString:@"http://file.bmob.cn/M02/FB/F0/oYYBAFZwp4KAfkI-AAg3Y3SaXls642.png"] placeholderImage:[UIImage imageNamed:png_Bg_SideTop]];
        __weak typeof(PostsTwoImageCell) *weakCell = cell;
        __weak typeof(self) weakSelf = self;
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
    
//    MemberDetailViewController *controller = [[MemberDetailViewController alloc] init];
//    controller.cardId = card.cardId;
//    [self.navigationController pushViewController:controller animated:YES];
    [self toPostsDetail:@"1"];
}

#pragma mark - SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"---点击了第%ld张图片", index);
}

- (void)toPostsDetail:(NSString *)postId {
}
@end
