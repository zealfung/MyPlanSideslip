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
#import "WZLBadgeImport.h"
#import "PlanSectionView.h"
#import "SecondViewController.h"
#import "AddPlanViewController.h"
#import <RESideMenu/RESideMenu.h>

NSUInteger const kPlan_MenuHeight = 44;
NSUInteger const kPlan_MenuLineHeight = 3;
NSUInteger const kPlanCellDeleteTag = 9527;
NSUInteger const kPlan_TodayCellHeaderViewHeight = 30;

@interface SecondViewController ()<UITableViewDataSource, UITableViewDelegate, PlanCellDelegate, HitViewDelegate> {
    
    PlanCell *planCell;
    HitView *hitView;
    NSInteger dayTotal;
    NSInteger futureTotal;
    NSInteger dayStart;
    NSInteger futureStart;
    BOOL *daySectionFlag;
    BOOL *futureSectionFlag;
    BOOL canCustomEditNow;
    BOOL isLoadMore;
    PlanType planType;
    Plan *deletePlan;
    NSMutableArray *dayDateKeyArray;
    NSMutableDictionary *dayPlanDict;
    NSMutableArray *futureDateKeyArray;
    NSMutableDictionary *futurePlanDict;
    
    UITableView *tableViewDay;
    UITableView *tableViewFuture;
    ThreeSubView *threeSubView;
    UIView *underLineView;
}

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = str_ViewTitle_2;
    self.tabBarItem.title = str_ViewTitle_2;
    [self createNavBarButton];
    
    [NotificationCenter addObserver:self selector:@selector(toPlan:) name:Notify_Push_LocalNotify object:nil];
    [NotificationCenter addObserver:self selector:@selector(getPlanData) name:Notify_Plan_Save object:nil];
    [NotificationCenter addObserver:self selector:@selector(refreshRedDot) name:Notify_Messages_Save object:nil];
    
    [self loadCustomView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshRedDot];
    [self checkUnread:self.tabBarController.tabBar index:1];
    
    //计算最近一次加载数据时间是否已经超过十分钟，如果是，就自动刷新一次数据
    NSDate *lastUpdatedTime = [UserDefaults objectForKey:str_PlanList_UpdatedTime];
    if (lastUpdatedTime) {
        NSTimeInterval last = [lastUpdatedTime timeIntervalSince1970];
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        
        if ((now-last)/60 > 5) {//大于五分钟，自动重载一次数据
            [self getPlanData];
            //记录刷新时间
            [UserDefaults setObject:[NSDate date] forKey:str_PlanList_UpdatedTime];
            [UserDefaults synchronize];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (planType == EverydayPlan) {
        [self moveUnderLineViewToButton:threeSubView.leftButton];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [NotificationCenter removeObserver:self];
}

- (void)createNavBarButton {
    self.leftBarButtonItem = [self createBarButtonItemWithNormalImageName:png_Btn_LeftMenu selectedImageName:png_Btn_LeftMenu selector:@selector(leftMenuAction:)];
    self.rightBarButtonItem = [self createBarButtonItemWithNormalImageName:png_Btn_Add selectedImageName:png_Btn_Add selector:@selector(addAction:)];
}

- (void)getPlanData {
    if (planType == FuturePlan) {
        [self getFuturePlan];
    } else {
        [self getDayPlan];
    }
}

- (void)getDayPlan {
    dayTotal = [[PlanCache getPlanTotalCount:@"DAY"] integerValue];
    if (!isLoadMore) {//重头开始加载
        dayStart = 0;
        dayDateKeyArray = [NSMutableArray array];
        dayPlanDict = [NSMutableDictionary dictionary];
    }
    NSArray *array = [NSArray arrayWithArray:[PlanCache getPlan:YES startIndex:dayStart]];
    NSMutableArray *dayDateKeyArrayTmp = [NSMutableArray array];
    
    NSString *today = [CommonFunction NSDateToNSString:[NSDate date] formatter:str_DateFormatter_yyyy_MM_dd];
    NSString *key = @"";
    for (NSInteger i = 0; i < array.count; i++) {
        Plan *plan = array[i];
        if ([plan.iscompleted isEqualToString:@"1"]) {//已完成的计划归到开始日期那天
            key = plan.beginDate;
        } else {//未完成的计划都归到今天里面
            key = today;
        }
        NSMutableArray *dateArray = [dayPlanDict objectForKey:key];
        if (!dateArray) {
            dateArray = [[NSMutableArray alloc] init];
            [dayPlanDict setValue:dateArray forKey:key];
            [dayDateKeyArrayTmp addObject:key];
        }
        
        [dateArray addObject:plan];
    }
    [dayDateKeyArray addObjectsFromArray:dayDateKeyArrayTmp];
    //日期降序排列
    dayDateKeyArray = [NSMutableArray arrayWithArray:[CommonFunction arraySort:dayDateKeyArray ascending:NO]];
    
    NSUInteger sections = dayDateKeyArray.count;
    daySectionFlag = (BOOL *)malloc(sections * sizeof(BOOL));
    memset((void *)daySectionFlag, NO, sections * sizeof(BOOL));
    daySectionFlag[0] = !daySectionFlag[0];
    
    isLoadMore = NO;
    if (dayStart < dayTotal) {
        dayStart += kPlanLoadMax;
    } else {
        [tableViewDay.mj_footer endRefreshingWithNoMoreData];
    }
    [tableViewDay.mj_footer endRefreshing];
    [self reloadTableViewData];
}

- (void)getFuturePlan {
    futureTotal = [[PlanCache getPlanTotalCount:@"FUTURE"] integerValue];
    if (!isLoadMore) {//重头开始加载
        futureStart = 0;
        futureDateKeyArray = [NSMutableArray array];
        [futureDateKeyArray addObject:str_Plan_FutureWeek];
        [futureDateKeyArray addObject:str_Plan_FutureMonth];
        [futureDateKeyArray addObject:str_Plan_FutureYear];
        futurePlanDict = [NSMutableDictionary dictionary];
    }
    NSArray *array = [NSArray arrayWithArray:[PlanCache getPlan:NO startIndex:futureStart]];

    NSString *key = @"";
    for (NSInteger i = 0; i < array.count; i++) {
        Plan *plan = array[i];
        
        NSDate *beginDate = [CommonFunction NSStringDateToNSDate:plan.beginDate formatter:str_DateFormatter_yyyy_MM_dd];
        NSInteger days = [self calculateDayFromDate:[NSDate date] toDate:beginDate];
        
        if (days >= 0 && days <= 7) {//一星期内开始
            key = str_Plan_FutureWeek;
        } else if (days > 7 && days <= 30) {//一个月内开始
            key = str_Plan_FutureMonth;
        } else {//一个月后开始
            key = str_Plan_FutureYear;
        }
        NSMutableArray *dateArray = [futurePlanDict objectForKey:key];
        if (!dateArray) {
            dateArray = [[NSMutableArray alloc] init];
            [futurePlanDict setValue:dateArray forKey:key];
        }
        [dateArray addObject:plan];
    }
    //----------------去掉没有子项的section-----------------------------------------
    NSMutableArray *arrayWeek = [futurePlanDict objectForKey:str_Plan_FutureWeek];
    if (!arrayWeek || arrayWeek.count == 0) {
        [futureDateKeyArray removeObject:str_Plan_FutureWeek];
    }
    NSMutableArray *arrayMonth = [futurePlanDict objectForKey:str_Plan_FutureMonth];
    if (!arrayMonth || arrayMonth.count == 0) {
        [futureDateKeyArray removeObject:str_Plan_FutureMonth];
    }
    NSMutableArray *arrayYear = [futurePlanDict objectForKey:str_Plan_FutureYear];
    if (!arrayYear || arrayYear.count == 0) {
        [futureDateKeyArray removeObject:str_Plan_FutureYear];
    }
    //----------------------------------------------------------------------------
    NSUInteger sections = futureDateKeyArray.count;
    futureSectionFlag = (BOOL *)malloc(sections * sizeof(BOOL));
    memset((void *)futureSectionFlag, YES, sections * sizeof(BOOL));
    
    isLoadMore = NO;
    if (futureStart < futureTotal) {
        futureStart += kPlanLoadMax;
    } else {
        [tableViewFuture.mj_footer endRefreshingWithNoMoreData];
    }
    [tableViewFuture.mj_footer endRefreshing];
    [self reloadTableViewData];
}

- (NSInteger)calculateDayFromDate:(NSDate *)date1 toDate:(NSDate *)date2{
    NSCalendar *userCalendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [userCalendar components:NSDayCalendarUnit fromDate:date1 toDate:date2 options:0];
    NSInteger days = [components day];
    return days;
}

- (void)reloadTableViewData {
    if (tableViewDay && planType == EverydayPlan) {
        [tableViewDay reloadData];
    } else if (tableViewFuture && planType == FuturePlan) {
        [tableViewFuture reloadData];
    }
}

- (void)refreshRedDot {
    //小红点
    if ([PlanCache hasUnreadMessages]) {
        [self.leftBarButtonItem showBadgeWithStyle:WBadgeStyleRedDot value:0 animationType:WBadgeAnimTypeNone];
        self.leftBarButtonItem.badgeCenterOffset = CGPointMake(-8, 0);
    } else {
        [self.leftBarButtonItem clearBadge];
    }
}

//初始化自定义界面
- (void)loadCustomView {
    if (!underLineView) {
        [self showMenuView];
        [self showUnderLineView];
    }
    self.planType = EverydayPlan;
    [self showListView];
}

- (void)showMenuView {
    __weak typeof(self) weakSelf = self;
    threeSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kPlan_MenuHeight) leftButtonSelectBlock: ^{
        
        weakSelf.planType = EverydayPlan;
        
    } centerButtonSelectBlock: ^{
        
        weakSelf.planType = FuturePlan;
        
    } rightButtonSelectBlock:nil];
    
    threeSubView.fixLeftWidth = CGRectGetWidth(self.view.bounds)/2;
    threeSubView.fixCenterWidth = CGRectGetWidth(self.view.bounds)/2;
    [threeSubView.leftButton setAllTitleColor:[CommonFunction getGenderColor]];
    [threeSubView.centerButton setAllTitleColor:[CommonFunction getGenderColor]];
    threeSubView.leftButton.titleLabel.font = font_Bold_18;
    threeSubView.centerButton.titleLabel.font = font_Bold_18;
    [threeSubView.leftButton setAllTitle:str_FirstView_11];
    [threeSubView.centerButton setAllTitle:str_FirstView_12];
    [threeSubView autoLayout];
    [self.view addSubview:threeSubView];
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2, 5, 1, kPlan_MenuHeight - 10)];
        view.backgroundColor = color_GrayLight;
        [threeSubView addSubview:view];
    }
    {
        UIImage *image = [UIImage imageNamed:png_Bg_Cell_White];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:threeSubView.frame];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        [self.view insertSubview:imageView belowSubview:threeSubView];
    }
}

