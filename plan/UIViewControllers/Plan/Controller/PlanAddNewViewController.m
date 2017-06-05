//
//  PlanAddNewViewController.m
//  plan
//
//  Created by Fengzy on 2017/4/24.
//  Copyright © 2017年 Fengzy. All rights reserved.
//

#import "PlanAddCell.h"
#import "PlanAddNewViewController.h"
#import "SingleSelectedViewController.h"

@interface PlanAddNewViewController ()

@property (strong, nonatomic) Plan *plan;
@property (strong, nonatomic) NSArray *arrayPlanLevel;
@property (strong, nonatomic) NSArray *arrayRepeat;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (assign, nonatomic) BOOL isSelectBeginDate;

@end

@implementation PlanAddNewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = STRViewTips14;
    
    __weak typeof(self) weakSelf = self;
    [self customRightButtonWithImage:[UIImage imageNamed:png_Btn_Save] action:^(UIButton *sender)
     {
         [weakSelf saveAction:sender];
     }];
    
    [self initView];
    [self initSelectItem];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)initView
{
    self.plan = [Plan new];
    self.plan.planLevel = @"0";
    self.plan.isRepeat = @"0";
    self.plan.beginDate = [CommonFunction NSDateToNSString:[NSDate date] formatter:STRDateFormatterType4];
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)initSelectItem
{
    SelectItem *itemLevel0 = [[SelectItem alloc] init];
    itemLevel0.itemName = @"不紧急";
    itemLevel0.itemValue = @"0";
    SelectItem *itemLevel1 = [[SelectItem alloc] init];
    itemLevel1.itemName = @"一般急";
    itemLevel1.itemValue = @"1";
    SelectItem *itemLevel2 = [[SelectItem alloc] init];
    itemLevel2.itemName = @"很紧急";
    itemLevel2.itemValue = @"2";
    self.arrayPlanLevel = [NSArray arrayWithObjects:itemLevel0, itemLevel1, itemLevel2, nil];
    
    SelectItem *itemRepeat0 = [[SelectItem alloc] init];
    itemRepeat0.itemName = @"否";
    itemRepeat0.itemValue = @"0";
    SelectItem *itemRepeat1 = [[SelectItem alloc] init];
    itemRepeat1.itemName = @"是";
    itemRepeat1.itemValue = @"1";
    self.arrayRepeat = [NSArray arrayWithObjects:itemRepeat0, itemRepeat1, nil];
}

- (void)showDatePicker
{
    //收起键盘
    [self.view endEditing:YES];
    
    UIView *pickerView = [[UIView alloc] initWithFrame:self.view.bounds];
    pickerView.backgroundColor = [UIColor clearColor];
    {
        UIView *bgView = [[UIView alloc] initWithFrame:pickerView.bounds];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.3;
        [pickerView addSubview:bgView];
    }
    {
        UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, pickerView.frame.size.height - kDatePickerHeight - kToolBarHeight, CGRectGetWidth(pickerView.bounds), kToolBarHeight)];
        toolbar.barStyle = UIBarStyleBlack;
        toolbar.translucent = YES;
        UIBarButtonItem* item1 = [[UIBarButtonItem alloc] initWithTitle:STRCommonTip27 style:UIBarButtonItemStylePlain target:nil action:@selector(onPickerCertainBtn)];
        UIBarButtonItem* item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem* item3 = [[UIBarButtonItem alloc] initWithTitle:STRCommonTip28 style:UIBarButtonItemStylePlain target:nil action:@selector(onPickerCancelBtn)];
        NSArray* toolbarItems = [NSArray arrayWithObjects:item3, item2, item1, nil];
        [toolbar setItems:toolbarItems];
        [pickerView addSubview:toolbar];
    }
    {
        UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, pickerView.frame.size.height - kDatePickerHeight, CGRectGetWidth(pickerView.bounds), kDatePickerHeight)];
        picker.backgroundColor = [UIColor whiteColor];
        picker.locale = [NSLocale currentLocale];
        if (self.isSelectBeginDate)
        {
            picker.datePickerMode = UIDatePickerModeDate;
        }
        else
        {
            picker.datePickerMode = UIDatePickerModeDateAndTime;
        }
        picker.minimumDate = [NSDate date];
        NSDate *defaultDate = [[NSDate date] dateByAddingTimeInterval:5 * 60];
        picker.date = defaultDate;
        [pickerView addSubview:picker];
        self.datePicker = picker;
    }
    pickerView.tag = kDatePickerBgViewTag;
    [self.view addSubview:pickerView];
}

- (void)onPickerCertainBtn
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (self.isSelectBeginDate)
    {
        [dateFormatter setDateFormat:STRDateFormatterType4];
        self.plan.beginDate = [dateFormatter stringFromDate:self.datePicker.date];
    }
    else
    {
        [dateFormatter setDateFormat:STRDateFormatterType3];
        self.plan.isnotify = @"1";
        self.plan.notifytime = [dateFormatter stringFromDate:self.datePicker.date];
    }
    [self.tableView reloadData];
    [self onPickerCancelBtn];
}

- (void)onPickerCancelBtn
{
    UIView *pickerView = [self.view viewWithTag:kDatePickerBgViewTag];
    [pickerView removeFromSuperview];
}

