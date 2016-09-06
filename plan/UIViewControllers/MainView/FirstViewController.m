//
//  FirstViewController.m
//  plan
//
//  Created by Fengzy on 15/8/28.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "PlanCache.h"
#import "DataCenter.h"
#import "ShareCenter.h"
#import "ThreeSubView.h"
#import "UIButton+Util.h"
#import "WZLBadgeImport.h"
#import "FirstViewController.h"
#import "SideMenuViewController.h"
#import <RESideMenu/RESideMenu.h>
#import "SettingsPersonalViewController.h"

NSUInteger const kDaysPerMonth = 30;
NSUInteger const kSecondsPerDay = 86400;
NSUInteger const kMinutesPerDay = 1440;
NSUInteger const kHoursPerDay = 24;

@interface FirstViewController () <UITextFieldDelegate> {
    
    ThreeSubView *nickNameView;
    ThreeSubView *liftetimeView;
    ThreeSubView *daysLeftView;
    ThreeSubView *secondsLeftView;
    ThreeSubView *minuteLeftView;
    ThreeSubView *hourLeftView;
    UIView *statisticsView;
    ThreeSubView *everydayView;
    ThreeSubView *longtermView;
    UIView *shareLogoView;
    
    NSTimer *timer;
    NSInteger daysLeft;
    NSDate *deadDay;
    
    NSUInteger xMiddle;
    NSUInteger yOffset;
    NSUInteger ySpace;
}

@end

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = STRViewTitle1;
    self.tabBarItem.title = STRViewTitle1;
    [self createNavBarButton];
    
    [NotificationCenter addObserver:self selector:@selector(refreshView:) name:NTFSettingsSave object:nil];
    [NotificationCenter addObserver:self selector:@selector(refreshView:) name:NTFPlanSave object:nil];
    [NotificationCenter addObserver:self selector:@selector(refreshRedDot) name:NTFMessagesSave object:nil];
    
    [DataCenter setPlanBeginDate];
    
    [self loadCustomView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkUnread:self.tabBarController.tabBar index:0];
    [self refreshRedDot];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [NotificationCenter removeObserver:self];
}

- (void)createNavBarButton {
    self.leftBarButtonItem = [self createBarButtonItemWithNormalImageName:png_Btn_LeftMenu selectedImageName:png_Btn_LeftMenu selector:@selector(leftMenuAction:)];
    self.rightBarButtonItem = [self createBarButtonItemWithNormalImageName:png_Btn_Share selectedImageName:png_Btn_Share selector:@selector(shareAction)];
}

- (void)leftMenuAction:(UIButton *)button {
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void)shareAction {
    shareLogoView.hidden = NO;
    
    UIImage* image = [UIImage imageNamed:png_ImageDefault];
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO , 0.0f);//高清，效率比较慢
    {

        [self.view.layer renderInContext: UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    shareLogoView.hidden = YES;
    
    [ShareCenter showShareActionSheet:self.view image:image];
}

- (void)refreshView:(NSNotification*)notification {
    [self loadCustomView];
}

- (void)refreshRedDot {
    //小红点
    if ([PlanCache hasUnreadMessages]) {
        [self.leftBarButtonItem showBadgeWithStyle:WBadgeStyleRedDot value:0 animationType:WBadgeAnimTypeNone];
        self.leftBarButtonItem.badgeCenterOffset = CGPointMake(-8, 0);
    } else {
        [self.leftBarButtonItem clearBadge];
    }
}

- (void)loadCustomView {
    //加载个人设置
    [Config shareInstance].settings = [PlanCache getPersonalSettings];
    
    //小红点
    [self refreshRedDot];
    
    [self createAvatar];
    [self createLabelText];
    [self createStatisticsView];
    [self createShareLogo];
}

- (void)createAvatar {
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSUInteger avatarSize = WIDTH_FULL_SCREEN / 3;
    xMiddle = WIDTH_FULL_SCREEN / 2;
    ySpace = HEIGHT_FULL_SCREEN / 25;
    yOffset = iPhone4 ? HEIGHT_FULL_SCREEN / 28 : HEIGHT_FULL_SCREEN / 15 - ySpace;
    
    UIImage *image = [UIImage imageNamed:png_AvatarDefault];
    if ([Config shareInstance].settings.avatar) {
        image = [UIImage imageWithData:[Config shareInstance].settings.avatar];
    }
    UIImageView *avatar = [[UIImageView alloc] initWithFrame:CGRectMake(xMiddle - avatarSize / 2, yOffset, avatarSize, avatarSize)];
    avatar.image = image;
    avatar.clipsToBounds = YES;
    avatar.layer.borderWidth = 1;
    avatar.userInteractionEnabled = YES;
    avatar.layer.cornerRadius = avatarSize / 2;
    avatar.backgroundColor = [UIColor clearColor];
    avatar.layer.borderColor = [color_dedede CGColor];
    avatar.contentMode = UIViewContentModeScaleAspectFit;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toSettingsViewController)];
    [avatar addGestureRecognizer:singleTap];
    
    [self.view addSubview:avatar];
    
    yOffset += avatarSize + ySpace;
}

