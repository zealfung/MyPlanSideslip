//
//  SecondViewController.m
//  plan
//
//  Created by Fengzy on 15/8/28.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "Plan.h"
#import "HitView.h"
#import "PlanCell.h"
#import "PlanCache.h"
#import "MJRefresh.h"
#import "ThreeSubView.h"
#import "PlanSectionView.h"
#import <BmobSDK/BmobUser.h>
#import "LogInViewController.h"
#import "PopupPlanRemarkView.h"
#import "SecondViewController.h"
#import "PlanAddNewViewController.h"
#import "PlanDetailViewController.h"

NSUInteger const kPlan_MenuHeight = 44;
NSUInteger const kPlan_MenuLineHeight = 3;
NSUInteger const kPlanCellDeleteTag = 9527;
NSUInteger const kPlan_TodayCellHeaderViewHeight = 30;

@interface SecondViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, PlanCellDelegate, HitViewDelegate>

@property (nonatomic, strong) PlanCell *planCell;
@property (nonatomic, strong) HitView *hitView;
@property (nonatomic, assign) NSInteger dayTotal;
@property (nonatomic, assign) NSInteger futureTotal;
@property (nonatomic, assign) NSInteger dayStart;
@property (nonatomic, assign) NSInteger futureStart;
@property (nonatomic, assign) BOOL *daySectionFlag;
@property (nonatomic, assign) BOOL *futureSectionFlag;
@property (nonatomic, assign) BOOL canCustomEditNow;
@property (nonatomic, assign) BOOL isLoadingPlanDay;
@property (nonatomic, assign) BOOL isLoadingPlanFuture;
@property (nonatomic, assign) PlanType planType;
@property (nonatomic, strong) Plan *deletePlan;
@property (nonatomic, strong) NSMutableArray *arrayPlanDay;
@property (nonatomic, strong) NSMutableArray *arrayPlanFuture;
@property (nonatomic, strong) NSMutableArray *dayDateKeyArray;
@property (nonatomic, strong) NSMutableDictionary *dayPlanDict;
@property (nonatomic, strong) NSMutableArray *futureDateKeyArray;
@property (nonatomic, strong) NSMutableDictionary *futurePlanDict;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSString *searchKeyword;
@property (nonatomic, strong) NSMutableArray *searchResultArray;
@property (nonatomic, strong) UITableView *tableViewPlan;
@property (nonatomic, strong) ThreeSubView *menuTabView;
@property (nonatomic, strong) UIView *underLineView;

@end

@implementation SecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = STRViewTitle2;
    self.tabBarItem.title = STRViewTitle2;
    self.planType = 1;

    [NotificationCenter addObserver:self selector:@selector(reloadData) name:NTFLogIn object:nil];
    [NotificationCenter addObserver:self selector:@selector(reloadData) name:NTFLogOut object:nil];
    [NotificationCenter addObserver:self selector:@selector(toPlan:) name:NTFLocalPush object:nil];
    [NotificationCenter addObserver:self selector:@selector(reloadData) name:NTFPlanSave object:nil];
    
    __weak typeof(self) weakSelf = self;
    [self customRightButtonWithImage:[UIImage imageNamed:png_Btn_Add] action:^(UIButton *sender)
     {
         if ([LogIn isLogin])
         {
             PlanAddNewViewController *controller = [[PlanAddNewViewController alloc] init];
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
    
    [self loadCustomView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //计算最近一次加载数据时间是否已经超过十分钟，如果是，就自动刷新一次数据
    NSDate *lastUpdatedTime = [UserDefaults objectForKey:STRPlanListFlag];
    if (lastUpdatedTime)
    {
        NSTimeInterval last = [lastUpdatedTime timeIntervalSince1970];
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        
        if ((now-last)/60 > 5)
        {//大于五分钟，自动重载一次数据
            [self getPlanData];
            //记录刷新时间
            [UserDefaults setObject:[NSDate date] forKey:STRPlanListFlag];
            [UserDefaults synchronize];
        }
    }
    if (self.planType == EverydayPlan)
    {
        [self moveUnderLineViewToButton:self.menuTabView.leftButton];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//初始化自定义界面
- (void)loadCustomView
{
    [self initTableView];
    
    if (!self.underLineView)
    {
        [self showMenuView];
        [self showUnderLineView];
    }
    [self getPlanData];
}

- (void)initTableView
{
    self.searchKeyword = @"";
    self.arrayPlanDay = [NSMutableArray array];
    self.arrayPlanFuture = [NSMutableArray array];
    self.searchResultArray = [NSMutableArray array];
    
    NSUInteger yOffset = kPlan_MenuHeight;
    NSUInteger tableHeight = CGRectGetHeight(self.view.bounds) - yOffset -40;
    CGRect frame = CGRectZero;
    frame.origin.x = 0;
    frame.origin.y =yOffset;
    frame.size.width = CGRectGetWidth(self.view.bounds);
    frame.size.height = tableHeight;
    
    __weak typeof(self) weakSelf = self;
    self.tableViewPlan = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    self.tableViewPlan.backgroundColor = [UIColor clearColor];
    self.tableViewPlan.backgroundView = nil;
    self.tableViewPlan.dataSource = self;
    self.tableViewPlan.delegate = self;
    self.tableViewPlan.showsHorizontalScrollIndicator = NO;
    self.tableViewPlan.showsVerticalScrollIndicator = NO;
    self.tableViewPlan.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableViewPlan.rowHeight = kPlanCellHeight;
    {
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, WIDTH_FULL_SCREEN, 44)];
        self.searchBar.delegate = self;
        self.searchBar.barTintColor = color_eeeeee;
        self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
        self.searchBar.inputAccessoryView = [self getInputAccessoryView];
        self.searchBar.placeholder = @"搜索";
        self.tableViewPlan.tableHeaderView = self.searchBar;
    }
    UIView *footer = [[UIView alloc] init];
    self.tableViewPlan.tableFooterView = footer;
    self.tableViewPlan.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableViewPlan.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
        weakSelf.arrayPlanDay = [NSMutableArray array];
        weakSelf.arrayPlanFuture = [NSMutableArray array];
        weakSelf.searchResultArray = [NSMutableArray array];
        [weakSelf getPlanData];
    }];
    self.tableViewPlan.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf getPlanData];
    }];
    [self.view addSubview:self.tableViewPlan];
}

