//
//  SecondViewController.m
//  plan
//
//  Created by Fengzy on 15/8/28.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "Plan.h"
#import "PlanCell.h"
#import "PlanCache.h"
#import "ThreeSubView.h"
#import "PlanSectionView.h"
#import "SecondViewController.h"
#import "AddPlanViewController.h"

NSUInteger const kPlan_MenuHeight = 44;
NSUInteger const kPlan_MenuLineHeight = 3;
NSUInteger const kPlan_TodayCellHeaderViewHeight = 30;

@interface SecondViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, assign) PlanType planType;
@property (nonatomic, weak) ThreeSubView *threeSubView;
@property (nonatomic, weak) UIView *underLineView;
@property (nonatomic, strong) NSArray *planLifeArray;
@property (nonatomic, strong) UITableView *planEverydayTableView;
@property (nonatomic, strong) UITableView *planLifeTableView;
@property (nonatomic, strong) NSMutableArray *dateKeyArray;
@property (nonatomic, strong) NSDictionary *planEverydayDic;
@property (nonatomic, strong) Plan *deletePlan;
@property (nonatomic, assign) BOOL *flag;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = str_ViewTitle_2;
    self.tabBarItem.title = str_ViewTitle_2;
    
//    [NotificationCenter addObserver:self selector:@selector(refreshTableData:) name:Notify_Plan_Save object:nil];
    
    [self getPlanData];
    
    [self loadCustomView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.planType == PlanEveryday)
        [self moveUnderLineViewToLeft];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)dealloc
//{
//    [NotificationCenter removeObserver:self];
//}

- (void)refreshTableData:(NSNotification*)notification
{
    [self getPlanData];
}

- (void)getPlanData
{
    self.planLifeArray = [NSArray arrayWithArray:[PlanCache getPlanByPlantype:@"0"]];
    NSArray *array = [NSArray arrayWithArray:[PlanCache getPlanByPlantype:@"1"]];
    
    self.dateKeyArray = [NSMutableArray array];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (NSInteger i = 0; i < array.count; i++) {
        Plan *plan = array[i];
        NSArray *spitArray = [plan.createtime componentsSeparatedByString:@" "];
        NSString *date = spitArray[0];
        
        NSMutableArray * dateArray = [dic objectForKey:date];
        if (!dateArray) {
            dateArray = [[NSMutableArray alloc] init];
            [dic setValue:dateArray forKey:date];
            [self.dateKeyArray addObject:date];
        }
        
        [dateArray addObject:plan];
    }
    self.planEverydayDic = [NSDictionary dictionaryWithDictionary:dic];
    
    [self reloadTableViewData];
}

- (void)reloadTableViewData
{
    if (self.planEverydayTableView && self.planType == PlanEveryday){
        
        [self.planEverydayTableView reloadData];
        
    } else if (self.planLifeTableView && self.planType == PlanLife){

        [self.planLifeTableView reloadData];
    }
}

#pragma mark -初始化自定义界面
- (void)loadCustomView
{
    NSUInteger sections = self.planEverydayDic.count;
    self.flag = (BOOL *)malloc(sections * sizeof(BOOL));
    memset((void *)self.flag, NO, sections * sizeof(BOOL));
    self.flag[0] = !self.flag[0];
    
    if (!self.underLineView) {
        [self showRightButtonView];
        [self showMenuView];
        [self showUnderLineView];
    }
    self.planType = PlanEveryday;
    [self showListView];
}

#pragma mark -添加导航栏按钮
- (void)showRightButtonView{
    NSMutableArray *rightBarButtonItems = [NSMutableArray array];
    {
        UIImage *image = [UIImage imageNamed:png_Btn_Add];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, image.size.width + 20, image.size.height);
        [button setAllImage:image];
        [button addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        [rightBarButtonItems addObject:barButtonItem];
    }
    
    self.rightBarButtonItems = rightBarButtonItems;
}

- (void)showMenuView{
    __weak typeof(self) weakSelf = self;
    ThreeSubView *threeSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kPlan_MenuHeight) leftButtonSelectBlock:^{
        
        weakSelf.planType = PlanEveryday;
        
    } centerButtonSelectBlock:^{
        
        weakSelf.planType = PlanLife;
        
    } rightButtonSelectBlock:nil];
    
    threeSubView.fixLeftWidth = CGRectGetWidth(self.view.bounds)/2;
    threeSubView.fixCenterWidth = CGRectGetWidth(self.view.bounds)/2;
    
    [threeSubView.leftButton setAllTitleColor:color_Blue];
    [threeSubView.centerButton setAllTitleColor:color_Blue];
    
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

