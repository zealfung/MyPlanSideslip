//
//  SettingsViewController.m
//  plan
//
//  Created by Fengzy on 15/9/1.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "LogIn.h"
#import "CLLockVC.h"
#import "PlanCache.h"
#import "DataCenter.h"
#import "ThreeSubView.h"
#import <BmobSDK/BmobUser.h>
#import <ShareSDK/ShareSDK.h>
#import "LogInViewController.h"
#import "SettingsViewController.h"
#import "ChangePasswordViewController.h"
#import "SettingsSetTextViewController.h"

NSString *const kSettingsViewEdgeWhiteSpace = @"  ";

@interface SettingsViewController() <UIActionSheetDelegate> {
    
    UIScrollView *scrollView;
    UIActionSheet *actionSheet;
    NSInteger actionSheetType;//1.设置剩余天/月数 2.设置剩余时分秒 2.设置自动处理未完计划延期
    ThreeSubView *tsvAutoSync;
    ThreeSubView *tsvCountdownType;//倒计时类型
    ThreeSubView *tsvDayOrMonth;//日月类型
    ThreeSubView *tsvAutoDelayUndonePlan;//未完计划是否自动后延设置
    ThreeSubView *tsvIsUseGestureLock;//启用手势解锁
    ThreeSubView *tsvIsShowGestureTrack;//显示手势轨迹
    ThreeSubView *tsvChangeGesture;//修改手势
}

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = STRViewTitle18;
    
    [NotificationCenter addObserver:self selector:@selector(loadCustomView) name:NTFLogIn object:nil];
    [NotificationCenter addObserver:self selector:@selector(loadCustomView) name:NTFSettingsSave object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!scrollView) {
        scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:scrollView];
        
        [self loadCustomView];
    }
}

- (void)loadCustomView {
    [scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self showHUD];
    
    CGFloat yOffset = kEdgeInset;
    
    UIView *view = [self createSectionView];
    [scrollView addSubview:view];
    
    CGRect frame = view.frame;
    frame.origin.y = yOffset;
    view.frame = frame;
    
    yOffset = CGRectGetMaxY(frame) + kEdgeInset;
    
    scrollView.contentSize = CGSizeMake(WIDTH_FULL_SCREEN, yOffset);
    
    [self hideHUD];
}

- (UIView *)createSectionView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(kEdgeInset, 0, [self contentWidth], 0)];
    view.backgroundColor = [UIColor whiteColor];
    
    NSUInteger yOffset = 0;
    if ([LogIn isLogin]) {
        //自动同步
        ThreeSubView *threeSubView = [self createAutoSyncSwitchView];
        [self addSeparatorForView:threeSubView];
        [view addSubview:threeSubView];
        
        CGRect frame = threeSubView.frame;
        frame.origin.y = yOffset;
        threeSubView.frame = frame;
        
        yOffset = CGRectGetMaxY(frame);
    }
    //日月显示样式
    {
        ThreeSubView *threeSubView = [self createDayOrMonthView];
        [self addSeparatorForView:threeSubView];
        [view addSubview:threeSubView];
        
        CGRect frame = threeSubView.frame;
        frame.origin.y = yOffset;
        threeSubView.frame = frame;
        
        yOffset = CGRectGetMaxY(frame);
    }
    //倒计时显示样式
    {
        ThreeSubView *threeSubView = [self createCountdownTypeView];
        [self addSeparatorForView:threeSubView];
        [view addSubview:threeSubView];
        
        CGRect frame = threeSubView.frame;
        frame.origin.y = yOffset;
        threeSubView.frame = frame;
        
        yOffset = CGRectGetMaxY(frame);
    }
    //未完计划自动处理设置
    {
        ThreeSubView *threeSubView = [self createAutoDelayUndonePlanView];
        [self addSeparatorForView:threeSubView];
        [view addSubview:threeSubView];
        
        CGRect frame = threeSubView.frame;
        frame.origin.y = yOffset;
        threeSubView.frame = frame;
        
        yOffset = CGRectGetMaxY(frame);
    }
    //手势解锁
    {
        ThreeSubView *threeSubView = [self createGestureLockSwitchView];
        [self addSeparatorForView:threeSubView];
        [view addSubview:threeSubView];
        
        CGRect frame = threeSubView.frame;
        frame.origin.y = yOffset;
        threeSubView.frame = frame;
        
        yOffset = CGRectGetMaxY(frame);
    }
    BOOL usePwd = [[Config shareInstance].settings.isUseGestureLock isEqualToString:@"1"];
    if (usePwd) {
        {
            ThreeSubView *threeSubView = [self createShowGestureTrackView];
            [self addSeparatorForView:threeSubView];
            [view addSubview:threeSubView];
            
            CGRect frame = threeSubView.frame;
            frame.origin.y = yOffset;
            threeSubView.frame = frame;
            
            yOffset = CGRectGetMaxY(frame);
        }
        {
            ThreeSubView *threeSubView = [self createChangeGestureView];
            [self addSeparatorForView:threeSubView];
            [view addSubview:threeSubView];
            
            CGRect frame = threeSubView.frame;
            frame.origin.y = yOffset;
            threeSubView.frame = frame;
            
            yOffset = CGRectGetMaxY(frame);
        }
    }
    
    CGRect frame = view.frame;
    frame.size.height = yOffset;
    view.frame = frame;
    
    [self configBorderForView:view];
    return view;
}