- (void)showUnderLineView {
    CGRect frame = [threeSubView.leftButton convertRect:threeSubView.leftButton.titleLabel.frame toView:threeSubView];
    frame.origin.y = threeSubView.frame.size.height - kPlan_MenuLineHeight;
    frame.size.height = kPlan_MenuLineHeight;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [CommonFunction getGenderColor];
    [threeSubView addSubview:view];
    underLineView = view;
}

- (void)showListView {
    NSUInteger yOffset = kPlan_MenuHeight;
    NSUInteger tableHeight = CGRectGetHeight(self.view.bounds) - yOffset -40;
    CGRect frame = CGRectZero;
    frame.origin.x = 0;
    frame.origin.y =yOffset;
    frame.size.width = CGRectGetWidth(self.view.bounds);
    frame.size.height = tableHeight;
    
    if (!tableViewDay && planType == EverydayPlan) {
        UITableView *tableView = [self createTableView];
        tableView.frame = frame;
        [self.view addSubview:tableView];
        tableViewDay = tableView;
    } else if (!tableViewFuture && planType == FuturePlan) {
        UITableView *tableView = [self createTableView];
        tableView.frame = frame;
        [self.view addSubview:tableView];
        tableViewFuture = tableView;
    } else {
        [tableViewDay reloadData];
        [tableViewFuture reloadData];
    }
}

