//
//  MoreViewController.m
//  plan
//
//  Created by Fengzy on 15/9/1.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "HelpViewController.h"
#import "MoreViewController.h"
#import "AboutViewController.h"
#import "SettingsViewController.h"
#import "PersonalCenterViewController.h"

@implementation MoreViewController {

    NSArray *rowTitles;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = str_More;
    
    UIView *footer = [[UIView alloc] init];
    self.tableView.tableFooterView = footer;
    
    rowTitles = @[str_ViewTitle_4, str_More_Settings, str_ViewTitle_6, str_ViewTitle_7, str_ViewTitle_8, str_ViewTitle_9];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return rowTitles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.row >= rowTitles.count) {
        return cell;
    }
    cell.detailTextLabel.text = rowTitles[indexPath.row];
    cell.detailTextLabel.textColor = color_GrayDark;
    cell.detailTextLabel.font = font_Normal_18;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [self toPersonalCenterViewController];
            break;
        case 1:
            [self toPersonSettingViewController];
            break;
        case 2:
            [self toHelpViewController];
            break;
        case 3:
            [self toLike];
            break;
        case 4:
            [self toFeedback];
            break;
        case 5:
            [self toAboutViewController];
            break;
        default:
            break;
    }
}

- (void)toPersonalCenterViewController {
    
    PersonalCenterViewController *controller = [[PersonalCenterViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)toPersonSettingViewController {
    
    SettingsViewController *controller = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)toHelpViewController {
    
    HelpViewController *controller = [[HelpViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)toLike {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/app/id983206049?mt=8"]];
}

- (void)toFeedback {
    
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
    
}

- (void)toAboutViewController {
    
    AboutViewController *controller = [[AboutViewController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
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
