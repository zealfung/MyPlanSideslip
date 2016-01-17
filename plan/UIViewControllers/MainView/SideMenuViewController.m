//
//  SideMenuViewController.m
//  plan
//
//  Created by Fengzy on 15/11/12.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import <RESideMenu.h>
#import "DataCenter.h"
#import "WZLBadgeImport.h"
#import "HelpViewController.h"
#import "AboutViewController.h"
#import "PhotoViewController.h"
#import "MessagesViewController.h"
#import "SettingsViewController.h"
#import "SideMenuViewController.h"
#import "PersonalCenterViewController.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface SideMenuViewController () <MFMailComposeViewControllerDelegate> {
    NSMutableArray *menuImgArray;
    NSMutableArray *menuArray;
}

@end

@implementation SideMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.bounces = NO;
    self.tableView.backgroundColor = color_GrayDark;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [NotificationCenter addObserver:self selector:@selector(reload) name:Notify_Settings_Save object:nil];
    [NotificationCenter addObserver:self selector:@selector(reload) name:Notify_Messages_Save object:nil];
    
    [self setMenuArray];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [NotificationCenter removeObserver:self];
}

- (void)setMenuArray {
    
    menuImgArray = [NSMutableArray arrayWithObjects:png_Icon_Menu_PersonalCenter, png_Icon_Menu_PhotoLine, png_Icon_Menu_Help, png_Icon_Menu_FiveStar, png_Icon_Menu_Feedback, png_Icon_Menu_Messages, png_Icon_Menu_About, nil];
    menuArray = [NSMutableArray arrayWithObjects:str_ViewTitle_4, str_ViewTitle_5, str_ViewTitle_6, str_ViewTitle_7, str_ViewTitle_8, str_ViewTitle_12, str_ViewTitle_9, nil];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 160;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    UIView *headerView = [UIView new];
    UIColor *bgColor = [UIColor colorWithPatternImage: [UIImage imageNamed:png_Bg_SideTop]];
    headerView.backgroundColor = bgColor;
    
    UIImageView *avatar = [UIImageView new];
    avatar.contentMode = UIViewContentModeScaleAspectFit;
    [avatar setCornerRadius:30];
    avatar.userInteractionEnabled = YES;
    avatar.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:avatar];
    UIImage *image = [UIImage imageNamed:@"avatarDefault1"];
    if ([Config shareInstance].settings.avatar) {
//        avatar.image = [Config shareInstance].settings.avatar;
        image = [Config shareInstance].settings.avatar;
    }
    avatar.image = image;

    NSString *nickname = str_NickName;
    if ([Config shareInstance].settings.nickname) {
        
        nickname = [Config shareInstance].settings.nickname;
    }
    UILabel *nameLabel = [UILabel new];
    nameLabel.text = nickname;
    nameLabel.font = font_Bold_20;
    nameLabel.textColor = [CommonFunction getGenderColor];
    nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:nameLabel];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(avatar, nameLabel);
    NSDictionary *metrics = @{@"x": @([UIScreen mainScreen].bounds.size.width / 4 - 15)};
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[avatar(60)]-10-[nameLabel]-15-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-x-[avatar(60)]" options:0 metrics:metrics views:views]];
    
    avatar.userInteractionEnabled = YES;
    nameLabel.userInteractionEnabled = YES;
    [avatar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushLoginPage)]];
    [nameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushLoginPage)]];
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return menuArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    cell.backgroundColor = [UIColor clearColor];
    if (menuArray.count == 0) {
        return cell;
    }
    
    UIView *selectedBackground = [UIView new];
    selectedBackground.backgroundColor = [CommonFunction getGenderColor];
    [cell setSelectedBackgroundView:selectedBackground];
    cell.imageView.image = [UIImage imageNamed:menuImgArray[indexPath.row]];
    cell.textLabel.text = menuArray[indexPath.row];
    cell.textLabel.font = font_Normal_16;
    cell.textLabel.textColor = [UIColor whiteColor];
    if (indexPath.row == 5 && [PlanCache hasUnreadMessages]) {
        [cell.imageView showBadge];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0: {//个人中心
            PersonalCenterViewController *controller = [[PersonalCenterViewController alloc] init];
            [self setContentViewController:controller];
            break;
        }
        case 1: {//岁月影像
            PhotoViewController *controller = [[PhotoViewController alloc] init];
            [self setContentViewController:controller];
            break;
        }
        case 2: {//常见问题
            HelpViewController *controller = [[HelpViewController alloc] init];
            [self setContentViewController:controller];
            break;
        }
        case 3: {//五星鼓励
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/app/id983206049?mt=8"]];
            [self.sideMenuViewController hideMenuViewController];
            break;
        }
        case 4: {//建议反馈
            Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
            if (!mailClass) {
                [self alertButtonMessage:str_More_Feedback_Tips1];
                return;
            }
            if (![mailClass canSendMail]) {
                [self alertButtonMessage:str_More_Feedback_Tips2];
                return;
            }
            [self displayMailPicker];
            break;
        }
        case 5: {//系统消息
            MessagesViewController *controller = [[MessagesViewController alloc]init];
            [self setContentViewController:controller];
            break;
        }
        case 6: {//关于我们
            AboutViewController *controller = [[AboutViewController alloc]init];
            [self setContentViewController:controller];
        }
        default: break;
    }
}

- (void)setContentViewController:(UIViewController *)viewController {
    viewController.hidesBottomBarWhenPushed = YES;
    UINavigationController *navController = (UINavigationController *)((UITabBarController *)self.sideMenuViewController.contentViewController).selectedViewController;
    [navController pushViewController:viewController animated:NO];
    
    [self.sideMenuViewController hideMenuViewController];
}

- (void)pushLoginPage {
    UINavigationController *navController = (UINavigationController *)((UITabBarController *)self.sideMenuViewController.contentViewController).selectedViewController;
    SettingsViewController *controller = [[SettingsViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [navController pushViewController:controller animated:YES];
    
    [self.sideMenuViewController hideMenuViewController];
}

- (void)reload {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

//调出邮件发送窗口
- (void)displayMailPicker {
    
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.mailComposeDelegate = self;
    
    //设置主题
    NSString *device = [NSString stringWithFormat:@"（%@，iOS%@）", [CommonFunction getDeviceType], [CommonFunction getiOSVersion]];
    NSString *subject = [NSString stringWithFormat:@"%@ V%@%@", str_More_Feedback_Tips8, [CommonFunction getAppVersion], device];
    [mailPicker setSubject:subject];
    //添加收件人
    NSArray *toRecipients = [NSArray arrayWithObject:str_Feedback_Email];
    [mailPicker setToRecipients: toRecipients];
    
    [mailPicker setMessageBody:str_More_Feedback_Tips3 isHTML:YES];
    [self presentViewController:mailPicker animated:YES completion:nil];
    
}

#pragma mark - 实现 MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    //关闭邮件发送窗口
    [controller dismissViewControllerAnimated:YES completion:nil];
    NSString *msg;
    switch (result) {
        case MFMailComposeResultCancelled:
            msg = str_More_Feedback_Tips4;
            break;
        case MFMailComposeResultSaved:
            [self alertToastMessage:str_More_Feedback_Tips5];
            break;
        case MFMailComposeResultSent:
            [self alertToastMessage:str_More_Feedback_Tips6];
            break;
        case MFMailComposeResultFailed:
            [self alertButtonMessage:str_More_Feedback_Tips7];
            break;
        default:
            msg = @"";
            break;
    }
}

@end
