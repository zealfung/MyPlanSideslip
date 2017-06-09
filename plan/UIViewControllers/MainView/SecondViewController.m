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
#import "AHSegment.h"
#import "PlanSectionView.h"
#import <BmobSDK/BmobUser.h>
#import "LogInViewController.h"
#import "PopupPlanRemarkView.h"
#import "SecondViewController.h"
#import "PlanAddNewViewController.h"
#import "PlanDetailNewViewController.h"

NSUInteger const kPlanCellDeleteTag = 9527;

@interface SecondViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, PlanCellDelegate, HitViewDelegate, AHSegmentDelegate>

@property (nonatomic, strong) PlanCell *planCell;
@property (nonatomic, strong) HitView *hitView;
@property (nonatomic, assign) BOOL *daySectionFlag;
@property (nonatomic, assign) BOOL *futureSectionFlag;
@property (nonatomic, assign) BOOL *doneSectionFlag;
@property (nonatomic, assign) BOOL canCustomEditNow;
@property (nonatomic, assign) BOOL isLoadingPlanDay;
@property (nonatomic, assign) BOOL isLoadingPlanFuture;
@property (nonatomic, assign) BOOL isLoadingPlanDone;
@property (nonatomic, strong) Plan *deletePlan;
@property (nonatomic, strong) NSMutableArray *arrayPlanDay;
@property (nonatomic, strong) NSMutableArray *arrayPlanFuture;
@property (nonatomic, strong) NSMutableArray *arrayPlanDone;
@property (nonatomic, strong) NSMutableArray *arrayDayDateKey;
@property (nonatomic, strong) NSMutableDictionary *dictDayPlan;
@property (nonatomic, strong) NSMutableArray *arrayDoneDateKey;
@property (nonatomic, strong) NSMutableDictionary *dictDonePlan;
@property (nonatomic, strong) NSMutableArray *arrayFutureDateKey;
@property (nonatomic, strong) NSMutableDictionary *dictFuturePlan;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSString *searchKeyword;
@property (nonatomic, strong) NSMutableArray *arraySearchResult;
@property (nonatomic, strong) UITableView *tableViewPlan;
@property (nonatomic, strong) AHSegment *segment;
@property (nonatomic, assign) NSInteger segmentIndex;

@end

@implementation SecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = STRViewTitle2;
    self.tabBarItem.title = STRViewTitle2;

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
            [self reloadData];
            //记录刷新时间
            [UserDefaults setObject:[NSDate date] forKey:STRPlanListFlag];
            [UserDefaults synchronize];
        }
    }
    else
    {
        //记录刷新时间
        [UserDefaults setObject:[NSDate date] forKey:STRPlanListFlag];
        [UserDefaults synchronize];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//初始化自定义界面
- (void)loadCustomView
{
    [self initSegment];
    
    [self initTableView];

    [self reloadData];
}

- (void)initSegment
{
    self.segment = [[AHSegment alloc] initWithFrame:CGRectMake(0, 0, WIDTH_FULL_SCREEN, 44)];
    [self.segment updateChannels:@[STRViewTips124, STRViewTips125, STRViewTips7]];
    self.segment.delegate = self;
    [self.view addSubview:self.segment];
}

- (void)initTableView
{
    self.searchKeyword = @"";

    CGRect frame = CGRectZero;
    frame.origin.y = 44;
    frame.size.width = WIDTH_FULL_SCREEN;
    frame.size.height = HEIGHT_FULL_VIEW - 44;
    
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
        self.searchBar.placeholder = STRCommonTip52;
        self.tableViewPlan.tableHeaderView = self.searchBar;
    }
    UIView *footer = [[UIView alloc] init];
    self.tableViewPlan.tableFooterView = footer;
    self.tableViewPlan.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableViewPlan.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
        if (self.searchKeyword.length == 0)
        {
            [weakSelf reloadData];
        }
        else
        {
            [weakSelf.tableViewPlan.mj_header endRefreshing];
            [weakSelf.tableViewPlan.mj_footer endRefreshing];
        }
    }];
    self.tableViewPlan.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        if (self.searchKeyword.length == 0)
        {
            [weakSelf getPlanData];
        }
        else
        {
            [weakSelf.tableViewPlan.mj_header endRefreshing];
            [weakSelf.tableViewPlan.mj_footer endRefreshing];
        }
    }];
    [self.tableViewPlan setDefaultEmpty];
    [self.view addSubview:self.tableViewPlan];
}

