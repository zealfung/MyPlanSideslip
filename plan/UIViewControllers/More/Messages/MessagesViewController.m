//
//  MessagesViewController.m
//  plan
//
//  Created by Fengzy on 15/12/8.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "LogIn.h"
#import "Messages.h"
#import "WZLBadgeImport.h"
#import <BmobSDK/BmobUser.h>
#import <BmobSDK/BmobQuery.h>
#import <BmobSDK/BmobRelation.h>
#import "MessagesViewController.h"
#import "PostsDetailViewController.h"
#import "MessagesDetailViewController.h"

@interface MessagesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *arrayMsg;

@end

@implementation MessagesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = STRViewTitle12;

    __weak typeof(self) weakSelf = self;
    [self customRightButtonWithImage:[UIImage imageNamed:png_Btn_Clean] action:^(UIButton *sender)
    {
        [weakSelf cleanHasRead];
    }];
    
    [self initTableView];
    
    [NotificationCenter addObserver:self selector:@selector(reloadData) name:NTFMessagesSave object:nil];
    
    [self reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)initTableView
{
    self.arrayMsg = [NSArray array];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.tableView setDefaultEmpty];
}

- (void)reloadData
{
    self.arrayMsg = [PlanCache getMessages];
    [self.tableView reloadData];
}

- (void)cleanHasRead
{
    [PlanCache cleanHasReadMessages];
    [self alertToastMessage:STRViewTips113];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayMsg.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    if (indexPath.row < self.arrayMsg.count)
    {
        Messages *message = self.arrayMsg[indexPath.row];
        static NSString *messageCellIdentifier = @"messageCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:messageCellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:messageCellIdentifier];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = font_Normal_14;
        cell.textLabel.textColor = color_8f8f8f;
        cell.textLabel.text = message.title;
        cell.detailTextLabel.font = font_Normal_11;
        cell.detailTextLabel.textColor = color_8f8f8f;
        cell.detailTextLabel.text = message.content;
        if ([message.hasRead isEqualToString:@"0"])
        {
            cell.textLabel.textColor = color_333333;
            cell.detailTextLabel.textColor = color_333333;
            [cell.detailTextLabel showBadgeWithStyle:WBadgeStyleNew value:0 animationType:WBadgeAnimTypeScale];
        }
        else
        {
            [cell.detailTextLabel clearBadge];
        }
        return cell;
    }
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.arrayMsg.count > 0)
    {
        Messages *message = self.arrayMsg[indexPath.row];
        
        if ([message.messageType isEqualToString:@"2"])
        {
            [self readNotice:message];
        }
        else
        {
            [self readSystemMessage:message];
        }
    }
}

- (void)readSystemMessage:(Messages *)message
{
    if ([message.hasRead isEqualToString:@"0"])
    {
        //本地标识已读
        [PlanCache setMessagesRead:message];
        //网络登记已读
        BmobObject *messages = [BmobObject objectWithoutDataWithClassName:@"Messages" objectId:message.messageId];
        //查看数加1
        [messages incrementKey:@"readTimes"];
        if ([LogIn isLogin])
        {
            //新建relation对象
            BmobRelation *relation = [[BmobRelation alloc] init];
            BmobUser *user = [BmobUser currentUser];
            [relation addObject:[BmobObject objectWithoutDataWithClassName:@"_User" objectId:user.objectId]];
            //添加关联关系到hasRead列中
            [messages addRelation:relation forKey:@"hasRead"];
        }
        [messages updateInBackground];
    }
    
    MessagesDetailViewController *controller = [[MessagesDetailViewController alloc] init];
    controller.message = message;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)readNotice:(Messages *)notice
{
    if ([notice.hasRead isEqualToString:@"0"])
    {
        //本地标识已读
        [PlanCache setMessagesRead:notice];
        //网络登记已读
        BmobObject *notices = [BmobObject objectWithoutDataWithClassName:@"Notices" objectId:notice.messageId];
        [notices setObject:@"1" forKey:@"hasRead"];
        [notices updateInBackground];
    }
    [self showHUD];
    __weak typeof(self) weakSelf = self;
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Posts"];
    [bquery includeKey:@"author"];//声明该次查询需要将author关联对象信息一并查询出来
    [bquery getObjectInBackgroundWithId:notice.detailURL block:^(BmobObject *object,NSError *error)
    {
        if (error)
        {
            [weakSelf hideHUD];
            [weakSelf alertToastMessage:STRViewTips115];
        }
        else
        {
            if (object)
            {
                [weakSelf isLikedPost:object];
                [weakSelf incrementPostsReadTimes:object];
                NSArray *imgURLArray = [NSArray arrayWithArray:[object objectForKey:@"imgURLArray"]];
                if (imgURLArray && imgURLArray > 0)
                {
                    for (NSString *imgURL in imgURLArray)
                    {
                        UIImageView *tmpImgView = [[UIImageView alloc] init];
                        [tmpImgView sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[UIImage imageNamed: png_AvatarDefault1]];
                    }
                }
            }
            else
            {
                [weakSelf hideHUD];
                [weakSelf alertToastMessage:STRViewTips115];
            }
        }
    }];
}

- (void)isLikedPost:(BmobObject *)posts
{
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Posts"];
    BmobQuery *inQuery = [BmobQuery queryWithClassName:@"UserSettings"];
    BmobUser *user = [BmobUser currentUser];
    [inQuery whereKey:@"userObjectId" equalTo:user.objectId];
    //匹配查询
    [bquery whereKey:@"likes" matchesQuery:inQuery];//（查询所有有关联的数据）
    [bquery whereKey:@"objectId" equalTo:posts.objectId];
    __weak typeof(self) weakSelf = self;
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
    {
        [weakSelf hideHUD];
        if (!error && array.count > 0)
        {
            [posts setObject:@(YES) forKey:@"isLike"];
        }
        else
        {
            [posts setObject:@(NO) forKey:@"isLike"];
        }
        PostsDetailViewController *controller = [[PostsDetailViewController alloc] init];
        controller.posts = posts;
        [weakSelf.navigationController pushViewController:controller animated:YES];
    }];
}

- (void)incrementPostsReadTimes:(BmobObject *)posts
{
    BmobObject *obj = [BmobObject objectWithoutDataWithClassName:@"Posts" objectId:posts.objectId];
    //查看数加1
    [obj incrementKey:@"readTimes"];
    //异步更新obj的数据
    [obj updateInBackground];
}

@end
