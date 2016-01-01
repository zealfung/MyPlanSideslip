//
//  PostsDetailViewController.m
//  plan
//
//  Created by Fengzy on 15/12/27.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "PostsDetailViewController.h"

@interface PostsDetailViewController () <UITableViewDelegate, UITableViewDataSource> {
}

@end

@implementation PostsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)getCommets {
//    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Posts"];
//    [bquery includeKey:@"author"];
//    [bquery whereKey:@"objectId" equalTo:self.posts.objectId];
////    __weak typeof(self) weakSelf = self;
//    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
//        
//        if (!error && array.count == 1) {
//            
//        }
//    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    BmobObject *author = [self.posts objectForKey:@"author"];
    NSString *nickName = [author objectForKey:@"nickName"];
    if (!nickName || nickName.length == 0) {
        nickName = @"匿名者";
    }
    NSString *avatarURL = [author objectForKey:@"avatarURL"];
//    NSString *content = [self.posts objectForKey:@"content"];
//    NSString *isTop = [self.posts objectForKey:@"isTop"];
//    NSString *isHighlight = [self.posts objectForKey:@"isHighlight"];
//    NSArray *imgURLArray = [NSArray arrayWithArray:[self.posts objectForKey:@"imgURLArray"]];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_FULL_SCREEN, 50)];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.borderWidth = 1;
    view.layer.borderColor = [color_dedede CGColor];
    //图像
    UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 5, 40, 40)];
    avatarView.layer.cornerRadius = 20;
    avatarView.clipsToBounds = YES;
    [avatarView sd_setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed:png_AvatarDefault1]];
    avatarView.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:avatarView];
    //昵称
    UILabel *labelNickName = [[UILabel alloc] initWithFrame:CGRectMake(57, 0, WIDTH_FULL_SCREEN / 2, 30)];
    labelNickName.textColor = color_Blue;
    labelNickName.font = font_Normal_16;
    labelNickName.text = nickName;
    [view addSubview:labelNickName];
    //发表时间
    UILabel *labelDate = [[UILabel alloc] initWithFrame:CGRectMake(57, 30, WIDTH_FULL_SCREEN / 2, 20)];
    labelDate.textColor = color_666666;
    labelDate.font = font_Normal_13;
    labelDate.text = [CommonFunction NSDateToNSString:self.posts.createdAt formatter:str_DateFormatter_yyyy_MM_dd_HHmm];
    [view addSubview:labelDate];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
