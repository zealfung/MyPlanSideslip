//
//  MessagesViewController.m
//  plan
//
//  Created by Fengzy on 15/12/8.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "WZLBadgeImport.h"
#import "MessagesViewController.h"

@interface MessagesViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = str_ViewTitle_12;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *TableSampleIdentifier = @"TableSampleIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableSampleIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:TableSampleIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = font_Normal_14;
    cell.textLabel.textColor = color_8f8f8f;
    cell.textLabel.text = @"消息标题";
    cell.detailTextLabel.font = font_Normal_11;
    cell.detailTextLabel.textColor = color_8f8f8f;
    cell.detailTextLabel.text = @"系统消息的明细摘要系统消息的明细摘要系统消息的明细摘要系统消息的明细摘要系统消息的明细摘要系统消息的明细摘要mo";
    if (indexPath.row == 2) {
        cell.textLabel.textColor = color_333333;
        cell.detailTextLabel.textColor = color_333333;
//        UIImage *image = [UIImage imageNamed:png_Icon_Alarm];
//        cell.imageView.image = image;
        [cell.detailTextLabel showBadgeWithStyle:WBadgeStyleNew value:0 animationType:WBadgeAnimTypeScale];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