- (void)moveUnderLineViewToLeft {
    [self moveUnderLineViewToButton:threeSubView.leftButton];
    tableViewFuture.hidden = YES;
    tableViewDay.hidden = NO;

    [self getPlanData];
    
    if (!tableViewDay) {
        [self showListView];
    }
}

- (void)moveUnderLineViewToRight {
    [self moveUnderLineViewToButton:threeSubView.centerButton];
    tableViewFuture.hidden = NO;
    tableViewDay.hidden = YES;
    
    [self getPlanData];
    
    if (!tableViewFuture) {
        [self showListView];
    }
}

- (void)moveUnderLineViewToButton:(UIButton *)button {
    CGRect frame = [button convertRect:button.titleLabel.frame toView:button.superview];
    frame.origin.y = threeSubView.frame.size.height - kPlan_MenuLineHeight;
    frame.size.height = kPlan_MenuLineHeight;
    button.superview.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.25 animations: ^{
        
        underLineView.frame = frame;
        
    } completion:^(BOOL finished) {
        if (finished) {
            button.superview.userInteractionEnabled = YES;
        }
    }];
}


- (void)setPlanType:(PlanType)type {
    planType = type;
    switch (planType) {
        case EverydayPlan:
        {
            [self moveUnderLineViewToLeft];
        }
            break;
        case FuturePlan:
        {
            [self moveUnderLineViewToRight];
        }
            break;
        default:
            break;
    }
}