- (void)showMenuView
{
    __weak typeof(self) weakSelf = self;
    self.menuTabView = [[ThreeSubView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kPlan_MenuHeight) leftButtonSelectBlock: ^{
        
        weakSelf.planType = EverydayPlan;
        
    } centerButtonSelectBlock: ^{
        
        weakSelf.planType = FuturePlan;
        
    } rightButtonSelectBlock:nil];
    
    self.menuTabView.fixLeftWidth = CGRectGetWidth(self.view.bounds)/2;
    self.menuTabView.fixCenterWidth = CGRectGetWidth(self.view.bounds)/2;
    [self.menuTabView.leftButton setAllTitleColor:[CommonFunction getGenderColor]];
    [self.menuTabView.centerButton setAllTitleColor:[CommonFunction getGenderColor]];
    self.menuTabView.leftButton.titleLabel.font = font_Bold_18;
    self.menuTabView.centerButton.titleLabel.font = font_Bold_18;
    [self.menuTabView.leftButton setAllTitle:STRViewTips9];
    [self.menuTabView.centerButton setAllTitle:STRViewTips10];
    [self.menuTabView autoLayout];
    [self.view addSubview:self.menuTabView];
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2, 5, 1, kPlan_MenuHeight - 10)];
        view.backgroundColor = color_dedede;
        [self.menuTabView addSubview:view];
    }
    {
        UIImage *image = [UIImage imageNamed:png_Bg_Cell_White];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.menuTabView.frame];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        [self.view insertSubview:imageView belowSubview:self.menuTabView];
    }
}

- (void)showUnderLineView
{
    CGRect frame = [self.menuTabView.leftButton convertRect:self.menuTabView.leftButton.titleLabel.frame toView:self.menuTabView];
    frame.origin.y = self.menuTabView.frame.size.height - kPlan_MenuLineHeight;
    frame.size.height = kPlan_MenuLineHeight;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [CommonFunction getGenderColor];
    [self.menuTabView addSubview:view];
    self.underLineView = view;
}

- (void)moveUnderLineViewToLeft
{
    [self moveUnderLineViewToButton:self.menuTabView.leftButton];
    if (self.arrayPlanDay.count)
    {
        [self.tableViewPlan reloadData];
    }
    else
    {
        [self getPlanData];
    }
}

- (void)moveUnderLineViewToRight
{
    [self moveUnderLineViewToButton:self.menuTabView.centerButton];
    if (self.arrayPlanFuture.count)
    {
        [self.tableViewPlan reloadData];
    }
    else
    {
        [self getPlanData];
    }
}

- (void)moveUnderLineViewToButton:(UIButton *)button
{
    [self.view endEditing:YES];
    
    CGRect frame = [button convertRect:button.titleLabel.frame toView:button.superview];
    frame.origin.y = self.menuTabView.frame.size.height - kPlan_MenuLineHeight;
    frame.size.height = kPlan_MenuLineHeight;
    button.superview.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.25 animations: ^{
        
        self.underLineView.frame = frame;
        
    } completion:^(BOOL finished) {
        if (finished)
        {
            button.superview.userInteractionEnabled = YES;
        }
    }];
}

- (void)reloadData
{
    self.arrayPlanDay = [NSMutableArray array];
    self.arrayPlanFuture = [NSMutableArray array];
    self.searchResultArray = [NSMutableArray array];
    [self getPlanData];
}

- (void)getPlanData
{
    if (self.planType == FuturePlan)
    {
        [self getPlanFuture];
    }
    else
    {
        [self getPlanDay];
    }
}