- (void)reloadData
{
    self.arrayPlanDay = [NSMutableArray array];
    self.arrayPlanFuture = [NSMutableArray array];
    self.arrayPlanDone = [NSMutableArray array];
    self.arraySearchResult = [NSMutableArray array];
    [self getPlanData];
}

- (void)getPlanData
{
    switch (self.segmentIndex)
    {
        case 0:
            [self getPlanDay];
            break;
        case 1:
            [self getPlanFuture];
            break;
        case 2:
            [self getPlanDone];
            break;
        default:
            break;
    }
}

- (void)getPlanDay
{
    if (self.isLoadingPlanDay || ![LogIn isLogin])
    {
        [self.tableViewPlan.mj_header endRefreshing];
        [self.tableViewPlan.mj_footer endRefreshing];
        return;
    }
    self.isLoadingPlanDay = YES;
    
    [self showHUD];
    BmobUser *user = [BmobUser currentUser];
    __weak typeof(self) weakSelf = self;
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Plan"];
    [bquery whereKey:@"userObjectId" equalTo:user.objectId];
    [bquery whereKey:@"isDeleted" notEqualTo:@"1"];
    [bquery whereKey:@"isCompleted" notEqualTo:@"1"];
    NSString *today = [Utils NSDateToNSString:[NSDate date] formatter:STRDateFormatterType4];
    //查询beginDate列中值早于今天的数据
    NSArray *array =  @[@{@"beginDate":@{@"$lte":today}}];
    [bquery addTheConstraintByOrOperationWithArray:array];

    [bquery orderByDescending:@"beginDate"];
    bquery.limit = 100;
    bquery.skip = self.arrayPlanDay.count;

    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
     {
         [weakSelf hideHUD];
         weakSelf.isLoadingPlanDay = NO;
         
         if (!error && array.count)
         {
             [weakSelf.tableViewPlan.mj_header endRefreshing];
             [weakSelf.tableViewPlan.mj_footer endRefreshing];
             
             for (BmobObject *obj in array)
             {
                 Plan *plan = [[Plan alloc] init];
                 plan.account = [obj objectForKey:@"userObjectId"];
                 plan.planid = obj.objectId;
                 plan.content = [obj objectForKey:@"content"];
                 plan.planLevel = [obj objectForKey:@"planLevel"];
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
                 
                 if ([plan.isnotify isEqualToString:@"1"])
                 {
                     if ([plan.isRepeat isEqualToString:@"1"])
                     {
                         //更新提醒时间，防止提醒时间早于当前时间导致的设置提醒无效
                         plan.notifytime = [Utils updateNotifyTime:plan.notifytime];
                     }
                     [Utils updatePlanNotification:plan];
                 }
                 else
                 {
                     [Utils cancelPlanNotification:plan.planid];
                 }
             }
         }
         else
         {
             [weakSelf.tableViewPlan.mj_header endRefreshing];
             [weakSelf.tableViewPlan.mj_footer endRefreshingWithNoMoreData];
         }
         [weakSelf groupPlanDay:weakSelf.arrayPlanDay];
     }];
}

