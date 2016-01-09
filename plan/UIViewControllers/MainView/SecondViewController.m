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
NSUInteger const kPlan_TodayCellHeaderViewHeight = 30;
NSUInteger const kPlanCellDeleteTag = 9527;

@interface SecondViewController ()<UITableViewDataSource, UITableViewDelegate, PlanCellDelegate, HitViewDelegate> {
    
    PlanCell *planCell;
    HitView *hitView;
    NSInteger dayTotal;
    NSInteger lifeTotal;
    NSInteger dayStart;
    NSInteger lifeStart;
    BOOL isLoadMore;
    NSMutableArray *planLifeArray;
    NSMutableArray *dateKeyArray;
    NSMutableDictionary *planEverydayDic;
}

@property (nonatomic, assign) PlanType planType;
@property (nonatomic, weak) ThreeSubView *threeSubView;
@property (nonatomic, weak) UIView *underLineView;
@property (nonatomic, strong) UITableView *planEverydayTableView;
@property (nonatomic, strong) UITableView *planLifeTableView;
@property (nonatomic, strong) Plan *deletePlan;
@property (nonatomic, assign) BOOL *flag;
@property (nonatomic, assign) BOOL canCustomEdit;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = str_ViewTitle_2;
    self.tabBarItem.title = str_ViewTitle_2;
    [self createNavBarButton];
    
    [NotificationCenter addObserver:self selector:@selector(getPlanData) name:Notify_Plan_Save object:nil];
    [NotificationCenter addObserver:self selector:@selector(refreshRedDot) name:Notify_Messages_Save object:nil];

    [self loadCustomView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkUnread:self.tabBarController.tabBar index:1];
    [self refreshRedDot];
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
    if (self.planType == PlanLife) {
        [self getLongPlan];
    } else {
        [self getDayPlan];
    }
}

- (void)getDayPlan {
    dayTotal = [[PlanCache getPlanTotalCountByPlantype:@"1"] integerValue];
    if (!isLoadMore) {//重头开始加载
        dayStart = 0;
        dateKeyArray = [NSMutableArray array];
        planEverydayDic = [NSMutableDictionary dictionary];
    }
    NSArray *array = [NSArray arrayWithArray:[PlanCache getPlanByPlantype:@"1" startIndex:dayStart]];
    NSMutableArray *dateKeyArrayTmp = [NSMutableArray array];
    
    for (NSInteger i = 0; i < array.count; i++) {
        Plan *plan = array[i];
        NSArray *spitArray = [plan.createtime componentsSeparatedByString:@" "];
        NSString *date = spitArray[0];
        
        NSMutableArray * dateArray = [planEverydayDic objectForKey:date];
        if (!dateArray) {
            dateArray = [[NSMutableArray alloc] init];
            [planEverydayDic setValue:dateArray forKey:date];
            [dateKeyArrayTmp addObject:date];
        }
        
        [dateArray addObject:plan];
    }
    [dateKeyArray addObjectsFromArray:dateKeyArrayTmp];
    //日期降序排列
    dateKeyArray = [NSMutableArray arrayWithArray:[CommonFunction arraySort:dateKeyArray ascending:NO]];
    
    NSUInteger sections = planEverydayDic.count;
    self.flag = (BOOL *)malloc(sections * sizeof(BOOL));
    memset((void *)self.flag, NO, sections * sizeof(BOOL));
    self.flag[0] = !self.flag[0];
    
    isLoadMore = NO;
    if (dayStart < dayTotal) {
        dayStart += kPlanLoadMax;
    } else {
        [self.planEverydayTableView.mj_footer endRefreshingWithNoMoreData];
    }
    [self.planEverydayTableView.mj_footer endRefreshing];
    [self reloadTableViewData];
}

- (void)getLongPlan {
    lifeTotal = [[PlanCache getPlanTotalCountByPlantype:@"0"] integerValue];
    if (!isLoadMore) {//重头开始加载
        lifeStart = 0;
        planLifeArray = [NSMutableArray array];
    }
    [planLifeArray addObjectsFromArray:[PlanCache getPlanByPlantype:@"0" startIndex:lifeStart]];

    isLoadMore = NO;
    if (lifeStart < lifeTotal) {
        lifeStart += kPlanLoadMax;
    } else {
        [self.planLifeTableView.mj_footer endRefreshingWithNoMoreData];
    }
    [self.planLifeTableView.mj_footer endRefreshing];
    [self reloadTableViewData];
}

