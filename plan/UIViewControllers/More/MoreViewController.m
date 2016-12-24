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

@implementation MoreViewController {

    NSArray *rowTitles;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = STRViewTitle24;
    
    UIView *footer = [[UIView alloc] init];
    self.tableView.tableFooterView = footer;
    
    rowTitles = @[STRViewTitle4, STRViewTitle18, STRViewTitle6, STRViewTitle7, STRViewTitle8, STRViewTitle9];
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
        [self alertButtonMessage:STRViewTips62];
        return;
    }
    if (![mailClass canSendMail]) {
        [self alertButtonMessage:STRViewTips63];
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
    NSString *subject = [NSString stringWithFormat:@"%@ V%@%@", STRViewTips69, [CommonFunction getAppVersion], device];
    [mailPicker setSubject:subject];
    //添加收件人
    NSArray *toRecipients = [NSArray arrayWithObject:STRFeedbackEmail];
    [mailPicker setToRecipients: toRecipients];
    
    [mailPicker setMessageBody:STRViewTips64 isHTML:YES];
    [self presentViewController:mailPicker animated:YES completion:nil];

}

#pragma mark - 实现 MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    //关闭邮件发送窗口
    [controller dismissViewControllerAnimated:YES completion:nil];
    NSString *msg;
    switch (result) {
        case MFMailComposeResultCancelled:
            msg = STRViewTips65;
            break;
        case MFMailComposeResultSaved:
            [self alertToastMessage:STRViewTips66];
            break;
        case MFMailComposeResultSent:
            [self alertToastMessage:STRViewTips67];
            break;
        case MFMailComposeResultFailed:
            [self alertButtonMessage:STRViewTips68];
            break;
        default:
            msg = @"";
            break;
    }
}

@end
