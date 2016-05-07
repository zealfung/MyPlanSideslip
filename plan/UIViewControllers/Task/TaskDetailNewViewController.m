//
//  TaskDetailNewViewController.m
//  plan
//
//  Created by Fengzy on 16/1/25.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import "KxMenu.h"
#import "AddTaskNewViewController.h"
#import "TaskDetailNewViewController.h"

NSUInteger const kTaskDeleteNewTag = 20151201;

@interface TaskDetailNewViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSArray *finishRecordArray;
}

@end

@implementation TaskDetailNewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = str_Task_Detail;
    [self createRightBarButton];
    
    [NotificationCenter addObserver:self selector:@selector(reloadTaskData) name:NTFTaskSave object:nil];
    [NotificationCenter addObserver:self selector:@selector(reloadTaskRecordData) name:NTFTaskRecordSave object:nil];

    [self setControls];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)createRightBarButton {
    self.rightBarButtonItem =[self createBarButtonItemWithNormalImageName:png_Btn_More selectedImageName:png_Btn_More selector:@selector(showMenu:)];
}

- (void)reloadTaskData {
    self.task = [PlanCache getTaskById:self.task.taskId];
    [self setControls];
}

- (void)reloadTaskRecordData {
    finishRecordArray = [PlanCache getTaskRecord:self.task.taskId];
    [self.tableRecord reloadData];
}

- (void)setControls {
    self.txtViewContent.layer.borderWidth = 1;
    self.txtViewContent.layer.cornerRadius = 5;
    self.txtViewContent.layer.borderColor = [color_eeeeee CGColor];
    self.txtViewContent.text = self.task.content;
    self.tableRecord.layer.borderWidth = 1;
    self.tableRecord.layer.cornerRadius = 5;
    self.tableRecord.layer.borderColor = [color_eeeeee CGColor];
    self.tableRecord.tableFooterView = [[UIView alloc] init];
    self.btnStart.layer.cornerRadius = 5;
    finishRecordArray = [NSArray array];
    
    [self.btnStart setAllTitle:str_Task_Tips8];

    if ([self.task.isNotify isEqualToString:@"0"]) {
        self.imgViewAlarm.hidden = YES;
        self.labelAlram.hidden = YES;
        self.imgViewRepeat.hidden = YES;
        self.labelRepeat.hidden = YES;
        self.layoutConstraintTxtViewBottom.constant = 10.f;
    } else {
        self.imgViewAlarm.hidden = NO;
        self.labelAlram.hidden = NO;
        self.labelAlram.text = [NSString stringWithFormat:@"%@%@", str_Task_Tips11, self.task.notifyTime];
        self.layoutConstraintTxtViewBottom.constant = 90.f;
    }
    if ([self.task.isRepeat isEqualToString:@"0"]) {
        self.imgViewRepeat.hidden = YES;
        self.labelRepeat.hidden = YES;
    } else {
        self.imgViewRepeat.hidden = NO;
        self.labelRepeat.hidden = NO;
        switch ([self.task.repeatType integerValue]) {
            case 0:
                self.labelRepeat.text = STRCommonTip8;
                break;
            case 1:
                self.labelRepeat.text = STRCommonTip9;
                break;
            case 2:
                self.labelRepeat.text = STRCommonTip10;
                break;
            case 3:
                self.labelRepeat.text = STRCommonTip11;
                break;
            default:
                break;
        }
    }
    if (self.task.totalCount.length == 0
        || [self.task.totalCount integerValue] == 0) {
        self.labelFinishedTimes.text = @"0";
    } else {
        self.labelFinishedTimes.text = self.task.totalCount;
    }
    
    self.tableRecord.dataSource = self;
    self.tableRecord.delegate = self;
    
    NSString *date = [CommonFunction NSDateToNSString:[NSDate date] formatter:str_DateFormatter_yyyy_MM_dd];
    if ([self.task.isTomato isEqualToString:@"0"]
        && [self.task.completionDate isEqualToString:date]) {
        self.btnStart.enabled = NO;
        [self.btnStart setBackgroundColor:color_8f8f8f];
    } else {
        self.btnStart.enabled = YES;
        [self.btnStart setBackgroundColor:color_0BA32A];
    }

    finishRecordArray = [PlanCache getTaskRecord:self.task.taskId];
    [self.tableRecord reloadData];
}