- (void)createLabelText {
    NSString *nickname = str_NickName;
    NSInteger lifetime = 100;
    CGFloat labelHeight = HEIGHT_FULL_SCREEN / 62;
    CGFloat labelWidth = WIDTH_FULL_SCREEN / 3 > 125 ? WIDTH_FULL_SCREEN / 3 : 125;

    if (![CommonFunction isEmptyString:[Config shareInstance].settings.nickname]) {
        nickname = [Config shareInstance].settings.nickname;
    }
    if (![CommonFunction isEmptyString:[Config shareInstance].settings.lifespan]) {
        NSString *life = [Config shareInstance].settings.lifespan;
        lifetime = [life integerValue];
    }
    
    __weak typeof(self) weakSelf = self;
    ThreeSubView *nickNameSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(xMiddle, yOffset, labelWidth, labelHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:^{
        
        [weakSelf toSettingsViewController];
        
    } rightButtonSelectBlock:nil];
    
    [nickNameSubView.centerButton.titleLabel setFont:font_Bold_32];
    [nickNameSubView.centerButton setAllTitleColor:[CommonFunction getGenderColor]];
    [nickNameSubView.centerButton setAllTitle:nickname];
    [nickNameSubView autoLayout];
    
    [self.view addSubview:nickNameSubView];
    
    nickNameView = nickNameSubView;
    
    CGRect nickFrame = CGRectZero;
    nickFrame.size.width = nickNameView.frame.size.width;
    nickFrame.size.height = nickNameView.frame.size.height;
    nickFrame.origin.x = xMiddle - nickNameView.frame.size.width/2;
    nickFrame.origin.y = yOffset;
    
    nickNameView.frame = nickFrame;
    yOffset += nickNameView.frame.size.height + (iPhone4 ? ySpace : ySpace * 2);
    
    ThreeSubView *liftetimeSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(xMiddle, yOffset, labelWidth, labelHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
    
    [liftetimeSubView.leftButton.titleLabel setFont:font_Normal_16];
    [liftetimeSubView.leftButton setAllTitleColor:color_Black];
    [liftetimeSubView.leftButton setAllTitle:str_FirstView_1];
    [liftetimeSubView.centerButton.titleLabel setFont:font_Normal_24];
    [liftetimeSubView.centerButton setAllTitleColor:color_Red];
    [liftetimeSubView.centerButton setAllTitle:[NSString stringWithFormat:@"%zd",lifetime]];
    [liftetimeSubView.rightButton.titleLabel setFont:font_Normal_16];
    [liftetimeSubView.rightButton setAllTitleColor:color_Black];
    [liftetimeSubView.rightButton setAllTitle:str_FirstView_2];
    [liftetimeSubView autoLayout];
    [self.view addSubview:liftetimeSubView];
    
    liftetimeView = liftetimeSubView;
    
    CGRect lifeFrame = CGRectZero;
    lifeFrame.size.width = liftetimeView.frame.size.width;
    lifeFrame.size.height = liftetimeView.frame.size.height;
    lifeFrame.origin.x = xMiddle - liftetimeView.frame.size.width/2;
    lifeFrame.origin.y = yOffset;
    
    liftetimeView.frame = lifeFrame;
    yOffset += liftetimeView.frame.size.height + ySpace;
    
    NSString *birthdayFormat = @"1987-03-05 00:00:00";
    if (![CommonFunction isEmptyString:[Config shareInstance].settings.birthday]) {
        birthdayFormat = [NSString stringWithFormat:@"%@ 00:00:00", [Config shareInstance].settings.birthday];
    }
    
    NSDate *birthday = [CommonFunction NSStringDateToNSDate:birthdayFormat formatter:str_DateFormatter_yyyy_MM_dd_HHmmss];

    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned units  = NSMonthCalendarUnit|NSDayCalendarUnit|NSYearCalendarUnit;
    NSDateComponents *comp = [calendar components:units fromDate:birthday];
    NSInteger year = [comp year];
    year += lifetime;
    [comp setYear:year];

    deadDay = [calendar dateFromComponents:comp];
    
    NSDate *now = [NSDate date];
    NSTimeInterval secondsBetweenDates= [deadDay timeIntervalSinceDate:now];
    if(secondsBetweenDates < 0) {
        daysLeft = 0;
    } else {
        daysLeft = secondsBetweenDates/kSecondsPerDay;
    }
    if ([[Config shareInstance].settings.dayOrMonth isEqualToString:@"1"]) {
        daysLeft = daysLeft / kDaysPerMonth;
    }
    //剩余天数
    ThreeSubView *daysLeftSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(xMiddle, yOffset, labelWidth, labelHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
    [daysLeftSubView.leftButton.titleLabel setFont:font_Normal_16];
    [daysLeftSubView.leftButton setAllTitleColor:color_Black];
    [daysLeftSubView.leftButton setAllTitle:str_FirstView_3];
    [daysLeftSubView.centerButton.titleLabel setFont:font_Normal_24];
    [daysLeftSubView.centerButton setAllTitleColor:color_Red];
    if (![CommonFunction isEmptyString:[Config shareInstance].settings.birthday]) {
        [daysLeftSubView.centerButton setAllTitle:[CommonFunction integerToDecimalStyle:daysLeft]];
    } else {
        [daysLeftSubView.centerButton setAllTitle:@"X"];
    }
    [daysLeftSubView.rightButton.titleLabel setFont:font_Normal_16];
    [daysLeftSubView.rightButton setAllTitleColor:color_Black];
    if ([[Config shareInstance].settings.dayOrMonth isEqualToString:@"1"]) {
        [daysLeftSubView.rightButton setAllTitle:str_FirstView_15];
    } else {
        [daysLeftSubView.rightButton setAllTitle:str_FirstView_4];
    }
    [daysLeftSubView autoLayout];
    [self.view addSubview:daysLeftSubView];
    
    daysLeftView = daysLeftSubView;
    
    CGRect daysFrame = CGRectZero;
    daysFrame.size.width = daysLeftView.frame.size.width;
    daysFrame.size.height = daysLeftView.frame.size.height;
    daysFrame.origin.x = xMiddle - daysLeftView.frame.size.width/2;
    daysFrame.origin.y = yOffset;
    
    daysLeftView.frame = daysFrame;
    yOffset += daysLeftView.frame.size.height + ySpace;
    //剩余秒
    if ([self showSeconds]) {
        ThreeSubView *secondsLeftSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(xMiddle, yOffset, labelWidth, labelHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
        [secondsLeftSubView.leftButton.titleLabel setFont:font_Normal_16];
        [secondsLeftSubView.leftButton setAllTitleColor:color_Black];
        [secondsLeftSubView.leftButton setAllTitle:str_FirstView_5];
        [secondsLeftSubView.centerButton.titleLabel setFont:font_Normal_24];
        [secondsLeftSubView.centerButton setAllTitleColor:color_Red];
        [secondsLeftSubView.centerButton setAllTitle:[CommonFunction integerToDecimalStyle:kSecondsPerDay]];
        [secondsLeftSubView.rightButton.titleLabel setFont:font_Normal_16];
        [secondsLeftSubView.rightButton setAllTitleColor:color_Black];
        [secondsLeftSubView.rightButton setAllTitle:str_FirstView_6];
        [secondsLeftSubView autoLayout];
        [self.view addSubview:secondsLeftSubView];
        
        secondsLeftView = secondsLeftSubView;
        
        CGRect secondsFrame = CGRectZero;
        secondsFrame.size.width = secondsLeftView.frame.size.width;
        secondsFrame.size.height = secondsLeftView.frame.size.height;
        secondsFrame.origin.x = xMiddle - secondsLeftView.frame.size.width/2;
        secondsFrame.origin.y = yOffset;
        
        secondsLeftView.frame = secondsFrame;
        yOffset += secondsLeftView.frame.size.height + ySpace;
    }
    //剩余分
    if ([self showMinutes]) {
        ThreeSubView *minuteLeftSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(xMiddle, yOffset, labelWidth, labelHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
        [minuteLeftSubView.leftButton.titleLabel setFont:font_Normal_16];
        [minuteLeftSubView.leftButton setAllTitleColor:color_Black];
        [minuteLeftSubView.leftButton setAllTitle:str_FirstView_5];
        [minuteLeftSubView.centerButton.titleLabel setFont:font_Normal_24];
        [minuteLeftSubView.centerButton setAllTitleColor:color_Red];
        [minuteLeftSubView.centerButton setAllTitle:[CommonFunction integerToDecimalStyle:kMinutesPerDay]];
        [minuteLeftSubView.rightButton.titleLabel setFont:font_Normal_16];
        [minuteLeftSubView.rightButton setAllTitleColor:color_Black];
        [minuteLeftSubView.rightButton setAllTitle:str_FirstView_13];
        [minuteLeftSubView autoLayout];
        [self.view addSubview:minuteLeftSubView];
        
        minuteLeftView = minuteLeftSubView;
        
        CGRect minuteFrame = CGRectZero;
        minuteFrame.size.width = minuteLeftView.frame.size.width;
        minuteFrame.size.height = minuteLeftView.frame.size.height;
        minuteFrame.origin.x = xMiddle - minuteLeftView.frame.size.width/2;
        minuteFrame.origin.y = yOffset;
        
        minuteLeftView.frame = minuteFrame;
        yOffset += minuteLeftView.frame.size.height + ySpace;
    }
    //剩余时
    if ([self showHours]) {
        ThreeSubView *hourLeftSubView = [[ThreeSubView alloc] initWithFrame:CGRectMake(xMiddle, yOffset, labelWidth, labelHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
        [hourLeftSubView.leftButton.titleLabel setFont:font_Normal_16];
        [hourLeftSubView.leftButton setAllTitleColor:color_Black];
        [hourLeftSubView.leftButton setAllTitle:str_FirstView_5];
        [hourLeftSubView.centerButton.titleLabel setFont:font_Normal_24];
        [hourLeftSubView.centerButton setAllTitleColor:color_Red];
        [hourLeftSubView.centerButton setAllTitle:[CommonFunction integerToDecimalStyle:kHoursPerDay]];
        [hourLeftSubView.rightButton.titleLabel setFont:font_Normal_16];
        [hourLeftSubView.rightButton setAllTitleColor:color_Black];
        [hourLeftSubView.rightButton setAllTitle:str_FirstView_14];
        [hourLeftSubView autoLayout];
        [self.view addSubview:hourLeftSubView];
        
        hourLeftView = hourLeftSubView;
        
        CGRect hourFrame = CGRectZero;
        hourFrame.size.width = hourLeftView.frame.size.width;
        hourFrame.size.height = hourLeftView.frame.size.height;
        hourFrame.origin.x = xMiddle - hourLeftView.frame.size.width/2;
        hourFrame.origin.y = yOffset;
        
        hourLeftView.frame = hourFrame;
        yOffset += hourLeftView.frame.size.height + ySpace;
    }
    //倒计时
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(secondsCountdown) userInfo:nil repeats:YES];
}

- (void)createStatisticsView {
    BOOL isiPhone4oriPhone5 = iPhone4 || iPhone5;
    
    CGFloat xOffset = isiPhone4oriPhone5 ? WIDTH_FULL_SCREEN / 15 : WIDTH_FULL_SCREEN / 7;
    CGFloat viewWidth = WIDTH_FULL_SCREEN - xOffset * 2;
    CGFloat subviewWidth = viewWidth / 3;
    CGFloat viewHeight = HEIGHT_FULL_SCREEN * 0.1875;
    CGFloat subviewHeight = viewHeight / 3;

    UIView *statisticsBgView = [[UIView alloc] initWithFrame:CGRectMake(xOffset, yOffset, viewWidth, subviewHeight * 4)];
    [self.view addSubview:statisticsBgView];
    [self addSeparatorForLeft:statisticsBgView];
    [self addSeparatorForMiddleLeft:statisticsBgView];
    [self addSeparatorForMiddleRight:statisticsBgView];
    [self addSeparatorForTop:statisticsBgView];
    [self addSeparatorForRight:statisticsBgView];
    statisticsView = statisticsBgView;
    
    ThreeSubView *topTitleView = [[ThreeSubView alloc] initWithFrame:CGRectMake(0, 0, subviewWidth * 3, subviewHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
    [topTitleView.leftButton.titleLabel setFont:font_Normal_16];
    [topTitleView.leftButton setAllTitleColor:color_Black];
    [topTitleView.leftButton setAllTitle:str_FirstView_7];
    topTitleView.fixLeftWidth = subviewWidth;
    [topTitleView.centerButton.titleLabel setFont:font_Normal_16];
    [topTitleView.centerButton setAllTitleColor:color_Black];
    [topTitleView.centerButton setAllTitle:str_FirstView_8];
    topTitleView.fixCenterWidth = subviewWidth;
    [topTitleView.rightButton.titleLabel setFont:font_Normal_16];
    [topTitleView.rightButton setAllTitleColor:color_Black];
    [topTitleView.rightButton setAllTitle:str_FirstView_9];
    topTitleView.fixRightWidth = subviewWidth;
    [self addSeparatorForBottom:topTitleView];
    [topTitleView autoLayout];
    [statisticsView addSubview:topTitleView];

    {
        ThreeSubView *everydayStatisticsView = [[ThreeSubView alloc] initWithFrame:CGRectMake(0, subviewHeight, subviewWidth * 3, subviewHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];

        float total = [[PlanCache getPlanTotalCount:@"ALL"] floatValue];
        [everydayStatisticsView.leftButton.titleLabel setFont:font_Normal_16];
        [everydayStatisticsView.leftButton setAllTitleColor:color_Black];
        [everydayStatisticsView.leftButton setAllTitle:[NSString stringWithFormat:@"%.0f", total]];
        everydayStatisticsView.fixLeftWidth = subviewWidth;
        
        float done = [[PlanCache getPlanCompletedCount] floatValue];
        [everydayStatisticsView.centerButton.titleLabel setFont:font_Normal_16];
        [everydayStatisticsView.centerButton setAllTitleColor:color_Green_Emerald];
        [everydayStatisticsView.centerButton setAllTitle:[NSString stringWithFormat:@"%.0f", done]];
        everydayStatisticsView.fixCenterWidth = subviewWidth;
        
        float percent = 0;
        if (total > 0) {
            percent = (float)done*100 /(float)total;
        }
        [everydayStatisticsView.rightButton.titleLabel setFont:font_Normal_16];
        [everydayStatisticsView.rightButton setAllTitleColor:color_Red];
        [everydayStatisticsView.rightButton setAllTitle:[NSString stringWithFormat:@"%.2f%%", percent]];
        everydayStatisticsView.fixRightWidth = subviewWidth;
        
        [self addSeparatorForBottom:everydayStatisticsView];
        [everydayStatisticsView autoLayout];
        [statisticsView addSubview:everydayStatisticsView];
    }
    
    ThreeSubView *titleView2 = [[ThreeSubView alloc] initWithFrame:CGRectMake(0, subviewHeight * 2, subviewWidth * 3, subviewHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
    [titleView2.leftButton.titleLabel setFont:font_Normal_16];
    [titleView2.leftButton setAllTitleColor:color_Black];
    [titleView2.leftButton setAllTitle:str_FirstView_13];
    titleView2.fixLeftWidth = subviewWidth;
    [titleView2.centerButton.titleLabel setFont:font_Normal_16];
    [titleView2.centerButton setAllTitleColor:color_Black];
    [titleView2.centerButton setAllTitle:str_FirstView_8];
    titleView2.fixCenterWidth = subviewWidth;
    [titleView2.rightButton.titleLabel setFont:font_Normal_16];
    [titleView2.rightButton setAllTitleColor:color_Black];
    [titleView2.rightButton setAllTitle:str_FirstView_9];
    titleView2.fixRightWidth = subviewWidth;
    [self addSeparatorForBottom:titleView2];
    [titleView2 autoLayout];
    [statisticsView addSubview:titleView2];
    
    {
        ThreeSubView *todayStatisticsView = [[ThreeSubView alloc] initWithFrame:CGRectMake(0, subviewHeight * 3, subviewWidth * 3, subviewHeight)leftButtonSelectBlock:nil centerButtonSelectBlock:nil rightButtonSelectBlock:nil];
        
        NSArray *array = [NSArray arrayWithArray:[PlanCache getPlan:YES startIndex:0]];
        NSMutableArray *todayArray = [NSMutableArray array];
        
        NSString *todayKey = [CommonFunction NSDateToNSString:[NSDate date] formatter:str_DateFormatter_yyyy_MM_dd];
        NSString *key = @"";
        for (NSInteger i = 0; i < array.count; i++) {
            Plan *plan = array[i];
            
            if ([[Config shareInstance].settings.autoDelayUndonePlan isEqualToString:@"1"]
                && [plan.iscompleted isEqualToString:@"0"]) {

                key = todayKey;
                plan.beginDate = todayKey;
                
            } else {
                
                key = plan.beginDate;
                
            }
            
            if ([key isEqualToString:todayKey]) {
                [todayArray addObject:plan];
            }
        }
        
        float total = todayArray.count;
        [todayStatisticsView.leftButton.titleLabel setFont:font_Normal_16];
        [todayStatisticsView.leftButton setAllTitleColor:color_Black];
        [todayStatisticsView.leftButton setAllTitle:[NSString stringWithFormat:@"%.0f", total]];
        todayStatisticsView.fixLeftWidth = subviewWidth;
        
        float done = 0;
        for (Plan *plan in todayArray) {
            if ([plan.iscompleted isEqualToString:@"1"]) {
                done ++;
            }
        }
        [todayStatisticsView.centerButton.titleLabel setFont:font_Normal_16];
        [todayStatisticsView.centerButton setAllTitleColor:color_Green_Emerald];
        [todayStatisticsView.centerButton setAllTitle:[NSString stringWithFormat:@"%.0f", done]];
        todayStatisticsView.fixCenterWidth = subviewWidth;
        
        float percent = 0;
        if (total > 0) {
            percent = (float)done*100 /(float)total;
        }
        [todayStatisticsView.rightButton.titleLabel setFont:font_Normal_16];
        [todayStatisticsView.rightButton setAllTitleColor:color_Red];
        [todayStatisticsView.rightButton setAllTitle:[NSString stringWithFormat:@"%.2f%%", percent]];
        todayStatisticsView.fixRightWidth = subviewWidth;
        
        [self addSeparatorForBottom:todayStatisticsView];
        [todayStatisticsView autoLayout];
        [statisticsView addSubview:todayStatisticsView];
    }

    yOffset += viewHeight + 20;
}

- (void)createShareLogo {
    CGFloat viewWidth = 110;
    CGFloat viewHeight = 20;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(WIDTH_FULL_SCREEN - viewWidth - 5, yOffset, viewWidth, viewHeight)];
    UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewHeight, viewHeight)];
    logo.image = [UIImage imageNamed:png_Icon_Logo_512];
    [view addSubview:logo];
    UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(viewHeight + 2, 0, viewWidth - viewHeight - 2, viewHeight)];
    labelName.text = str_Share_Tips1;
    labelName.font = font_Normal_10;
    labelName.textColor = [CommonFunction getGenderColor];
    [view addSubview:labelName];
    view.hidden = YES;
    shareLogoView = view;
    [self.view addSubview:view];
}

- (void)addSeparatorForTop:(UIView *)view {
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(view.bounds) - 1, 1)];
    separator.backgroundColor = color_GrayLight;
    [view addSubview:separator];
}

- (void)addSeparatorForBottom:(UIView *)view {
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(view.bounds) - 1, CGRectGetWidth(view.bounds) - 1, 1)];
    separator.backgroundColor = color_GrayLight;
    [view addSubview:separator];
}

- (void)addSeparatorForLeft:(UIView *)view {
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, CGRectGetHeight(view.bounds))];
    separator.backgroundColor = color_GrayLight;
    [view addSubview:separator];
}

