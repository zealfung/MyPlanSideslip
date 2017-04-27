//
//  PersonalCenterMyPostsViewController.m
//  plan
//
//  Created by Fengzy on 16/4/15.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import "LogIn.h"
#import "MJRefresh.h"
#import <BmobSDK/BmobUser.h>
#import "PostsNoImageCell.h"
#import <BmobSDK/BmobQuery.h>
#import "PostsOneImageCell.h"
#import "PostsTwoImageCell.h"
#import <BmobSDK/BmobRelation.h>
#import "PostsDetailViewController.h"
#import "PersonalCenterMyPostsViewController.h"

@interface PersonalCenterMyPostsViewController ()
    
@property (nonatomic, assign) BOOL isLoadMore;
@property (nonatomic, assign) BOOL isLoadingPosts;
@property (nonatomic, assign) BOOL isSendingLikes;
@property (nonatomic, assign) BOOL isLoadEnd;
@property (nonatomic, assign) NSInteger startIndex;
@property (nonatomic, strong) NSMutableArray *postsArray;
@property (nonatomic, strong) UIButton *btnBackToTop;
@property (nonatomic, assign) CGFloat buttonY;
@property (nonatomic, assign) NSInteger checkLikeCount;

@end

@implementation PersonalCenterMyPostsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"我的帖子";
    
    self.postsArray = [NSMutableArray array];

    [self initTableView];
    [self createBack2TopButton];
    [self reloadPostsData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)initTableView
{
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = color_eeeeee;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView setDefaultEmpty];
    __weak typeof(self) weakSelf = self;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //刷新帖子数据
        [weakSelf reloadPostsData];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_header = header;
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.isLoadMore = YES;
        //加载更多帖子数据
        [weakSelf reloadPostsData];
    }];
    self.tableView.mj_footer.hidden = YES;
}

- (void)createBack2TopButton
{
    self.btnBackToTop = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH_FULL_SCREEN - 60, HEIGHT_FULL_VIEW - 120, 50, 50)];
    [self.btnBackToTop setBackgroundImage:[UIImage imageNamed:png_Btn_BackToTop] forState:UIControlStateNormal];
    self.btnBackToTop.layer.cornerRadius = 25;
    [self.btnBackToTop.layer setMasksToBounds:YES];
    self.btnBackToTop.alpha = 0.0;
    [self.btnBackToTop addTarget:self action:@selector(backToTop:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView addSubview:self.btnBackToTop];
    [self.tableView bringSubviewToFront:self.btnBackToTop];
    self.buttonY = self.btnBackToTop.frame.origin.y;
}

