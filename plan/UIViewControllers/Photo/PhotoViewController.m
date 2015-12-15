//
//  PhotoViewController.m
//  plan
//
//  Created by Fengzy on 15/11/17.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "PhotoCell.h"
#import "MJRefresh.h"
#import "PhotoViewController.h"
#import "AddPhotoViewController.h"
#import "PhotoDetailViewController.h"

@interface PhotoViewController () {
    
    NSMutableArray *photoArray;
    NSInteger photoTotal;
    NSInteger loadStart;
    BOOL isLoadMore;
}

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = str_ViewTitle_5;
    [self createNavBarButton];
    
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.tableFooterView = [[UIView alloc] init];
    __weak typeof(self) weakSelf = self;
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        isLoadMore = YES;
        [weakSelf reloadPhotoData];
    }];
    self.tableView.mj_footer.hidden = YES;
    
    [NotificationCenter addObserver:self selector:@selector(reloadPhotoData) name:Notify_Photo_Save object:nil];
    [NotificationCenter addObserver:self selector:@selector(refreshTable) name:Notify_Photo_RefreshOnly object:nil];
    
    [self reloadPhotoData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [NotificationCenter removeObserver:self];
}

- (void)createNavBarButton {
    self.rightBarButtonItem = [self createBarButtonItemWithNormalImageName:png_Btn_Add selectedImageName:png_Btn_Add selector:@selector(addAction:)];
}

- (void)addAction:(UIButton *)button {
    AddPhotoViewController *controller = [[AddPhotoViewController alloc] init];
    controller.operationType = Add;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)reloadPhotoData {
    [self showHUD];
    photoTotal = [[PlanCache getPhotoTotalCount] integerValue];
    if (!isLoadMore) {
        loadStart = 0;
        photoArray = [NSMutableArray array];
    }
    [photoArray addObjectsFromArray:[PlanCache getPhoto:loadStart]];
    isLoadMore = NO;
    if (loadStart < photoTotal) {
        loadStart += kPhotoLoadMax;
    } else {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
    [self.tableView.mj_footer endRefreshing];
    
    [self.tableView reloadData];
    [self hideHUD];
}

- (void)refreshTable {
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (photoArray.count > 0) {
        return photoArray.count;
    } else {
        return 5;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (photoArray.count > 0) {
        return kPhotoCellHeight;
    } else {
        return 44.f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < photoArray.count) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        Photo *photo = photoArray[indexPath.row];
        PhotoCell *cell = [PhotoCell cellView:photo];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        static NSString *noticeCellIdentifier = @"noPhotoCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noticeCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noticeCellIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"";
            cell.textLabel.frame = cell.contentView.bounds;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.textLabel.font = font_Bold_16;
        }
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        if (indexPath.row == 4) {
            cell.textLabel.text = str_Photo_Tips1;
        } else {
            cell.textLabel.text = nil;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < photoArray.count) {
        PhotoDetailViewController *controller = [[PhotoDetailViewController alloc] init];
        controller.photo = photoArray[indexPath.row];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
