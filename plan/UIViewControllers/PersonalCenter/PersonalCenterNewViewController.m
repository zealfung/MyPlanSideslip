//
//  PersonalCenterNewViewController.m
//  plan
//
//  Created by Fengzy on 16/4/15.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import "PersonalCenterNewCell0.h"
#import "SettingsViewController.h"
#import "SettingsPersonalViewController.h"
#import "PersonalCenterNewViewController.h"
#import "PersonalCenterMyPostsViewController.h"
#import "PersonalCenterUndonePlanViewController.h"

@interface PersonalCenterNewViewController ()

@end

@implementation PersonalCenterNewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = STRViewTitle4;
    [self createRightBarButton];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = color_eeeeee;
    [NotificationCenter addObserver:self selector:@selector(reloadTableView) name:NTFSettingsSave object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)createRightBarButton {
    self.rightBarButtonItem = [self createBarButtonItemWithNormalImageName:png_Btn_Settings selectedImageName:png_Btn_Settings selector:@selector(btnSettingsAction:)];
}

- (void)btnSettingsAction:(UIButton *)sender {
    SettingsViewController *controller = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)reloadTableView {
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 2;
        default:
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return 120.f;
        case 1:
            return kTableViewCellHeight;
        default:
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.001f;
    } else {
        return 10.f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        PersonalCenterNewCell0 *cell = [PersonalCenterNewCell0 cellView];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UITableViewCell description]];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[UITableViewCell description]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.textColor = color_Black;
            cell.textLabel.font = font_Normal_16;
        }
        if (indexPath.row == 0) {
            cell.textLabel.text = @"我的帖子";
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"未完计划";
        }
        return cell;
    } else {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
        {
            SettingsPersonalViewController *controller = [[SettingsPersonalViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 1:
        {
            if (indexPath.row == 0) {
                PersonalCenterMyPostsViewController *controller = [[PersonalCenterMyPostsViewController alloc] init];
                [self.navigationController pushViewController:controller animated:YES];
            } else if (indexPath.row == 1) {
                PersonalCenterUndonePlanViewController *controller = [[PersonalCenterUndonePlanViewController alloc] init];
                [self.navigationController pushViewController:controller animated:YES];
            }
        }
            break;
        default:
            break;
    }
}

@end