- (void)backToTop:(id)sender
{
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^(void) {
        if (scrollView.contentOffset.y <= 150)
        {
            weakSelf.btnBackToTop.alpha = 0.0;
        }
        else
        {
            weakSelf.btnBackToTop.alpha = 1.0;
        }
    }];
    self.btnBackToTop.frame = CGRectMake(self.btnBackToTop.frame.origin.x, self.buttonY+self.tableView.contentOffset.y, self.btnBackToTop.frame.size.width, self.btnBackToTop.frame.size.height);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.postsArray.count > indexPath.row)
    {
        BmobObject *obj = self.postsArray[indexPath.row];
        NSArray *imgURLArray = [NSArray arrayWithArray:[obj objectForKey:@"imgURLArray"]];
        if (imgURLArray && imgURLArray.count > 0)
        {
            return 275.f;
        }
        else
        {
            return 130.f;
        }
    }
    else
    {
        return 44.f;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (self.postsArray.count > indexPath.row)
    {
        BmobObject *obj = self.postsArray[indexPath.row];
        BmobObject *author = [obj objectForKey:@"author"];
        NSString *nickName = [author objectForKey:@"nickName"];
        NSString *gender = [author objectForKey:@"gender"];
        NSString *level = [author objectForKey:@"level"];
        if (!nickName || nickName.length == 0)
        {
            nickName = STRCommonTip12;
        }
        NSString *avatarURL = [author objectForKey:@"avatarURL"];
        NSString *content = [obj objectForKey:@"content"];
        NSString *isTop = [obj objectForKey:@"isTop"];
        NSString *isHighlight = [obj objectForKey:@"isHighlight"];
        NSInteger readTimes = [[obj objectForKey:@"readTimes"] integerValue];
        NSInteger likesCount = [[obj objectForKey:@"likesCount"] integerValue];
        NSInteger commentsCount = [[obj objectForKey:@"commentsCount"] integerValue];
        NSArray *imgURLArray = [NSArray arrayWithArray:[obj objectForKey:@"imgURLArray"]];
        BOOL isLike = NO;
        if ([LogIn isLogin])
        {
            isLike = [[obj objectForKey:@"isLike"] boolValue];
        }
        __weak typeof(self) weakSelf = self;
        if (imgURLArray && imgURLArray.count)
        {
            if (imgURLArray.count == 1)
            {
                PostsOneImageCell *cell = [PostsOneImageCell cellView];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell.imgViewAvatar sd_setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed: png_AvatarDefault1]];
                
                cell.labelNickName.text = nickName;
                if (!gender || [gender isEqualToString:@"1"])
                {
                    cell.labelNickName.textColor = color_Blue;
                }
                else
                {
                    cell.labelNickName.textColor = color_Pink;
                }
                if (level)
                {
                    cell.btnUserLevel.enabled = YES;
                    [cell.btnUserLevel setBackgroundImage:[CommonFunction getUserLevelIcon:level] forState:UIControlStateNormal];
                }
                else
                {
                    cell.btnUserLevel.enabled = NO;
                }
                
                cell.labelPostTime.text = [CommonFunction intervalSinceNow:[obj objectForKey:@"updatedTime"]];
                cell.labelContent.text = content;
                if ([isTop isEqualToString:@"1"])
                {
                    cell.labelIsTop.hidden = NO;
                }
                if ([isHighlight isEqualToString:@"1"])
                {
                    cell.labelIsHighlight.hidden = NO;
                }
                [cell.imgViewOne sd_setImageWithURL:[NSURL URLWithString:imgURLArray[0]] placeholderImage:[UIImage imageNamed:png_ImageDefault_Rectangle]];
                if (isLike)
                {
                    cell.isLiked = YES;
                    cell.imgLike.image = [UIImage imageNamed:png_Icon_Posts_Praise_Selected];
                    cell.labelLike.textColor = color_Red;
                }
                cell.labelEye.text = [CommonFunction checkNumberForThousand:readTimes];
                cell.labelComment.text = [CommonFunction checkNumberForThousand:commentsCount];
                cell.labelLike.text = [CommonFunction checkNumberForThousand:likesCount];
                __weak typeof(PostsOneImageCell) *weakCell = cell;
                cell.postsCellViewBlock = ^(){
                    [weakSelf toPostsDetail:obj];
                };
                cell.postsCellCommentBlock = ^(){
                    [weakSelf toPostsDetail:obj];
                };
                cell.postsCellLikeBlock = ^(){
                    if ([LogIn isLogin])
                    {
                        BmobObject *obj = self.postsArray[indexPath.row];
                        weakCell.isLiked = !weakCell.isLiked;
                        if (weakCell.isLiked)
                        {
                            [weakSelf likePosts:obj];
                            NSInteger likesCount = [[obj objectForKey:@"likesCount"] integerValue];
                            likesCount += 1;
                            weakCell.imgLike.image = [UIImage imageNamed:png_Icon_Posts_Praise_Selected];
                            weakCell.labelLike.textColor = color_Red;
                            weakCell.labelLike.text = [CommonFunction checkNumberForThousand:likesCount];
                        }
                        else
                        {
                            [weakSelf unlikePosts:obj];
                            NSInteger likesCount = [[obj objectForKey:@"likesCount"] integerValue];
                            likesCount -= 1;
                            weakCell.imgLike.image = [UIImage imageNamed:png_Icon_Posts_Praise_Normal];
                            weakCell.labelLike.textColor = color_8f8f8f;
                            weakCell.labelLike.text = [CommonFunction checkNumberForThousand:likesCount];
                        }
                    }
                };
                return cell;
            }
            else
            {
                PostsTwoImageCell *cell = [PostsTwoImageCell cellView];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell.imgViewAvatar sd_setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed: png_AvatarDefault1]];
                
                cell.labelNickName.text = nickName;
                if (!gender || [gender isEqualToString:@"1"])
                {
                    cell.labelNickName.textColor = color_Blue;
                }
                else
                {
                    cell.labelNickName.textColor = color_Pink;
                }
                if (level)
                {
                    cell.btnUserLevel.enabled = YES;
                    [cell.btnUserLevel setBackgroundImage:[CommonFunction getUserLevelIcon:level] forState:UIControlStateNormal];
                }
                else
                {
                    cell.btnUserLevel.enabled = NO;
                }
                
                cell.labelPostTime.text = [CommonFunction intervalSinceNow:[obj objectForKey:@"updatedTime"]];
                cell.labelContent.text = content;
                if ([isTop isEqualToString:@"1"])
                {
                    cell.labelIsTop.hidden = NO;
                }
                if ([isHighlight isEqualToString:@"1"])
                {
                    cell.labelIsHighlight.hidden = NO;
                }
                [cell.imgViewOne sd_setImageWithURL:[NSURL URLWithString:imgURLArray[0]] placeholderImage:[UIImage imageNamed:png_ImageDefault]];
                [cell.imgViewTwo sd_setImageWithURL:[NSURL URLWithString:imgURLArray[1]] placeholderImage:[UIImage imageNamed:png_ImageDefault]];
                if (isLike) {
                    cell.isLiked = YES;
                    cell.imgLike.image = [UIImage imageNamed:png_Icon_Posts_Praise_Selected];
                    cell.labelLike.textColor = color_Red;
                }
                cell.labelEye.text = [CommonFunction checkNumberForThousand:readTimes];
                cell.labelComment.text = [CommonFunction checkNumberForThousand:commentsCount];
                cell.labelLike.text = [CommonFunction checkNumberForThousand:likesCount];
                __weak typeof(PostsTwoImageCell) *weakCell = cell;
                cell.postsCellViewBlock = ^(){
                    [weakSelf toPostsDetail:obj];
                };
                cell.postsCellCommentBlock = ^(){
                    [weakSelf toPostsDetail:obj];
                };
                cell.postsCellLikeBlock = ^(){
                    if ([LogIn isLogin])
                    {
                        BmobObject *obj = weakSelf.postsArray[indexPath.row];
                        weakCell.isLiked = !weakCell.isLiked;
                        if (weakCell.isLiked)
                        {
                            [weakSelf likePosts:obj];
                            NSInteger likesCount = [[obj objectForKey:@"likesCount"] integerValue];
                            likesCount += 1;
                            weakCell.imgLike.image = [UIImage imageNamed:png_Icon_Posts_Praise_Selected];
                            weakCell.labelLike.textColor = color_Red;
                            weakCell.labelLike.text = [CommonFunction checkNumberForThousand:likesCount];
                        }
                        else
                        {
                            [weakSelf unlikePosts:obj];
                            NSInteger likesCount = [[obj objectForKey:@"likesCount"] integerValue];
                            likesCount -= 1;
                            weakCell.imgLike.image = [UIImage imageNamed:png_Icon_Posts_Praise_Normal];
                            weakCell.labelLike.textColor = color_8f8f8f;
                            weakCell.labelLike.text = [CommonFunction checkNumberForThousand:likesCount];
                        }
                    }
                };
                return cell;
            }
        }
        else
        {
            PostsNoImageCell *cell = [PostsNoImageCell cellView];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.imgViewAvatar sd_setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed: png_AvatarDefault1]];
            
            cell.labelNickName.text = nickName;
            if (!gender || [gender isEqualToString:@"1"])
            {
                cell.labelNickName.textColor = color_Blue;
            }
            else
            {
                cell.labelNickName.textColor = color_Pink;
            }
            if (level)
            {
                cell.btnUserLevel.enabled = YES;
                [cell.btnUserLevel setBackgroundImage:[CommonFunction getUserLevelIcon:level] forState:UIControlStateNormal];
            }
            else
            {
                cell.btnUserLevel.enabled = NO;
            }
            
            cell.labelPostTime.text = [CommonFunction intervalSinceNow:[obj objectForKey:@"updatedTime"]];
            cell.labelContent.text = content;
            if ([isTop isEqualToString:@"1"])
            {
                cell.labelIsTop.hidden = NO;
            }
            if ([isHighlight isEqualToString:@"1"])
            {
                cell.labelIsHighlight.hidden = NO;
            }
            if (isLike)
            {
                cell.isLiked = YES;
                cell.imgLike.image = [UIImage imageNamed:png_Icon_Posts_Praise_Selected];
                cell.labelLike.textColor = color_Red;
            }
            cell.labelEye.text = [CommonFunction checkNumberForThousand:readTimes];
            cell.labelComment.text = [CommonFunction checkNumberForThousand:commentsCount];
            cell.labelLike.text = [CommonFunction checkNumberForThousand:likesCount];
            __weak typeof(PostsNoImageCell) *weakCell = cell;
            cell.postsCellViewBlock = ^(){
                [weakSelf toPostsDetail:obj];
            };
            cell.postsCellCommentBlock = ^(){
                [weakSelf toPostsDetail:obj];
            };
            cell.postsCellLikeBlock = ^(){
                if ([LogIn isLogin])
                {
                    BmobObject *obj = weakSelf.postsArray[indexPath.row];
                    weakCell.isLiked = !weakCell.isLiked;
                    if (weakCell.isLiked)
                    {
                        [weakSelf likePosts:obj];
                        NSInteger likesCount = [[obj objectForKey:@"likesCount"] integerValue];
                        likesCount += 1;
                        weakCell.imgLike.image = [UIImage imageNamed:png_Icon_Posts_Praise_Selected];
                        weakCell.labelLike.textColor = color_Red;
                        weakCell.labelLike.text = [CommonFunction checkNumberForThousand:likesCount];
                    }
                    else
                    {
                        [weakSelf unlikePosts:obj];
                        NSInteger likesCount = [[obj objectForKey:@"likesCount"] integerValue];
                        likesCount -= 1;
                        weakCell.imgLike.image = [UIImage imageNamed:png_Icon_Posts_Praise_Normal];
                        weakCell.labelLike.textColor = color_8f8f8f;
                        weakCell.labelLike.text = [CommonFunction checkNumberForThousand:likesCount];
                    }
                }
            };
            return cell;
        }
    }
    else
    {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.postsArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.postsArray.count > indexPath.row)
    {
        BmobObject *obj = self.postsArray[indexPath.row];
        [self toPostsDetail:obj];
    }
    else
    {
        [self reloadPostsData];
    }
}

