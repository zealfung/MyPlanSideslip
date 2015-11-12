//
//  ThreeViewController.m
//  plan
//
//  Created by Fengzy on 15/10/6.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "PlanCache.h"
#import "PhotoCell.h"
#import "ThreeViewController.h"
#import "AddPhotoViewController.h"
#import "PhotoDetailViewController.h"

@interface ThreeViewController ()

@property (nonatomic, strong) NSArray *photoArray;

@end

@implementation ThreeViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = str_ViewTitle_3;
    self.tabBarItem.title = str_ViewTitle_3;
    
    [self createRightBarButton];
    
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    UIView *footer = [[UIView alloc] init];
    self.tableView.tableFooterView = footer;
    
    self.photoArray = [NSArray array];
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

#pragma mark -添加导航栏按钮
- (void)createRightBarButton {
    
    self.rightBarButtonItem = [self createBarButtonItemWithNormalImageName:png_Btn_Add selectedImageName:png_Btn_Add selector:@selector(addAction:)];
    
}

#pragma mark - action
- (void)addAction:(UIButton *)button {
    
    AddPhotoViewController *controller = [[AddPhotoViewController alloc] init];
    controller.operationType = Add;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (void)reloadPhotoData {
    
    [self showHUD];
    self.photoArray = [NSArray arrayWithArray:[PlanCache getPhoto]];
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

    if (self.photoArray.count > 0) {
        
        return self.photoArray.count;
        
    } else {
        
        return 5;
        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.photoArray.count > 0) {
        
        return kPhotoCellHeight;
        
    } else {
        
        return 44.f;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < self.photoArray.count) {
        
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        Photo *photo = self.photoArray[indexPath.row];
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
    
    if (indexPath.row < self.photoArray.count) {
        
        PhotoDetailViewController *controller = [[PhotoDetailViewController alloc] init];
        controller.photo = self.photoArray[indexPath.row];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
        
    }
    
}

@end