- (void)showMenu:(UIButton *)sender {
    NSArray *menuItems =
    @[
      [KxMenuItem menuItem:str_Edit
                     image:[UIImage imageNamed:png_Btn_Edit]
                    target:self
                    action:@selector(editAction:)],
      [KxMenuItem menuItem:str_Delete
                     image:[UIImage imageNamed:png_Btn_Delete]
                    target:self
                    action:@selector(deleteAction:)],
      ];
    
    if (![KxMenu isShowMenu]) {
        CGRect frame = sender.frame;
        frame.origin.y -= 30;
        [KxMenu showMenuInView:self.view
                      fromRect:frame
                     menuItems:menuItems];
    } else {
        [KxMenu dismissMenu];
    }
}

- (void)editAction:(UIButton *)sender {
    AddTaskNewViewController *controller = [[AddTaskNewViewController alloc]init];
    controller.operationType = Edit;
    controller.task = self.task;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)deleteAction:(UIButton *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:str_Task_Delete_Tips
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:str_Cancel
                                          otherButtonTitles:str_OK,
                          nil];
    
    alert.tag = kTaskDeleteNewTag;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kTaskDeleteNewTag) {
        
        if (buttonIndex == 1) {
            
            BOOL result = [PlanCache deleteTask:self.task];
            if (result) {
                
                [self alertToastMessage:str_Delete_Success];
                [self.navigationController popViewControllerAnimated:YES];
                
            } else {
                
                [self alertButtonMessage:str_Delete_Fail];
            }
        }
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (finishRecordArray.count > 0) {
        return finishRecordArray.count;
    } else {
        return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < finishRecordArray.count) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        static NSString *taskRecordCellIdentifier = @"taskRecordCellIdentifier";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:taskRecordCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:taskRecordCellIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"";
            cell.textLabel.frame = cell.contentView.bounds;
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.textLabel.font = font_Normal_13;
        }
        TaskRecord *taskRecord = finishRecordArray[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@%@", str_Task_Tips13, taskRecord.createTime];
        return cell;
        
    } else {
        
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        static NSString *noTaskRecordCellIdentifier = @"noTaskRecordCellIdentifier";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noTaskRecordCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noTaskRecordCellIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"";
            cell.textLabel.frame = cell.contentView.bounds;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.textLabel.font = font_Bold_16;
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = str_Task_Tips12;
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (IBAction)startAction:(id)sender {
    [self finishOnce];
}

- (void)finishOnce {
    self.btnStart.enabled = NO;
    [self.btnStart setBackgroundColor:color_8f8f8f];
    [self addRecord];
}

- (void)addRecord {
    NSString *date = [CommonFunction NSDateToNSString:[NSDate date] formatter:str_DateFormatter_yyyy_MM_dd];
    self.task.completionDate = date;
    NSString *count = self.task.totalCount;
    NSInteger totalCount = 0;
    if (count.length > 0) {
        totalCount = [count integerValue] + 1;
    }
    self.task.totalCount = [NSString stringWithFormat:@"%ld", (long)totalCount];
    NSString *time = [CommonFunction getTimeNowString];
    self.task.updateTime = time;
    
    TaskRecord *taskRecord = [[TaskRecord alloc] init];
    taskRecord.recordId = self.task.taskId;
    taskRecord.createTime = time;
    
    [PlanCache storeTask:self.task];
    [PlanCache storeTaskRecord:taskRecord];
}

@end
