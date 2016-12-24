//
//  AddTaskNewViewController.m
//  plan
//
//  Created by Fengzy on 15/11/29.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "TaskRecord.h"
#import "AddTaskNewViewController.h"

@interface AddTaskNewViewController () <UITextViewDelegate, UIActionSheetDelegate> {
    BOOL isTomato;
    BOOL isAlarm;
    BOOL isRepeat;
    UIDatePicker *datePicker;
    UIActionSheet *repeatActionSheet;
}

@end

@implementation AddTaskNewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setControls];
    
    //注册通知,监听键盘出现
    [NotificationCenter addObserver:self selector:@selector(handleKeyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    //注册通知，监听键盘消失事件
    [NotificationCenter addObserver:self selector:@selector(handleKeyboardDidHidden:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//监听事件
- (void)handleKeyboardDidShow:(NSNotification*)showNotification {
    //获取键盘高度
    NSValue *keyboardRectAsObject=[[showNotification userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect;
    [keyboardRectAsObject getValue:&keyboardRect];
    
    self.txtView.contentInset = UIEdgeInsetsMake(0, 0,keyboardRect.size.height, 0);
}

- (void)handleKeyboardDidHidden:(NSNotification*)hiddenNotification {
    self.txtView.contentInset = UIEdgeInsetsZero;
}

- (void)setControls {
    if (self.operationType == Add) {
        self.title = STRViewTitle21;
    } else if (self.operationType == Edit) {
        self.title = STRViewTitle22;
    }
    [self createRightBarButton];
    
    self.txtView.layer.borderWidth = 1;
    self.txtView.layer.cornerRadius = 5;
    self.txtView.layer.borderColor = [color_eeeeee CGColor];
    self.txtView.editable = YES;
    self.txtView.delegate = self;
    self.txtView.inputAccessoryView = [self getInputAccessoryView];

    self.labelAlarmTime.hidden = YES;
    self.labelAlarmTime.userInteractionEnabled = YES;
    UITapGestureRecognizer *alarmTimeTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelAlarmTimeTouchUpInside:)];
    [self.labelAlarmTime addGestureRecognizer:alarmTimeTapGestureRecognizer];
    
    self.imgViewRepeat.hidden = YES;
    self.switchRepeat.hidden = YES;
    self.labelRepeat.hidden = YES;
    self.labelRepeat.userInteractionEnabled = YES;
    UITapGestureRecognizer *repeatTypeTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelRepeatTypeTouchUpInside:)];
    [self.labelRepeat addGestureRecognizer:repeatTypeTapGestureRecognizer];
    
    if (self.operationType == Add) {
        self.task = [[Task alloc]init];
        [self.txtView becomeFirstResponder];
    } else if (self.operationType == Edit) {
        self.txtView.text = self.task.content;

        if ([self.task.isNotify isEqualToString:@"1"]) {
            [self.switchAlarm setOn:YES];
            isAlarm = YES;
            self.labelAlarmTime.hidden = NO;
            self.labelAlarmTime.text = self.task.notifyTime;
            self.imgViewRepeat.hidden = NO;
            self.switchRepeat.hidden = NO;
            self.labelRepeat.hidden = NO;
            self.layoutConstraintTxtViewTop.constant = 90.f;
        } else {
            self.layoutConstraintTxtViewTop.constant = 50.f;
        }
        if ([self.task.isRepeat isEqualToString:@"1"]) {
            [self.switchRepeat setOn:YES];
            isRepeat = YES;
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
    }
}

- (void)createRightBarButton {
    if (self.operationType == Add || self.operationType == Edit) {
        self.rightBarButtonItem = [self createBarButtonItemWithNormalImageName:png_Btn_Save selectedImageName:png_Btn_Save selector:@selector(saveAction:)];
    }
}

- (void)saveAction:(UIButton *)button {
    NSString *content = [self.txtView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (content.length < 2) {
        [self alertButtonMessage:STRCommonTip3];
        return;
    }
    
    NSString *timeNow = [CommonFunction getTimeNowString];
    NSString *taskId = [CommonFunction NSDateToNSString:[NSDate date] formatter:STRDateFormatterType2];
    if (self.operationType == Add) {
        self.task.taskId = taskId;
        self.task.createTime = timeNow;
        self.task.updateTime = timeNow;
    } else {
        self.task.updateTime = timeNow;
    }
    self.task.content = content;
    if (isAlarm) {
        NSTimeInterval iNow = [[NSDate date] timeIntervalSince1970];
        NSDate *notifyDate = [CommonFunction NSStringDateToNSDate:self.task.notifyTime formatter:STRDateFormatterType3];
        NSTimeInterval iNotify = [notifyDate timeIntervalSince1970];
        if (iNotify - iNow <= 10) {//提醒时间已经过期了
            [self alertButtonMessage:STRViewTips51];
            return;
        }
        self.task.isNotify = @"1";
    } else {
        self.task.isNotify = @"0";
    }
    if (isRepeat) {
        self.task.isRepeat = @"1";
    } else {
        self.task.isRepeat = @"0";
    }

    BOOL result = [PlanCache storeTask:self.task updateNotify:YES];
    if (result) {
        [self alertToastMessage:STRCommonTip13];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self alertButtonMessage:STRCommonTip14];
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    NSString *text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([text isEqualToString:STRViewTips24]) {
        textView.text = @"";
        textView.textColor = color_333333;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSString *text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length == 0) {
        textView.text = STRViewTips24;
        textView.textColor = color_8f8f8f;
    }
}

- (void)labelAlarmTimeTouchUpInside:(UITapGestureRecognizer *)recognizer {
    if (isAlarm) {
        [self showDatePicker];
    }
}

- (void)labelRepeatTypeTouchUpInside:(UITapGestureRecognizer *)recognizer {
    if (isRepeat) {
        [self showRepeatActionSheet];
    }
}

- (IBAction)switchAlarmAction:(id)sender {
    [self.view endEditing:YES];
    UISwitch *btnSwitch = (UISwitch*)sender;
    BOOL isButtonOn = [btnSwitch isOn];
    isAlarm = isButtonOn;
    if (isButtonOn) {
        self.labelAlarmTime.hidden = NO;
        self.imgViewRepeat.hidden = NO;
        self.switchRepeat.hidden = NO;
        self.labelRepeat.hidden = NO;
        [self showDatePicker];
        self.layoutConstraintTxtViewTop.constant = 90.f;
    } else {
        self.labelAlarmTime.hidden = YES;
        self.labelAlarmTime.text = @"";
        self.imgViewRepeat.hidden = YES;
        self.switchRepeat.hidden = YES;
        self.labelRepeat.hidden = YES;
        self.labelRepeat.text = @"";
        [self.switchRepeat setOn:NO];
        isRepeat = NO;
        [self onPickerCancelBtn];
        self.layoutConstraintTxtViewTop.constant = 50.f;
    }
}

- (IBAction)switchRepeatAction:(id)sender {
    [self.view endEditing:YES];
    UISwitch *btnSwitch = (UISwitch*)sender;
    BOOL isButtonOn = [btnSwitch isOn];
    isRepeat = isButtonOn;
    if (isButtonOn) {
        NSDate *notifyTime = [CommonFunction NSStringDateToNSDate:self.task.notifyTime formatter:STRDateFormatterType3];
        if ([notifyTime compare:[NSDate date]] == NSOrderedAscending) {
            [self.switchRepeat setOn:NO];
            [self alertButtonMessage:STRViewTips51];
            return;
        }
        self.labelRepeat.hidden = NO;
        [self showRepeatActionSheet];
    } else {
        self.task.repeatType = @"4";
        self.labelRepeat.hidden = YES;
        self.labelRepeat.text = @"";
    }
}

- (void)showDatePicker {
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
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, pickerView.frame.size.height - kDatePickerHeight - kToolBarHeight, CGRectGetWidth(pickerView.bounds), kToolBarHeight)];
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
        picker.datePickerMode = UIDatePickerModeDateAndTime;
        picker.minimumDate = [NSDate date];
        NSDate *defaultDate = [[NSDate date] dateByAddingTimeInterval:5 * 60];
        picker.date = defaultDate;
        [pickerView addSubview:picker];
        datePicker = picker;
    }
    pickerView.tag = kDatePickerBgViewTag;
    [self.view addSubview:pickerView];
}

- (void)onPickerCertainBtn {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:STRDateFormatterType3];
    self.task.notifyTime = [dateFormatter stringFromDate:datePicker.date];
    self.labelAlarmTime.text = self.task.notifyTime;
    [self onPickerCancelBtn];
}

