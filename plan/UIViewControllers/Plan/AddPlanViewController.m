//
//  AddPlanViewController.m
//  plan
//
//  Created by Fengzy on 15/8/30.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "PlanCache.h"
#import "AddPlanViewController.h"

NSUInteger const kDatePickerBgViewTag = 20150907;
NSUInteger const kEdgeInset = 10;
NSUInteger const kDatePickerHeight = 216;
NSUInteger const kToolBarHeight = 44;

@interface AddPlanViewController () <UITextFieldDelegate, UITextViewDelegate> {
    
    NSUInteger yOffset;
    UIDatePicker *datePicker;
    UISwitch *switchBtnAlarm;
    UISwitch *switchBtnTomorrow;
    UISwitch *switchBtnEveryday;
    UILabel *labelNotifyTime;
    UIView *viewEverydayNotify;
    BOOL isTomorrowPlan;
    BOOL isEverydayNotify;
}

@property (strong, nonatomic) UITextField *textNoteTitle;
@property (strong, nonatomic) UITextView *textNoteDetail;

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)createRightBarButton {
    self.rightBarButtonItem = [self createBarButtonItemWithNormalImageName:png_Btn_Save selectedImageName:png_Btn_Save selector:@selector(saveAction:)];
}

- (void)loadCustomView {
    yOffset = kEdgeInset;
    {
        CGFloat txtViewHeight = HEIGHT_FULL_SCREEN / 4;
        UITextView *detailTextView = [[UITextView alloc] initWithFrame:CGRectMake(kEdgeInset, yOffset, WIDTH_FULL_SCREEN - kEdgeInset * 2, txtViewHeight)];
        detailTextView.backgroundColor = [UIColor clearColor];
        detailTextView.layer.borderWidth = 1;
        detailTextView.layer.borderColor = [color_GrayLight CGColor];
        detailTextView.layer.cornerRadius = 5;
        detailTextView.font = font_Normal_18;
        detailTextView.textColor = color_Black;
        detailTextView.delegate = self;
        detailTextView.inputAccessoryView = [self getInputAccessoryView];
        [self.view addSubview:detailTextView];
        self.textNoteDetail = detailTextView;
        
        yOffset += txtViewHeight + kEdgeInset;
    }
    CGFloat iconSize = 30;
    CGFloat switchWidth = 20;
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
        UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelTouchUpInside:)];
        [labelTime addGestureRecognizer:labelTapGestureRecognizer];
        labelNotifyTime = labelTime;
        [self.view addSubview:labelTime];
        
        yOffset += iconSize + kEdgeInset;
    }
    //设为明天计划
    if (self.planType == EverydayPlan
        && self.operationType == Add) {
        
        UIImageView *tomorrow = [[UIImageView alloc] initWithFrame:CGRectMake(kEdgeInset, yOffset, iconSize, iconSize)];
        tomorrow.image = [UIImage imageNamed:png_Icon_Tomorrow];
        [self.view addSubview:tomorrow];
        
        UISwitch *btnSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(kEdgeInset + iconSize + 2, yOffset, switchWidth, iconSize)];
        [btnSwitch setOn:NO];
        [btnSwitch addTarget:self action:@selector(tomorrowSwitchAction:) forControlEvents:UIControlEventValueChanged];
        switchBtnTomorrow = btnSwitch;
        [self.view addSubview:btnSwitch];

        UILabel *labelTomorrow = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btnSwitch.frame) + kEdgeInset - 2, yOffset, 150, iconSize)];
        labelTomorrow.textColor = color_Black;
        labelTomorrow.font = font_Normal_18;
        labelTomorrow.text = str_Plan_Tomorrow;
        [self.view addSubview:labelTomorrow];
        
        yOffset += iconSize + kEdgeInset;
    }
    //每天提醒
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, yOffset, WIDTH_FULL_SCREEN, iconSize)];
        view.backgroundColor = [UIColor whiteColor];
        view.hidden = YES;
        
        UIImageView *everyday = [[UIImageView alloc] initWithFrame:CGRectMake(kEdgeInset, 1, iconSize, iconSize - 2)];
        everyday.image = [UIImage imageNamed:png_Icon_EverydayNotify];
        [view addSubview:everyday];
        
        UISwitch *btnSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(kEdgeInset + iconSize, 0, switchWidth, iconSize)];
        [btnSwitch setOn:NO];
        [btnSwitch addTarget:self action:@selector(everydaySwitchAction:) forControlEvents:UIControlEventValueChanged];
        switchBtnEveryday = btnSwitch;
        [view addSubview:btnSwitch];
        
        UILabel *labelEveryday = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btnSwitch.frame) + kEdgeInset, 0, WIDTH_FULL_SCREEN - kEdgeInset * 3 - iconSize - switchWidth, iconSize)];
        labelEveryday.textColor = color_Black;
        labelEveryday.font = font_Normal_18;
        labelEveryday.text = str_Plan_EverydayNotify;
        [view addSubview:labelEveryday];
        
        [self.view addSubview:view];
        viewEverydayNotify = view;
        
        yOffset += iconSize + kEdgeInset;
    }
    if (self.operationType == Edit) {
        self.textNoteDetail.text = self.plan.content;
        if ([self.plan.isnotify isEqualToString:@"1"]) {
            [switchBtnAlarm setOn:YES];
            labelNotifyTime.text = self.plan.notifytime;
        }
    } else {
        [self.textNoteDetail becomeFirstResponder];
    }
}