- (void)groupPlanDay:(NSArray *)array
{
    self.arrayDayDateKey = [NSMutableArray array];
    [self.arrayDayDateKey addObject:STRCommonTip53];
    [self.arrayDayDateKey addObject:STRCommonTip54];
    [self.arrayDayDateKey addObject:STRCommonTip55];
    self.dictDayPlan = [NSMutableDictionary dictionary];
    
    NSString *key = @"";
    for (NSInteger i = 0; i < array.count; i++)
    {
        Plan *plan = array[i];

        if ([plan.planLevel isEqualToString:@"2"])
        {
            key = STRCommonTip53;
        }
        else if ([plan.planLevel isEqualToString:@"1"])
        {
            key = STRCommonTip54;
        }
        else
        {
            key = STRCommonTip55;
        }
        NSMutableArray *arrayLevel = [self.dictDayPlan objectForKey:key];
        if (!arrayLevel)
        {
            arrayLevel = [[NSMutableArray alloc] init];
            [self.dictDayPlan setValue:arrayLevel forKey:key];
        }
        [arrayLevel addObject:plan];
    }
    //----------------去掉没有子项的section-----------------------------------------
    NSMutableArray *arrayLevel2 = [self.dictDayPlan objectForKey:STRCommonTip53];
    if (!arrayLevel2 || arrayLevel2.count == 0)
    {
        [self.arrayDayDateKey removeObject:STRCommonTip53];
    }
    NSMutableArray *arrayLevel1 = [self.dictDayPlan objectForKey:STRCommonTip54];
    if (!arrayLevel1 || arrayLevel1.count == 0)
    {
        [self.arrayDayDateKey removeObject:STRCommonTip54];
    }
    NSMutableArray *arrayLevel0 = [self.dictDayPlan objectForKey:STRCommonTip55];
    if (!arrayLevel0 || arrayLevel0.count == 0)
    {
        [self.arrayDayDateKey removeObject:STRCommonTip55];
    }
    //----------------------------------------------------------------------------
    NSUInteger sections = self.arrayDayDateKey.count;
    self.daySectionFlag = (BOOL *)malloc(sections * sizeof(BOOL));
    memset((void *)self.daySectionFlag, YES, sections * sizeof(BOOL));

    [self.tableViewPlan reloadData];
}

