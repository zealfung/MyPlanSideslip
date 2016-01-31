//
//  MessagesViewController.m
//  plan
//
//  Created by Fengzy on 15/12/8.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "LogIn.h"
#import "Messages.h"
#import "BmobQuery.h"
#import "BmobRelation.h"
#import "WZLBadgeImport.h"
#import <BmobSDK/BmobUser.h>
#import "MessagesViewController.h"
#import "PostsDetailViewController.h"
#import "MessagesDetailViewController.h"

@interface MessagesViewController () <UITableViewDataSource, UITableViewDelegate> {

    NSArray *messagesArray;
}

@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = str_ViewTitle_12;
    [self createNavBarButton];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    [NotificationCenter addObserver:self selector:@selector(reloadData) name:Notify_Messages_Save object:nil];
    
    messagesArray = [NSArray array];
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [NotificationCenter removeObserver:self];
}

- (void)createNavBarButton {
    self.rightBarButtonItem = [self createBarButtonItemWithNormalImageName:png_Btn_Clean selectedImageName:png_Btn_Clean selector:@selector(cleanHasRead)];
}

- (void)reloadData {
    messagesArray = [PlanCache getMessages];
    [self.tableView reloadData];
}

- (void)cleanHasRead {
    [PlanCache cleanHasReadMessages];
    [self alertToastMessage:str_Messages_Tips2];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (messagesArray.count > 0) {
        return messagesArray.count;
    } else {
        return 5;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    if (indexPath.row < messagesArray.count) {
        Messages *message = messagesArray[indexPath.row];
        static NSString *messageCellIdentifier = @"messageCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:messageCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:messageCellIdentifier];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = font_Normal_14;
        cell.textLabel.textColor = color_8f8f8f;
        cell.textLabel.text = message.title;
        cell.detailTextLabel.font = font_Normal_11;
        cell.detailTextLabel.textColor = color_8f8f8f;
        cell.detailTextLabel.text = message.content;
        if ([message.hasRead isEqualToString:@"0"]) {
            cell.textLabel.textColor = color_333333;
            cell.detailTextLabel.textColor = color_333333;
            [cell.detailTextLabel showBadgeWithStyle:WBadgeStyleNew value:0 animationType:WBadgeAnimTypeScale];
        } else {
            [cell.detailTextLabel clearBadge];
        }
        return cell;
    } else {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        static NSString *noMessageCellIdentifier = @"noMessageCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noMessageCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noMessageCellIdentifier];
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
            cell.textLabel.text = str_Messages_Tips1;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (messagesArray.count > 0) {
        
        Messages *message = messagesArray[indexPath.row];
        
        if ([message.messageType isEqualToString:@"2"]) {
            [self readNotice:message];
        } else {
            [self readSystemMessage:message];
        }
    }
}

- (void)readSystemMessage:(Messages *)message {
    if ([message.hasRead isEqualToString:@"0"]) {
        //本地标识已读
        [PlanCache setMessagesRead:message];
        //网络登记已读
        BmobObject *messages = [BmobObject objectWithoutDatatWithClassName:@"Messages" objectId:message.messageId];
        //查看数加1
        [messages incrementKey:@"readTimes"];
        if ([LogIn isLogin]) {
            //新建relation对象
            BmobRelation *relation = [[BmobRelation alloc] init];
            BmobUser *user = [BmobUser getCurrentUser];
            [relation addObject:[BmobObject objectWithoutDatatWithClassName:@"_User" objectId:user.objectId]];
            //添加关联关系到hasRead列中
            [messages addRelation:relation forKey:@"hasRead"];
        }
        [messages updateInBackground];
    }
    
    MessagesDetailViewController *controller = [[MessagesDetailViewController alloc] init];
    controller.message = message;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)readNotice:(Messages *)notice {
    if ([notice.hasRead isEqualToString:@"0"]) {
        //本地标识已读
        [PlanCache setMessagesRead:notice];
        //网络登记已读
        BmobObject *notices = [BmobObject objectWithoutDatatWithClassName:@"Notices" objectId:notice.messageId];
        [notices setObject:@"1" forKey:@"hasRead"];
        [notices updateInBackground];
    }
    [self showHUD];
    __weak typeof(self) weakSelf = self;
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Posts"];
    [bquery includeKey:@"author"];//声明该次查询需要将author关联对象信息一并查询出来
    [bquery getObjectInBackgroundWithId:notice.detailURL block:^(BmobObject *object,NSError *error){
        
        if (error){
            [weakSelf hideHUD];
            [weakSelf alertToastMessage:str_Messages_Tips4];
        } else {
            if (object) {
                [weakSelf isLikedPost:object];
                NSArray *imgURLArray = [NSArray arrayWithArray:[object objectForKey:@"imgURLArray"]];
                if (imgURLArray && imgURLArray > 0) {
                    for (NSString *imgURL in imgURLArray) {
                        UIImageView *tmpImgView = [[UIImageView alloc] init];
                        [tmpImgView sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:[UIImage imageNamed: png_AvatarDefault1]];
                    }
                }
            } else {
                [weakSelf hideHUD];
                [weakSelf alertToastMessage:str_Messages_Tips4];
            }
        }
    }];
}

- (void)isLikedPost:(BmobObject *)posts {
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Posts"];
    BmobQuery *inQuery = [BmobQuery queryWithClassName:@"UserSettings"];
    BmobUser *user = [BmobUser getCurrentUser];
    [inQuery whereKey:@"userObjectId" equalTo:user.objectId];
    //匹配查询
    [bquery whereKey:@"likes" matchesQuery:inQuery];//（查询所有有关联的数据）
    [bquery whereKey:@"objectId" equalTo:posts.objectId];
    __weak typeof(self) weakSelf = self;
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        [weakSelf hideHUD];
        if (!error && array.count > 0) {
            [posts setObject:@(YES) forKey:@"isLike"];
        } else {
            [posts setObject:@(NO) forKey:@"isLike"];
        }
        PostsDetailViewController *controller = [[PostsDetailViewController alloc] init];
        controller.posts = posts;
        [weakSelf.navigationController pushViewController:controller animated:YES];
    }];
}

@end
