//
//  PersonalCenterUndonePlanViewController.m
//  plan
//
//  Created by Fengzy on 16/6/29.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import "Plan.h"
#import "HitView.h"
#import "PlanCell.h"
#import "PlanCache.h"
#import "ThreeSubView.h"
#import "PlanDetailViewController.h"
#import "PersonalCenterUndonePlanViewController.h"

NSUInteger const kUndonePlanCellDeleteTag = 9527;

@interface PersonalCenterUndonePlanViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, PlanCellDelegate, HitViewDelegate> {
    
    PlanCell *planCell;
    HitView *hitView;
    BOOL canCustomEditNow;
    Plan *deletePlan;

    NSMutableArray *planArray;
    UISearchBar *searchBar;
    NSString *searchKeyword;
    NSArray *searchResultArray;
    UITableView *tableViewPlan;
}

@end


@implementation PersonalCenterUndonePlanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"未完计划";
    
    [NotificationCenter addObserver:self selector:@selector(getUndonePlan) name:NTFPlanSave object:nil];
    
    [self loadCustomView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//初始化自定义界面
- (void)loadCustomView {
    [self initTableView];
    
    [self getUndonePlan];
}

- (void)initTableView {
    searchKeyword = @"";
    searchResultArray = [NSArray array];
    
    NSUInteger tableHeight = CGRectGetHeight(self.view.bounds);
    CGRect frame = CGRectZero;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = CGRectGetWidth(self.view.bounds);
    frame.size.height = tableHeight;
    
    tableViewPlan = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableViewPlan.backgroundColor = [UIColor clearColor];
    tableViewPlan.backgroundView = nil;
    tableViewPlan.dataSource = self;
    tableViewPlan.delegate = self;
    tableViewPlan.showsHorizontalScrollIndicator = NO;
    tableViewPlan.showsVerticalScrollIndicator = NO;
    tableViewPlan.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tableViewPlan.rowHeight = kPlanCellHeight;
    {
        searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, WIDTH_FULL_SCREEN, 44)];
        searchBar.delegate = self;
        searchBar.barTintColor = color_eeeeee;
        searchBar.searchBarStyle = UISearchBarStyleMinimal;
        searchBar.inputAccessoryView = [self getInputAccessoryView];
        searchBar.placeholder = @"搜索";
        tableViewPlan.tableHeaderView = searchBar;
    }
    {
        UIView *footer = [[UIView alloc] init];
        tableViewPlan.tableFooterView = footer;
    }
    tableViewPlan.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.view addSubview:tableViewPlan];
}

- (void)getUndonePlan {

    planArray = [NSMutableArray arrayWithArray:[PlanCache getUndonePlan]];
    
    [tableViewPlan reloadData];
}

- (void)searchPlan {
    searchResultArray = [NSArray arrayWithArray:[PlanCache searchPlan:searchKeyword]];
    [tableViewPlan reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (searchKeyword.length > 0) {
        if (searchResultArray.count > 0) {
            return searchResultArray.count;
        } else {
            return 3;
        }
    } else {
        if (planArray.count > 0) {
            return planArray.count;
        } else {
            return 3;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    if (searchKeyword.length > 0) {
        if(indexPath.row < searchResultArray.count) {
            
            static NSString *searchCellIdentifier = @"searchCellIdentifier";
            
            PlanCell *cell = [tableView dequeueReusableCellWithIdentifier:searchCellIdentifier];
            if(!cell) {
                cell = [[PlanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchCellIdentifier];
            }
            Plan *plan = searchResultArray[indexPath.row];
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
            
            return [self createNoDataCell:tableView indexPath:indexPath tips:@"无匹配结果"];
        }
    } else {
        if (indexPath.row < planArray.count) {
            static NSString *undoneCellIdentifier = @"undoneCellIdentifier";
            
            PlanCell *cell = [tableView dequeueReusableCellWithIdentifier:undoneCellIdentifier];
            if(!cell) {
                cell = [[PlanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:undoneCellIdentifier];
            }
            Plan *plan = planArray[indexPath.row];
            cell.plan = plan;
            cell.isDone = plan.iscompleted;
            cell.moveContentView.backgroundColor = [UIColor whiteColor];
            cell.backgroundColor = [UIColor whiteColor];
            cell.delegate = self;
            return cell;
            
        } else {
            
            return [self createNoDataCell:tableView indexPath:indexPath tips:STRViewTips13];
        }
    }
}

- (UITableViewCell *)createNoDataCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath tips:(NSString *)tips {
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    static NSString *noDataCellIdentifier = @"noDataCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noDataCellIdentifier];
    if (!cell) {
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
    if (indexPath.row == 2) {
        cell.textLabel.text = tips;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ((searchKeyword.length == 0
         && indexPath.row >= planArray.count)
        || (searchKeyword.length > 0
            && indexPath.row >= searchResultArray.count)) {
            return;
        }
    Plan *selectedPlan = nil;
    if (searchKeyword.length > 0) {
        selectedPlan = searchResultArray[indexPath.row];
    } else {
        selectedPlan = planArray[indexPath.row];
    }
    if (selectedPlan) {
        [self toPlanDetailWithPlan:selectedPlan];
    }
}

#pragma mark - action
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kUndonePlanCellDeleteTag) {
        if (buttonIndex == 0) {
            deletePlan = nil;
            [planCell hideMenuView:YES Animated:YES];
        } else {
            [self deletePlanWithPlan:deletePlan];
        }
    }
}

- (void)toPlanDetailWithPlan:(Plan *)plan
{
    PlanDetailViewController *controller = [[PlanDetailViewController alloc]init];
    controller.plan = plan;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

//修改计划完成状态
- (void)changePlanCompleteStatus:(Plan *)plan {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:STRDateFormatterType1];
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
    
    @synchronized (STRDecodeSignal)
    {
        [PlanCache storePlan:plan];
    }
    
    [tableViewPlan reloadData];
}

//删除计划
- (void)deletePlanWithPlan:(Plan *)plan {
    BOOL result = [PlanCache deletePlan:plan];
    if (result) {
        [self alertToastMessage:STRCommonTip16];
    } else {
        [self alertButtonMessage:STRCommonTip17];
    }
}

-(void)setCanCustomEdit:(BOOL)canCustomEdit {
    if (canCustomEditNow != canCustomEdit) {
        canCustomEditNow = canCustomEdit;
        
        CGRect frame = tableViewPlan.frame;
        if (canCustomEditNow) {
            if (hitView == nil) {
                hitView = [[HitView alloc] init];
                hitView.delegate = self;
                hitView.frame = frame;
            }
            hitView.frame = frame;
            [self.view addSubview:hitView];
            
            tableViewPlan.scrollEnabled = NO;
        } else {
            planCell = nil;
            [hitView removeFromSuperview];
            
            tableViewPlan.scrollEnabled = YES;
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
    
    vSlidedCellRect = [hitView convertRect:planCell.frame fromView:tableViewPlan];
    
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:STRViewTips11
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:STRCommonTip28
                                          otherButtonTitles:STRCommonTip27,
                          nil];
    alert.tag = kUndonePlanCellDeleteTag;
    [alert show];
}

//搜索栏事件
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    searchResultArray = [NSArray array];
    searchKeyword = [searchText copy];

    if (searchKeyword.length == 0) {
        [self getUndonePlan];
    } else {
        [self searchPlan];
    }
}

@end