- (void)showUnderLineView{
    CGRect frame = [self.threeSubView.leftButton convertRect:self.threeSubView.leftButton.titleLabel.frame toView:self.threeSubView];
    frame.origin.y = self.threeSubView.frame.size.height - kPlan_MenuLineHeight;
    frame.size.height = kPlan_MenuLineHeight;
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = color_Blue;
    [self.threeSubView addSubview:view];
    self.underLineView = view;
}

- (void)showListView{

    NSUInteger yOffset = kPlan_MenuHeight;
    NSUInteger tableHeight = CGRectGetHeight(self.view.bounds) - yOffset -40;
    CGRect frame = CGRectZero;
    frame.origin.x = 0;
    frame.origin.y =yOffset;
    frame.size.width = CGRectGetWidth(self.view.bounds);
    frame.size.height = tableHeight;
    
    if (!self.planEverydayTableView && self.planType == PlanEveryday){
        UITableView *tableView = [self createTableView];
        tableView.frame = frame;
        [self.view addSubview:tableView];
        self.planEverydayTableView = tableView;
        
    } else if (!self.planLifeTableView && self.planType == PlanLife){
        UITableView *tableView = [self createTableView];
        tableView.frame = frame;
        [self.view addSubview:tableView];
        self.planLifeTableView = tableView;
    } else {
        [self.planEverydayTableView reloadData];
        [self.planLifeTableView reloadData];
    }
}

- (void)moveUnderLineViewToLeft{
    [self moveUnderLineViewToButton:self.threeSubView.leftButton];
    self.planLifeTableView.hidden = YES;
    self.planEverydayTableView.hidden = NO;
    
    [self getPlanData];
    
    if (!self.planEverydayTableView) {
        [self showListView];
    }
    
}

- (void)moveUnderLineViewToRight{
    [self moveUnderLineViewToButton:self.threeSubView.centerButton];
    self.planLifeTableView.hidden = NO;
    self.planEverydayTableView.hidden = YES;
    
    [self getPlanData];
    
    if (!self.planLifeTableView) {
        [self showListView];
    }
}

- (void)moveUnderLineViewToButton:(UIButton *)button{
    CGRect frame = [button convertRect:button.titleLabel.frame toView:button.superview];
    frame.origin.y = self.threeSubView.frame.size.height - kPlan_MenuLineHeight;
    frame.size.height = kPlan_MenuLineHeight;
    
    button.superview.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.underLineView.frame = frame;
        
    } completion:^(BOOL finished) {
        
        if (finished) {
            
            button.superview.userInteractionEnabled = YES;
        }
    }];
}


- (void)setPlanType:(PlanType)planType{
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
    [self.planEverydayTableView reloadData];
}

