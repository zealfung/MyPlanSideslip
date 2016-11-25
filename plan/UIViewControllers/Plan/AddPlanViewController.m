//
//  AddPlanViewController.m
//  plan
//
//  Created by Fengzy on 15/8/30.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "PlanCache.h"
#import "AddPlanViewController.h"

@interface AddPlanViewController () <UITextFieldDelegate, UITextViewDelegate> {
    UITextView *txtViewContent;
    NSUInteger yOffset;
    NSString *beginDate;//开始日期
    NSString *notifyTime;//提醒时间
    UIDatePicker *datePicker;
    UISwitch *switchBtnAlarm;
    UILabel *labelNotifyTime;
    UILabel *labelBeginDate;
    BOOL isSelectBeginDate;
    CGRect txtViewFrame;
}

@end

@implementation AddPlanViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.operationType == Add) {
        self.title = str_Plan_Add;
    } else {
        self.title = str_Plan_Edit;
    }
    
    [self createRightBarButton];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadCustomView];
    //注册通知,监听键盘出现
    [NotificationCenter addObserver:self selector:@selector(handleKeyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    //注册通知，监听键盘消失事件
    [NotificationCenter addObserver:self selector:@selector(handleKeyboardDidHidden:) name:UIKeyboardDidHideNotification object:nil];
}

//监听事件
- (void)handleKeyboardDidShow:(NSNotification*)showNotification {
    //获取键盘高度
    NSValue *keyboardRectAsObject=[[showNotification userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect;
    [keyboardRectAsObject getValue:&keyboardRect];
    
    txtViewContent.contentInset = UIEdgeInsetsMake(0, 0,keyboardRect.size.height, 0);
}

- (void)handleKeyboardDidHidden:(NSNotification*)hiddenNotification {
    txtViewContent.contentInset = UIEdgeInsetsZero;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)createRightBarButton {
    self.rightBarButtonItem = [self createBarButtonItemWithNormalImageName:png_Btn_Save selectedImageName:png_Btn_Save selector:@selector(saveAction:)];
}

- (void)loadCustomView {
    yOffset = kEdgeInset;
    CGFloat iconSize = 30;
    CGFloat switchWidth = 20;
    {
        CGFloat tipsWidth = 95;
        beginDate = [CommonFunction NSDateToNSString:[NSDate date] formatter:str_DateFormatter_yyyy_MM_dd];
        UILabel *labelBeginTimeTips = [[UILabel alloc] initWithFrame:CGRectMake(kEdgeInset, yOffset, tipsWidth, iconSize)];
        labelBeginTimeTips.textColor = color_Black;
        labelBeginTimeTips.font = font_Normal_18;
        labelBeginTimeTips.text = str_Plan_BeginDate;
        [self.view addSubview:labelBeginTimeTips];
        
        UILabel *labelBeginTime = [[UILabel alloc] initWithFrame:CGRectMake(kEdgeInset + tipsWidth, yOffset, WIDTH_FULL_SCREEN - kEdgeInset * 2 - tipsWidth, iconSize)];
        labelBeginTime.textColor = color_Black;
        labelBeginTime.font = font_Normal_18;
        labelBeginTime.layer.borderWidth = 1;
        labelBeginTime.layer.cornerRadius = 5;
        labelBeginTime.layer.borderColor = [color_eeeeee CGColor];
        labelBeginTime.userInteractionEnabled = YES;
        labelBeginTime.text = [CommonFunction getBeginDateStringForShow:beginDate];
        UITapGestureRecognizer *labelBeginTimeTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(beginDateTouchAction:)];
        [labelBeginTime addGestureRecognizer:labelBeginTimeTapGestureRecognizer];
        [self.view addSubview:labelBeginTime];
        labelBeginDate = labelBeginTime;
        yOffset += iconSize + kEdgeInset;
    }
    {
        UIImageView *alarm = [[UIImageView alloc] initWithFrame:CGRectMake(kEdgeInset, yOffset, iconSize, iconSize)];
        alarm.image = [UIImage imageNamed:png_Icon_Alarm];
        [self.view addSubview:alarm];
        
        UISwitch *btnSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(kEdgeInset + iconSize, yOffset, switchWidth, iconSize)];
        [btnSwitch setOn:NO];
        [btnSwitch addTarget:self action:@selector(alarmSwitchAction:) forControlEvents:UIControlEventValueChanged];
        switchBtnAlarm = btnSwitch;
        [self.view addSubview:btnSwitch];
        
        UILabel *labelTime = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btnSwitch.frame) + kEdgeInset, yOffset, WIDTH_FULL_SCREEN - kEdgeInset * 3 - iconSize - switchWidth, iconSize)];
        labelTime.textColor = color_Black;
        labelTime.font = font_Normal_18;
        labelTime.userInteractionEnabled = YES;
        UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(notifyTimeTouchAction:)];
        [labelTime addGestureRecognizer:labelTapGestureRecognizer];
        labelNotifyTime = labelTime;
        [self.view addSubview:labelTime];
        
        yOffset += iconSize + kEdgeInset;
    }
    {
        CGFloat txtViewHeight = HEIGHT_FULL_VIEW - kEdgeInset - yOffset;
        UITextView *detailTextView = [[UITextView alloc] initWithFrame:CGRectMake(kEdgeInset, yOffset, WIDTH_FULL_SCREEN - kEdgeInset * 2, txtViewHeight)];
        detailTextView.backgroundColor = [UIColor clearColor];
        detailTextView.layer.borderWidth = 1;
        detailTextView.layer.borderColor = [color_eeeeee CGColor];
        detailTextView.layer.cornerRadius = 5;
        detailTextView.font = font_Normal_18;
        detailTextView.textColor = color_Black;
        detailTextView.delegate = self;
        detailTextView.inputAccessoryView = [self getInputAccessoryView];
        [self.view addSubview:detailTextView];
        txtViewFrame = txtViewContent.frame;
        txtViewContent = detailTextView;
    }
    if (self.operationType == Edit) {
        txtViewContent.text = self.plan.content;
        beginDate = self.plan.beginDate;
        labelBeginDate.text = [CommonFunction getBeginDateStringForShow:beginDate];
        if ([self.plan.isnotify isEqualToString:@"1"]) {
            [switchBtnAlarm setOn:YES];
            notifyTime = self.plan.notifytime;
            labelNotifyTime.text = [CommonFunction getNotifyTimeStringForShow:notifyTime];
        }
    } else {
        [txtViewContent becomeFirstResponder];
    }
}