- (void)refreshPostsList
{
    [self.tableView reloadData];
}

- (void)reloadPostsData
{
    if (self.isLoadingPosts) return;
    
    self.isLoadingPosts = YES;
    if (!self.isLoadMore)
    {
        self.startIndex = 0;
        self.postsArray = [NSMutableArray array];
    }

    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Posts"];
    BmobQuery *inQuery = [BmobQuery queryWithClassName:@"UserSettings"];
    BmobUser *user = [BmobUser currentUser];
    if (!user)
    {
        return;
    }
    [inQuery whereKey:@"userObjectId" equalTo:user.objectId];
    [bquery whereKey:@"author" matchesQuery:inQuery];//匹配我的帖子
    [bquery includeKey:@"author"];//声明该次查询需要将author关联对象信息一并查询出来
    [bquery whereKey:@"isDeleted" equalTo:@"0"];
    [bquery orderByDescending:@"isTop"];//先按照是否置顶排序
    [bquery orderByDescending:@"updatedTime"];//再按照更新时间排序
    bquery.limit = 10;
    bquery.skip = self.postsArray.count;
    
    [self showHUD];
    __weak typeof(self) weakSelf = self;
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
    {
        //自动回顶部
        if (!weakSelf.isLoadMore)
        {
            [weakSelf backToTop:nil];
        }
        weakSelf.isLoadMore = NO;
        weakSelf.isLoadingPosts = NO;
        weakSelf.isLoadEnd = YES;
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
        //记录加载时间
        [UserDefaults setObject:[NSDate date] forKey:STRPostsListFlag];
        [UserDefaults synchronize];
        
        if (!error && array.count)
        {
            [weakSelf.postsArray addObjectsFromArray:array];
            [weakSelf checkIsLike:weakSelf.postsArray];
        }
        else
        {
            [weakSelf hideHUD];
        }
    }];
}