#pragma mark - action
- (void)saveAction:(UIButton *)button
{
    NSString *content = [self.plan.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (content.length == 0)
    {
        [self alertButtonMessage:STRCommonTip3];
        return;
    }
    [self savePlan];
}

- (void)savePlan
{
    [self showHUD];
    [self.view endEditing:YES];

    self.plan.iscompleted = @"0";
    self.plan.isdeleted = @"0";
    
    if (!self.plan.isnotify)
    {
        self.plan.isnotify = @"0";
        self.plan.notifytime = @"";
    }

    BmobUser *user = [BmobUser currentUser];
    BmobObject *newPlan = [BmobObject objectWithClassName:@"Plan"];
    NSDictionary *dic = @{@"userObjectId":user.objectId,
                          @"content":self.plan.content,
                          @"planLevel":self.plan.planLevel,
                          @"notifyTime":self.plan.notifytime,
                          @"isCompleted":self.plan.iscompleted,
                          @"isNotify":self.plan.isnotify,
                          @"isDeleted":self.plan.isdeleted,
                          @"isRepeat":self.plan.isRepeat,
                          @"beginDate":self.plan.beginDate};
    [newPlan saveAllWithDictionary:dic];
    BmobACL *acl = [BmobACL ACL];
    [acl setReadAccessForUser:user];//设置只有当前用户可读
    [acl setWriteAccessForUser:user];//设置只有当前用户可写
    newPlan.ACL = acl;
    __weak typeof(self) weakSelf = self;
    [newPlan saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error)
     {
         [weakSelf hideHUD];
         if (isSuccessful)
         {
             //添加提醒
             if ([weakSelf.plan.isnotify isEqualToString:@"1"])
             {
                 weakSelf.plan.planid = newPlan.objectId;
                 [CommonFunction addPlanNotification:weakSelf.plan];
             }
             
             [weakSelf alertToastMessage:STRCommonTip13];
             [NotificationCenter postNotificationName:NTFPlanSave object:nil];
             [weakSelf.navigationController popViewControllerAnimated:YES];
         }
         else
         {
             [weakSelf alertButtonMessage:@"新建计划失败"];
         }
     }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 4)
    {
        return 300.f;
    }
    else
    {
        return 60.f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    static NSString *cellIdentifier = @"cell0";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"";
        cell.textLabel.frame = cell.contentView.bounds;
        cell.textLabel.textColor = color_666666;
        cell.textLabel.font = font_Normal_16;
    }
    switch (indexPath.row)
    {
        case 0:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"开始时间";
            cell.detailTextLabel.text = [CommonFunction getBeginDateStringForShow:self.plan.beginDate];
        }
            break;
        case 1:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"设置提醒";
            if ([self.plan.isnotify isEqualToString:@"1"])
            {
                cell.detailTextLabel.text = [CommonFunction getBeginDateStringForShow:self.plan.notifytime];
            }
            else
            {
                cell.detailTextLabel.text = @"未设置";
            }
        }
            break;
        case 2:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"紧急等级";
            cell.detailTextLabel.text = [CommonFunction getPlanLevelStringForShow:self.plan.planLevel];
        }
            break;
        case 3:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"每天重复";
            cell.detailTextLabel.text = [CommonFunction getRepeatStringForShow:self.plan.isRepeat];
        }
            break;
        case 4:
        {
            __weak typeof(self) weakSelf = self;
            PlanAddCell *cell1 = [PlanAddCell cellView];
            cell1.accessoryType = UITableViewCellAccessoryNone;
            cell1.textView.text = self.plan.content;
            cell1.textView.inputAccessoryView = [self getInputAccessoryView];
            cell1.textView.placeHolder = @"请输入计划内容";
            cell1.textView.textChange = ^(NSString *text) {
                weakSelf.plan.content = text;
            };
            return cell1;
        }
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row)
    {
        case 0:
        {
            self.isSelectBeginDate = YES;
            [self showDatePicker];
        }
            break;
        case 1:
        {
            self.isSelectBeginDate = NO;
            if ([self.plan.isnotify isEqualToString:@"1"])
            {
                self.plan.isnotify = @"0";
                self.plan.notifytime = @"";
                [tableView reloadData];
            }
            else
            {
                [self showDatePicker];
            }
        }
            break;
        case 2:
            [self toSetPlanLevel];
            break;
        case 3:
            [self toSetPlanRepeat];
            break;
        default:
            break;
    }
}

- (void)toSetPlanLevel
{
    __weak typeof(self) weakSelf = self;
    SingleSelectedViewController *controller = [[SingleSelectedViewController alloc] init];
    controller.viewTitle = @"紧急等级";
    controller.arrayData = self.arrayPlanLevel;
    controller.selectedValue = self.plan.planLevel;
    controller.SelectedDelegate = ^(NSString *selectedValue)
    {
        weakSelf.plan.planLevel = selectedValue;
        [weakSelf.tableView reloadData];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)toSetPlanRepeat
{
    __weak typeof(self) weakSelf = self;
    SingleSelectedViewController *controller = [[SingleSelectedViewController alloc] init];
    controller.viewTitle = @"每天重复";
    controller.arrayData = self.arrayRepeat;
    controller.selectedValue = self.plan.isRepeat;
    controller.SelectedDelegate = ^(NSString *selectedValue)
    {
        weakSelf.plan.isRepeat = selectedValue;
        [weakSelf.tableView reloadData];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

@end
