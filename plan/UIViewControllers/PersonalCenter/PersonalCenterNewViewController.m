//
//  PersonalCenterNewViewController.m
//  plan
//
//  Created by Fengzy on 16/4/15.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import <BmobSDK/BmobUser.h>
#import "LogInViewController.h"
#import "PersonalCenterNewCell0.h"
#import "SettingsPersonalViewController.h"
#import "PersonalCenterNewViewController.h"
#import "PersonalCenterTaskViewController.h"
#import "PersonalCenterMyPostsViewController.h"
#import "PersonalCenterUndonePlanViewController.h"
#import "PersonalCenterTaskStatisticsViewController.h"

@interface PersonalCenterNewViewController ()

@property (nonatomic, strong) NSMutableArray *titleArray;
@property (nonatomic, assign) NSInteger planCount;
@property (nonatomic, assign) NSInteger photoCount;

@end

@implementation PersonalCenterNewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = STRViewTitle4;

    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = color_eeeeee;
    [NotificationCenter addObserver:self selector:@selector(reloadTableView) name:NTFSettingsSave object:nil];
    
    self.titleArray = [NSMutableArray arrayWithObjects:@"我的帖子", @"未完计划", @"我的任务", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([LogIn isLogin])
    {
        [self getCount];
    }
}

- (void)reloadTableView
{
    [self.tableView reloadData];
}

- (void)getCount
{
    [self showHUD];
    BmobUser *user = [BmobUser currentUser];
    __weak typeof(self) weakSelf = self;
    BmobQuery *queryPlan = [BmobQuery queryWithClassName:@"Plan"];
    [queryPlan whereKey:@"userObjectId" equalTo:user.objectId];
    [queryPlan whereKey:@"isDeleted" notEqualTo:@"1"];
    [queryPlan countObjectsInBackgroundWithBlock:^(int number,NSError  *error)
     {
         [weakSelf hideHUD];
         if (!error)
         {
             weakSelf.planCount = number;
             [weakSelf.tableView reloadData];
         }
    }];

    BmobQuery *queryPhoto = [BmobQuery queryWithClassName:@"Photo"];
    [queryPhoto whereKey:@"userObjectId" equalTo:user.objectId];
    [queryPhoto whereKey:@"isDeleted" notEqualTo:@"1"];
    [queryPhoto countObjectsInBackgroundWithBlock:^(int number,NSError  *error)
     {
         [weakSelf hideHUD];
         if (!error)
         {
             weakSelf.photoCount = number;
             [weakSelf.tableView reloadData];
         }
     }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return 1;
        case 1:
            return self.titleArray.count;
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
            return 120.f;
        case 1:
            return kTableViewCellHeight;
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 0.001f;
    }
    else
    {
        return 10.f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
        {
            PersonalCenterNewCell0 *cell = [PersonalCenterNewCell0 cellView];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.labelPlanCount.text = [NSString stringWithFormat: @"%ld 计划", self.planCount];
            cell.labelPhotoCount.text = [NSString stringWithFormat: @"%ld 影像", self.photoCount];
            return cell;
        }
            break;
        case 1:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UITableViewCell description]];
            if (!cell)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[UITableViewCell description]];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.textColor = color_Black;
                cell.textLabel.font = font_Normal_16;
            }
            if (indexPath.row < self.titleArray.count)
            {
                cell.textLabel.text = self.titleArray[indexPath.row];
            }
            return cell;
        }
            break;
        default:
        {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            return cell;
        }
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section)
    {
        case 0:
        {
            SettingsPersonalViewController *controller = [[SettingsPersonalViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 1:
        {
            BmobUser *user = [BmobUser currentUser];
            if (user)
            {
                if (indexPath.row == 0)
                {
                    PersonalCenterMyPostsViewController *controller = [[PersonalCenterMyPostsViewController alloc] init];
                    [self.navigationController pushViewController:controller animated:YES];
                    
                }
                else if (indexPath.row == 1)
                {
                    PersonalCenterUndonePlanViewController *controller = [[PersonalCenterUndonePlanViewController alloc] init];
                    [self.navigationController pushViewController:controller animated:YES];
                }
                else if (indexPath.row == 2)
                {
                    PersonalCenterTaskViewController *controller = [[PersonalCenterTaskViewController alloc] init];
                    [self.navigationController pushViewController:controller animated:YES];
                }
            }
            else
            {
                LogInViewController *controller = [[LogInViewController alloc] init];
                [self.navigationController pushViewController:controller animated:YES];
            }
        }
            break;
        default:
            break;
    }
}

@end
