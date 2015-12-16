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
            //        UIImage *image = [UIImage imageNamed:png_Icon_Alarm];
            //        cell.imageView.image = image;
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
        } else {
            cell.textLabel.text = nil;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (messagesArray.count > 0) {
        
        Messages *message = messagesArray[indexPath.row];
        
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
            //异步更新obj的数据
            [messages updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                if (isSuccessful) {
                    NSLog(@"successful");
                }else{
                    NSLog(@"error %@",[error description]);
                }
            }];
        }
        
        MessagesDetailViewController *controller = [[MessagesDetailViewController alloc] init];
        controller.message = message;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
