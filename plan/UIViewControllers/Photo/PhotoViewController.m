//
//  PhotoViewController.m
//  plan
//
//  Created by Fengzy on 15/11/17.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "PhotoCell.h"
#import "MJRefresh.h"
#import "PhotoViewController.h"
#import "LogInViewController.h"
#import "AddPhotoViewController.h"
#import "PhotoDetailViewController.h"

@interface PhotoViewController ()

@property(nonatomic, strong) NSMutableArray *photoArray;
@property(nonatomic, assign) BOOL isLoadingPhoto;

@end

@implementation PhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = STRViewTitle5;

    __weak typeof(self) weakSelf = self;
    [self customRightButtonWithImage:[UIImage imageNamed:png_Btn_Add] action:^(UIButton *sender) {
        if ([LogIn isLogin])
        {
            AddPhotoViewController *controller = [[AddPhotoViewController alloc] init];
            controller.operationType = Add;
            controller.hidesBottomBarWhenPushed = YES;
            [weakSelf.navigationController pushViewController:controller animated:YES];
        }
        else
        {
            LogInViewController *controller = [[LogInViewController alloc] init];
            controller.hidesBottomBarWhenPushed = YES;
            [weakSelf.navigationController pushViewController:controller animated:YES];
        }
    }];
    
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.photoArray = [NSMutableArray array];
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.photoArray = [NSMutableArray array];
        [weakSelf reloadPhotoData];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_header = header;
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf reloadPhotoData];
    }];
    
    [NotificationCenter addObserver:self selector:@selector(reloadPhotoData) name:NTFPhotoSave object:nil];
    [NotificationCenter addObserver:self selector:@selector(refreshTable) name:NTFPhotoRefreshOnly object:nil];
    
    [self reloadPhotoData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)reloadPhotoData
{
    if (self.isLoadingPhoto)
    {
        return;
    }
    self.isLoadingPhoto = YES;
    
    [self showHUD];
    BmobUser *user = [BmobUser currentUser];
    __weak typeof(self) weakSelf = self;
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Photo"];
    [bquery whereKey:@"userObjectId" equalTo:user.objectId];
    [bquery whereKey:@"isDeleted" notEqualTo:@"1"];
    [bquery orderByDescending:@"updatedTime"];
    bquery.limit = 100;
    bquery.skip = self.photoArray.count;
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
    {
         [weakSelf hideHUD];
         weakSelf.isLoadingPhoto = NO;
         [weakSelf.tableView.mj_header endRefreshing];
         [weakSelf.tableView.mj_footer endRefreshing];
         
         if (!error && array.count)
         {
             for (BmobObject *obj in array)
             {
                 Photo *photo = [[Photo alloc] init];
                 photo.account = [obj objectForKey:@"userObjectId"];
                 photo.photoid = obj.objectId;
                 photo.content = [obj objectForKey:@"content"];
                 photo.createtime = [obj objectForKey:@"createdTime"];
                 photo.phototime = [obj objectForKey:@"photoTime"];
                 photo.updatetime = [obj objectForKey:@"updatedTime"];
                 photo.location = [obj objectForKey:@"location"];
                 photo.photoURLArray = [NSMutableArray array];
                 for (NSInteger n = 0; n < 9; n++)
                 {
                     NSString *key = [NSString stringWithFormat:@"photo%ldURL", (long)(n + 1)];
                     if ([obj objectForKey:key])
                     {
                         [photo.photoURLArray addObject:[obj objectForKey:key]];
                     }
                 }

                 [weakSelf.photoArray addObject:photo];
             }
         }
         [weakSelf refreshTable];
     }];
}

- (void)refreshTable
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.photoArray.count)
    {
        return self.photoArray.count;
    }
    else
    {
        return 5;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.photoArray.count)
    {
        return kPhotoCellHeight;
    }
    else
    {
        return 44.f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (indexPath.row < self.photoArray.count)
    {
        Photo *photo = self.photoArray[indexPath.row];
        PhotoCell *cell = [PhotoCell cellView:photo];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        static NSString *noticeCellIdentifier = @"noPhotoCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noticeCellIdentifier];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noticeCellIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"";
            cell.textLabel.frame = cell.contentView.bounds;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.textLabel.font = font_Bold_16;
        }
        
        if (indexPath.row == 4)
        {
            cell.textLabel.text = STRViewTips31;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.photoArray.count)
    {
        PhotoDetailViewController *controller = [[PhotoDetailViewController alloc] init];
        controller.photo = self.photoArray[indexPath.row];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