- (void)showDatePicker {
    //收起键盘
    [self.textNoteDetail resignFirstResponder];
    
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

#pragma mark - action
- (void)saveAction:(UIButton *)button {
    NSString *title = [self.textNoteTitle.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *detail = [self.textNoteDetail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (title.length == 0 && detail.length == 0) {
        [self alertButtonMessage:str_Common_Tips3];
        return;
    }
    [self savePlan];
}

- (void)alarmSwitchAction:(id)sender {
    UISwitch *btnSwitch = (UISwitch*)sender;
    BOOL isButtonOn = [btnSwitch isOn];
    if (isButtonOn) {
        //显示每天提醒设置开关
        viewEverydayNotify.hidden = NO;
        //显示时间设置器
        [self showDatePicker];
    } else {
        //----联动处理每天提醒开关----------
        isEverydayNotify = NO;
        [switchBtnEveryday setOn:NO];
        viewEverydayNotify.hidden = YES;
        //-------------End--------------
        labelNotifyTime.text = @"";
        [self onPickerCancelBtn];
    }
}

- (void)tomorrowSwitchAction:(id)sender {
    UISwitch *btnSwitch = (UISwitch*)sender;
    BOOL isButtonOn = [btnSwitch isOn];
    if (isButtonOn) {
        isTomorrowPlan = YES;
    } else {
        isTomorrowPlan = NO;
    }
}

- (void)everydaySwitchAction:(id)sender {
    UISwitch *btnSwitch = (UISwitch*)sender;
    BOOL isButtonOn = [btnSwitch isOn];
    if (isButtonOn) {
        isEverydayNotify = YES;
    } else {
        isEverydayNotify = NO;
    }
}

- (void)labelTouchUpInside:(UITapGestureRecognizer *)recognizer {
    if ([switchBtnAlarm isOn]) {
        [self showDatePicker];
    }
}

- (void)onPickerCertainBtn {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:str_DateFormatter_yyyy_MM_dd_HHmm];
    labelNotifyTime.text = [dateFormatter stringFromDate:datePicker.date];
    [self onPickerCancelBtn];
}

- (void)onPickerCancelBtn {
    UIView *pickerView = [self.view viewWithTag:kDatePickerBgViewTag];
    [pickerView removeFromSuperview];
    
    NSString *time = labelNotifyTime.text;
    if (!time || [time isEqualToString:@""]) {
        [switchBtnAlarm setOn:NO];
    }
}

- (void)savePlan {
    [self.view endEditing:YES];
    NSString *timeNow = @"";
    NSString *planid = [CommonFunction NSDateToNSString:[NSDate date] formatter:str_DateFormatter_yyyyMMddHHmmss];
    
    if (self.planType == EverydayPlan
        && isTomorrowPlan) {//明天计划
        timeNow = [CommonFunction getTomorrowTimeNowString];
    } else {//每日计划
        timeNow = [CommonFunction getTimeNowString];
    }
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
        self.plan.notifytime = labelNotifyTime.text;
        self.plan.isEverydayNotify = isEverydayNotify;
    } else {
        self.plan.isnotify = @"0";
        self.plan.notifytime = @"";
    }
    
    self.plan.content = self.textNoteDetail.text;
    self.plan.plantype = self.planType == EverydayPlan ? @"1" : @"0";
    
    BOOL result = [PlanCache storePlan:self.plan];
    if (result) {
        [self alertToastMessage:str_Save_Success];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self alertButtonMessage:str_Save_Fail];
    }
}

@end