- (void)getPlanDay
{
    if (self.isLoadingPlanDay)
    {
        return;
    }
    self.isLoadingPlanDay = YES;
    
    [self showHUD];
    BmobUser *user = [BmobUser currentUser];
    __weak typeof(self) weakSelf = self;
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Plan"];
    [bquery whereKey:@"userObjectId" equalTo:user.objectId];
    [bquery whereKey:@"isDeleted" notEqualTo:@"1"];
    NSString *today = [CommonFunction NSDateToNSString:[NSDate date] formatter:STRDateFormatterType4];
    //查询beginDate列中值早于今天的数据
    NSArray *array =  @[@{@"beginDate":@{@"$lte":today}}];
    [bquery addTheConstraintByOrOperationWithArray:array];

    [bquery orderByDescending:@"updatedAt"];
    bquery.limit = 100;
    bquery.skip = self.arrayPlanDay.count;

    self.arrayPlanDay = [NSMutableArray array];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
     {
         [weakSelf hideHUD];
         weakSelf.isLoadingPlanDay = NO;
         [weakSelf.tableViewPlan.mj_header endRefreshing];
         [weakSelf.tableViewPlan.mj_footer endRefreshing];
         
         if (!error && array.count)
         {
             for (BmobObject *obj in array)
             {
                 Plan *plan = [[Plan alloc] init];
                 plan.account = [obj objectForKey:@"userObjectId"];
                 plan.planid = obj.objectId;
                 plan.content = [obj objectForKey:@"content"];
                 plan.createtime = [obj objectForKey:@"createdTime"];
                 plan.completetime = [obj objectForKey:@"completedTime"];
                 plan.updatetime = [obj objectForKey:@"updatedTime"];
                 plan.notifytime = [obj objectForKey:@"notifyTime"];
                 plan.iscompleted = [obj objectForKey:@"isCompleted"];
                 plan.isnotify = [obj objectForKey:@"isNotify"];
                 plan.isdeleted = [obj objectForKey:@"isDeleted"];
                 plan.isRepeat = [obj objectForKey:@"isRepeat"];
                 plan.remark = [obj objectForKey:@"remark"];
                 plan.beginDate = [obj objectForKey:@"beginDate"];
                 [weakSelf.arrayPlanDay addObject:plan];
                 
                 if ([plan.isnotify isEqualToString:@"1"]
                     && [plan.iscompleted isEqualToString:@"0"])
                 {
                     plan.notifytime = [CommonFunction updateNotifyTime:plan.notifytime];
                     
                     [CommonFunction updatePlanNotification:plan];
                 }
                 else
                 {
                     [CommonFunction cancelPlanNotification:plan.planid];
                 }
             }
         }
         [weakSelf groupPlanDay:weakSelf.arrayPlanDay];
     }];
}

- (void)groupPlanDay:(NSArray *)array
{
    self.dayDateKeyArray = [NSMutableArray array];
    self.dayPlanDict = [NSMutableDictionary dictionary];
    NSMutableArray *dayDateKeyArrayTmp = [NSMutableArray array];
    
    NSString *key = @"";
    for (NSInteger i = 0; i < array.count; i++)
    {
        Plan *plan = array[i];
        
        if ([[Config shareInstance].settings.autoDelayUndonePlan isEqualToString:@"1"]
            && [plan.iscompleted isEqualToString:@"0"])
        {
            key = [CommonFunction NSDateToNSString:[NSDate date] formatter:STRDateFormatterType4];
            plan.beginDate = key;
        }
        else
        {
            key = plan.beginDate;
        }

        NSMutableArray *dateArray = [self.dayPlanDict objectForKey:key];
        if (!dateArray)
        {
            dateArray = [[NSMutableArray alloc] init];
            [self.dayPlanDict setValue:dateArray forKey:key];
            [dayDateKeyArrayTmp addObject:key];
        }
        
        if ([plan.iscompleted isEqualToString:@"1"])
        {
            [dateArray addObject:plan];
        }
        else
        {
            [dateArray insertObject:plan atIndex:0];
        }
    }
    [self.dayDateKeyArray addObjectsFromArray:dayDateKeyArrayTmp];
    //日期降序排列
    self.dayDateKeyArray = [NSMutableArray arrayWithArray:[CommonFunction arraySort:self.dayDateKeyArray ascending:NO]];
    
    NSUInteger sections = self.dayDateKeyArray.count;
    self.daySectionFlag = (BOOL *)malloc(sections * sizeof(BOOL));
    memset((void *)self.daySectionFlag, NO, sections * sizeof(BOOL));
    self.daySectionFlag[0] = !self.daySectionFlag[0];
    
    if (self.dayStart < self.dayTotal)
    {
        self.dayStart += kPlanLoadMax;
    }
    else if (self.planType == EverydayPlan)
    {
        [self.tableViewPlan.mj_footer endRefreshingWithNoMoreData];
    }
    [self.tableViewPlan.mj_footer endRefreshing];
    [self.tableViewPlan reloadData];
}