- (ThreeSubView *)createAutoSyncSwitchView {
    __weak typeof(self) weakSelf = self;
    ThreeSubView *threeSubView = [self getThreeSubViewForCenterBlock: nil rightBlock: ^{
        [weakSelf setAutoSync];
    }];
    
    threeSubView.fixRightWidth = 55;
    [threeSubView.rightButton setImage:[UIImage imageNamed:png_Icon_AutoSync_Normal] forState:UIControlStateNormal];
    [threeSubView.rightButton setImage:[UIImage imageNamed:png_Icon_AutoSync_Selected] forState:UIControlStateSelected];
    
    [threeSubView.leftButton setAllTitle:[self addLeftWhiteSpaceForString:STRSettingsViewTips1]];
    threeSubView.fixLeftWidth = [self contentWidth] - threeSubView.fixRightWidth - threeSubView.fixCenterWidth;
    threeSubView.rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    NSString *isAutoSync = [Config shareInstance].settings.isAutoSync;
    if (isAutoSync) {
        if ([isAutoSync intValue] == 0) {
            
            threeSubView.rightButton.selected = NO;
            
        } else if ([isAutoSync intValue] == 1) {
            
            threeSubView.rightButton.selected = YES;
        }
    } else {
        
        threeSubView.rightButton.selected = NO;
    }
    [threeSubView autoLayout];
    tsvAutoSync = threeSubView;
    return threeSubView;
}

- (ThreeSubView *)createDayOrMonthView {
    __weak typeof(self) weakSelf = self;
    ThreeSubView *threeSubView = [self getThreeSubViewForCenterBlock: ^{
        [weakSelf setDayOrMonth];
    } rightBlock:nil];
    [threeSubView.leftButton setAllTitle:[self addLeftWhiteSpaceForString:STRSettingsViewTips12]];
    threeSubView.fixRightWidth = kEdgeInset;
    threeSubView.fixCenterWidth = [self contentWidth] - threeSubView.fixLeftWidth - threeSubView.fixRightWidth;
    
    NSString *dayOrMonth = [Config shareInstance].settings.dayOrMonth;
    switch ([dayOrMonth integerValue]) {
        case 0:
            [threeSubView.centerButton setAllTitle:STRSettingsViewTips13];
            break;
        case 1:
            [threeSubView.centerButton setAllTitle:STRSettingsViewTips14];
            break;
            break;
        default:
            [threeSubView.centerButton setAllTitle:STRSettingsViewTips13];
            break;
    }
    [threeSubView autoLayout];
    tsvDayOrMonth = threeSubView;
    return threeSubView;
}

- (ThreeSubView *)createCountdownTypeView {
    __weak typeof(self) weakSelf = self;
    ThreeSubView *threeSubView = [self getThreeSubViewForCenterBlock: ^{
        [weakSelf setCountdownType];
    } rightBlock:nil];
    [threeSubView.leftButton setAllTitle:[self addLeftWhiteSpaceForString:STRSettingsViewTips2]];
    threeSubView.fixRightWidth = kEdgeInset;
    threeSubView.fixCenterWidth = [self contentWidth] - threeSubView.fixLeftWidth - threeSubView.fixRightWidth;
    
    NSString *countdownType = [Config shareInstance].settings.countdownType;
    switch ([countdownType integerValue]) {
        case 0:
            [threeSubView.centerButton setAllTitle:STRSettingsViewTips7];
            break;
        case 1:
            [threeSubView.centerButton setAllTitle:STRSettingsViewTips8];
            break;
        case 2:
            [threeSubView.centerButton setAllTitle:STRSettingsViewTips9];
            break;
        case 3:
            [threeSubView.centerButton setAllTitle:STRSettingsViewTips10];
            break;
        default:
            [threeSubView.centerButton setAllTitle:STRSettingsViewTips7];
            break;
    }
    [threeSubView autoLayout];
    tsvCountdownType = threeSubView;
    return threeSubView;
}