- (void)reloadTableViewData {
    if (self.planEverydayTableView && self.planType == PlanEveryday) {
        [self.planEverydayTableView reloadData];
    } else if (self.planLifeTableView && self.planType == PlanLife) {
        [self.planLifeTableView reloadData];
    }
}

- (void)refreshRedDot {
    //小红点
    if ([PlanCache hasUnreadMessages]) {
        [self.leftBarButtonItem showBadge];
    } else {
        [self.leftBarButtonItem clearBadge];
    }
}

#pragma mark -初始化自定义界面
- (void)loadCustomView {
    if (!self.underLineView) {
        [self showMenuView];
        [self showUnderLineView];
    }
    self.planType = PlanEveryday;
    [self showListView];
}

- (void)showMenuView {
    __weak typeof(self) weakSelf = self;
    ThreeSubView *threeSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kPlan_MenuHeight) leftButtonSelectBlock: ^{
        
        weakSelf.planType = PlanEveryday;
        
    } centerButtonSelectBlock: ^{
        
        weakSelf.planType = PlanLife;
        
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
    self.threeSubView = threeSubView;
}

- (void)showUnderLineView {
    CGRect frame = [self.threeSubView.leftButton convertRect:self.threeSubView.leftButton.titleLabel.frame toView:self.threeSubView];
    frame.origin.y = self.threeSubView.frame.size.height - kPlan_MenuLineHeight;
    frame.size.height = kPlan_MenuLineHeight;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [CommonFunction getGenderColor];
    [self.threeSubView addSubview:view];
    self.underLineView = view;
}

- (void)showListView {
    NSUInteger yOffset = kPlan_MenuHeight;
    NSUInteger tableHeight = CGRectGetHeight(self.view.bounds) - yOffset -40;
    CGRect frame = CGRectZero;
    frame.origin.x = 0;
    frame.origin.y =yOffset;
    frame.size.width = CGRectGetWidth(self.view.bounds);
    frame.size.height = tableHeight;
    
    if (!self.planEverydayTableView && self.planType == PlanEveryday) {
        UITableView *tableView = [self createTableView];
        tableView.frame = frame;
        [self.view addSubview:tableView];
        self.planEverydayTableView = tableView;
    } else if (!self.planLifeTableView && self.planType == PlanLife) {
        UITableView *tableView = [self createTableView];
        tableView.frame = frame;
        [self.view addSubview:tableView];
        self.planLifeTableView = tableView;
    } else {
        [self.planEverydayTableView reloadData];
        [self.planLifeTableView reloadData];
    }
}

- (void)moveUnderLineViewToLeft {
    [self moveUnderLineViewToButton:self.threeSubView.leftButton];
    self.planLifeTableView.hidden = YES;
    self.planEverydayTableView.hidden = NO;

    [self getPlanData];
    
    if (!self.planEverydayTableView) {
        [self showListView];
    }
}

- (void)moveUnderLineViewToRight {
    [self moveUnderLineViewToButton:self.threeSubView.centerButton];
    self.planLifeTableView.hidden = NO;
    self.planEverydayTableView.hidden = YES;
    
    [self getPlanData];
    
    if (!self.planLifeTableView) {
        [self showListView];
    }
}

- (void)moveUnderLineViewToButton:(UIButton *)button {
    CGRect frame = [button convertRect:button.titleLabel.frame toView:button.superview];
    frame.origin.y = self.threeSubView.frame.size.height - kPlan_MenuLineHeight;
    frame.size.height = kPlan_MenuLineHeight;
    button.superview.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.25 animations: ^{
        
        self.underLineView.frame = frame;
        
    } completion:^(BOOL finished) {
        if (finished) {
            button.superview.userInteractionEnabled = YES;
        }
    }];
}