- (void)getPlanFuture
{
    if (self.isLoadingPlanFuture || ![LogIn isLogin])
    {
        [self.tableViewPlan.mj_header endRefreshing];
        [self.tableViewPlan.mj_footer endRefreshing];
        return;
    }
    self.isLoadingPlanFuture = YES;
    
    [self showHUD];
    BmobUser *user = [BmobUser currentUser];
    __weak typeof(self) weakSelf = self;
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Plan"];
    [bquery whereKey:@"userObjectId" equalTo:user.objectId];
    [bquery whereKey:@"isDeleted" notEqualTo:@"1"];
    NSString *today = [Utils NSDateToNSString:[NSDate date] formatter:STRDateFormatterType4];
    //查询beginDate列中值晚于今天的数据
    NSArray *array =  @[@{@"beginDate":@{@"$gt":today}}];
    [bquery addTheConstraintByOrOperationWithArray:array];
    
    [bquery orderByAscending:@"beginDate"];
    bquery.limit = 100;
    bquery.skip = self.arrayPlanFuture.count;
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
     {
         [weakSelf hideHUD];
         weakSelf.isLoadingPlanFuture = NO;
         
         if (!error && array.count)
         {
             [weakSelf.tableViewPlan.mj_header endRefreshing];
             [weakSelf.tableViewPlan.mj_footer endRefreshing];
             
             for (BmobObject *obj in array)
             {
                 Plan *plan = [[Plan alloc] init];
                 plan.account = [obj objectForKey:@"userObjectId"];
                 plan.planid = obj.objectId;
                 plan.content = [obj objectForKey:@"content"];
                 plan.planLevel = [obj objectForKey:@"planLevel"];
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
         else
         {
             [weakSelf.tableViewPlan.mj_header endRefreshing];
             [weakSelf.tableViewPlan.mj_footer endRefreshingWithNoMoreData];
         }
         [weakSelf groupPlanFuture:weakSelf.arrayPlanFuture];
     }];
}

- (void)groupPlanFuture:(NSArray *)array
{
    self.arrayFutureDateKey = [NSMutableArray array];
    [self.arrayFutureDateKey addObject:STRViewTips17];
    [self.arrayFutureDateKey addObject:STRViewTips18];
    [self.arrayFutureDateKey addObject:STRViewTips19];
    [self.arrayFutureDateKey addObject:STRViewTips20];
    self.dictFuturePlan = [NSMutableDictionary dictionary];

    NSString *key = @"";
    for (NSInteger i = 0; i < array.count; i++)
    {
        Plan *plan = array[i];
        
        NSDate *beginDate = [Utils NSStringDateToNSDate:plan.beginDate formatter:STRDateFormatterType4];
        NSInteger days = [Utils calculateDayFromDate:[NSDate date] toDate:beginDate];
        
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
        NSMutableArray *dateArray = [self.dictFuturePlan objectForKey:key];
        if (!dateArray)
        {
            dateArray = [[NSMutableArray alloc] init];
            [self.dictFuturePlan setValue:dateArray forKey:key];
        }
        [dateArray addObject:plan];
    }
    //----------------去掉没有子项的section-----------------------------------------
    NSMutableArray *arrayTomorrow = [self.dictFuturePlan objectForKey:STRViewTips17];
    if (!arrayTomorrow || arrayTomorrow.count == 0)
    {
        [self.arrayFutureDateKey removeObject:STRViewTips17];
    }
    NSMutableArray *arrayWeek = [self.dictFuturePlan objectForKey:STRViewTips18];
    if (!arrayWeek || arrayWeek.count == 0)
    {
        [self.arrayFutureDateKey removeObject:STRViewTips18];
    }
    NSMutableArray *arrayMonth = [self.dictFuturePlan objectForKey:STRViewTips19];
    if (!arrayMonth || arrayMonth.count == 0)
    {
        [self.arrayFutureDateKey removeObject:STRViewTips19];
    }
    NSMutableArray *arrayYear = [self.dictFuturePlan objectForKey:STRViewTips20];
    if (!arrayYear || arrayYear.count == 0)
    {
        [self.arrayFutureDateKey removeObject:STRViewTips20];
    }
    //----------------------------------------------------------------------------
    NSUInteger sections = self.arrayFutureDateKey.count;
    self.futureSectionFlag = (BOOL *)malloc(sections * sizeof(BOOL));
    memset((void *)self.futureSectionFlag, YES, sections * sizeof(BOOL));

    [self.tableViewPlan reloadData];
}

- (void)getPlanDone
{
    if (self.isLoadingPlanDone || ![LogIn isLogin])
    {
        [self.tableViewPlan.mj_header endRefreshing];
        [self.tableViewPlan.mj_footer endRefreshing];
        return;
    }
    self.isLoadingPlanDone = YES;
    
    [self showHUD];
    BmobUser *user = [BmobUser currentUser];
    __weak typeof(self) weakSelf = self;
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Plan"];
    [bquery whereKey:@"userObjectId" equalTo:user.objectId];
    [bquery whereKey:@"isDeleted" notEqualTo:@"1"];
    [bquery whereKey:@"isCompleted" equalTo:@"1"];
    NSString *today = [Utils NSDateToNSString:[NSDate date] formatter:STRDateFormatterType4];
    //查询beginDate列中值早于今天的数据
    NSArray *array =  @[@{@"beginDate":@{@"$lte":today}}];
    [bquery addTheConstraintByOrOperationWithArray:array];
    
    [bquery orderByDescending:@"updatedAt"];
    bquery.limit = 100;
    bquery.skip = self.arrayPlanDone.count;
    
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
     {
         [weakSelf hideHUD];
         weakSelf.isLoadingPlanDone = NO;
         
         if (!error && array.count)
         {
             [weakSelf.tableViewPlan.mj_header endRefreshing];
             [weakSelf.tableViewPlan.mj_footer endRefreshing];
             
             for (BmobObject *obj in array)
             {
                 Plan *plan = [[Plan alloc] init];
                 plan.account = [obj objectForKey:@"userObjectId"];
                 plan.planid = obj.objectId;
                 plan.content = [obj objectForKey:@"content"];
                 plan.planLevel = [obj objectForKey:@"planLevel"];
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
                 [weakSelf.arrayPlanDone addObject:plan];
                 
                 if ([plan.isnotify isEqualToString:@"1"])
                 {
                     [Utils cancelPlanNotification:plan.planid];
                 }
             }
         }
         else
         {
             [weakSelf.tableViewPlan.mj_header endRefreshing];
             [weakSelf.tableViewPlan.mj_footer endRefreshingWithNoMoreData];
         }
         [weakSelf groupPlanDone:weakSelf.arrayPlanDone];
     }];
}

