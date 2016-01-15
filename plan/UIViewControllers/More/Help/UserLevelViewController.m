//
//  UserLevelViewController.m
//  plan
//
//  Created by Fengzy on 16/1/14.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import "BmobObject.h"
#import "UserLevelViewController.h"

@interface UserLevelViewController ()

@end

@implementation UserLevelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = str_ViewTitle_16;
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.userTagsArray && self.userTagsArray.count > 0) {
        return self.userTagsArray.count;
    } else {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.userTagsArray.count > indexPath.row) {
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
        BmobObject *obj = self.userTagsArray[indexPath.row];
        cell.imageView.image = [CommonFunction getUserLevelIcon:[obj objectForKey:@"tagCode"]];
        cell.textLabel.text = [obj objectForKey:@"tagRemark"];
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
            cell.textLabel.text = str_Common_Tips6;
        } else {
            cell.textLabel.text = nil;
        }
        return cell;
    }
}

@end
