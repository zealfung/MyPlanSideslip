//
//  ThreeViewController.m
//  plan
//
//  Created by Fengzy on 15/10/6.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "Task.h"
#import "TaskCell.h"
#import "WZLBadgeImport.h"
#import "ThreeViewController.h"
#import "AddTaskViewController.h"
#import <RESideMenu/RESideMenu.h>
#import "TaskDetailViewController.h"

@interface ThreeViewController () {
    
    NSArray *taskArray;
}

@end

@implementation ThreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = str_ViewTitle_3;
    self.tabBarItem.title = str_ViewTitle_3;
    [self createNavBarButton];
    
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    taskArray = [NSArray array];
    [NotificationCenter addObserver:self selector:@selector(toTask:) name:Notify_Push_LocalNotify object:nil];
    [NotificationCenter addObserver:self selector:@selector(reloadTaskData) name:Notify_Task_Save object:nil];
    [NotificationCenter addObserver:self selector:@selector(refreshRedDot) name:Notify_Messages_Save object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [self reloadTaskData];
    [self checkUnread:self.tabBarController.tabBar index:2];
    [self refreshRedDot];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [NotificationCenter removeObserver:self];
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
    
    AddTaskViewController *controller = [[AddTaskViewController alloc] init];
    controller.operationType = Add;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)reloadTaskData {
    taskArray = [PlanCache getTeask];
    [self.tableView reloadData];
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

- (void)toTask:(NSNotification*)notification {
    NSDictionary *dict = notification.userInfo;
    NSInteger type = [[dict objectForKey:@"type"] integerValue];
    if (type != 1) {//非任务提醒
        return;
    }
    Task *task = [[Task alloc] init];
    task.account = [dict objectForKey:@"account"];
    task.taskId = [dict objectForKey:@"tag"];
    task.content = [dict objectForKey:@"content"];
    task.totalCount = [dict objectForKey:@"totalCount"];
    task.completionDate = [dict objectForKey:@"completionDate"];
    task.createTime = [dict objectForKey:@"createTime"];
    task.updateTime = [dict objectForKey:@"updateTime"];
    task.isNotify = [dict objectForKey:@"isNotify"];
    task.notifyTime = [dict objectForKey:@"notifyTime"];
    task.isTomato = [dict objectForKey:@"isTomato"];
    task.tomatoMinute = [dict objectForKey:@"tomatoMinute"];
    task.isRepeat = [dict objectForKey:@"isRepeat"];
    task.repeatType = [dict objectForKey:@"repeatType"];
    task.isDeleted = @"0";
    
    TaskDetailViewController *controller = [[TaskDetailViewController alloc]init];
    controller.task = task;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (taskArray.count > 0) {
        return taskArray.count;
    } else {
        return 5;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (taskArray.count > 0) {
        return 60.f;
    } else {
        return 44.f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < taskArray.count) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        Task *task = taskArray[indexPath.row];
        TaskCell *cell = [TaskCell cellView:task];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        static NSString *noTaskCellIdentifier = @"noTaskCellIdentifier";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noTaskCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noTaskCellIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"";
            cell.textLabel.frame = cell.contentView.bounds;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.textLabel.font = font_Bold_16;
        }
        if (indexPath.row == 4) {
            cell.textLabel.text = str_Task_Tips1;
        } else {
            cell.textLabel.text = nil;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < taskArray.count) {
        TaskDetailViewController *controller = [[TaskDetailViewController alloc]init];
        controller.task = taskArray[indexPath.row];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