- (void)groupPlanDone:(NSArray *)array
{
    self.arrayDoneDateKey = [NSMutableArray array];
    self.dictDonePlan = [NSMutableDictionary dictionary];
    NSMutableArray *arrayDoneDateKeyTmp = [NSMutableArray array];
    
    NSString *key = @"";
    for (NSInteger i = 0; i < array.count; i++)
    {
        Plan *plan = array[i];
        
        key = plan.beginDate;
        
        NSMutableArray *dateArray = [self.dictDonePlan objectForKey:key];
        if (!dateArray)
        {
            dateArray = [[NSMutableArray alloc] init];
            [self.dictDonePlan setValue:dateArray forKey:key];
            [arrayDoneDateKeyTmp addObject:key];
        }
        
        [dateArray addObject:plan];
    }
    [self.arrayDoneDateKey addObjectsFromArray:arrayDoneDateKeyTmp];
    //日期降序排列
    self.arrayDoneDateKey = [NSMutableArray arrayWithArray:[Utils arraySort:self.arrayDoneDateKey ascending:NO]];
    
    NSUInteger sections = self.arrayDoneDateKey.count;
    self.doneSectionFlag = (BOOL *)malloc(sections * sizeof(BOOL));
    memset((void *)self.doneSectionFlag, NO, sections * sizeof(BOOL));
    self.doneSectionFlag[0] = !self.doneSectionFlag[0];
    
    [self.tableViewPlan reloadData];
}

- (void)searchPlan
{
    if (![LogIn isLogin])
    {
        return;
    }
    [self showHUD];
    BmobUser *user = [BmobUser currentUser];
    __weak typeof(self) weakSelf = self;
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Plan"];
    [bquery whereKey:@"userObjectId" equalTo:user.objectId];
    [bquery whereKey:@"isDeleted" notEqualTo:@"1"];
    [bquery whereKey:@"content" matchesWithRegex:[NSString stringWithFormat:@".*?%@.*?", self.searchKeyword]];
    [bquery orderByDescending:@"updatedTime"];
    bquery.limit = 100;
    bquery.skip = self.arraySearchResult.count;
    
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
                 plan.planLevel = [obj objectForKey:@"planLevel"];
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
                 [weakSelf.arraySearchResult addObject:plan];
             }
         }
         [weakSelf.tableViewPlan reloadData];
     }];
}

