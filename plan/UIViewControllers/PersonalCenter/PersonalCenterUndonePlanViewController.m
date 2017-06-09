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
#import "PopupPlanRemarkView.h"
#import "PlanDetailNewViewController.h"
#import "PersonalCenterUndonePlanViewController.h"

NSUInteger const kUndonePlanCellDeleteTag = 9527;

@interface PersonalCenterUndonePlanViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, PlanCellDelegate, HitViewDelegate>
    
@property (nonatomic, strong) PlanCell *planCell;
@property (nonatomic, strong) HitView *hitView;
@property (nonatomic, assign) BOOL canCustomEditNow;
@property (nonatomic, strong) Plan *deletePlan;
@property (nonatomic, strong) NSMutableArray *planArray;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSString *searchKeyword;
@property (nonatomic, strong) NSMutableArray *searchResultArray;
@property (nonatomic, strong) UITableView *tableViewPlan;

@end


@implementation PersonalCenterUndonePlanViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"未完计划";
    
    [NotificationCenter addObserver:self selector:@selector(getUndonePlan) name:NTFPlanSave object:nil];
    
    [self loadCustomView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//初始化自定义界面
- (void)loadCustomView
{
    [self initTableView];
    
    [self getUndonePlan];
}

- (void)initTableView
{
    self.searchKeyword = @"";
    self.searchResultArray = [NSMutableArray array];
    
    NSUInteger tableHeight = CGRectGetHeight(self.view.bounds);
    CGRect frame = CGRectZero;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = CGRectGetWidth(self.view.bounds);
    frame.size.height = tableHeight;
    
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
    {
        UIView *footer = [[UIView alloc] init];
        self.tableViewPlan.tableFooterView = footer;
    }
    self.tableViewPlan.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableViewPlan setDefaultEmpty];

    [self.view addSubview:self.tableViewPlan];
}

- (void)getUndonePlan
{
    [self showHUD];
    BmobUser *user = [BmobUser currentUser];
    __weak typeof(self) weakSelf = self;
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Plan"];
    [bquery whereKey:@"userObjectId" equalTo:user.objectId];
    [bquery whereKey:@"isDeleted" notEqualTo:@"1"];
    [bquery whereKey:@"isCompleted" notEqualTo:@"1"];
    [bquery orderByDescending:@"updatedTime"];
    
    self.planArray = [NSMutableArray array];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
     {
         [weakSelf hideHUD];

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
                 [weakSelf.planArray addObject:plan];
             }
         }
         [weakSelf.tableViewPlan reloadData];
     }];
}

- (void)searchPlan
{
    [self showHUD];
    BmobUser *user = [BmobUser currentUser];
    __weak typeof(self) weakSelf = self;
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Plan"];
    [bquery whereKey:@"userObjectId" equalTo:user.objectId];
    [bquery whereKey:@"isDeleted" notEqualTo:@"1"];
    [bquery whereKey:@"isCompleted" notEqualTo:@"1"];
    [bquery whereKey:@"content" matchesWithRegex:[NSString stringWithFormat:@".*?%@.*?", self.searchKeyword]];
    [bquery orderByDescending:@"updatedTime"];
    
    self.searchResultArray = [NSMutableArray array];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
     {
         [weakSelf hideHUD];
         
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

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchKeyword.length)
    {
        return self.searchResultArray.count;
    }
    else
    {
        return self.planArray.count;
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
    }
    else
    {
        if (indexPath.row < self.planArray.count)
        {
            static NSString *undoneCellIdentifier = @"undoneCellIdentifier";
            
            PlanCell *cell = [tableView dequeueReusableCellWithIdentifier:undoneCellIdentifier];
            if(!cell)
            {
                cell = [[PlanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:undoneCellIdentifier];
            }
            Plan *plan = self.planArray[indexPath.row];
            cell.plan = plan;
            cell.isDone = plan.iscompleted;
            cell.moveContentView.backgroundColor = [UIColor whiteColor];
            cell.backgroundColor = [UIColor whiteColor];
            cell.delegate = self;
            return cell;
        }
    }
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ((self.searchKeyword.length == 0
         && indexPath.row >= self.planArray.count)
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
        selectedPlan = self.planArray[indexPath.row];
    }
    if (selectedPlan)
    {
        [self toPlanDetailWithPlan:selectedPlan];
    }
}

#pragma mark - action
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kUndonePlanCellDeleteTag)
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

- (void)toPlanDetailWithPlan:(Plan *)plan
{
    PlanDetailNewViewController *controller = [[PlanDetailNewViewController alloc]init];
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

- (void)setCanCustomEdit:(BOOL)canCustomEdit
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
    alert.tag = kUndonePlanCellDeleteTag;
    [alert show];
}

//搜索栏事件
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.searchResultArray = [NSMutableArray array];
    self.searchKeyword = [searchText copy];

    if (self.searchKeyword.length)
    {
        [self searchPlan];
    }
    else
    {
        [self getUndonePlan];
    }
}

@end