- (void)onPickerCancelBtn {
    UIView *pickerView = [self.view viewWithTag:kDatePickerBgViewTag];
    [pickerView removeFromSuperview];
    
    NSString *time = self.labelAlarmTime.text;
    if (!time || [time isEqualToString:@""]) {
        isAlarm = NO;
        self.task.notifyTime = @"";
        [self.switchAlarm setOn:NO];
        
        self.imgViewRepeat.hidden = YES;
        self.switchRepeat.hidden = YES;
        self.labelRepeat.hidden = YES;
        self.labelRepeat.text = @"";
        [self.switchRepeat setOn:NO];
        isRepeat = NO;
        self.layoutConstraintTxtViewTop.constant = 50.f;
    }
}

- (void)showRepeatActionSheet {
    repeatActionSheet = [[UIActionSheet alloc] initWithTitle:STRViewTips44 delegate:self cancelButtonTitle:STRCommonTip28 destructiveButtonTitle:nil otherButtonTitles:STRCommonTip8, STRCommonTip9, STRCommonTip10, STRCommonTip11, nil];
    [repeatActionSheet showInView:self.view];
}

#pragma mark actionSheet点击事件
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIAlertView *alertView;
    switch (buttonIndex) {
        case 0://每天
        {
            self.task.repeatType = @"0";
            self.labelRepeat.text = STRCommonTip8;
            [self performSelector:@selector(dismissAlertView:) withObject:alertView afterDelay:2.0];
        }
            break;
        case 1://每周
        {
            self.task.repeatType = @"1";
            self.labelRepeat.text = STRCommonTip9;
            [self performSelector:@selector(dismissAlertView:) withObject:alertView afterDelay:2.0];
        }
            break;
        case 2://每月
        {
            self.task.repeatType = @"2";
            self.labelRepeat.text = STRCommonTip10;
            [self performSelector:@selector(dismissAlertView:) withObject:alertView afterDelay:2.0];
        }
            break;
        case 3://每年
        {
            self.task.repeatType = @"3";
            self.labelRepeat.text = STRCommonTip11;
            [self performSelector:@selector(dismissAlertView:) withObject:alertView afterDelay:2.0];
        }
            break;
        case 4://取消
        {
            [self.switchRepeat setOn:NO];
            isRepeat = NO;
            self.task.repeatType = @"4";
            self.labelRepeat.text = @"";
            [self performSelector:@selector(dismissAlertView:) withObject:alertView afterDelay:2.0];
        }
            break;
        default:
            break;
    }
}

#pragma mark 让alertView消失
- (void)dismissAlertView:(UIAlertView *)alertView {
    if (alertView) {
        [alertView dismissWithClickedButtonIndex:[alertView cancelButtonIndex] animated:YES];
        alertView.hidden = YES;
    }
}

@end