- (ThreeSubView *)createAutoDelayUndonePlanView {
    __weak typeof(self) weakSelf = self;
    ThreeSubView *threeSubView = [self getThreeSubViewForCenterBlock: ^{
        [weakSelf setAutoDelayUndonePlan];
    } rightBlock:nil];
    [threeSubView.leftButton setAllTitle:[self addLeftWhiteSpaceForString:STRSettingsViewTips15]];
    threeSubView.fixRightWidth = kEdgeInset;
    threeSubView.fixCenterWidth = [self contentWidth] - threeSubView.fixLeftWidth - threeSubView.fixRightWidth;
    
    NSString *autoDelayUndonePlan = [Config shareInstance].settings.autoDelayUndonePlan;
    switch ([autoDelayUndonePlan integerValue]) {
        case 0:
            [threeSubView.centerButton setAllTitle:STRSettingsViewTips16];
            break;
        case 1:
            [threeSubView.centerButton setAllTitle:STRSettingsViewTips17];
            break;
        default:
            [threeSubView.centerButton setAllTitle:STRSettingsViewTips16];
            break;
    }
    [threeSubView autoLayout];
    tsvAutoDelayUndonePlan = threeSubView;
    return threeSubView;
}

- (ThreeSubView *)createGestureLockSwitchView {
    __weak typeof(self) weakSelf = self;
    ThreeSubView *threeSubView = [self getThreeSubViewForCenterBlock: nil rightBlock: ^{
        [weakSelf toGestureLockViewController];
    }];
    
    threeSubView.fixRightWidth = 55;
    [threeSubView.rightButton setImage:[UIImage imageNamed:png_Icon_Gesture_Unlock] forState:UIControlStateNormal];
    [threeSubView.rightButton setImage:[UIImage imageNamed:png_Icon_Gesture_Lock] forState:UIControlStateSelected];
    
    [threeSubView.leftButton setAllTitle:[self addLeftWhiteSpaceForString:STRSettingsViewTips3]];
    threeSubView.fixLeftWidth = [self contentWidth] - threeSubView.fixRightWidth - threeSubView.fixCenterWidth;
    threeSubView.rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    NSString *isUseGestureLock = [Config shareInstance].settings.isUseGestureLock;
    if (isUseGestureLock) {
        if ([isUseGestureLock intValue] == 0) {
            
            threeSubView.rightButton.selected = NO;
            
        } else if ([isUseGestureLock intValue] == 1) {
            
            threeSubView.rightButton.selected = YES;
        }
    } else {
        
        threeSubView.rightButton.selected = NO;
    }
    [threeSubView autoLayout];
    tsvIsUseGestureLock = threeSubView;
    return threeSubView;
}

- (ThreeSubView *)createShowGestureTrackView {
    ThreeSubView *threeSubView = [self getThreeSubViewForCenterBlock: nil rightBlock: ^{
        
        tsvIsShowGestureTrack.rightButton.selected = !tsvIsShowGestureTrack.rightButton.selected;
        if (tsvIsShowGestureTrack.rightButton.selected) {
            [Config shareInstance].settings.isShowGestureTrack = @"1";
        } else {
            [Config shareInstance].settings.isShowGestureTrack = @"0";
        }
        [PlanCache storePersonalSettings:[Config shareInstance].settings];
    }];
    
    threeSubView.fixRightWidth = 55;
    [threeSubView.rightButton setImage:[UIImage imageNamed:png_Icon_GestureTrack_Hide] forState:UIControlStateNormal];
    [threeSubView.rightButton setImage:[UIImage imageNamed:png_Icon_GestureTrack_Show] forState:UIControlStateSelected];
    
    [threeSubView.leftButton setAllTitle:[self addLeftWhiteSpaceForString:STRSettingsViewTips4]];
    threeSubView.fixLeftWidth = [self contentWidth] - threeSubView.fixRightWidth - threeSubView.fixCenterWidth;
    threeSubView.rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    NSString *isShowGestureTrack = [Config shareInstance].settings.isShowGestureTrack;
    if (isShowGestureTrack) {
        if ([isShowGestureTrack intValue] == 0) {
            
            threeSubView.rightButton.selected = NO;
            
        } else if ([isShowGestureTrack intValue] == 1) {
            
            threeSubView.rightButton.selected = YES;
        }
    } else {
        
        threeSubView.rightButton.selected = NO;
    }
    [threeSubView autoLayout];
    tsvIsShowGestureTrack = threeSubView;
    return threeSubView;
}

