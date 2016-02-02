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

@interface ThreeViewController () <UIGestureRecognizerDelegate> {
    
    BOOL isTableEditing;
    NSMutableArray *taskArray;
    UILongPressGestureRecognizer *longPress;
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
    
    taskArray = [NSMutableArray array];
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

- (void)orderAction {
    if (taskArray.count == 0) {
        return;
    }
    //设置tableview编辑状态
    BOOL flag = !self.tableView.editing;
    [self.tableView setEditing:flag animated:YES];
    if (!flag) {
        isTableEditing = YES;
        for (NSInteger i = 0; i < taskArray.count; i++) {
            Task *task = taskArray[i];
            task.taskOrder = [NSString stringWithFormat:@"%ld", i];
            [PlanCache storeTask:task];
        }
        taskArray = [PlanCache getTeask];
        isTableEditing = NO;
    }
    //更换按钮icon
    if (flag) {
        self.rightBarButtonItem = [self createBarButtonItemWithTitle:@"完成" titleColor:[UIColor whiteColor] font:font_Normal_16 selector:@selector(orderAction)];
    } else {
        self.rightBarButtonItem = [self createBarButtonItemWithNormalImageName:png_Btn_Add selectedImageName:png_Btn_Add selector:@selector(addAction:)];
    }
}

- (void)reloadTaskData {
    if (isTableEditing) return;
    
    taskArray = [PlanCache getTeask];
    if (taskArray.count > 0) {
        longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        longPress.minimumPressDuration = 1.0;
        longPress.delegate = self;
        [self.tableView addGestureRecognizer:longPress];
    }
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
    task.taskOrder = [dict objectForKey:@"taskOrder"];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (taskArray.count > 0) {
        return 44.f;
    } else {
        return 0.00001f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (taskArray.count > 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_FULL_SCREEN, 44.f)];
        view.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kEdgeInset, 0, WIDTH_FULL_SCREEN - kEdgeInset * 2, 43.f)];
        label.textAlignment = NSTextAlignmentRight;
        label.text = @"长按任务可拖动排序";
        label.textColor = color_8f8f8f;
        [view addSubview:label];
        
        UILabel *labelLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 43.f, WIDTH_FULL_SCREEN, 1)];
        labelLine.backgroundColor = color_dedede;
        [view addSubview:labelLine];
        return view;
    } else {
        return nil;
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

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan
       && !self.tableView.editing) {
        [self orderAction];
    }
}

#pragma mark 选择编辑模式，添加模式很少用,默认是删除
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

#pragma mark 排序 当移动了某一行时候会调用
//编辑状态下，只要实现这个方法，就能实现拖动排序
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    //取出要拖动的模型数据
    Task *task = taskArray[sourceIndexPath.row];
    //删除之前行的数据
    [taskArray removeObject:task];
    // 插入数据到新的位置
    [taskArray insertObject:task atIndex:destinationIndexPath.row];
}

@end
