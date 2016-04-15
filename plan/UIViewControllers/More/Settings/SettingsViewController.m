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
    ThreeSubView *autoSyncThreeSubView;
    ThreeSubView *isUseGestureLockThreeSubView;//启用手势解锁
    ThreeSubView *isShowGestureTrackThreeSubView;//显示手势轨迹
    ThreeSubView *changeGestureThreeSubView;//修改手势
}

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = str_More_Settings;
    
    [NotificationCenter addObserver:self selector:@selector(loadCustomView) name:Notify_LogIn object:nil];
    [NotificationCenter addObserver:self selector:@selector(loadCustomView) name:Notify_Settings_Save object:nil];
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
    
    UIView *view = [self createSectionThreeView];
    [scrollView addSubview:view];
    
    CGRect frame = view.frame;
    frame.origin.y = yOffset;
    view.frame = frame;
    
    yOffset = CGRectGetMaxY(frame) + kEdgeInset;
    
    scrollView.contentSize = CGSizeMake(WIDTH_FULL_SCREEN, yOffset);
    
    [self hideHUD];
}

- (UIView *)createSectionThreeView {
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
    
    [threeSubView.leftButton setAllTitle:[self addLeftWhiteSpaceForString:str_Settings_AutoSync]];
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
    autoSyncThreeSubView = threeSubView;
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
    
    [threeSubView.leftButton setAllTitle:[self addLeftWhiteSpaceForString:str_Settings_Gesture]];
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
    isUseGestureLockThreeSubView = threeSubView;
    return threeSubView;
}

- (ThreeSubView *)createShowGestureTrackView {
    ThreeSubView *threeSubView = [self getThreeSubViewForCenterBlock: nil rightBlock: ^{
        
        isShowGestureTrackThreeSubView.rightButton.selected = !isShowGestureTrackThreeSubView.rightButton.selected;
        if (isShowGestureTrackThreeSubView.rightButton.selected) {
            [Config shareInstance].settings.isShowGestureTrack = @"1";
        } else {
            [Config shareInstance].settings.isShowGestureTrack = @"0";
        }
        [PlanCache storePersonalSettings:[Config shareInstance].settings];
    }];
    
    threeSubView.fixRightWidth = 55;
    [threeSubView.rightButton setImage:[UIImage imageNamed:png_Icon_GestureTrack_Hide] forState:UIControlStateNormal];
    [threeSubView.rightButton setImage:[UIImage imageNamed:png_Icon_GestureTrack_Show] forState:UIControlStateSelected];
    
    [threeSubView.leftButton setAllTitle:[self addLeftWhiteSpaceForString:str_Settings_ShowGesture]];
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
    isShowGestureTrackThreeSubView = threeSubView;
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

    [threeSubView.leftButton setAllTitle:[self addLeftWhiteSpaceForString:str_Settings_ChangeGesture]];
    threeSubView.fixCenterWidth = [self contentWidth] - threeSubView.fixRightWidth - threeSubView.fixLeftWidth;
    threeSubView.rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;

    [threeSubView autoLayout];
    changeGestureThreeSubView = threeSubView;
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
            
            [weakSelf alertToastMessage:str_Settings_Tips1];
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
    autoSyncThreeSubView.rightButton.selected = !autoSyncThreeSubView.rightButton.selected;
    if (autoSyncThreeSubView.rightButton.selected) {
        [Config shareInstance].settings.isAutoSync = @"1";
    } else {
        [Config shareInstance].settings.isAutoSync = @"0";
    }
    [PlanCache storePersonalSettings:[Config shareInstance].settings];
}

@end