#pragma mark - AHSegmentDelegate
- (void)AHSegment:(AHSegment *)segment didSelectedIndex:(NSInteger)index
{
    self.segmentIndex = index;
    
    if ((self.segmentIndex == 0 && self.arrayPlanDay.count)
        || (self.segmentIndex == 1 && self.arrayPlanFuture.count)
        || (self.segmentIndex == 2 && self.arrayPlanDone.count))
    {
        [self.tableViewPlan reloadData];
    }
    else
    {
        [self getPlanData];
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
        if (self.segmentIndex == 2)
        {
            return self.dictDonePlan.count;
        }
        else if (self.segmentIndex == 1)
        {
            return self.dictFuturePlan.count;
        }
        else
        {
            return self.dictDayPlan.count;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchKeyword.length)
    {
        return self.arraySearchResult.count;
    }
    else
    {
        switch (self.segmentIndex)
        {
            case 0:
            {
                if(self.arrayDayDateKey.count)
                {
                    if (self.daySectionFlag[section])
                    {
                        NSString *key = self.arrayDayDateKey[section];
                        NSArray *dateArray = [self.dictDayPlan objectForKey:key];
                        return dateArray.count;
                    }
                    else
                    {
                        return 0;
                    }
                }
                else
                {
                    return 0;
                }
            }
            case 1:
            {
                if(self.arrayFutureDateKey.count)
                {
                    if (self.futureSectionFlag[section])
                    {
                        NSString *key = self.arrayFutureDateKey[section];
                        NSArray *dateArray = [self.dictFuturePlan objectForKey:key];
                        return dateArray.count;
                    }
                    else
                    {
                        return 0;
                    }
                }
                else
                {
                    return 0;
                }
            }
            case 2:
            {
                if(self.arrayDoneDateKey.count)
                {
                    if (self.doneSectionFlag[section])
                    {
                        NSString *key = self.arrayDoneDateKey[section];
                        NSArray *dateArray = [self.dictDonePlan objectForKey:key];
                        return dateArray.count;
                    }
                    else
                    {
                        return 0;
                    }
                }
                else
                {
                    return 0;
                }
            }
            default:
                return 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    if (self.searchKeyword.length)
    {
        if(indexPath.row < self.arraySearchResult.count)
        {
            static NSString *searchCellIdentifier = @"searchCellIdentifier";
            PlanCell *cell = [tableView dequeueReusableCellWithIdentifier:searchCellIdentifier];
            if(!cell)
            {
                cell = [[PlanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchCellIdentifier];
            }
            Plan *plan = self.arraySearchResult[indexPath.row];
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
        switch (self.segmentIndex)
        {
            case 0:
            {
                if(indexPath.section < self.arrayDayDateKey.count)
                {
                    NSString *dateKey = self.arrayDayDateKey[indexPath.section];
                    NSArray *planArray = [self.dictDayPlan objectForKey:dateKey];
                    if (indexPath.row < planArray.count)
                    {
                        static NSString *dayCellIdentifier = @"dayCellIdentifier";
                        PlanCell *cell = [tableView dequeueReusableCellWithIdentifier:dayCellIdentifier];
                        if(!cell)
                        {
                            cell = [[PlanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:dayCellIdentifier];
                        }
                        Plan *plan = planArray[indexPath.row];
                        cell.plan = plan;
                        cell.isDone = plan.iscompleted;
                        cell.delegate = self;
                        if (plan.completetime.length)
                        {
                            NSDate *today = [NSDate date];
                            NSString *todayString = [Utils NSDateToNSString:today formatter:STRDateFormatterType4];
                            NSDate *completeDate = [Utils NSStringDateToNSDate:plan.completetime formatter:STRDateFormatterType1];
                            NSString *completeDateString = [Utils NSDateToNSString:completeDate formatter:STRDateFormatterType4];
                            if ([todayString isEqualToString:completeDateString])
                            {
                                cell.moveContentView.backgroundColor = color_Green_Mint;
                                cell.backgroundColor = color_Green_Mint;
                            }
                            else
                            {
                                cell.moveContentView.backgroundColor = [UIColor whiteColor];
                                cell.backgroundColor = [UIColor whiteColor];
                            }
                        }
                        else
                        {
                            cell.moveContentView.backgroundColor = [UIColor whiteColor];
                            cell.backgroundColor = [UIColor whiteColor];
                        }
                        return cell;
                    }
                }
            }
                break;
            case 1:
            {
                if(indexPath.section < self.arrayFutureDateKey.count)
                {
                    NSString *dateKey = self.arrayFutureDateKey[indexPath.section];
                    NSArray *planArray = [self.dictFuturePlan objectForKey:dateKey];
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
            }
                break;
            case 2:
            {
                if(indexPath.section < self.arrayDoneDateKey.count)
                {
                    NSString *dateKey = self.arrayDoneDateKey[indexPath.section];
                    NSArray *planArray = [self.dictDonePlan objectForKey:dateKey];
                    if (indexPath.row < planArray.count)
                    {
                        static NSString *doneCellIdentifier = @"doneCellIdentifier";
                        PlanCell *cell = [tableView dequeueReusableCellWithIdentifier:doneCellIdentifier];
                        if(!cell)
                        {
                            cell = [[PlanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:doneCellIdentifier];
                        }
                        Plan *plan = planArray[indexPath.row];
                        cell.plan = plan;
                        cell.isDone = plan.iscompleted;
                        cell.moveContentView.backgroundColor = color_Green_Mint;
                        cell.backgroundColor = color_Green_Mint;
                        cell.delegate = self;
                        return cell;
                    }
                }
            }
                break;
            default:
                break;
        }
    }
    return [[UITableViewCell alloc] init];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ((self.segmentIndex == 0
         && self.arrayDayDateKey.count == 0)
        || (self.segmentIndex == 1
         && self.arrayFutureDateKey.count == 0)
        || (self.segmentIndex == 2
            && self.arrayDoneDateKey.count == 0)
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
        if (self.segmentIndex == 2 && self.arrayDoneDateKey.count > section)
        {
            NSString *date = self.arrayDoneDateKey[section];
            NSArray *planArray = [self.dictDonePlan objectForKey:date];
            NSDictionary *dic = [self isAllDone:planArray];
            NSString *count = [dic objectForKey:@"count"];
            BOOL isAllDone = [[dic objectForKey:@"isAllDone"] boolValue];
            date = [self getSectionTitle:date];
            
            view = [[PlanSectionView alloc] initWithTitle:date count:count isAllDone:isAllDone];
            view.sectionIndex = section;
            if (self.doneSectionFlag[section])
                [view toggleArrow];
            [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionClickedAction:)]];
            return view;
        }
        else if (self.segmentIndex == 1 && self.arrayFutureDateKey.count > section)
        {
            NSString *date = self.arrayFutureDateKey[section];
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
            NSString *date = self.arrayDayDateKey[section];
            view = [[PlanSectionView alloc] initWithTitle:date count:@"" isAllDone:YES];
            view.sectionIndex = section;
            if (self.daySectionFlag[section])
                [view toggleArrow];
            [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionClickedAction:)]];
            return view;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ((self.segmentIndex == 2
         && indexPath.section >= self.arrayDoneDateKey.count)
        || (self.segmentIndex == 1
            && indexPath.section >= self.arrayFutureDateKey.count)
        || (self.segmentIndex == 0
            && indexPath.row >= self.arrayDayDateKey.count)
        || (self.searchKeyword.length
            && indexPath.row >= self.arraySearchResult.count))
    {
        return;
    }
    Plan *selectedPlan = nil;
    if (self.searchKeyword.length)
    {
        selectedPlan = self.arraySearchResult[indexPath.row];
    }
    else
    {
        switch (self.segmentIndex)
        {
            case 0:
            {
                NSString *dateKey = self.arrayDayDateKey[indexPath.section];
                NSArray *planArray = [self.dictDayPlan objectForKey:dateKey];
                selectedPlan = planArray[indexPath.row];
            }
                break;
            case 1:
            {
                NSString *dateKey = self.arrayFutureDateKey[indexPath.section];
                NSArray *planArray = [self.dictFuturePlan objectForKey:dateKey];
                selectedPlan = planArray[indexPath.row];
            }
                break;
            case 2:
            {
                NSString *dateKey = self.arrayDoneDateKey[indexPath.section];
                NSArray *planArray = [self.dictDonePlan objectForKey:dateKey];
                selectedPlan = planArray[indexPath.row];
            }
                break;
            default:
                break;
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
    NSString *todayString = [Utils NSDateToNSString:today formatter:STRDateFormatterType4];
    NSString *yesterdayString = [Utils NSDateToNSString:yesterday formatter:STRDateFormatterType4];
    NSString *tomorrowString = [Utils NSDateToNSString:tomorrow formatter:STRDateFormatterType4];
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
    NSString *todayString = [Utils NSDateToNSString:today formatter:STRDateFormatterType4];
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
    
    if (self.segmentIndex == 2)
    {
        self.doneSectionFlag[view.sectionIndex] = !self.doneSectionFlag[view.sectionIndex];
        [self.tableViewPlan reloadSections:[NSIndexSet indexSetWithIndex:view.sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
        //section自动上移
        if (self.doneSectionFlag[view.sectionIndex])
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:view.sectionIndex];
            [self.tableViewPlan scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
    else if (self.segmentIndex == 1)
    {
        self.futureSectionFlag[view.sectionIndex] = !self.futureSectionFlag[view.sectionIndex];
        [self.tableViewPlan reloadSections:[NSIndexSet indexSetWithIndex:view.sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        self.daySectionFlag[view.sectionIndex] = !self.daySectionFlag[view.sectionIndex];
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
        plan.planLevel = [dict objectForKey:@"planLevel"];
        plan.isRepeat = [dict objectForKey:@"isRepeat"];
        
        [self toPlanDetailWithPlan:plan];
    }
}

- (void)toPlanDetailWithPlan:(Plan *)plan
{
    PlanDetailNewViewController *controller = [[PlanDetailNewViewController alloc] init];
    controller.plan = plan;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

//修改计划完成状态
- (void)changePlanCompleteStatus:(Plan *)plan
{
    NSString *timeNow = [Utils NSDateToNSString:[NSDate date] formatter:STRDateFormatterType1];
    plan.updatetime = timeNow;
    //1完成 0未完成
    if ([plan.iscompleted isEqualToString:@"0"])
    {
        if ([plan.isRepeat isEqualToString:@"1"])
        {
            plan.iscompleted = @"0";
        }
        else
        {
            plan.iscompleted = @"1";
        }
        plan.completetime = timeNow;
        //如果预计开始时间是在今天之后的，属于提前完成，把预计开始时间设成今天
        NSDate *beginDate = [Utils NSStringDateToNSDate:plan.beginDate formatter:STRDateFormatterType4];
        NSInteger days = [Utils calculateDayFromDate:[NSDate date] toDate:beginDate];
        if (days > 0)
        {
            plan.beginDate = [Utils NSDateToNSString:[NSDate date] formatter:STRDateFormatterType4];
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
                 [object setObject:plan.beginDate forKey:@"beginDate"];
                 [object setObject:plan.iscompleted forKey:@"isCompleted"];
                 [object setObject:plan.completetime forKey:@"completedTime"];
                 [object setObject:plan.remark forKey:@"remark"];
                 [object updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
                  {
                      [weakSelf hideHUD];
                      if (isSuccessful)
                      {
                          [NotificationCenter postNotificationName:NTFPlanSave object:nil];
                          if ([plan.isRepeat isEqualToString:@"1"])
                          {
                              [weakSelf addDonePlan:plan];
                          }
                      }
                      else
                      {
                          [weakSelf alertButtonMessage:STRErrorTip2];
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

- (void)addDonePlan:(Plan *)plan
{
    plan.iscompleted = @"1";
    plan.beginDate = [Utils NSDateToNSString:[NSDate date] formatter:STRDateFormatterType4];
    NSString *timeNow = [Utils NSDateToNSString:[NSDate date] formatter:STRDateFormatterType1];
    plan.updatetime = timeNow;
    plan.completetime = timeNow;

    if (!plan.isnotify)
    {
        plan.isnotify = @"0";
        plan.notifytime = @"";
    }
    
    BmobUser *user = [BmobUser currentUser];
    BmobObject *newPlan = [BmobObject objectWithClassName:@"Plan"];
    NSDictionary *dic = @{@"userObjectId":user.objectId,
                          @"content":plan.content,
                          @"planLevel":plan.planLevel,
                          @"notifyTime":plan.notifytime,
                          @"isCompleted":plan.iscompleted,
                          @"completedTime":plan.completetime,
                          @"isNotify":plan.isnotify,
                          @"isDeleted":plan.isdeleted,
                          @"isRepeat":plan.isRepeat,
                          @"remark":plan.remark,
                          @"beginDate":plan.beginDate};
    [newPlan saveAllWithDictionary:dic];
    BmobACL *acl = [BmobACL ACL];
    [acl setReadAccessForUser:user];//设置只有当前用户可读
    [acl setWriteAccessForUser:user];//设置只有当前用户可写
    newPlan.ACL = acl;
    [newPlan saveInBackground];
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
                            [Utils cancelPlanNotification:object.objectId];
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
    self.arraySearchResult = [NSMutableArray array];
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