- (void)showDatePicker {
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
        UIBarButtonItem* item1 = [[UIBarButtonItem alloc] initWithTitle:str_OK style:UIBarButtonItemStylePlain target:nil action:@selector(onPickerCertainBtn)];
        UIBarButtonItem* item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem* item3 = [[UIBarButtonItem alloc] initWithTitle:str_Cancel style:UIBarButtonItemStylePlain target:nil action:@selector(onPickerCancelBtn)];
        NSArray* toolbarItems = [NSArray arrayWithObjects:item3, item2, item1, nil];
        [toolbar setItems:toolbarItems];
        [pickerView addSubview:toolbar];
    }
    {
        UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, pickerView.frame.size.height - kDatePickerHeight, CGRectGetWidth(pickerView.bounds), kDatePickerHeight)];
        picker.backgroundColor = [UIColor whiteColor];
        picker.locale = [NSLocale currentLocale];
        if (isSelectBeginDate) {
            picker.datePickerMode = UIDatePickerModeDate;
        } else {
            picker.datePickerMode = UIDatePickerModeDateAndTime;
        }
        picker.minimumDate = [NSDate date];
        NSDate *defaultDate = [[NSDate date] dateByAddingTimeInterval:5 * 60];
        picker.date = defaultDate;
        [pickerView addSubview:picker];
        datePicker = picker;
    }
    pickerView.tag = kDatePickerBgViewTag;
    [self.view addSubview:pickerView];
}

#pragma mark - action
- (void)saveAction:(UIButton *)button {
    NSString *content = [txtViewContent.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (content.length == 0) {
        [self alertButtonMessage:STRCommonTip3];
        return;
    }
    [self savePlan];
}

- (void)alarmSwitchAction:(id)sender {
    //收起键盘
    [self.view endEditing:YES];
    
    UISwitch *btnSwitch = (UISwitch*)sender;
    BOOL isButtonOn = [btnSwitch isOn];
    if (isButtonOn) {
        isSelectBeginDate = NO;
        //显示时间设置器
        [self showDatePicker];
    } else {
        notifyTime = @"";
        labelNotifyTime.text = @"";
        [self onPickerCancelBtn];
    }
}

- (void)beginDateTouchAction:(UITapGestureRecognizer *)recognizer {
    isSelectBeginDate = YES;
    [self showDatePicker];
}

- (void)notifyTimeTouchAction:(UITapGestureRecognizer *)recognizer {
    if ([switchBtnAlarm isOn]) {
        isSelectBeginDate = NO;
        [self showDatePicker];
    } else {
        notifyTime = @"";
    }
}

- (void)onPickerCertainBtn {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (isSelectBeginDate) {
        [dateFormatter setDateFormat:str_DateFormatter_yyyy_MM_dd];
        beginDate = [dateFormatter stringFromDate:datePicker.date];
        labelBeginDate.text = [CommonFunction getBeginDateStringForShow:beginDate];
    } else {
        [dateFormatter setDateFormat:str_DateFormatter_yyyy_MM_dd_HHmm];
        notifyTime = [dateFormatter stringFromDate:datePicker.date];
        labelNotifyTime.text = [CommonFunction getNotifyTimeStringForShow:notifyTime];
    }
    [self onPickerCancelBtn];
}

- (void)onPickerCancelBtn {
    UIView *pickerView = [self.view viewWithTag:kDatePickerBgViewTag];
    [pickerView removeFromSuperview];
    
    if (!notifyTime || [notifyTime isEqualToString:@""]) {
        [switchBtnAlarm setOn:NO];
    }
}

- (void)savePlan {
    [self.view endEditing:YES];
    NSString *timeNow = [CommonFunction getTimeNowString];
    NSString *planid = [CommonFunction NSDateToNSString:[NSDate date] formatter:str_DateFormatter_yyyyMMddHHmmss];

    if (self.operationType == Add) {
        self.plan = [[Plan alloc]init];
        self.plan.planid = planid;
        self.plan.createtime = timeNow;
        self.plan.updatetime = timeNow;
        self.plan.iscompleted = @"0";
        self.plan.isdeleted = @"0";
    } else {
        self.plan.updatetime = timeNow;
    }
    if ([switchBtnAlarm isOn]) {
        self.plan.isnotify = @"1";
        self.plan.notifytime = notifyTime;
    } else {
        self.plan.isnotify = @"0";
        self.plan.notifytime = @"";
    }
    self.plan.content = txtViewContent.text;
    self.plan.beginDate = beginDate;
    
    BOOL result = [PlanCache storePlan:self.plan];
    if (result) {
        [self alertToastMessage:str_Save_Success];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self alertButtonMessage:str_Save_Fail];
    }
}

@end