- (void)checkIsLike:(NSMutableArray *)array
{
    if ([LogIn isLogin])
    {
        self.checkLikeCount = 0;
        for (NSInteger i=0; i < array.count; i++)
        {
            [self isLikedPost:array[i]];
        }
    }
    else
    {
        [self hideHUD];
        [self.tableView reloadData];
    }
}

- (void)incrementBannerReadTimes:(BmobObject *)obj
{
    BmobObject *banner = [BmobObject objectWithoutDataWithClassName:@"Banner" objectId:obj.objectId];
    //查看数加1
    [banner incrementKey:@"readTimes"];
    if ([LogIn isLogin])
    {
        //新建relation对象
        BmobRelation *relation = [[BmobRelation alloc] init];
        BmobUser *user = [BmobUser currentUser];
        [relation addObject:[BmobObject objectWithoutDataWithClassName:@"_User" objectId:user.objectId]];
        //添加关联关系到readUser列中
        [banner addRelation:relation forKey:@"readUser"];
    }
    //异步更新obj的数据
    [banner updateInBackground];
}

- (void)incrementPostsReadTimes:(BmobObject *)posts
{
    BmobObject *obj = [BmobObject objectWithoutDataWithClassName:@"Posts" objectId:posts.objectId];
    //查看数加1
    [obj incrementKey:@"readTimes"];

    if ([LogIn isLogin])
    {
        //新建relation对象
        BmobRelation *relation = [[BmobRelation alloc] init];
        BmobUser *user = [BmobUser currentUser];
        [relation addObject:[BmobObject objectWithoutDataWithClassName:@"_User" objectId:user.objectId]];
        //添加关联关系到readUser列中
        [obj addRelation:relation forKey:@"readUser"];
    }
    //异步更新obj的数据
    [obj updateInBackground];
}

