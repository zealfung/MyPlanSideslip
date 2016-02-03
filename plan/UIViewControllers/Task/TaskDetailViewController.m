//
//  TaskDetailViewController.m
//  plan
//
//  Created by Fengzy on 16/1/25.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import "KxMenu.h"
#import "AddTaskViewController.h"
#import "TaskDetailViewController.h"

NSUInteger const kTaskDeleteTag = 20151201;

@interface TaskDetailViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSArray *finishRecordArray;
}

@end

@implementation TaskDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"任务详情";
    [self createRightBarButton];
    
    [self setControls];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)createRightBarButton {
    self.rightBarButtonItem =[self createBarButtonItemWithNormalImageName:png_Btn_More selectedImageName:png_Btn_More selector:@selector(showMenu:)];
}

- (void)setControls {
    self.txtViewContent.layer.borderWidth = 1;
    self.txtViewContent.layer.cornerRadius = 5;
    self.txtViewContent.layer.borderColor = [color_GrayLight CGColor];
    self.txtViewContent.text = self.task.content;
    self.tableRecord.layer.borderWidth = 1;
    self.tableRecord.layer.cornerRadius = 5;
    self.tableRecord.layer.borderColor = [color_GrayLight CGColor];
    self.tableRecord.tableFooterView = [[UIView alloc] init];
    finishRecordArray = [NSArray array];
    
    if ([self.task.isTomato isEqualToString:@"0"]) {
        self.imgViewTomato.hidden = YES;
        self.labelTomato.hidden = YES;
        self.imgViewAlarmConstraint.constant = 10;
        self.labelAlarmConstraint.constant = 10;
    } else {
        self.labelTomato.text = [NSString stringWithFormat:@"番茄时间每次 %@ 分钟", self.task.tomatoMinute];
    }
    if ([self.task.isNotify isEqualToString:@"0"]) {
        self.imgViewAlarm.hidden = YES;
        self.labelAlram.hidden = YES;
        self.imgViewRepeat.hidden = YES;
        self.labelRepeat.hidden = YES;
    } else {
        self.labelAlram.text = [NSString stringWithFormat:@"任务提醒时间：%@", self.task.notifyTime];
    }
    if ([self.task.isRepeat isEqualToString:@"0"]) {
        self.imgViewRepeat.hidden = YES;
        self.labelRepeat.hidden = YES;
    } else {
        switch ([self.task.repeatType integerValue]) {
            case 0:
                self.labelRepeat.text = @"每天重复提醒";
                break;
            case 1:
                self.labelRepeat.text = @"每周重复提醒";
                break;
            case 2:
                self.labelRepeat.text = @"每月重复提醒";
                break;
            case 3:
                self.labelRepeat.text = @"每年重复提醒";
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
    
    finishRecordArray = [PlanCache getTeaskRecord:self.task.taskId];
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
    AddTaskViewController *controller = [[AddTaskViewController alloc]init];
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
    
    alert.tag = kTaskDeleteTag;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kTaskDeleteTag) {
        
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
        return 4;
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
        cell.textLabel.text = [NSString stringWithFormat:@"完成时间：%@", taskRecord.createTime];
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
        
        if (indexPath.row == 3) {
            cell.textLabel.text = @"暂无完成记录";
        } else {
            cell.textLabel.text = nil;
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