- (UITableView *)createTableView {
    __weak typeof(self) weakSelf = self;
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.backgroundView = nil;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tableView.rowHeight = kPlanCellHeight;
    {
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 5)];
        header.backgroundColor = [UIColor clearColor];
        tableView.tableHeaderView = header;
    }
    {
        UIView *footer = [[UIView alloc] init];
        tableView.tableFooterView = footer;
    }
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        isLoadMore = YES;
        [weakSelf getPlanData];
    }];
    tableView.mj_footer.hidden = YES;
    return tableView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (planType == EverydayPlan) {
        if (dayPlanDict.count > 0) {
            return dayPlanDict.count;
        } else {
            return 1;
        }
    } else if (planType == FuturePlan) {
        if (futurePlanDict.count > 0) {
            return futurePlanDict.count;
        } else {
            return 1;
        }
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (planType == EverydayPlan) {
        if(dayDateKeyArray.count > 0) {
            if (daySectionFlag[section]) {
                NSString *key = dayDateKeyArray[section];
                NSArray *dateArray = [dayPlanDict objectForKey:key];
                return dateArray.count;
            } else {
                return 0;
            }
        } else {
            return 3;
        }
    } else if (planType == FuturePlan) {
        if(futureDateKeyArray.count > 0) {
            if (futureSectionFlag[section]) {
                NSString *key = futureDateKeyArray[section];
                NSArray *dateArray = [futurePlanDict objectForKey:key];
                return dateArray.count;
            } else {
                return 0;
            }
        } else {
            return 3;
        }
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (planType == EverydayPlan) {
        if(indexPath.section < dayDateKeyArray.count) {
            NSString *dateKey = dayDateKeyArray[indexPath.section];
            NSArray *planArray = [dayPlanDict objectForKey:dateKey];
            if (indexPath.row < planArray.count) {
                tableViewDay.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                static NSString *everydayCellIdentifier = @"everydayCellIdentifier";
                
                PlanCell *cell = [tableView dequeueReusableCellWithIdentifier:everydayCellIdentifier];
                if(!cell) {
                    cell = [[PlanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:everydayCellIdentifier];
                }
                Plan *plan = planArray[indexPath.row];
                cell.plan = plan;
                cell.isDone = plan.iscompleted;
                if ([plan.iscompleted isEqualToString:@"1"]) {
                    cell.moveContentView.backgroundColor = color_Green_Mint;
                    cell.backgroundColor = color_Green_Mint;
                } else {
                    cell.moveContentView.backgroundColor = [UIColor whiteColor];
                    cell.backgroundColor = [UIColor whiteColor];
                }
                cell.delegate = self;
                return cell;
            }
        } else {
            tableViewDay.separatorStyle = UITableViewCellSeparatorStyleNone;
            static NSString *noEverydayCellIdentifier = @"noEverydayCellIdentifier";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noEverydayCellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noEverydayCellIdentifier];
                cell.backgroundColor = [UIColor clearColor];
                cell.contentView.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.text = @"";
                cell.textLabel.frame = cell.contentView.bounds;
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.textColor = [UIColor lightGrayColor];
                cell.textLabel.font = font_Bold_16;
            }
            if (indexPath.row == 2) {
                cell.textLabel.text = str_NoPlan_EveryDay;
            }
            return cell;
        }
    } else if (planType == FuturePlan) {
        if(indexPath.section < futureDateKeyArray.count) {
            NSString *dateKey = futureDateKeyArray[indexPath.section];
            NSArray *planArray = [futurePlanDict objectForKey:dateKey];
            if (indexPath.row < planArray.count) {
                tableViewFuture.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                static NSString *futureCellIdentifier = @"futureCellIdentifier";
                
                PlanCell *cell = [tableView dequeueReusableCellWithIdentifier:futureCellIdentifier];
                if(!cell) {
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
        } else {
            tableViewFuture.separatorStyle = UITableViewCellSeparatorStyleNone;
            static NSString *noFutureCellIdentifier = @"noFutureCellIdentifier";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noFutureCellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noFutureCellIdentifier];
                cell.backgroundColor = [UIColor clearColor];
                cell.contentView.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.text = @"";
                cell.textLabel.frame = cell.contentView.bounds;
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.textColor = [UIColor lightGrayColor];
                cell.textLabel.font = font_Bold_16;
            }
            if (indexPath.row == 2) {
                cell.textLabel.text = str_NoPlan_Future;
            }
            return cell;
        }
    }
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ((planType == EverydayPlan
         && dayDateKeyArray.count == 0)
        || (planType == FuturePlan
         && futureDateKeyArray.count == 0)) {
        return 0.00001f;
    } else {
        return kPlanSectionViewHeight;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    PlanSectionView *view;
    if (planType == EverydayPlan && dayDateKeyArray.count > section) {
        NSString *date = dayDateKeyArray[section];
        NSArray *planArray = [dayPlanDict objectForKey:date];
        BOOL isAllDone = [self isAllDone:planArray];
        date = [self getSectionTitle:date];

        view = [[PlanSectionView alloc] initWithTitle:date isAllDone:isAllDone];
        view.sectionIndex = section;
        if (daySectionFlag[section])
            [view toggleArrow];
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionClickedAction:)]];
        return view;
    } else if (planType == FuturePlan && futureDateKeyArray.count > section) {
        NSString *date = futureDateKeyArray[section];
        view = [[PlanSectionView alloc] initWithTitle:date isAllDone:YES];
        view.sectionIndex = section;
        if (futureSectionFlag[section])
            [view toggleArrow];
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionClickedAction:)]];
        return view;
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ((planType == EverydayPlan
         && indexPath.section >= dayDateKeyArray.count)
        || (planType == FuturePlan
            && indexPath.section >= futureDateKeyArray.count)) {
        return;
    }
    Plan *selectedPlan = nil;
    if (planType == EverydayPlan) {
        NSString *dateKey = dayDateKeyArray[indexPath.section];
        NSArray *planArray = [dayPlanDict objectForKey:dateKey];
        selectedPlan = planArray[indexPath.row];
    } else if (planType == FuturePlan) {
        NSString *dateKey = futureDateKeyArray[indexPath.section];
        NSArray *planArray = [futurePlanDict objectForKey:dateKey];
        selectedPlan = planArray[indexPath.row];
    }
    if (selectedPlan) {
        [self toPlanDetailWithPlan:selectedPlan];
    }
}

