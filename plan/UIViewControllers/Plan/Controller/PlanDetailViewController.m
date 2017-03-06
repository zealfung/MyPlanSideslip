//
//  PlanDetailViewController.m
//  plan
//
//  Created by Fengzy on 17/1/15.
//  Copyright © 2017年 Fengzy. All rights reserved.
//

#import "PlanEditViewController.h"
#import "PlanDetailViewController.h"

@interface PlanDetailViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) UITextView *txtViewDetail;
@property (assign, nonatomic) NSUInteger yOffset;
@property (strong, nonatomic) NSString *beginDate;//开始日期
@property (strong, nonatomic) NSString *notifyTime;//提醒时间
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UISwitch *switchBtnAlarm;
@property (strong, nonatomic) UISwitch *switchBtnRepeat;
@property (strong, nonatomic) UILabel *labelNotifyTime;
@property (strong, nonatomic) UILabel *labelRepeatTips;
@property (strong, nonatomic) UILabel *labelBeginDate;
@property (assign, nonatomic) BOOL isSelectBeginDate;
@property (assign, nonatomic) CGRect txtViewFrame;

@end

@implementation PlanDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = STRViewTitle26;
    self.view.backgroundColor = color_F2F3F5;
    
    __weak typeof(self) weakSelf = self;
    [self customRightButtonWithImage:[UIImage imageNamed:png_Btn_Save] action:^(UIButton *sender)
     {
         [weakSelf savePlan];
     }];
    
    [NotificationCenter addObserver:self selector:@selector(loadCustomView) name:NTFPlanSave object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadCustomView];
    //注册通知,监听键盘出现
    [NotificationCenter addObserver:self selector:@selector(handleKeyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    //注册通知，监听键盘消失事件
    [NotificationCenter addObserver:self selector:@selector(handleKeyboardDidHidden:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)loadCustomView
{
    [[self.view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.yOffset = kEdgeInset;
    CGFloat iconSize = 30;
    CGFloat switchWidth = 20;
    {
        CGFloat tipsWidth = 95;
        self.beginDate = [CommonFunction NSDateToNSString:[NSDate date] formatter:STRDateFormatterType4];
        UILabel *labelBeginTimeTips = [[UILabel alloc] initWithFrame:CGRectMake(kEdgeInset, self.yOffset, tipsWidth, iconSize)];
        labelBeginTimeTips.textColor = color_Black;
        labelBeginTimeTips.font = font_Normal_18;
        labelBeginTimeTips.text = STRViewTips21;
        [self.view addSubview:labelBeginTimeTips];
        
        UILabel *labelBeginTime = [[UILabel alloc] initWithFrame:CGRectMake(kEdgeInset + tipsWidth, self.yOffset, WIDTH_FULL_SCREEN - kEdgeInset * 2 - tipsWidth, iconSize)];
        labelBeginTime.textColor = color_Black;
        labelBeginTime.font = font_Normal_18;
        labelBeginTime.layer.borderWidth = 1;
        labelBeginTime.layer.cornerRadius = 5;
        labelBeginTime.layer.borderColor = [color_eeeeee CGColor];
        labelBeginTime.userInteractionEnabled = YES;
        labelBeginTime.text = [CommonFunction getBeginDateStringForShow:self.beginDate];
        UITapGestureRecognizer *labelBeginTimeTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(beginDateTouchAction:)];
        [labelBeginTime addGestureRecognizer:labelBeginTimeTapGestureRecognizer];
        [self.view addSubview:labelBeginTime];
        self.labelBeginDate = labelBeginTime;
        self.yOffset += iconSize + kEdgeInset;
    }
    {//提醒
        UIImageView *alarm = [[UIImageView alloc] initWithFrame:CGRectMake(kEdgeInset, self.yOffset, iconSize, iconSize)];
        alarm.image = [UIImage imageNamed:png_Icon_Alarm];
        [self.view addSubview:alarm];
        
        UISwitch *btnSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(kEdgeInset + iconSize, self.yOffset, switchWidth, iconSize)];
        [btnSwitch setOn:NO];
        [btnSwitch addTarget:self action:@selector(alarmSwitchAction:) forControlEvents:UIControlEventValueChanged];
        self.switchBtnAlarm = btnSwitch;
        [self.view addSubview:btnSwitch];
        
        UILabel *labelTime = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btnSwitch.frame) + kEdgeInset, self.yOffset, WIDTH_FULL_SCREEN - kEdgeInset * 3 - iconSize - switchWidth, iconSize)];
        labelTime.textColor = color_Black;
        labelTime.font = font_Normal_18;
        labelTime.userInteractionEnabled = YES;
        UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(notifyTimeTouchAction:)];
        [labelTime addGestureRecognizer:labelTapGestureRecognizer];
        self.labelNotifyTime = labelTime;
        [self.view addSubview:labelTime];
        
        self.yOffset += iconSize + kEdgeInset;
    }
    {//重复
        UIImageView *imgViewRepeat = [[UIImageView alloc] initWithFrame:CGRectMake(kEdgeInset, self.yOffset + 2, iconSize, iconSize - 4)];
        imgViewRepeat.image = [UIImage imageNamed:png_Icon_EverydayNotify];
        [self.view addSubview:imgViewRepeat];
        
        UISwitch *btnSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(kEdgeInset + iconSize, self.yOffset, switchWidth, iconSize)];
        [btnSwitch setOn:NO];
        [btnSwitch addTarget:self action:@selector(repeatSwitchAction:) forControlEvents:UIControlEventValueChanged];
        self.switchBtnRepeat = btnSwitch;
        [self.view addSubview:btnSwitch];
        
        UILabel *labelTips = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btnSwitch.frame) + kEdgeInset, self.yOffset, WIDTH_FULL_SCREEN - kEdgeInset * 3 - iconSize - switchWidth, iconSize)];
        labelTips.textColor = color_Black;
        labelTips.font = font_Normal_18;
        self.labelRepeatTips = labelTips;
        [self.view addSubview:labelTips];
        
        self.yOffset += iconSize + kEdgeInset;
    }
    
    if (self.plan.remark.length)
    {
        CGFloat txtViewHeight = (HEIGHT_FULL_VIEW - kEdgeInset * 4 - self.yOffset - iconSize) / 2;
        self.txtViewDetail = [[UITextView alloc] initWithFrame:CGRectMake(kEdgeInset, self.yOffset, WIDTH_FULL_SCREEN - kEdgeInset * 2, txtViewHeight)];
        self.txtViewDetail.backgroundColor = [UIColor whiteColor];
        self.txtViewDetail.layer.cornerRadius = 5;
        self.txtViewDetail.font = font_Normal_18;
        self.txtViewDetail.textColor = color_Black;
        self.txtViewDetail.text = self.plan.content;
        self.txtViewDetail.delegate = self;
        self.txtViewDetail.inputAccessoryView = [self getInputAccessoryView];
        [self.view addSubview:self.txtViewDetail];
        
        self.yOffset += txtViewHeight + kEdgeInset;
        
        UILabel *labelTips = [[UILabel alloc] initWithFrame:CGRectMake(kEdgeInset, self.yOffset, WIDTH_FULL_SCREEN - kEdgeInset * 2, iconSize)];
        labelTips.textColor = color_999999;
        labelTips.font = font_Normal_18;
        labelTips.text = STRCommonTip51;
        [self.view addSubview:labelTips];
        
        self.yOffset += iconSize + kEdgeInset;
        
        UITextView *txtViewRemark = [[UITextView alloc] initWithFrame:CGRectMake(kEdgeInset, self.yOffset, WIDTH_FULL_SCREEN - kEdgeInset * 2, txtViewHeight)];
        txtViewRemark.backgroundColor = [UIColor whiteColor];
        txtViewRemark.layer.cornerRadius = 5;
        txtViewRemark.font = font_Normal_18;
        txtViewRemark.textColor = color_0BA32A;
        txtViewRemark.text = self.plan.remark;
        txtViewRemark.editable = NO;
        [self.view addSubview:txtViewRemark];
    }
    else
    {
        CGFloat txtViewHeight = HEIGHT_FULL_VIEW - kEdgeInset - self.yOffset;
        self.txtViewDetail = [[UITextView alloc] initWithFrame:CGRectMake(kEdgeInset, self.yOffset, WIDTH_FULL_SCREEN - kEdgeInset * 2, txtViewHeight)];
        self.txtViewDetail.backgroundColor = [UIColor whiteColor];
        self.txtViewDetail.layer.cornerRadius = 5;
        self.txtViewDetail.font = font_Normal_18;
        self.txtViewDetail.textColor = color_Black;
        self.txtViewDetail.text = self.plan.content;
        self.txtViewDetail.delegate = self;
        self.txtViewDetail.inputAccessoryView = [self getInputAccessoryView];
        [self.view addSubview:self.txtViewDetail];
    }
    
    self.beginDate = self.plan.beginDate;
    self.labelBeginDate.text = [CommonFunction getBeginDateStringForShow:self.beginDate];
    if ([self.plan.isnotify isEqualToString:@"1"])
    {
        [self.switchBtnAlarm setOn:YES];
        self.notifyTime = self.plan.notifytime;
        self.labelNotifyTime.text = [CommonFunction getNotifyTimeStringForShow:self.notifyTime];
    }
    if ([self.plan.isRepeat isEqualToString:@"1"])
    {
        [self.switchBtnRepeat setOn:YES];
        self.labelRepeatTips.text = STRCommonTip50;
    }
}