- (void)addSeparatorForMiddleLeft:(UIView *)view {
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(view.bounds) / 3, 0, 1, CGRectGetHeight(view.bounds))];
    separator.backgroundColor = color_GrayLight;
    [view addSubview:separator];
}

- (void)addSeparatorForMiddleRight:(UIView *)view {
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(view.bounds) * 2 / 3 + 1, 0, 1, CGRectGetHeight(view.bounds))];
    separator.backgroundColor = color_GrayLight;
    [view addSubview:separator];
}

- (void)addSeparatorForRight:(UIView *)view {
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(view.bounds) - 1, 0, 1, CGRectGetHeight(view.bounds))];
    separator.backgroundColor = color_GrayLight;
    [view addSubview:separator];
}

- (void)secondsCountdown {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    NSInteger hour = [dateComponent hour];
    NSInteger minute = [dateComponent minute];
    NSInteger second = [dateComponent second];
    
    //刷新秒
    NSInteger secondsLeft = kSecondsPerDay - hour*3600 - minute*60 - second;
    if ([self showSeconds]) {
        [secondsLeftView.centerButton setAllTitle:[CommonFunction integerToDecimalStyle:secondsLeft]];
        [secondsLeftView autoLayout];
        CGRect frame = secondsLeftView.frame;
        frame.origin.x = self.view.frame.size.width / 2 - secondsLeftView.frame.size.width / 2;
        secondsLeftView.frame = frame;
    }
    //刷新分
    if ([self showMinutes]) {
        NSInteger minutesLeft = kMinutesPerDay - hour*60 - minute;
        [minuteLeftView.centerButton setAllTitle:[CommonFunction integerToDecimalStyle:minutesLeft]];
        [minuteLeftView autoLayout];
        CGRect frame = minuteLeftView.frame;
        frame.origin.x = self.view.frame.size.width / 2 - minuteLeftView.frame.size.width / 2;
        minuteLeftView.frame = frame;
    }
    //刷新时
    if ([self showHours]) {
        NSInteger hoursLeft = kHoursPerDay - hour;
        [hourLeftView.centerButton setAllTitle:[CommonFunction integerToDecimalStyle:hoursLeft]];
        [hourLeftView autoLayout];
        CGRect frame = hourLeftView.frame;
        frame.origin.x = self.view.frame.size.width / 2 - hourLeftView.frame.size.width / 2;
        hourLeftView.frame = frame;
    }
    
    if (secondsLeft == kSecondsPerDay) {
        NSTimeInterval secondsBetweenDates= [deadDay timeIntervalSinceDate:now];
        if(secondsBetweenDates < 0) {
            daysLeft = 0;
        } else {
            daysLeft = secondsBetweenDates / kSecondsPerDay;
        }
        if ([[Config shareInstance].settings.dayOrMonth isEqualToString:@"1"]) {
            daysLeft = daysLeft / kDaysPerMonth;
        }
        [daysLeftView.centerButton setAllTitle:[CommonFunction integerToDecimalStyle:daysLeft]];
        [daysLeftView autoLayout];
        CGRect frame = daysLeftView.frame;
        frame.origin.x = self.view.frame.size.width / 2 - daysLeftView.frame.size.width / 2;
        daysLeftView.frame = frame;
    }
}

- (void)toSettingsViewController {
    SettingsPersonalViewController *controller = [[SettingsPersonalViewController alloc]init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)showSeconds {
    if (![Config shareInstance].settings.countdownType
        || [[Config shareInstance].settings.countdownType isEqualToString:@"0"]
        || [[Config shareInstance].settings.countdownType isEqualToString:@"3"]) {
        return YES;
    }
    return NO;
}

- (BOOL)showMinutes {
    if ([[Config shareInstance].settings.countdownType isEqualToString:@"1"]
        || [[Config shareInstance].settings.countdownType isEqualToString:@"3"]) {
        return YES;
    }
    return NO;
}

- (BOOL)showHours {
    if ([[Config shareInstance].settings.countdownType isEqualToString:@"2"]
        || [[Config shareInstance].settings.countdownType isEqualToString:@"3"]) {
        return YES;
    }
    return NO;
}

@end