- (void)getPlanFuture
{
    if (self.isLoadingPlanFuture)
    {
        return;
    }
    self.isLoadingPlanFuture = YES;
    
    [self showHUD];
    BmobUser *user = [BmobUser currentUser];
    __weak typeof(self) weakSelf = self;
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Plan"];
    [bquery whereKey:@"userObjectId" equalTo:user.objectId];
    [bquery whereKey:@"isDeleted" notEqualTo:@"1"];
    NSString *today = [CommonFunction NSDateToNSString:[NSDate date] formatter:STRDateFormatterType4];
    //查询beginDate列中值晚于今天的数据
    NSArray *array =  @[@{@"beginDate":@{@"$gt":today}}];
    [bquery addTheConstraintByOrOperationWithArray:array];
    
    [bquery orderByDescending:@"updatedTime"];
    bquery.limit = 100;
    bquery.skip = self.arrayPlanFuture.count;
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
     {
         [weakSelf hideHUD];
         weakSelf.isLoadingPlanFuture = NO;
         [weakSelf.tableViewPlan.mj_header endRefreshing];
         [weakSelf.tableViewPlan.mj_footer endRefreshing];
         
         if (!error && array.count)
         {
             for (BmobObject *obj in array)
             {
                 Plan *plan = [[Plan alloc] init];
                 plan.account = [obj objectForKey:@"userObjectId"];
                 plan.planid = obj.objectId;
                 plan.content = [obj objectForKey:@"content"];
                 plan.createtime = [obj objectForKey:@"createdTime"];
                 plan.completetime = [obj objectForKey:@"completedTime"];
                 plan.updatetime = [obj objectForKey:@"updatedTime"];
                 plan.notifytime = [obj objectForKey:@"notifyTime"];
                 plan.iscompleted = [obj objectForKey:@"isCompleted"];
                 plan.isnotify = [obj objectForKey:@"isNotify"];
                 plan.isdeleted = [obj objectForKey:@"isDeleted"];
                 plan.isRepeat = [obj objectForKey:@"isRepeat"];
                 plan.remark = [obj objectForKey:@"remark"];
                 plan.beginDate = [obj objectForKey:@"beginDate"];
                 [weakSelf.arrayPlanFuture addObject:plan];
             }
         }
         [weakSelf groupPlanFuture:weakSelf.arrayPlanFuture];
     }];
}

- (void)groupPlanFuture:(NSArray *)array
{
    self.futureDateKeyArray = [NSMutableArray array];
    [self.futureDateKeyArray addObject:STRViewTips17];
    [self.futureDateKeyArray addObject:STRViewTips18];
    [self.futureDateKeyArray addObject:STRViewTips19];
    [self.futureDateKeyArray addObject:STRViewTips20];
    self.futurePlanDict = [NSMutableDictionary dictionary];

    NSString *key = @"";
    for (NSInteger i = 0; i < array.count; i++)
    {
        Plan *plan = array[i];
        
        NSDate *beginDate = [CommonFunction NSStringDateToNSDate:plan.beginDate formatter:STRDateFormatterType4];
        NSInteger days = [CommonFunction calculateDayFromDate:[NSDate date] toDate:beginDate];
        
        if (days >= 0 && days < 1)
        {//
            key = STRViewTips17;
        }
        else if (days >= 1 && days < 7)
        {//一星期内开始
            key = STRViewTips18;
        }
        else if (days >= 7 && days < 30)
        {//一个月内开始
            key = STRViewTips19;
        }
        else
        {//一个月后开始
            key = STRViewTips20;
        }
        NSMutableArray *dateArray = [self.futurePlanDict objectForKey:key];
        if (!dateArray)
        {
            dateArray = [[NSMutableArray alloc] init];
            [self.futurePlanDict setValue:dateArray forKey:key];
        }
        [dateArray addObject:plan];
    }
    //----------------去掉没有子项的section-----------------------------------------
    NSMutableArray *arrayTomorrow = [self.futurePlanDict objectForKey:STRViewTips17];
    if (!arrayTomorrow || arrayTomorrow.count == 0)
    {
        [self.futureDateKeyArray removeObject:STRViewTips17];
    }
    NSMutableArray *arrayWeek = [self.futurePlanDict objectForKey:STRViewTips18];
    if (!arrayWeek || arrayWeek.count == 0)
    {
        [self.futureDateKeyArray removeObject:STRViewTips18];
    }
    NSMutableArray *arrayMonth = [self.futurePlanDict objectForKey:STRViewTips19];
    if (!arrayMonth || arrayMonth.count == 0)
    {
        [self.futureDateKeyArray removeObject:STRViewTips19];
    }
    NSMutableArray *arrayYear = [self.futurePlanDict objectForKey:STRViewTips20];
    if (!arrayYear || arrayYear.count == 0)
    {
        [self.futureDateKeyArray removeObject:STRViewTips20];
    }
    //----------------------------------------------------------------------------
    NSUInteger sections = self.futureDateKeyArray.count;
    self.futureSectionFlag = (BOOL *)malloc(sections * sizeof(BOOL));
    memset((void *)self.futureSectionFlag, YES, sections * sizeof(BOOL));

    if (self.futureStart < self.futureTotal)
    {
        self.futureStart += kPlanLoadMax;
    }
    else if (self.planType == FuturePlan)
    {
        [self.tableViewPlan.mj_footer endRefreshingWithNoMoreData];
    }
    [self.tableViewPlan.mj_footer endRefreshing];
    [self.tableViewPlan reloadData];
}