- (NSString *)getSectionTitle:(NSString *)date {
    NSDate *today = [NSDate date];
    NSDate *yesterday = [today dateByAddingTimeInterval:-24 * 3600];
    NSDate *tomorrow = [today dateByAddingTimeInterval:24 * 3600];
    NSString *todayString = [CommonFunction NSDateToNSString:today formatter:str_DateFormatter_yyyy_MM_dd];
    NSString *yesterdayString = [CommonFunction NSDateToNSString:yesterday formatter:str_DateFormatter_yyyy_MM_dd];
    NSString *tomorrowString = [CommonFunction NSDateToNSString:tomorrow formatter:str_DateFormatter_yyyy_MM_dd];
    if ([date isEqualToString:todayString]) {
        return [NSString stringWithFormat:@"%@ • %@", date, str_Common_Time2];
    } else if ([date isEqualToString:yesterdayString]) {
        return [NSString stringWithFormat:@"%@ • %@", date, str_Common_Time3];
    } else if ([date isEqualToString:tomorrowString]) {
        return [NSString stringWithFormat:@"%@ • %@", date, str_Common_Time9];
    } else {
        return date;
    }
}

- (BOOL)isToday:(NSString *)date {
    NSDate *today = [NSDate date];
    NSString *todayString = [CommonFunction NSDateToNSString:today formatter:str_DateFormatter_yyyy_MM_dd];
    if ([date isEqualToString:todayString]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isAllDone:(NSArray *)planArray {
    for (Plan *plan in planArray) {
        if ([plan.iscompleted isEqualToString:@"0"]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - action
- (void)leftMenuAction:(UIButton *)button {
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void)addAction:(UIButton *)button {
    AddPlanViewController *controller = [[AddPlanViewController alloc] init];
    controller.operationType = Add;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)sectionClickedAction:(UITapGestureRecognizer *)sender {
    PlanSectionView *view = (PlanSectionView *) sender.view;
    [view toggleArrow];
    
    if (planType == EverydayPlan) {
        daySectionFlag[view.sectionIndex] = !daySectionFlag[view.sectionIndex];
        [tableViewDay reloadSections:[NSIndexSet indexSetWithIndex:view.sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
        //section自动上移
        if (daySectionFlag[view.sectionIndex]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:view.sectionIndex];
            [tableViewDay scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    } else if (planType == FuturePlan) {
        futureSectionFlag[view.sectionIndex] = !futureSectionFlag[view.sectionIndex];
        [tableViewFuture reloadSections:[NSIndexSet indexSetWithIndex:view.sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kPlanCellDeleteTag) {
        if (buttonIndex == 0) {
            deletePlan = nil;
            [planCell hideMenuView:YES Animated:YES];
        } else {
            [self deletePlanWithPlan:deletePlan];
        }
    }
}

- (void)toPlan:(NSNotification*)notification {
    NSDictionary *dict = notification.userInfo;
    NSInteger type = [[dict objectForKey:@"type"] integerValue];
    if (type != 0) {//非计划提醒
        return;
    }
    Plan *plan = [[Plan alloc] init];
    plan.account = [dict objectForKey:@"account"];
    plan.planid = [dict objectForKey:@"tag"];
    plan.createtime = [dict objectForKey:@"createtime"];
    plan.content = [dict objectForKey:@"content"];
    plan.beginDate = [dict objectForKey:@"beginDate"];
    plan.iscompleted = [dict objectForKey:@"iscompleted"];
    plan.completetime = [dict objectForKey:@"completetime"];
    plan.isnotify = @"1";
    plan.notifytime = [dict objectForKey:@"notifytime"];
    if ([plan.planid isEqualToString:Notify_FiveDay_Tag]) {
        //5天未新建计划提醒，不需要跳转到计划详情
        return;
    }
    [self toPlanDetailWithPlan:plan];
}

- (void)toPlanDetailWithPlan:(Plan *)plan {
    AddPlanViewController *controller = [[AddPlanViewController alloc]init];
    controller.operationType = Edit;
    controller.plan = plan;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

//修改计划完成状态
- (void)changePlanCompleteStatus:(Plan *)plan {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:str_DateFormatter_yyyy_MM_dd_HHmmss];
    NSString *timeNow = [dateFormatter stringFromDate:[NSDate date]];
    //1完成 0未完成
    if ([plan.iscompleted isEqualToString:@"0"]) {
        plan.iscompleted = @"1";
        plan.completetime = timeNow;
        //如果预计开始时间是在今天之后的，属于提前完成，把预计开始时间设成今天
        NSDate *beginDate = [CommonFunction NSStringDateToNSDate:plan.beginDate formatter:str_DateFormatter_yyyy_MM_dd];
        NSInteger days = [self calculateDayFromDate:[NSDate date] toDate:beginDate];
        if (days > 0) {
            plan.beginDate = [CommonFunction NSDateToNSString:[NSDate date] formatter:str_DateFormatter_yyyy_MM_dd];
        }
    } else {
        plan.iscompleted = @"0";
        plan.completetime = @"";
    }
    plan.updatetime = timeNow;
    
    [PlanCache storePlan:plan];
    
    if (planType == EverydayPlan) {
        [tableViewDay reloadData];
    } else {
        [tableViewFuture reloadData];
    }
}

//删除计划
- (void)deletePlanWithPlan:(Plan *)plan {
    BOOL result = [PlanCache deletePlan:plan];
    if (result) {
        [self alertToastMessage:str_Delete_Success];
    } else {
        [self alertButtonMessage:str_Delete_Fail];
    }
}

-(void)setCanCustomEdit:(BOOL)canCustomEdit {
    if (canCustomEditNow != canCustomEdit) {
        canCustomEditNow = canCustomEdit;
        
        CGRect frame = planType == EverydayPlan ? tableViewDay.frame : tableViewFuture.frame;
        if (canCustomEditNow) {
            if (hitView == nil) {
                hitView = [[HitView alloc] init];
                hitView.delegate = self;
                hitView.frame = frame;
            }
            hitView.frame = frame;
            [self.view addSubview:hitView];
            
            if (planType == EverydayPlan) {
                tableViewDay.scrollEnabled = NO;
            } else {
                tableViewFuture.scrollEnabled = NO;
            }
        } else {
            planCell = nil;
            [hitView removeFromSuperview];
            
            if (planType == EverydayPlan) {
                tableViewDay.scrollEnabled = YES;
            } else {
                tableViewFuture.scrollEnabled = YES;
            }
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (planCell == [tableView cellForRowAtIndexPath:indexPath]) {
        [planCell hideMenuView:YES Animated:YES ];
        return NO;
    }
    return YES;
}

- (UIView *)hitViewClicked:(CGPoint)point event:(UIEvent *)event touchView:(UIView *)touchView {
    BOOL vCloudReceiveTouch = NO;
    CGRect vSlidedCellRect;
    if (planType == EverydayPlan) {
        vSlidedCellRect = [hitView convertRect:planCell.frame fromView:tableViewDay];
    } else {
        vSlidedCellRect = [hitView convertRect:planCell.frame fromView:tableViewFuture];
    }
    vCloudReceiveTouch = CGRectContainsPoint(vSlidedCellRect, point);
    if (!vCloudReceiveTouch) {
        [planCell hideMenuView:YES Animated:YES];
    }
    return vCloudReceiveTouch ? [planCell hitTest:point withEvent:event] : touchView;
}

- (void)didCellWillShow:(id)aSender {
    planCell = aSender;
    self.canCustomEdit = YES;
}

- (void)didCellWillHide:(id)aSender {
    planCell = nil;
    self.canCustomEdit = NO;
}

- (void)didCellHided:(id)aSender {
    planCell = nil;
    self.canCustomEdit = NO;
}

- (void)didCellShowed:(id)aSender {
    planCell = aSender;
    self.canCustomEdit = YES;
}

- (void)didCellClicked:(id)aSender {
    PlanCell *cell = (PlanCell *)aSender;
    [self toPlanDetailWithPlan:cell.plan];
}

- (void)didCellClickedDoneButton:(id)aSender {
    PlanCell *cell = (PlanCell *)aSender;
    [self changePlanCompleteStatus:cell.plan];
}

- (void)didCellClickedDeleteButton:(id)aSender {
    PlanCell *cell = (PlanCell *)aSender;
    deletePlan = cell.plan;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:str_Delete_Plan
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:str_Cancel
                                          otherButtonTitles:str_OK,
                          nil];
    alert.tag = kPlanCellDeleteTag;
    [alert show];
}

@end
