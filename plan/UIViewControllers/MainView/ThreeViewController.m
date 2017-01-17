//
//  ThreeViewController.m
//  plan
//
//  Created by Fengzy on 15/10/6.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "Task.h"
#import "TaskCell.h"
#import <BmobSDK/BmobUser.h>
#import "ThreeViewController.h"
#import "AddTaskNewViewController.h"
#import "TaskDetailNewViewController.h"

@interface ThreeViewController () <UIGestureRecognizerDelegate>

@property (assign, nonatomic) BOOL isTableEditing;
@property (strong, nonatomic) NSMutableArray *taskArray;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPress;

@end

@implementation ThreeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = STRViewTitle3;
    self.tabBarItem.title = STRViewTitle3;

    __weak typeof(self) weakSelf = self;
    [self customRightButtonWithImage:[UIImage imageNamed:png_Btn_Add] action:^(UIButton *sender)
     {
         [weakSelf addAction];
     }];
    
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.taskArray = [NSMutableArray array];
    [NotificationCenter addObserver:self selector:@selector(toTask:) name:NTFLocalPush object:nil];
    [NotificationCenter addObserver:self selector:@selector(reloadTaskData) name:NTFTaskSave object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self reloadTaskData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)addAction
{
    AddTaskNewViewController *controller = [[AddTaskNewViewController alloc] init];
    controller.operationType = Add;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)orderAction
{
    if (self.taskArray.count == 0)
    {
        return;
    }
    //设置tableview编辑状态
    BOOL flag = !self.tableView.editing;
    [self.tableView setEditing:flag animated:YES];
    if (!flag)
    {
        self.isTableEditing = YES;
        NSString *timenow = [CommonFunction getTimeNowString];
        for (NSInteger i = 0; i < self.taskArray.count; i++)
        {
            Task *task = self.taskArray[i];
            task.updateTime = timenow;
            [PlanCache storeTask:task updateNotify:NO];
        }
        self.taskArray = [PlanCache getTask];
        self.isTableEditing = NO;
    }
    //更换按钮icon
    if (flag)
    {
        __weak typeof(self) weakSelf = self;
        [self customRightButtonWithTitle:STRViewTips123 action:^(UIButton *sender)
        {
            [weakSelf orderAction];
        }];
    }
    else
    {
        __weak typeof(self) weakSelf = self;
        [self customRightButtonWithImage:[UIImage imageNamed:png_Btn_Add] action:^(UIButton *sender)
         {
             [weakSelf addAction];
         }];
    }
}

- (void)reloadTaskData
{
    if (self.isTableEditing) return;
    
    self.taskArray = [NSMutableArray arrayWithArray:[PlanCache getTask]];
    if (self.taskArray.count > 0)
    {
        self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        self.longPress.minimumPressDuration = 1.0;
        self.longPress.delegate = self;
        [self.tableView addGestureRecognizer:self.longPress];
    }
    [self.tableView reloadData];
}

- (void)toTask:(NSNotification*)notification
{
    NSDictionary *dict = notification.userInfo;
    NSInteger type = [[dict objectForKey:@"type"] integerValue];
    if (type != 1)
    {//非任务提醒
        return;
    }
    Task *task = [[Task alloc] init];
    task.account = [dict objectForKey:@"account"];
    BmobUser *user = [BmobUser currentUser];
    if ((user && [task.account isEqualToString:user.objectId])
        || (!user && [task.account isEqualToString:@""]))
    {
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
        
        TaskDetailNewViewController *controller = [[TaskDetailNewViewController alloc]init];
        controller.task = task;
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.taskArray.count)
    {
        return self.taskArray.count;
    }
    else
    {
        return 5;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.taskArray.count)
    {
        return 60.f;
    }
    else
    {
        return 44.f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.taskArray.count > 0)
    {
        return 44.f;
    }
    else
    {
        return 0.01f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.taskArray.count)
    {
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
    }
    else
    {
        return [[UIView alloc] init];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.taskArray.count)
    {
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        Task *task = self.taskArray[indexPath.row];
        TaskCell *cell = [TaskCell cellView:task];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        static NSString *noTaskCellIdentifier = @"noTaskCellIdentifier";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noTaskCellIdentifier];
        if (!cell)
        {
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
        if (indexPath.row == 4)
        {
            cell.textLabel.text = STRViewTips38;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.taskArray.count)
    {
        TaskDetailNewViewController *controller = [[TaskDetailNewViewController alloc]init];
        controller.task = self.taskArray[indexPath.row];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan
       && !self.tableView.editing)
    {
        [self orderAction];
    }
}

#pragma mark 选择编辑模式，添加模式很少用,默认是删除
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

#pragma mark 排序 当移动了某一行时候会调用
//编辑状态下，只要实现这个方法，就能实现拖动排序
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    //取出要拖动的模型数据
    Task *task = self.taskArray[sourceIndexPath.row];
    //删除之前行的数据
    [self.taskArray removeObject:task];
    task.taskOrder = [NSString stringWithFormat:@"%ld", (long)destinationIndexPath.row];
    // 插入数据到新的位置
    [self.taskArray insertObject:task atIndex:destinationIndexPath.row];
}

@end