- (void)searchPlan
{
    [self showHUD];
    BmobUser *user = [BmobUser currentUser];
    __weak typeof(self) weakSelf = self;
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Plan"];
    [bquery whereKey:@"userObjectId" equalTo:user.objectId];
    [bquery whereKey:@"isDeleted" notEqualTo:@"1"];
    [bquery whereKey:@"content" matchesWithRegex:[NSString stringWithFormat:@".*?%@.*?", self.searchKeyword]];
    [bquery orderByDescending:@"updatedTime"];
    bquery.limit = 100;
    bquery.skip = self.searchResultArray.count;
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
     {
         [weakSelf hideHUD];
         weakSelf.isLoadingPlanDay = NO;
         [weakSelf.tableViewPlan.mj_header endRefreshing];
         [weakSelf.tableViewPlan.mj_footer endRefreshing];
         
         if (!error && array.count)
         {
             for (BmobObject *obj in array)
             {
                 Plan *plan = [[Plan alloc] init];
                 plan.account = [obj objectForKey:@"userObjectId"];
                 plan.planid = obj.objectId;
                 plan.content = [obj objectForKey:@"content"];
                 plan.createtime = [obj objectForKey:@"createdTime"];
                 plan.completetime = [obj objectForKey:@"completedTime"];
                 plan.updatetime = [obj objectForKey:@"updatedTime"];
                 plan.notifytime = [obj objectForKey:@"notifyTime"];
                 plan.iscompleted = [obj objectForKey:@"isCompleted"];
                 plan.isnotify = [obj objectForKey:@"isNotify"];
                 plan.isdeleted = [obj objectForKey:@"isDeleted"];
                 plan.isRepeat = [obj objectForKey:@"isRepeat"];
                 plan.remark = [obj objectForKey:@"remark"];
                 plan.beginDate = [obj objectForKey:@"beginDate"];
                 [weakSelf.searchResultArray addObject:plan];
             }
         }
         [weakSelf.tableViewPlan reloadData];
     }];
}