//监听事件
- (void)handleKeyboardDidShow:(NSNotification*)showNotification
{
    //获取键盘高度
    NSValue *keyboardRectAsObject=[[showNotification userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect;
    [keyboardRectAsObject getValue:&keyboardRect];
    
    self.txtViewDetail.contentInset = UIEdgeInsetsMake(0, 0,keyboardRect.size.height, 0);
}

- (void)handleKeyboardDidHidden:(NSNotification*)hiddenNotification
{
    self.txtViewDetail.contentInset = UIEdgeInsetsZero;
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

#pragma mark - action
- (void)saveAction:(UIButton *)button
{
    NSString *content = [self.txtViewDetail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (content.length == 0)
    {
        [self alertButtonMessage:STRCommonTip3];
        return;
    }
    [self savePlan];
}

- (void)alarmSwitchAction:(id)sender
{
    //收起键盘
    [self.view endEditing:YES];
    
    UISwitch *btnSwitch = (UISwitch*)sender;
    BOOL isButtonOn = [btnSwitch isOn];
    if (isButtonOn)
    {
        self.isSelectBeginDate = NO;
        //显示时间设置器
        [self showDatePicker];
    }
    else
    {
        self.notifyTime = @"";
        self.labelNotifyTime.text = @"";
        [self onPickerCancelBtn];
    }
}

- (void)repeatSwitchAction:(id)sender
{
    //收起键盘
    [self.view endEditing:YES];
    
    UISwitch *btnSwitch = (UISwitch*)sender;
    BOOL isButtonOn = [btnSwitch isOn];
    if (isButtonOn)
    {
        self.labelRepeatTips.text = STRCommonTip50;
    }
    else
    {
        self.labelRepeatTips.text = @"";
    }
}

- (void)beginDateTouchAction:(UITapGestureRecognizer *)recognizer
{
    self.isSelectBeginDate = YES;
    [self showDatePicker];
}

- (void)notifyTimeTouchAction:(UITapGestureRecognizer *)recognizer
{
    if ([self.switchBtnAlarm isOn])
    {
        self.isSelectBeginDate = NO;
        [self showDatePicker];
    }
    else
    {
        self.notifyTime = @"";
    }
}

- (void)onPickerCertainBtn
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (self.isSelectBeginDate)
    {
        [dateFormatter setDateFormat:STRDateFormatterType4];
        self.beginDate = [dateFormatter stringFromDate:self.datePicker.date];
        self.labelBeginDate.text = [CommonFunction getBeginDateStringForShow:self.beginDate];
    }
    else
    {
        [dateFormatter setDateFormat:STRDateFormatterType3];
        self.notifyTime = [dateFormatter stringFromDate:self.datePicker.date];
        self.labelNotifyTime.text = [CommonFunction getNotifyTimeStringForShow:self.notifyTime];
    }
    [self onPickerCancelBtn];
}

- (void)onPickerCancelBtn
{
    UIView *pickerView = [self.view viewWithTag:kDatePickerBgViewTag];
    [pickerView removeFromSuperview];
    
    if (!self.notifyTime || [self.notifyTime isEqualToString:@""])
    {
        [self.switchBtnAlarm setOn:NO];
    }
}

- (void)savePlan
{
    [self.view endEditing:YES];
    NSString *timeNow = [CommonFunction getTimeNowString];
    
    self.plan.updatetime = timeNow;
    
    if ([self.switchBtnAlarm isOn])
    {
        self.plan.isnotify = @"1";
        self.plan.notifytime = self.notifyTime;
    }
    else
    {
        self.plan.isnotify = @"0";
        self.plan.notifytime = @"";
    }
    if ([self.switchBtnRepeat isOn])
    {
        self.plan.isRepeat = @"1";
    }
    else
    {
        self.plan.isRepeat = @"0";
    }
    self.plan.content = self.txtViewDetail.text;
    self.plan.beginDate = self.beginDate;
    
    BOOL result = [PlanCache storePlan:self.plan];
    
    if (result)
    {
        [self alertToastMessage:STRCommonTip13];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self alertButtonMessage:STRCommonTip14];
    }
}

@end
