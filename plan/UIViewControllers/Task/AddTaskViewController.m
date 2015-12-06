//
//  AddTaskViewController.m
//  plan
//
//  Created by Fengzy on 15/11/29.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "TaskRecord.h"
#import "AddTaskViewController.h"

NSUInteger const kTaskDeleteTag = 20151201;

@interface AddTaskViewController () <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    NSArray *finishRecordArray;
}

@end

@implementation AddTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setControls];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setControls {
    if (self.operationType == Add) {
        
        self.title = str_Task_Add;
        
    } else if (self.operationType == Edit) {
        
        self.title = str_Task_Edit;
        
    } else if (self.operationType == View) {
        
        self.title = str_Task_Detail;
    }
    [self createRightBarButton];
    
    self.txtView.layer.borderWidth = 1;
    self.txtView.layer.borderColor = [color_GrayLight CGColor];
    self.txtView.layer.cornerRadius = 5;
    self.tableView.layer.borderWidth = 1;
    self.tableView.layer.borderColor = [color_GrayLight CGColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
    finishRecordArray = [NSArray array];
    
    if (self.operationType == Add || self.operationType == Edit) {
        
        self.txtView.editable = YES;
        self.txtView.inputAccessoryView = [self getInputAccessoryView];
        self.txtView.delegate = self;
        if (self.task) {
            self.txtView.text = self.task.content;
        }
        [self.txtView becomeFirstResponder];
        
        self.labelCountTips.hidden = YES;
        self.btnCount.hidden = YES;
        self.tableView.hidden = YES;
        
    } else if (self.operationType == View) {
        
        self.txtView.editable = NO;
        self.txtView.text = self.task.content;
        
        self.labelCountTips.hidden = NO;
        self.btnCount.layer.cornerRadius = 25;
        self.btnCount.hidden = NO;
        [self.btnCount setAllTitle:self.task.totalCount];
        self.tableView.hidden = NO;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        
        finishRecordArray = [PlanCache getTeaskRecord:self.task.taskId];
        [self.tableView reloadData];
    }
}

- (void)createRightBarButton {
    if (self.operationType == Add || self.operationType == Edit) {
        
        self.rightBarButtonItem = [self createBarButtonItemWithNormalImageName:png_Btn_Save selectedImageName:png_Btn_Save selector:@selector(saveAction:)];
        
    } else if (self.operationType == View) {
        
        self.rightBarButtonItems = [NSArray arrayWithObjects:
                                    [self createBarButtonItemWithNormalImageName:png_Btn_Edit selectedImageName:png_Btn_Edit selector:@selector(editAction:)],
                                    [self createBarButtonItemWithNormalImageName:png_Btn_Delete selectedImageName:png_Btn_Delete selector:@selector(deleteAction:)], nil];
    }
}

- (void)saveAction:(UIButton *)button {
    NSString *content = [self.txtView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (content.length < 2) {
        [self alertButtonMessage:str_Common_Tips3];
        return;
    }
    
    NSString *timeNow = [CommonFunction getTimeNowString];
    NSString *taskId = [CommonFunction NSDateToNSString:[NSDate date] formatter:str_DateFormatter_yyyyMMddHHmmss];
    
    if (self.operationType == Add) {
        self.task = [[Task alloc]init];
        self.task.taskId = taskId;
        self.task.createTime = timeNow;
        self.task.updateTime = timeNow;
    } else {
        self.task.updateTime = timeNow;
    }
    
    self.task.content = content;

    BOOL result = [PlanCache storeTask:self.task];
    if (result) {
        
        [self alertToastMessage:str_Save_Success];
        
        if (self.operationType == Add) {
            [self.navigationController popViewControllerAnimated:YES];
        } else if (self.operationType == Edit) {
            self.operationType = View;
            [self setControls];
        }
    } else {
        
        [self alertButtonMessage:str_Save_Fail];
    }
}

- (void)editAction:(UIButton *)button {
    self.operationType = Edit;
    [self setControls];
}

- (void)deleteAction:(UIButton *)button {
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

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    NSString *text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([text isEqualToString:str_Photo_Add_Tips1]) {
        textView.text = @"";
        textView.textColor = color_333333;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSString *text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length == 0) {
        textView.text = str_Photo_Add_Tips1;
        textView.textColor = color_8f8f8f;
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
