//
//  PersonalCenterTaskViewController.m
//  plan
//
//  Created by Fengzy on 2017/4/27.
//  Copyright © 2017年 Fengzy. All rights reserved.
//

#import "Task.h"
#import "MJRefresh.h"
#import <BmobSDK/BmobUser.h>
#import "TaskDetailNewViewController.h"
#import "PersonalCenterTaskViewController.h"

@interface PersonalCenterTaskViewController ()

@property (strong, nonatomic) NSMutableArray *taskArray;
@property (nonatomic, assign) BOOL isLoadMore;
@property (nonatomic, assign) BOOL isLoadingPosts;
@property (nonatomic, assign) BOOL isLoadEnd;
@property (nonatomic, assign) NSInteger startIndex;

@end

@implementation PersonalCenterTaskViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"我的任务";
    
    [self initTableView];
    
    self.taskArray = [NSMutableArray array];
    [NotificationCenter addObserver:self selector:@selector(toTask:) name:NTFLocalPush object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self reloadTaskData];
}

- (void)initTableView
{
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView setDefaultEmpty];
    __weak typeof(self) weakSelf = self;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf reloadTaskData];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_header = header;
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.isLoadMore = YES;
        [weakSelf reloadTaskData];
    }];
    self.tableView.mj_footer.hidden = YES;
}

- (void)reloadTaskData
{
    if (self.isLoadingPosts) return;
    
    self.isLoadingPosts = YES;
    if (!self.isLoadMore)
    {
        self.startIndex = 0;
        self.taskArray = [NSMutableArray array];
    }
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Task"];
    BmobUser *user = [BmobUser currentUser];
    if (!user)
    {
        return;
    }
    [bquery whereKey:@"userObjectId" equalTo:user.objectId];
    [bquery whereKey:@"isDeleted" equalTo:@"0"];
    [bquery orderByDescending:@"taskOrder"];
    bquery.limit = 10;
    bquery.skip = self.taskArray.count;
    
    [self showHUD];
    __weak typeof(self) weakSelf = self;
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
     {
         [weakSelf hideHUD];
         
         weakSelf.isLoadMore = NO;
         weakSelf.isLoadingPosts = NO;
         weakSelf.isLoadEnd = YES;
         [weakSelf.tableView.mj_header endRefreshing];
         [weakSelf.tableView.mj_footer endRefreshing];

         if (!error && array.count)
         {
             for (BmobObject *obj in array)
             {
                 Task *task = [[Task alloc] init];
                 task.taskId = obj.objectId;
                 task.content = [obj objectForKey:@"content"];
                 task.totalCount = [obj objectForKey:@"totalCount"];
                 task.completionDate = [obj objectForKey:@"completionDate"];
                 task.createTime = [obj objectForKey:@"createdTime"];
                 task.updateTime = [obj objectForKey:@"updatedTime"];
                 task.isNotify = @"0";
                 task.notifyTime = @"";
                 task.isTomato = @"0";
                 task.taskOrder = [obj objectForKey:@"taskOrder"];
                 task.isDeleted = @"0";
                 [weakSelf.taskArray addObject:task];
             }
         }
         [weakSelf.tableView reloadData];
     }];
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
    return self.taskArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    if (indexPath.row < self.taskArray.count)
    {
        Task *task = self.taskArray[indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UITableViewCell description]];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[UITableViewCell description]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.textColor = color_Black;
            cell.textLabel.font = font_Normal_16;
        }
        cell.textLabel.text = task.content;
        return cell;
    }
    else
    {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
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

@end