- (UITableView *)createTableView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.backgroundView = nil;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tableView.rowHeight = kPlanCellHeight;
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 5)];
        view.backgroundColor = [UIColor clearColor];
        tableView.tableHeaderView = view;
    }
    return tableView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    if (self.planType == PlanEveryday) {
        
        if (self.planEverydayDic.count > 0) {
            return self.planEverydayDic.count;
        } else {
            return 1;
        }
        
    } else if (self.planType == PlanLife) {
        
        return 1;
        
    } else {
        
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.planType == PlanEveryday) {
        
        if (self.flag[section]) {
            
            if(self.dateKeyArray.count > 0)
            {
                NSString *key = self.dateKeyArray[section];
                NSArray *dateArray = [self.planEverydayDic objectForKey:key];
                return dateArray.count;
            } else {
                return 3;
            }
            
        } else {
            return 0;
        }
    } else if (self.planType == PlanLife) {
        
        if (self.planLifeArray.count == 0) {
            return 3;
            
        } else {
            return self.planLifeArray.count;
            
        }
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.planType == PlanEveryday) {
        
        if(indexPath.section < self.dateKeyArray.count){
            
            NSString *dateKey = self.dateKeyArray[indexPath.section];
            NSArray *planArray = [self.planEverydayDic objectForKey:dateKey];
            
            if (indexPath.row < planArray.count) {
                
                static NSString *PlanTodayCellIdentifier = @"PlanTodayCellIdentifier";
                
                PlanCell *cell = [tableView dequeueReusableCellWithIdentifier:PlanTodayCellIdentifier];
                if(!cell) {
                    
                    cell = [[PlanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PlanTodayCellIdentifier];
                }
                
                Plan *plan = planArray[indexPath.row];

                cell.contentLabel.text = plan.content;
                cell.isCompleted = plan.iscompleted;
                if ([plan.iscompleted isEqualToString:@"1"]) {
                    cell.backgroundColor = color_Green_Mint;
                } else {
                    cell.backgroundColor = [UIColor whiteColor];
                }
                
                __weak typeof(self) weakSelf = self;
                cell.detailBlock = ^{
                    [weakSelf toPlanDetailWithPlan:plan];
                };
                
                cell.deleteBlock = ^{
                    self.deletePlan = plan;
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:str_Delete_Plan
                                                                    message:nil
                                                                   delegate:self
                                                          cancelButtonTitle:str_Cancel
                                                          otherButtonTitles:str_OK,
                                          nil];
                    
                    alert.tag = 9527;
                    [alert show];
                };
                
                cell.completeBlock = ^{
                    [weakSelf changePlanCompleteStatus:plan];
                };
                
                return cell;
                
            } else {
                
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
            
        } else {
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
        
        NSUInteger planCount = self.planLifeArray.count;
        if (indexPath.row < planCount) {
            static NSString *PlanLifeCellIdentifier = @"PlanLifeCellIdentifier";
            
            PlanCell *cell = [tableView dequeueReusableCellWithIdentifier:PlanLifeCellIdentifier];
            if(!cell) {
                
                cell = [[PlanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PlanLifeCellIdentifier];
            }
            
            Plan *plan = self.planLifeArray[indexPath.row];
            
            cell.contentLabel.text = plan.content;
            cell.isCompleted = plan.iscompleted;
            
            if ([plan.iscompleted isEqualToString:@"1"]) {

                cell.backgroundColor = color_Green_Mint;
            } else {

                cell.backgroundColor = [UIColor whiteColor];
            }
            
            __weak typeof(self) weakSelf = self;
            cell.detailBlock = ^{
                
                [weakSelf toPlanDetailWithPlan:plan];
                
            };
            
            cell.deleteBlock = ^{
                self.deletePlan = plan;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:str_Delete_Plan
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:str_Cancel
                                                      otherButtonTitles:str_OK,
                                      nil];
                
                alert.tag = 9527;
                [alert show];
            };
            
            cell.completeBlock = ^{
                [weakSelf changePlanCompleteStatus:plan];
            };
            
            return cell;
            
        } else {
            
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
        
    } else {
        
        return nil;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if (self.planType == PlanEveryday) {
        
        if (self.dateKeyArray.count > 0) {
            
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
 
    PlanSectionView *view;
    if (self.planType == PlanEveryday && self.dateKeyArray.count > 0) {
        
        
        
        NSString *date = self.dateKeyArray[section];
        
        view = [[PlanSectionView alloc] initWithTitle:date];
        view.sectionIndex = section;
        if (self.flag[section])
            [view toggleArrow];
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionClickedAction:)]];
        
        return view;
        
    } else if (self.planType == PlanLife) {
        
        return nil;
        
    } else {
        
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.planType == PlanLife && indexPath.row >= self.planLifeArray.count) {
        return;
    }
    
    Plan *selectedPlan = nil;
    
    if (self.planType == PlanEveryday) {
        
        NSString *dateKey = self.dateKeyArray[indexPath.section];
        NSArray *planArray = [self.planEverydayDic objectForKey:dateKey];
        
        selectedPlan = planArray[indexPath.row];
        
        [self toPlanDetailWithPlan:selectedPlan];
        
    } else if (self.planType == PlanLife) {
        
        selectedPlan = self.planLifeArray[indexPath.row];
        
        [self toPlanDetailWithPlan:selectedPlan];
    }
    
}

#pragma mark - action
- (void)addAction:(UIButton *)button{
    
    __weak typeof(self) weakSelf = self;
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
    controller.finishBlock = ^(){
        
        [weakSelf alertToastMessage:str_Save_Success];
        [weakSelf getPlanData];
    };
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)sectionClickedAction:(UITapGestureRecognizer *)sender
{
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

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 9527) {
        if (buttonIndex == 0) {
            self.deletePlan = nil;
            return;
            
        } else {
            
            [self deletePlanWithPlan:self.deletePlan];
            return;
        }
        
    }
}

- (void)toPlanDetailWithPlan:(Plan *)plan{
    __weak typeof(self) weakSelf = self;
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
    controller.finishBlock = ^(){
        
        [weakSelf alertToastMessage:str_Save_Success];
        [weakSelf getPlanData];
    };
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark -修改计划完成状态
- (void)changePlanCompleteStatus:(Plan *)plan
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
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
- (void)deletePlanWithPlan:(Plan *)plan
{
    
    [PlanCache deletePlan:plan];
    [self alertToastMessage:str_Delete_Success];
    [self getPlanData];
    
}
@end