- (void)likePosts:(BmobObject *)posts
{
    BOOL isLike = [[posts objectForKey:@"isLike"] boolValue];
    if (self.isSendingLikes && isLike) return;
    
    __weak typeof(self) weakSelf = self;
    BmobObject *obj = [BmobObject objectWithoutDataWithClassName:@"Posts" objectId:posts.objectId];
    [obj incrementKey:@"likesCount"];
    BmobRelation *relation = [[BmobRelation alloc] init];
    [relation addObject:[BmobObject objectWithoutDataWithClassName:@"UserSettings" objectId:[Config shareInstance].settings.objectId]];
    [obj addRelation:relation forKey:@"likes"];
    self.isSendingLikes = YES;
    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
     {
        weakSelf.isSendingLikes = NO;
        if (isSuccessful)
        {
            NSInteger likesCount = [[posts objectForKey:@"likesCount"] integerValue];
            likesCount += 1;
            [posts setObject:@(likesCount) forKey:@"likesCount"];
            [posts setObject:@(YES) forKey:@"isLike"];
            [weakSelf addNoticesForLikesPosts:posts];
        }
    }];
}

- (void)unlikePosts:(BmobObject *)posts
{
    NSInteger likesCount = [[posts objectForKey:@"likesCount"] integerValue];
    BOOL isLike = [[posts objectForKey:@"isLike"] boolValue];
    if (self.isSendingLikes || likesCount < 1 || !isLike) return;
    
    BmobObject *obj = [BmobObject objectWithoutDataWithClassName:@"Posts" objectId:posts.objectId];
    [obj decrementKey:@"likesCount"];
    BmobRelation *relation = [[BmobRelation alloc] init];
    [relation removeObject:[BmobObject objectWithoutDataWithClassName:@"UserSettings" objectId:[Config shareInstance].settings.objectId]];
    [obj addRelation:relation forKey:@"likes"];
    self.isSendingLikes = YES;
    __weak typeof(self) weakSelf = self;
    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
     {
        weakSelf.isSendingLikes = NO;
        if (isSuccessful)
        {
            NSInteger likesCount = [[posts objectForKey:@"likesCount"] integerValue];
            likesCount -= 1;
            [posts setObject:@(likesCount) forKey:@"likesCount"];
            [posts setObject:@(NO) forKey:@"isLike"];
            NSLog(@"successful");
        }
    }];
}