- (void)setPlanType:(PlanType)type
{
    _planType = type;
    switch (type)
    {
        case EverydayPlan:
            [self moveUnderLineViewToLeft];
            break;
        case FuturePlan:
            [self moveUnderLineViewToRight];
            break;
        default:
            break;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.searchKeyword.length)
    {
        return 1;
    }
    else
    {
        if (self.planType == EverydayPlan)
        {
            if (self.dayPlanDict.count)
            {
                return self.dayPlanDict.count;
            }
            else
            {
                return 1;
            }
        }
        else
        {
            if (self.futurePlanDict.count)
            {
                return self.futurePlanDict.count;
            }
            else
            {
                return 1;
            }
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchKeyword.length)
    {
        if (self.searchResultArray.count)
        {
            return self.searchResultArray.count;
        }
        else
        {
            return 3;
        }
    }
    else
    {
        if (self.planType == EverydayPlan)
        {
            if(self.dayDateKeyArray.count)
            {
                if (self.daySectionFlag[section])
                {
                    NSString *key = self.dayDateKeyArray[section];
                    NSArray *dateArray = [self.dayPlanDict objectForKey:key];
                    return dateArray.count;
                }
                else
                {
                    return 0;
                }
            }
            else
            {
                return 3;
            }
        }
        else
        {
            if(self.futureDateKeyArray.count)
            {
                if (self.futureSectionFlag[section])
                {
                    NSString *key = self.futureDateKeyArray[section];
                    NSArray *dateArray = [self.futurePlanDict objectForKey:key];
                    return dateArray.count;
                }
                else
                {
                    return 0;
                }
            }
            else
            {
                return 3;
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    if (self.searchKeyword.length)
    {
        if(indexPath.row < self.searchResultArray.count)
        {
            static NSString *searchCellIdentifier = @"searchCellIdentifier";
            
            PlanCell *cell = [tableView dequeueReusableCellWithIdentifier:searchCellIdentifier];
            if(!cell)
            {
                cell = [[PlanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchCellIdentifier];
            }
            Plan *plan = self.searchResultArray[indexPath.row];
            cell.plan = plan;
            cell.isDone = plan.iscompleted;
            if ([plan.iscompleted isEqualToString:@"1"])
            {
                cell.moveContentView.backgroundColor = color_Green_Mint;
                cell.backgroundColor = color_Green_Mint;
            }
            else
            {
                cell.moveContentView.backgroundColor = [UIColor whiteColor];
                cell.backgroundColor = [UIColor whiteColor];
            }
            cell.delegate = self;
            return cell;
            
        }
        else
        {
            return [self createNoDataCell:tableView indexPath:indexPath tips:@"无匹配结果"];
        }
    }
    else
    {
        if (self.planType == EverydayPlan)
        {
            if(indexPath.section < self.dayDateKeyArray.count)
            {
                NSString *dateKey = self.dayDateKeyArray[indexPath.section];
                NSArray *planArray = [self.dayPlanDict objectForKey:dateKey];
                if (indexPath.row < planArray.count)
                {
                    static NSString *everydayCellIdentifier = @"everydayCellIdentifier";
                    
                    PlanCell *cell = [tableView dequeueReusableCellWithIdentifier:everydayCellIdentifier];
                    if(!cell)
                    {
                        cell = [[PlanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:everydayCellIdentifier];
                    }
                    Plan *plan = planArray[indexPath.row];
                    cell.plan = plan;
                    cell.isDone = plan.iscompleted;
                    if ([plan.iscompleted isEqualToString:@"1"])
                    {
                        cell.moveContentView.backgroundColor = color_Green_Mint;
                        cell.backgroundColor = color_Green_Mint;
                    }
                    else
                    {
                        cell.moveContentView.backgroundColor = [UIColor whiteColor];
                        cell.backgroundColor = [UIColor whiteColor];
                    }
                    cell.delegate = self;
                    return cell;
                }
            }
            else
            {
                return [self createNoDataCell:tableView indexPath:indexPath tips:STRViewTips12];
            }
        }
        else if (self.planType == FuturePlan)
        {
            if(indexPath.section < self.futureDateKeyArray.count)
            {
                NSString *dateKey = self.futureDateKeyArray[indexPath.section];
                NSArray *planArray = [self.futurePlanDict objectForKey:dateKey];
                if (indexPath.row < planArray.count)
                {
                    static NSString *futureCellIdentifier = @"futureCellIdentifier";
                    
                    PlanCell *cell = [tableView dequeueReusableCellWithIdentifier:futureCellIdentifier];
                    if(!cell)
                    {
                        cell = [[PlanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:futureCellIdentifier];
                    }
                    Plan *plan = planArray[indexPath.row];
                    cell.plan = plan;
                    cell.isDone = plan.iscompleted;
                    cell.moveContentView.backgroundColor = [UIColor whiteColor];
                    cell.backgroundColor = [UIColor whiteColor];
                    cell.delegate = self;
                    return cell;
                }
            }
            else
            {
                return [self createNoDataCell:tableView indexPath:indexPath tips:STRViewTips13];
            }
        }
    }
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}

- (UITableViewCell *)createNoDataCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath tips:(NSString *)tips
{
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    static NSString *noDataCellIdentifier = @"noDataCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noDataCellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noDataCellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"";
        cell.textLabel.frame = cell.contentView.bounds;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.font = font_Bold_16;
    }
    if (indexPath.row == 2)
    {
        cell.textLabel.text = tips;
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ((self.planType == EverydayPlan
         && self.dayDateKeyArray.count == 0)
        || (self.planType == FuturePlan
         && self.futureDateKeyArray.count == 0)
        || self.searchKeyword.length > 0)
    {
        return 0.1f;
    }
    else
    {
        return kPlanSectionViewHeight;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.searchKeyword.length)
    {
        return [[UIView alloc] init];
    }
    else
    {
        PlanSectionView *view;
        if (self.planType == EverydayPlan && self.dayDateKeyArray.count > section)
        {
            NSString *date = self.dayDateKeyArray[section];
            NSArray *planArray = [self.dayPlanDict objectForKey:date];
            NSDictionary *dic = [self isAllDone:planArray];
            NSString *count = [dic objectForKey:@"count"];
            BOOL isAllDone = [[dic objectForKey:@"isAllDone"] boolValue];
            date = [self getSectionTitle:date];
            
            view = [[PlanSectionView alloc] initWithTitle:date count:count isAllDone:isAllDone];
            view.sectionIndex = section;
            if (self.daySectionFlag[section])
                [view toggleArrow];
            [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionClickedAction:)]];
            return view;
        }
        else if (self.planType == FuturePlan && self.futureDateKeyArray.count > section)
        {
            NSString *date = self.futureDateKeyArray[section];
            BOOL isAllDone = YES;
            if ([date isEqualToString:STRViewTips17])
            {
                isAllDone = NO;
            }
            view = [[PlanSectionView alloc] initWithTitle:date count:@"" isAllDone:isAllDone];
            view.sectionIndex = section;
            if (self.futureSectionFlag[section])
                [view toggleArrow];
            [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionClickedAction:)]];
            return view;
        }
        else
        {
            return [[UIView alloc] init];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ((self.planType == EverydayPlan
         && indexPath.section >= self.dayDateKeyArray.count)
        || (self.planType == FuturePlan
            && indexPath.section >= self.futureDateKeyArray.count)
        || (self.searchKeyword.length
            && indexPath.row >= self.searchResultArray.count))
    {
        return;
    }
    Plan *selectedPlan = nil;
    if (self.searchKeyword.length)
    {
        selectedPlan = self.searchResultArray[indexPath.row];
    }
    else
    {
        if (self.planType == EverydayPlan)
        {
            NSString *dateKey = self.dayDateKeyArray[indexPath.section];
            NSArray *planArray = [self.dayPlanDict objectForKey:dateKey];
            selectedPlan = planArray[indexPath.row];
        }
        else if (self.planType == FuturePlan)
        {
            NSString *dateKey = self.futureDateKeyArray[indexPath.section];
            NSArray *planArray = [self.futurePlanDict objectForKey:dateKey];
            selectedPlan = planArray[indexPath.row];
        }
    }
    if (selectedPlan)
    {
        [self toPlanDetailWithPlan:selectedPlan];
    }
}

- (NSString *)getSectionTitle:(NSString *)date
{
    NSDate *today = [NSDate date];
    NSDate *yesterday = [today dateByAddingTimeInterval:-24 * 3600];
    NSDate *tomorrow = [today dateByAddingTimeInterval:24 * 3600];
    NSString *todayString = [CommonFunction NSDateToNSString:today formatter:STRDateFormatterType4];
    NSString *yesterdayString = [CommonFunction NSDateToNSString:yesterday formatter:STRDateFormatterType4];
    NSString *tomorrowString = [CommonFunction NSDateToNSString:tomorrow formatter:STRDateFormatterType4];
    if ([date isEqualToString:todayString])
    {
        return [NSString stringWithFormat:@"%@ • %@", date, STRCommonTime2];
    }
    else if ([date isEqualToString:yesterdayString])
    {
        return [NSString stringWithFormat:@"%@ • %@", date, STRCommonTime3];
    }
    else if ([date isEqualToString:tomorrowString])
    {
        return [NSString stringWithFormat:@"%@ • %@", date, STRCommonTime9];
    }
    else
    {
        return date;
    }
}

- (BOOL)isToday:(NSString *)date
{
    NSDate *today = [NSDate date];
    NSString *todayString = [CommonFunction NSDateToNSString:today formatter:STRDateFormatterType4];
    if ([date isEqualToString:todayString])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSDictionary *)isAllDone:(NSArray *)planArray
{
    int done = 0;
    BOOL result = YES;
    for (Plan *plan in planArray)
    {
        if ([plan.iscompleted isEqualToString:@"0"])
        {
            result = NO;
        }
        else
        {
            done++;
        }
    }
    NSString *count = result ? @"" : [NSString stringWithFormat:@"%d/%lu", done, (unsigned long)planArray.count];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@(result) forKey:@"isAllDone"];
    [dic setObject:count forKey:@"count"];
    return dic;
}

- (void)sectionClickedAction:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
    
    PlanSectionView *view = (PlanSectionView *) sender.view;
    [view toggleArrow];
    
    if (self.planType == EverydayPlan)
    {
        self.daySectionFlag[view.sectionIndex] = !self.daySectionFlag[view.sectionIndex];
        [self.tableViewPlan reloadSections:[NSIndexSet indexSetWithIndex:view.sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
        //section自动上移
        if (self.daySectionFlag[view.sectionIndex])
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:view.sectionIndex];
            [self.tableViewPlan scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
    else if (self.planType == FuturePlan)
    {
        self.futureSectionFlag[view.sectionIndex] = !self.futureSectionFlag[view.sectionIndex];
        [self.tableViewPlan reloadSections:[NSIndexSet indexSetWithIndex:view.sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kPlanCellDeleteTag)
    {
        if (buttonIndex == 0)
        {
            self.deletePlan = nil;
            [self.planCell hideMenuView:YES Animated:YES];
        }
        else
        {
            [self deletePlanWithPlan:self.deletePlan];
        }
    }
}

- (void)toPlan:(NSNotification*)notification
{
    NSDictionary *dict = notification.userInfo;
    NSInteger type = [[dict objectForKey:@"type"] integerValue];
    if (type != 0)
    {//非计划提醒
        return;
    }
    Plan *plan = [[Plan alloc] init];
    plan.account = [dict objectForKey:@"account"];
    plan.planid = [dict objectForKey:@"tag"];
    if ([plan.planid isEqualToString:STRFiveDayFlag1])
    {
        //5天未新建计划提醒，不需要跳转到计划详情
        return;
    }
    BmobUser *user = [BmobUser currentUser];
    if ((user && [plan.account isEqualToString:user.objectId])
        || (!user && [plan.account isEqualToString:@""]))
    {
        plan.createtime = [dict objectForKey:@"createtime"];
        plan.content = [dict objectForKey:@"content"];
        plan.beginDate = [dict objectForKey:@"beginDate"];
        plan.iscompleted = [dict objectForKey:@"iscompleted"];
        plan.completetime = [dict objectForKey:@"completetime"];
        plan.isnotify = @"1";
        plan.notifytime = [dict objectForKey:@"notifytime"];
        
        [self toPlanDetailWithPlan:plan];
    }
}

- (void)toPlanDetailWithPlan:(Plan *)plan
{
    PlanDetailViewController *controller = [[PlanDetailViewController alloc] init];
    controller.plan = plan;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

//修改计划完成状态
- (void)changePlanCompleteStatus:(Plan *)plan
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:STRDateFormatterType1];
    NSString *timeNow = [dateFormatter stringFromDate:[NSDate date]];
    plan.updatetime = timeNow;
    //1完成 0未完成
    if ([plan.iscompleted isEqualToString:@"0"])
    {
        plan.iscompleted = @"1";
        plan.completetime = timeNow;
        //如果预计开始时间是在今天之后的，属于提前完成，把预计开始时间设成今天
        NSDate *beginDate = [CommonFunction NSStringDateToNSDate:plan.beginDate formatter:STRDateFormatterType4];
        NSInteger days = [CommonFunction calculateDayFromDate:[NSDate date] toDate:beginDate];
        if (days > 0)
        {
            plan.beginDate = [CommonFunction NSDateToNSString:[NSDate date] formatter:STRDateFormatterType4];
        }
        
        __weak typeof(self) weakSelf = self;
        PopupPlanRemarkView *remarkView = [[PopupPlanRemarkView alloc] initWithTitle:STRCommonTip51];
        remarkView.callbackBlock = ^(NSString *remark) {
            plan.remark = remark;
            [weakSelf saveAndRefresh:plan];
        };
        [remarkView show];
    }
    else
    {
        plan.iscompleted = @"0";
        plan.completetime = @"";
        [self saveAndRefresh:plan];
    }
}

- (void)saveAndRefresh:(Plan *)plan
{
    [self showHUD];
    __weak typeof(self) weakSelf = self;
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Plan"];
    [bquery getObjectInBackgroundWithId:plan.planid block:^(BmobObject *object,NSError *error)
     {
         if (error)
         {
             [weakSelf hideHUD];
         }
         else
         {
             if (object)
             {
                 [object setObject:plan.iscompleted forKey:@"isCompleted"];
                 [object setObject:plan.completetime forKey:@"completedTime"];
                 [object setObject:plan.remark forKey:@"remark"];
                 [object updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
                  {
                      [weakSelf hideHUD];
                      if (isSuccessful)
                      {
                          [NotificationCenter postNotificationName:NTFPlanSave object:nil];
                      }
                      else
                      {
                          [weakSelf alertButtonMessage:@"操作失败"];
                      }
                  }];
             }
             else
             {
                 [weakSelf hideHUD];
             }
         }
     }];
}

//删除计划
- (void)deletePlanWithPlan:(Plan *)plan
{
    [self showHUD];
    __weak typeof(self) weakSelf = self;
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Plan"];
    [bquery getObjectInBackgroundWithId:plan.planid block:^(BmobObject *object,NSError *error)
    {
        if (error)
        {
            [weakSelf hideHUD];
        }
        else
        {
            if (object)
            {
                [object setObject:@"1" forKey:@"isDeleted"];
                [object updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
                {
                    [weakSelf hideHUD];
                    if (isSuccessful)
                    {
                        if ([plan.isnotify isEqualToString:@"1"])
                        {
                            [CommonFunction cancelPlanNotification:object.objectId];
                        }
                        [NotificationCenter postNotificationName:NTFPlanSave object:nil];
                        [weakSelf alertToastMessage:STRCommonTip16];
                    }
                    else
                    {
                        [weakSelf alertButtonMessage:STRCommonTip17];
                    }
                }];
            }
            else
            {
                [weakSelf hideHUD];
            }
        }
    }];
}

-(void)setCanCustomEdit:(BOOL)canCustomEdit
{
    if (self.canCustomEditNow != canCustomEdit)
    {
        self.canCustomEditNow = canCustomEdit;
        
        CGRect frame = self.tableViewPlan.frame;
        if (self.canCustomEditNow)
        {
            if (self.hitView == nil)
            {
                self.hitView = [[HitView alloc] init];
                self.hitView.delegate = self;
                self.hitView.frame = frame;
            }
            self.hitView.frame = frame;
            [self.view addSubview:self.hitView];
            self.tableViewPlan.scrollEnabled = NO;
        }
        else
        {
            self.planCell = nil;
            [self.hitView removeFromSuperview];
            self.tableViewPlan.scrollEnabled = YES;
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.planCell == [tableView cellForRowAtIndexPath:indexPath])
    {
        [self.planCell hideMenuView:YES Animated:YES ];
        return NO;
    }
    return YES;
}

- (UIView *)hitViewClicked:(CGPoint)point event:(UIEvent *)event touchView:(UIView *)touchView
{
    BOOL vCloudReceiveTouch = NO;
    CGRect vSlidedCellRect;
    
    vSlidedCellRect = [self.hitView convertRect:self.planCell.frame fromView:self.tableViewPlan];
    
    vCloudReceiveTouch = CGRectContainsPoint(vSlidedCellRect, point);
    if (!vCloudReceiveTouch)
    {
        [self.planCell hideMenuView:YES Animated:YES];
    }
    return vCloudReceiveTouch ? [self.planCell hitTest:point withEvent:event] : touchView;
}

- (void)didCellWillShow:(id)aSender
{
    self.planCell = aSender;
    self.canCustomEdit = YES;
}

- (void)didCellWillHide:(id)aSender
{
    self.planCell = nil;
    self.canCustomEdit = NO;
}

- (void)didCellHided:(id)aSender
{
    self.planCell = nil;
    self.canCustomEdit = NO;
}

- (void)didCellShowed:(id)aSender
{
    self.planCell = aSender;
    self.canCustomEdit = YES;
}

- (void)didCellClicked:(id)aSender
{
    PlanCell *cell = (PlanCell *)aSender;
    [self toPlanDetailWithPlan:cell.plan];
}

- (void)didCellClickedDoneButton:(id)aSender
{
    PlanCell *cell = (PlanCell *)aSender;
    [self changePlanCompleteStatus:cell.plan];
}

- (void)didCellClickedDeleteButton:(id)aSender
{
    PlanCell *cell = (PlanCell *)aSender;
    self.deletePlan = cell.plan;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:STRViewTips11
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:STRCommonTip28
                                          otherButtonTitles:STRCommonTip27,
                          nil];
    alert.tag = kPlanCellDeleteTag;
    [alert show];
}

//搜索栏事件
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.searchResultArray = [NSMutableArray array];
    self.searchKeyword = [searchText copy];
    if (self.searchKeyword.length == 0)
    {
        [self getPlanData];
    }
    else
    {
        [self searchPlan];
    }
}

@end