- (ThreeSubView *)createChangeGestureView {
    __weak typeof(self) weakSelf = self;
    ThreeSubView *threeSubView = [self getThreeSubViewForCenterBlock: ^{
        [weakSelf toChangeGestureViewController];
    } rightBlock: ^{
        [weakSelf toChangeGestureViewController];
    }];
    
    threeSubView.fixRightWidth = 55;
    [threeSubView.rightButton setImage:[UIImage imageNamed:png_Icon_Arrow_Right] forState:UIControlStateNormal];

    [threeSubView.leftButton setAllTitle:[self addLeftWhiteSpaceForString:STRSettingsViewTips5]];
    threeSubView.fixCenterWidth = [self contentWidth] - threeSubView.fixRightWidth - threeSubView.fixLeftWidth;
    threeSubView.rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;

    [threeSubView autoLayout];
    tsvChangeGesture = threeSubView;
    return threeSubView;
}

- (ThreeSubView *)getThreeSubViewForCenterBlock:(ButtonSelectBlock)centerBlock rightBlock:(ButtonSelectBlock)rightBlock {
    CGRect frame = CGRectZero;
    frame.size = [self cellSize];
    
    ThreeSubView *threeSubView = [[ThreeSubView alloc] initWithFrame:frame leftButtonSelectBlock:nil centerButtonSelectBlock:centerBlock rightButtonSelectBlock:rightBlock];
    
    threeSubView.backgroundColor = [UIColor clearColor];
    
    threeSubView.fixLeftWidth = 100;
    threeSubView.leftButton.titleLabel.font = font_Normal_14;
    threeSubView.centerButton.titleLabel.font = font_Normal_16;
    threeSubView.rightButton.titleLabel.font = font_Normal_16;
    
    [threeSubView.leftButton setAllTitleColor:color_GrayDark];
    [threeSubView.centerButton setAllTitleColor:color_GrayDark];
    [threeSubView.rightButton setAllTitleColor:color_GrayDark];
    
    [threeSubView.leftButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [threeSubView.centerButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [threeSubView.rightButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    return threeSubView;
}

- (void)configBorderForView:(UIView *)view {
    view.layer.borderWidth = 1;
    view.layer.borderColor = [color_GrayLight CGColor];
    view.layer.cornerRadius = 2;
}

- (void)addSeparatorForView:(UIView *)view {
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(view.bounds) - 1, CGRectGetWidth(view.bounds) - 1, 1)];
    separator.backgroundColor = color_GrayLight;
    [view addSubview:separator];
}

- (NSUInteger)contentWidth {
    static NSUInteger contentWidth = 0;
    if (contentWidth == 0) {
        contentWidth = CGRectGetWidth(scrollView.bounds) - kEdgeInset * 2;
    }
    return contentWidth;
}

- (CGSize)cellSize {
    static CGSize cellSize = {0, 0};
    if (CGSizeEqualToSize(cellSize, CGSizeZero)) {
        cellSize = CGSizeMake([self contentWidth], kTableViewCellHeight);
    }
    return cellSize;
}

- (NSString *)addLeftWhiteSpaceForString:(NSString *)string {
    
    return [NSString stringWithFormat:@"%@%@", kSettingsViewEdgeWhiteSpace, string];
}

- (void)setCountdownType {
    actionSheetType = 2;
    actionSheet = [[UIActionSheet alloc] initWithTitle:STRSettingsViewTips6 delegate:self cancelButtonTitle:str_Cancel destructiveButtonTitle:nil otherButtonTitles:STRSettingsViewTips7, STRSettingsViewTips8, STRSettingsViewTips9, STRSettingsViewTips10, nil];
    [actionSheet showInView:self.view];
}

- (void)setDayOrMonth {
    actionSheetType = 1;
    actionSheet = [[UIActionSheet alloc] initWithTitle:STRSettingsViewTips6 delegate:self cancelButtonTitle:str_Cancel destructiveButtonTitle:nil otherButtonTitles:STRSettingsViewTips13, STRSettingsViewTips14, nil];
    [actionSheet showInView:self.view];
}

- (void)setAutoDelayUndonePlan {
    actionSheetType = 3;
    actionSheet = [[UIActionSheet alloc] initWithTitle:STRSettingsViewTips15 delegate:self cancelButtonTitle:str_Cancel destructiveButtonTitle:nil otherButtonTitles:STRSettingsViewTips16, STRSettingsViewTips17, nil];
    [actionSheet showInView:self.view];
}

#pragma mark actionSheet点击事件
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIAlertView *alertView;
    if (actionSheetType == 1) {
        switch (buttonIndex) {
            case 0://显示剩余天数
            {
                [Config shareInstance].settings.dayOrMonth = @"0";
            }
                break;
            case 1://显示剩余月数
            {
                [Config shareInstance].settings.dayOrMonth = @"1";
            }
                break;
            default:
                break;
        }
    } else if (actionSheetType == 2) {
        switch (buttonIndex) {
            case 0://只显示秒倒计
            {
                [Config shareInstance].settings.countdownType = @"0";
            }
                break;
            case 1://只显示分倒计
            {
                [Config shareInstance].settings.countdownType = @"1";
            }
                break;
            case 2://只显示时倒计
            {
                [Config shareInstance].settings.countdownType = @"2";
            }
                break;
            case 3://全部都显示
            {
                [Config shareInstance].settings.countdownType = @"3";
            }
                break;
            default:
                break;
        }
    } else if(actionSheetType == 3) {
        switch (buttonIndex) {
            case 0://未完计划不延期
                [Config shareInstance].settings.autoDelayUndonePlan = @"0";
                break;
            case 1://未完计划自动延期
                [Config shareInstance].settings.autoDelayUndonePlan = @"1";
                break;
            default:
                break;
        }
    }
    [PlanCache storePersonalSettings:[Config shareInstance].settings];
    [self performSelector:@selector(dismissAlertView:) withObject:alertView afterDelay:2.0];
}

