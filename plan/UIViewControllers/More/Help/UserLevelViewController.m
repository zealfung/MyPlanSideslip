//
//  UserLevelViewController.m
//  plan
//
//  Created by Fengzy on 16/1/14.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import "UserLevel.h"
#import "UserLevelViewController.h"

@interface UserLevelViewController () {
    NSMutableArray *levelArray;
}

@end

@implementation UserLevelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"用户身份标识说明";
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    [self setLevelArray];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setLevelArray {
    levelArray = [NSMutableArray array];
    UserLevel *userLevel9 = [[UserLevel alloc] init];
    userLevel9.level = @"9";
    userLevel9.remark = @"管理员";
    UserLevel *userLevel8 = [[UserLevel alloc] init];
    userLevel8.level = @"8";
    userLevel8.remark = @"iOS内测资格";
    UserLevel *userLevel7 = [[UserLevel alloc] init];
    userLevel7.level = @"7";
    userLevel7.remark = @"Android内测资格";
    UserLevel *userLevel6 = [[UserLevel alloc] init];
    userLevel6.level = @"6";
    userLevel6.remark = @"活跃用户";
    UserLevel *userLevel5 = [[UserLevel alloc] init];
    userLevel5.level = @"5";
    userLevel5.remark = @"高级用户";
    UserLevel *userLevel4 = [[UserLevel alloc] init];
    userLevel4.level = @"4";
    userLevel4.remark = @"普通用户";
    
    [levelArray addObject:userLevel9];
    [levelArray addObject:userLevel8];
    [levelArray addObject:userLevel7];
    [levelArray addObject:userLevel6];
    [levelArray addObject:userLevel5];
    [levelArray addObject:userLevel4];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (levelArray.count > 0) {
        return levelArray.count;
    } else {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (levelArray.count > indexPath.row) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        static NSString *levelCellIdentifier = @"levelCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:levelCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:levelCellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"";
            cell.textLabel.frame = cell.contentView.bounds;
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.textLabel.textColor = color_333333;
            cell.textLabel.font = font_Normal_16;
        }
        UserLevel *userLevel = levelArray[indexPath.row];
        cell.imageView.image = [CommonFunction getUserLevelIcon:userLevel.level];
        cell.textLabel.text = userLevel.remark;
        return cell;
    } else {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
        if (indexPath.row == 2) {
            cell.textLabel.text = @"暂无内容";
        } else {
            cell.textLabel.text = nil;
        }
        return cell;
    }
}


@end