- (void)isLikedPost:(BmobObject *)posts
{
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Posts"];
    BmobQuery *inQuery = [BmobQuery queryWithClassName:@"UserSettings"];
    BmobUser *user = [BmobUser currentUser];
    [inQuery whereKey:@"userObjectId" equalTo:user.objectId];
    //匹配查询
    [bquery whereKey:@"likes" matchesQuery:inQuery];//（查询所有有关联的数据）
    [bquery whereKey:@"objectId" equalTo:posts.objectId];
    __weak typeof(self) weakSelf = self;
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
    {
        if (!error && array.count)
        {
            [posts setObject:@(YES) forKey:@"isLike"];
        }
        else
        {
            [posts setObject:@(NO) forKey:@"isLike"];
        }
        
        weakSelf.checkLikeCount ++;
        if (weakSelf.checkLikeCount == weakSelf.postsArray.count)
        {
            [weakSelf hideHUD];
            [weakSelf.tableView reloadData];
        }
    }];
}

- (void)addNoticesForLikesPosts:(BmobObject *)posts
{
    BmobObject *author = [posts objectForKey:@"author"];
    NSString *userObjectId = [author objectForKey:@"userObjectId"];
    BmobUser *user = [BmobUser currentUser];
    if ([user.objectId isEqualToString:userObjectId]) return;
    
    BmobObject *newNotice = [BmobObject objectWithClassName:@"Notices"];
    [newNotice setObject:@"1" forKey:@"noticeType"];//通知类型：1赞帖子 2赞评论 3回复帖子 4回复评论
    [newNotice setObject:posts.objectId forKey:@"postsObjectId"];//被评论或点赞的帖子id
    [newNotice setObject:[posts objectForKey:@"content"] forKey:@"noticeForContent"];//被评论的帖子内容
    BmobObject *fromUser = [BmobObject objectWithoutDataWithClassName:@"UserSettings" objectId:[Config shareInstance].settings.objectId];
    [newNotice setObject:fromUser forKey:@"fromUser"];
    [newNotice setObject:userObjectId forKey:@"toAuthorObjectId"];//评论对象的ID
    [newNotice setObject:@"0" forKey:@"hasRead"];// 0未读 1已读
    [newNotice saveInBackground];
}

- (void)toPostsDetail:(BmobObject *)posts
{
    [self incrementPostsReadTimes:posts];
    
    PostsDetailViewController *controller = [[PostsDetailViewController alloc] init];
    controller.posts = posts;
    controller.userTagsArray = [NSArray array];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
