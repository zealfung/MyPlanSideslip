//
//  SideMenuViewController.m
//  plan
//
//  Created by Fengzy on 15/11/12.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "SideMenuViewController.h"

@interface SideMenuViewController ()

@end

@implementation SideMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.bounces = NO;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 160;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    UIView *headerView = [UIView new];
    headerView.backgroundColor = [UIColor clearColor];
    
    UIImageView *avatar = [UIImageView new];
    avatar.contentMode = UIViewContentModeScaleAspectFit;
    [avatar setCornerRadius:30];
    avatar.userInteractionEnabled = YES;
    avatar.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:avatar];
    UIImage *image = [UIImage imageNamed:png_AvatarDefault];
    if ([Config shareInstance].settings.avatar) {
        
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
    NSString *gender = [Config shareInstance].settings.gender;
    if (gender && [gender isEqualToString:@"0"]) {
        nameLabel.textColor = color_Pink;
    } else {
        nameLabel.textColor = color_Blue;
    }
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
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell new];
    
    cell.backgroundColor = [UIColor clearColor];
    
    UIView *selectedBackground = [UIView new];
    selectedBackground.backgroundColor = color_Blue;
    [cell setSelectedBackgroundView:selectedBackground];
    
    cell.imageView.image = [UIImage imageNamed:@[@"sidemenu_QA", @"sidemenu-software", @"sidemenu_blog", @"sidemenu_setting", @"sidemenu-night"][indexPath.row]];
    cell.textLabel.text = @[@"技术问答", @"开源软件", @"博客区", @"设置", @"夜间模式", @"注销"][indexPath.row];
    
//    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode){
//        cell.textLabel.textColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
//        if (indexPath.row == 4) {
//            cell.textLabel.text = @"日间模式";
//            cell.imageView.image = [UIImage imageNamed:@"sidemenu-day"];
//        }
//    } else {
//        cell.textLabel.textColor = [UIColor colorWithHex:0x555555];
//        if (indexPath.row == 4) {
//            cell.textLabel.text = @"夜间模式";
//            cell.imageView.image = [UIImage imageNamed:@"sidemenu-night"];
//        }
//    }
    cell.textLabel.font = [UIFont systemFontOfSize:19];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0: {
//            SwipableViewController *newsSVC = [[SwipableViewController alloc] initWithTitle:@"技术问答"
//                                                                               andSubTitles:@[@"提问", @"分享", @"综合", @"职业", @"站务"]
//                                                                             andControllers:@[
//                                                                                              [[PostsViewController alloc] initWithPostsType:PostsTypeQA],
//                                                                                              [[PostsViewController alloc] initWithPostsType:PostsTypeShare],
//                                                                                              [[PostsViewController alloc] initWithPostsType:PostsTypeSynthesis],
//                                                                                              [[PostsViewController alloc] initWithPostsType:PostsTypeCaree],
//                                                                                              [[PostsViewController alloc] initWithPostsType:PostsTypeSiteManager]
//                                                                                              ]];
//            
//            [self setContentViewController:newsSVC];
            
            break;
        }
        case 1: {
//            SwipableViewController *softwaresSVC = [[SwipableViewController alloc] initWithTitle:@"开源软件"
//                                                                                    andSubTitles:@[@"分类", @"推荐", @"最新", @"热门", @"国产"]
//                                                                                  andControllers:@[
//                                                                                                   [[SoftwareCatalogVC alloc] initWithTag:0],
//                                                                                                   [[SoftwareListVC alloc] initWithSoftwaresType:SoftwaresTypeRecommended],
//                                                                                                   [[SoftwareListVC alloc] initWithSoftwaresType:SoftwaresTypeNewest],
//                                                                                                   [[SoftwareListVC alloc] initWithSoftwaresType:SoftwaresTypeHottest],
//                                                                                                   [[SoftwareListVC alloc] initWithSoftwaresType:SoftwaresTypeCN]
//                                                                                                   ]];
//            
//            [self setContentViewController:softwaresSVC];
            
            break;
        }
        case 2: {
//            SwipableViewController *blogsSVC = [[SwipableViewController alloc] initWithTitle:@"博客区"
//                                                                                andSubTitles:@[@"最新博客", @"推荐阅读"]
//                                                                              andControllers:@[
//                                                                                               [[BlogsViewController alloc] initWithBlogsType:BlogTypeLatest],
//                                                                                               [[BlogsViewController alloc] initWithBlogsType:BlogTypeRecommended]
//                                                                                               ]];
//            
//            [self setContentViewController:blogsSVC];
            
            break;
        }
        case 3: {
//            SettingsPage *settingPage = [SettingsPage new];
//            [self setContentViewController:settingPage];
            
            break;
        }
        case 4: {
//            isNight = [Config getMode];
//            if (isNight) {
//                ((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode = NO;
//            } else {
//                ((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode = YES;
//            }
//            self.tableView.backgroundColor = [UIColor titleBarColor];
//            [Config saveWhetherNightMode:!isNight];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"dawnAndNight" object:nil];
            //            isNight = !isNight;
        }
        default: break;
    }
}


- (void)setContentViewController:(UIViewController *)viewController
{
//    viewController.hidesBottomBarWhenPushed = YES;
//    UINavigationController *nav = (UINavigationController *)((UITabBarController *)self.sideMenuViewController.contentViewController).selectedViewController;
//    //UIViewController *vc = nav.viewControllers[0];
//    //vc.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:nil action:nil];
//    [nav pushViewController:viewController animated:NO];
//    
//    [self.sideMenuViewController hideMenuViewController];
}

#pragma mark - 点击登录
- (void)pushLoginPage {
//    if ([Config getOwnID] == 0) {
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
//        LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
//        [self setContentViewController:loginVC];
//    } else {
//        return;
//    }
}

- (void)reload
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

@end