#pragma mark 让alertView消失
- (void)dismissAlertView:(UIAlertView *)alertView {
    if (alertView) {
        [alertView dismissWithClickedButtonIndex:[alertView cancelButtonIndex] animated:YES];
        alertView.hidden = YES;
    }
}

- (void)toGestureLockViewController {
    __weak typeof(self) weakSelf = self;
    BOOL hasPwd = [[Config shareInstance].settings.isUseGestureLock isEqualToString:@"1"];
    if (hasPwd) {
        //关闭手势解锁
        [CLLockVC showVerifyLockVCInVC:self isLogIn:NO forgetPwdBlock:^{
            
            LogInViewController *controller = [[LogInViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
            
        } successBlock:^(CLLockVC *lockVC, NSString *pwd) {
            
            [Config shareInstance].settings.isUseGestureLock = @"0";
            [Config shareInstance].settings.gesturePasswod = @"";
            [PlanCache storePersonalSettings:[Config shareInstance].settings];
            [lockVC dismiss:.5f];
        }];
        
    } else {
        
        //打开手势解锁
        [CLLockVC showSettingLockVCInVC:self successBlock:^(CLLockVC *lockVC, NSString *pwd) {
            
            [weakSelf alertToastMessage:STRSettingsViewTips11];
            [lockVC dismiss:.5f];
        }];
    }
}

- (void)toChangeGestureViewController {
    __weak typeof(self) weakSelf = self;
    BOOL hasPwd = [[Config shareInstance].settings.isUseGestureLock isEqualToString:@"1"];
    if (hasPwd) {
        [CLLockVC showModifyLockVCInVC:self successBlock:^(CLLockVC *lockVC, NSString *pwd) {
            
            [weakSelf alertToastMessage:str_Modify_Success];
            [lockVC dismiss:.5f];
        }];
    }
}

- (void)setAutoSync {
    tsvAutoSync.rightButton.selected = !tsvAutoSync.rightButton.selected;
    if (tsvAutoSync.rightButton.selected) {
        [Config shareInstance].settings.isAutoSync = @"1";
    } else {
        [Config shareInstance].settings.isAutoSync = @"0";
    }
    [PlanCache storePersonalSettings:[Config shareInstance].settings];
}

@end