- (void)setPlanType:(PlanType)planType {
    _planType = planType;
    switch (planType) {
        case PlanEveryday:
        {
            [self moveUnderLineViewToLeft];
        }
            break;
        case PlanLife:
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
    if (self.planType == PlanEveryday) {
        if (planEverydayDic.count > 0) {
            return planEverydayDic.count;
        } else {
            return 1;
        }
    } else if (self.planType == PlanLife) {
        return 1;
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.planType == PlanEveryday) {
        if (self.flag[section]) {
            if(dateKeyArray.count > 0) {
                NSString *key = dateKeyArray[section];
                NSArray *dateArray = [planEverydayDic objectForKey:key];
                return dateArray.count;
            } else {
                return 3;
            }
        } else {
            return 0;
        }
    } else if (self.planType == PlanLife) {
        if (planLifeArray.count == 0) {
            return 3;
        } else {
            return planLifeArray.count;
        }
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.planType == PlanEveryday) {
        if(indexPath.section < dateKeyArray.count) {
            NSString *dateKey = dateKeyArray[indexPath.section];
            NSArray *planArray = [planEverydayDic objectForKey:dateKey];
            if (indexPath.row < planArray.count) {
                self.planEverydayTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                static NSString *PlanTodayCellIdentifier = @"PlanTodayCellIdentifier";
                
                PlanCell *cell = [tableView dequeueReusableCellWithIdentifier:PlanTodayCellIdentifier];
                if(!cell) {
                    cell = [[PlanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PlanTodayCellIdentifier];
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
            self.planEverydayTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            static NSString *noticeCellIdentifier = @"noTodayCellIdentifier";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noticeCellIdentifier];
            if (!cell) {
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
            
            if (indexPath.row == 2) {
                cell.textLabel.text = str_NoPlan_EveryDay;
            } else {
                cell.textLabel.text = nil;
            }
            return cell;
        }
    } else if (self.planType == PlanLife) {
        NSUInteger planCount = planLifeArray.count;
        if (indexPath.row < planCount) {
            self.planLifeTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            static NSString *PlanLifeCellIdentifier = @"PlanLifeCellIdentifier";
            
            PlanCell *cell = [tableView dequeueReusableCellWithIdentifier:PlanLifeCellIdentifier];
            if(!cell) {
                cell = [[PlanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PlanLifeCellIdentifier];
            }
            
            Plan *plan = planLifeArray[indexPath.row];
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
        } else {
            self.planLifeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            static NSString *noticeCellIdentifier = @"noLifeCellIdentifier";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noticeCellIdentifier];
            if (!cell) {
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
            
            if (indexPath.row == 2) {
                cell.textLabel.text = str_NoPlan_LongTerm;
            } else {
                cell.textLabel.text = nil;
            }
            return cell;
        }
    }
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.planType == PlanEveryday) {
        if (dateKeyArray.count > 0) {
            return kPlanSectionViewHeight;
        } else {
            return 0;
        }
    } else if (self.planType == PlanLife) {
        return 0;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    PlanSectionView *view;
    if (self.planType == PlanEveryday && dateKeyArray.count > 0) {
        NSString *date = dateKeyArray[section];
        NSArray *planArray = [planEverydayDic objectForKey:date];
        BOOL isAllDone = [self isAllDone:planArray];
        date = [self isToday:date];
        
        view = [[PlanSectionView alloc] initWithTitle:date isAllDone:isAllDone];
        view.sectionIndex = section;
        if (self.flag[section])
            [view toggleArrow];
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionClickedAction:)]];
        return view;
        
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ((self.planType == PlanEveryday
         && indexPath.section >= dateKeyArray.count)
        || (self.planType == PlanLife
            && indexPath.row >= planLifeArray.count)) {
        return;
    }
    Plan *selectedPlan = nil;
    if (self.planType == PlanEveryday) {
        NSString *dateKey = dateKeyArray[indexPath.section];
        NSArray *planArray = [planEverydayDic objectForKey:dateKey];
        selectedPlan = planArray[indexPath.row];
        [self toPlanDetailWithPlan:selectedPlan];
    } else if (self.planType == PlanLife) {
        selectedPlan = planLifeArray[indexPath.row];
        [self toPlanDetailWithPlan:selectedPlan];
    }
}

- (NSString *)isToday:(NSString *)date {
    NSDate *today = [NSDate date];
    NSDate *yesterday = [today dateByAddingTimeInterval:-24 * 3600];
    NSString *todayString = [CommonFunction NSDateToNSString:today formatter:str_DateFormatter_yyyy_MM_dd];
    NSString *yesterdayString = [CommonFunction NSDateToNSString:yesterday formatter:str_DateFormatter_yyyy_MM_dd];
    if ([date isEqualToString:todayString]) {
        return [NSString stringWithFormat:@"%@ • %@", date, str_Common_Time2];
    } else if ([date isEqualToString:yesterdayString]) {
        return [NSString stringWithFormat:@"%@ • %@", date, str_Common_Time3];
    } else {
        return date;
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
    controller.planType = self.planType;
    controller.operationType = Add;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.backBarButtonItem = backItem;
    if (self.planType == PlanEveryday) {
        backItem.title = str_FirstView_11;
    } else {
        backItem.title = str_FirstView_12;
    }
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)sectionClickedAction:(UITapGestureRecognizer *)sender {
    PlanSectionView *view = (PlanSectionView *) sender.view;
    [view toggleArrow];
    
    self.flag[view.sectionIndex] = !self.flag[view.sectionIndex];

    [self.planEverydayTableView reloadSections:[NSIndexSet indexSetWithIndex:view.sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    //section自动上移
    if (self.flag[view.sectionIndex]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:view.sectionIndex];
        [self.planEverydayTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kPlanCellDeleteTag) {
        if (buttonIndex == 0) {
            self.deletePlan = nil;
            [planCell hideMenuView:YES Animated:YES];
        } else {
            [self deletePlanWithPlan:self.deletePlan];
        }
    }
}

- (void)toPlanDetailWithPlan:(Plan *)plan {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.backBarButtonItem = backItem;
    if (self.planType == PlanEveryday) {
        backItem.title = str_FirstView_11;
    } else {
        backItem.title = str_FirstView_12;
    }
    AddPlanViewController *controller = [[AddPlanViewController alloc]init];
    controller.planType = self.planType;
    controller.operationType = Edit;
    controller.plan = plan;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark -修改计划完成状态
- (void)changePlanCompleteStatus:(Plan *)plan {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:str_DateFormatter_yyyy_MM_dd_HHmmss];
    NSString *timeNow = [dateFormatter stringFromDate:[NSDate date]];
    //1完成 0未完成
    if ([plan.iscompleted isEqualToString:@"0"]) {
        plan.iscompleted = @"1";
        plan.completetime = timeNow;
    } else {
        plan.iscompleted = @"0";
        plan.completetime = @"";
    }
    plan.updatetime = timeNow;
    
    [PlanCache storePlan:plan];
    
    if (self.planType == PlanEveryday) {
        [self.planEverydayTableView reloadData];
    } else {
        [self.planLifeTableView reloadData];
    }
}

#pragma mark -删除计划
- (void)deletePlanWithPlan:(Plan *)plan {
    BOOL result = [PlanCache deletePlan:plan];
    if (result) {
        [self alertToastMessage:str_Delete_Success];
    } else {
        [self alertButtonMessage:str_Delete_Fail];
    }
}

-(void)setCanCustomEdit:(BOOL)canCustomEdit {
    if (_canCustomEdit != canCustomEdit) {
        _canCustomEdit = canCustomEdit;
        
        CGRect frame = self.planType == PlanEveryday ? self.planEverydayTableView.frame : self.planLifeTableView.frame;
        if (_canCustomEdit) {
            if (hitView == nil) {
                hitView = [[HitView alloc] init];
                hitView.delegate = self;
                hitView.frame = frame;
            }
            hitView.frame = frame;
            [self.view addSubview:hitView];
            
            if (self.planType == PlanEveryday) {
                self.planEverydayTableView.scrollEnabled = NO;
            } else {
                self.planLifeTableView.scrollEnabled = NO;
            }
        } else {
            planCell = nil;
            [hitView removeFromSuperview];
            
            if (self.planType == PlanEveryday) {
                self.planEverydayTableView.scrollEnabled = YES;
            } else {
                self.planLifeTableView.scrollEnabled = YES;
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
    if (self.planType == PlanEveryday) {
        vSlidedCellRect = [hitView convertRect:planCell.frame fromView:self.planEverydayTableView];
    } else {
        vSlidedCellRect = [hitView convertRect:planCell.frame fromView:self.planLifeTableView];
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
    self.deletePlan = cell.plan;
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
